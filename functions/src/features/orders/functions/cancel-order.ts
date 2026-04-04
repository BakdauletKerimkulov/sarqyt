import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../../reservations/helpers/stripe-client";

interface CancelOrderRequest {
  orderId: string;
}

/**
 * Cancels an order and refunds the payment via Stripe.
 * Can be called by the customer (own order) or store owner.
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
      const orderSnap = await orderRef.get();

      if (!orderSnap.exists) {
        throw new AppError("not-found", "Order not found");
      }

      const order = orderSnap.data()!;
      const status = order.status as string;

      // Only allow cancellation of active orders
      if (!["confirmed", "preparing"].includes(status)) {
        throw new AppError(
          "failed-precondition",
          `Cannot cancel order with status: ${status}`
        );
      }

      // Auth: customer or store owner
      const isCustomer = order.customerId === uid;
      const storeId = order.storeId as string;
      let isOwner = false;

      if (!isCustomer) {
        const storeSnap = await db
          .collection(FirestoreCollections.STORES)
          .doc(storeId)
          .get();
        isOwner = storeSnap.data()?.ownerId === uid;
      }

      if (!isCustomer && !isOwner) {
        throw new AppError("permission-denied", "No access to this order");
      }

      // Refund via Stripe if paymentIntentId exists
      const paymentIntentId = order.paymentIntentId as string | undefined;
      if (paymentIntentId) {
        const stripe = getStripe();
        await stripe.refunds.create({ payment_intent: paymentIntentId });
      }

      // Restore offer quantity
      const offerId = order.offerId as string | undefined;
      const qty = order.itemQuantity as number | undefined;
      if (offerId && qty) {
        const { FieldValue } = await import("firebase-admin/firestore");
        await db
          .collection(FirestoreCollections.OFFERS)
          .doc(offerId)
          .update({ quantity: FieldValue.increment(qty) });
      }

      // Update order
      await orderRef.update({
        status: "cancelled",
        paymentStatus: paymentIntentId ? "refunded" : "paid",
        updatedAt: serverTimestamp(),
      });

      logInfo("cancelOrder done", { orderId, uid });
      return { success: true };
    } catch (error) {
      logError("cancelOrder failed", { error, data: req.data });
      throw toHttpsError(error);
    }
  }
);
