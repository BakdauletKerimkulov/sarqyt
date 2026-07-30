import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";

interface UpdateOrderStatusRequest {
  orderId: string;
  status: string;
}

// Cancellation is NOT allowed here — use cancelOrder instead, which
// handles quantity restoration and offer reactivation.
const VALID_TRANSITIONS: Record<string, string[]> = {
  confirmed: ["preparing"],
  preparing: ["readyForPickup"],
  readyForPickup: ["completed"],
  // completed, cancelled, expired are terminal — no transitions out
};

/**
 * Updates order status. Only store owner/staff can call this.
 * Enforces valid status transitions inside a transaction to prevent
 * TOCTOU races on concurrent updates.
 */
export const updateOrderStatus = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const { orderId, status } = req.data as UpdateOrderStatusRequest;

    if (!orderId || typeof orderId !== "string") {
      throw new AppError("invalid-argument", "orderId is required");
    }
    if (!status || typeof status !== "string") {
      throw new AppError("invalid-argument", "status is required");
    }

    const orderRef = db.collection(FirestoreCollections.ORDERS).doc(orderId);

    // Pre-read order to get storeId for auth check
    const preSnap = await orderRef.get();
    if (!preSnap.exists) {
      throw new AppError("not-found", "Order not found");
    }
    const storeId = preSnap.data()!.storeId as string;

    // Auth: verify store access via storeShips
    await assertStoreAccess(uid, storeId);

    // Transaction: re-read order + validate transition + update status
    await db.runTransaction(async (tx) => {
      const orderSnap = await tx.get(orderRef);
      if (!orderSnap.exists) {
        throw new AppError("not-found", "Order not found");
      }

      const order = orderSnap.data()!;
      const currentStatus = order.status as string;

      // Validate transition
      const allowed = VALID_TRANSITIONS[currentStatus];
      if (!allowed || !allowed.includes(status)) {
        throw new AppError(
          "failed-precondition",
          `Cannot transition from ${currentStatus} to ${status}`
        );
      }

      const orderUpdate: Record<string, unknown> = {
        status,
        updatedAt: serverTimestamp(),
      };
      // completedAt anchors the delayed review prompt (spec 034, R7).
      if (status === "completed") {
        orderUpdate.completedAt = serverTimestamp();
      }
      tx.update(orderRef, orderUpdate);
    });

    logInfo("updateOrderStatus done", { orderId, to: status });
    return { success: true };
  } catch (error) {
    logError("updateOrderStatus failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
