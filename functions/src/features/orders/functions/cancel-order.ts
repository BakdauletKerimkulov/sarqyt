import { Timestamp } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";

interface CancelOrderRequest {
  orderId: string;
  reason?: string;
}

/**
 * Idempotent: if order is already cancelled, returns success.
 * Cancels order, restores offer quantity, and conditionally reactivates
 * soldOut offers when the pickup window is still open.
 */
export const cancelOrder = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const { orderId, reason } = req.data as CancelOrderRequest;

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
    await db.runTransaction(async (tx) => {
      const orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw new AppError("not-found", "Order not found");
      }

      const order = orderSnap.data()!;
      const status = order.status as string;

      // Idempotent: already cancelled
      if (status === "cancelled") return;

      if (!["confirmed", "preparing", "readyForPickup"].includes(status)) {
        throw new AppError(
          "failed-precondition",
          `Cannot cancel order with status: ${status}. Only confirmed, preparing, or readyForPickup orders can be cancelled.`
        );
      }

      // Restore offer quantity and conditionally reactivate from soldOut.
      // All reads must happen before any writes in a Firestore transaction.
      const offerId = order.offerId as string | undefined;
      const qty = order.itemQuantity as number | undefined;
      const offerRef = offerId && qty ?
        db.collection(FirestoreCollections.OFFERS).doc(offerId) :
        undefined;
      const offerSnap = offerRef ? await tx.get(offerRef) : undefined;

      // R4: determine who cancelled and write reason
      const cancelledBy = isCustomer ? "customer" : "store";
      const orderUpdate: Record<string, unknown> = {
        status: "cancelled",
        cancelledBy,
        updatedAt: serverTimestamp(),
      };
      if (reason) {
        orderUpdate.cancellationReason = reason;
      }
      tx.update(orderRef, orderUpdate);

      if (offerRef && offerSnap!.exists) {
        const offerData = offerSnap!.data()!;
        const currentQty = (offerData.quantity as number) ?? 0;
        const offerUpdate: Record<string, unknown> = {
          quantity: currentQty + qty!,
          updatedAt: serverTimestamp(),
        };
        // R7: reactivate soldOut offer only if pickup window is still open
        if (offerData.status === "soldOut") {
          const pickupEnd = offerData.pickupEndTime as Timestamp | undefined;
          if (pickupEnd && pickupEnd.toMillis() > Timestamp.now().toMillis()) {
            offerUpdate.status = "active";
          }
        }
        tx.update(offerRef, offerUpdate);
      }
    });

    logInfo("cancelOrder done", { orderId, uid });
    return { success: true };
  } catch (error) {
    logError("cancelOrder failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
