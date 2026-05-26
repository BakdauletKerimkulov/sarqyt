import { FieldValue } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";
import { getStripe, stripeSecretKey } from "../../../shared/helpers/stripe-client";

interface CancelOrderRequest {
  orderId: string;
}

const MAX_REFUND_RETRIES = 3;

/**
 * Idempotent: if order is already cancelled, returns success.
 * Cancels order, restores offer quantity in transaction, then refunds Stripe
 * with retry logic. If refund fails after retries, order is marked as
 * "refund_failed" paymentStatus so it can be resolved manually.
 */
export const cancelOrder = onCall(
  { secrets: [stripeSecretKey] },
  async (req) => {
    try {
      if (req.auth == null) {
        throw new AppError("unauthenticated", "Login required");
      }
      const uid = req.auth.uid;
      const { orderId } = req.data as CancelOrderRequest;

      if (!orderId || typeof orderId !== "string") {
        throw new AppError("invalid-argument", "orderId is required");
      }

      const orderRef = db.collection(FirestoreCollections.ORDERS).doc(orderId);

      // Pre-read order for auth check
      const preSnap = await orderRef.get();
      if (!preSnap.exists) {
        throw new AppError("not-found", "Order not found");
      }
      const preOrder = preSnap.data()!;

      // Auth: customer OR store owner/staff
      const isCustomer = preOrder.customerId === uid;
      if (!isCustomer) {
        await assertStoreAccess(uid, preOrder.storeId as string);
      }

      // Transaction: re-read + validate + update status + restore quantity
      const result = await db.runTransaction(async (tx) => {
        const orderSnap = await tx.get(orderRef);
        if (!orderSnap.exists) {
          throw new AppError("not-found", "Order not found");
        }

        const order = orderSnap.data()!;
        const status = order.status as string;

        // Idempotent: already cancelled
        if (status === "cancelled") {
          return { alreadyCancelled: true, paymentIntentId: null };
        }

        if (!["confirmed", "preparing"].includes(status)) {
          throw new AppError(
            "failed-precondition",
            `Cannot cancel order with status: ${status}. Only confirmed or preparing orders can be cancelled.`
          );
        }

        const paymentIntentId = order.paymentIntentId as string | undefined;

        // Cancel order — set paymentStatus to "refund_pending" if there's
        // a payment to refund. This will be updated to "refunded" after
        // successful Stripe refund, or "refund_failed" if retries exhaust.
        tx.update(orderRef, {
          status: "cancelled",
          paymentStatus: paymentIntentId ? "refund_pending" : "paid",
          updatedAt: serverTimestamp(),
        });

        // Restore offer quantity
        const offerId = order.offerId as string | undefined;
        const qty = order.itemQuantity as number | undefined;
        if (offerId && qty) {
          tx.update(
            db.collection(FirestoreCollections.OFFERS).doc(offerId),
            { quantity: FieldValue.increment(qty) }
          );
        }

        return { alreadyCancelled: false, paymentIntentId };
      });

      // Stripe refund with retry logic (outside transaction — external API)
      if (!result.alreadyCancelled && result.paymentIntentId) {
        let refunded = false;

        for (let attempt = 1; attempt <= MAX_REFUND_RETRIES; attempt++) {
          try {
            const stripe = getStripe();
            await stripe.refunds.create({
              payment_intent: result.paymentIntentId,
            });
            refunded = true;
            break;
          } catch (stripeError) {
            logError("Stripe refund attempt failed", {
              orderId,
              attempt,
              error: stripeError,
            });
            if (attempt < MAX_REFUND_RETRIES) {
              // Exponential backoff: 1s, 2s, 4s
              await new Promise((r) => setTimeout(r, 1000 * Math.pow(2, attempt - 1)));
            }
          }
        }

        // Update paymentStatus based on refund outcome
        await orderRef.update({
          paymentStatus: refunded ? "refunded" : "refund_failed",
          updatedAt: serverTimestamp(),
        });

        if (!refunded) {
          logError("Stripe refund exhausted retries", {
            orderId,
            paymentIntentId: result.paymentIntentId,
          });
        }
      }

      logInfo("cancelOrder done", { orderId, uid });
      return { success: true };
    } catch (error) {
      logError("cancelOrder failed", { error, data: req.data });
      throw toHttpsError(error);
    }
  }
);
