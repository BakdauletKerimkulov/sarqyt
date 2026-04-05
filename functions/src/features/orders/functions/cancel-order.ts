import { FieldValue } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../../../shared/helpers/stripe-client";

interface CancelOrderRequest {
  orderId: string;
}

/**
 * Idempotent: if order is already cancelled, returns success.
 * Cancels order, restores offer quantity in transaction, then refunds Stripe.
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

      // Transaction: read + validate + update status + restore quantity
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
            `Cannot cancel order with status: ${status}`
          );
        }

        // Auth check
        const isCustomer = order.customerId === uid;
        if (!isCustomer) {
          const storeId = order.storeId as string;
          const storeSnap = await tx.get(
            db.collection(FirestoreCollections.STORES).doc(storeId)
          );
          if (storeSnap.data()?.ownerId !== uid) {
            throw new AppError("permission-denied", "No access to this order");
          }
        }

        const paymentIntentId = order.paymentIntentId as string | undefined;

        // Cancel order
        tx.update(orderRef, {
          status: "cancelled",
          paymentStatus: paymentIntentId ? "refunded" : "paid",
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

      // Stripe refund outside transaction (external API call)
      if (!result.alreadyCancelled && result.paymentIntentId) {
        const stripe = getStripe();
        await stripe.refunds.create({
          payment_intent: result.paymentIntentId,
        });
      }

      logInfo("cancelOrder done", { orderId, uid });
      return { success: true };
    } catch (error) {
      logError("cancelOrder failed", { error, data: req.data });
      throw toHttpsError(error);
    }
  }
);
