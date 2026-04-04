import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";

interface UpdateOrderStatusRequest {
  orderId: string;
  status: string;
}

const VALID_TRANSITIONS: Record<string, string[]> = {
  confirmed: ["preparing", "cancelled"],
  preparing: ["readyForPickup", "cancelled"],
  readyForPickup: ["completed", "cancelled"],
};

/**
 * Updates order status. Only store owner/staff can call this.
 * Enforces valid status transitions.
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
    const orderSnap = await orderRef.get();

    if (!orderSnap.exists) {
      throw new AppError("not-found", "Order not found");
    }

    const order = orderSnap.data()!;
    const currentStatus = order.status as string;
    const storeId = order.storeId as string;

    // Auth: store owner or staff only
    const storeSnap = await db
      .collection(FirestoreCollections.STORES)
      .doc(storeId)
      .get();
    const storeData = storeSnap.data();
    const isOwner = storeData?.ownerId === uid;
    const isStaff = (storeData?.staffIds as string[] ?? []).includes(uid);

    if (!isOwner && !isStaff) {
      throw new AppError("permission-denied", "Only store owner/staff can update orders");
    }

    // Validate transition
    const allowed = VALID_TRANSITIONS[currentStatus];
    if (!allowed || !allowed.includes(status)) {
      throw new AppError(
        "failed-precondition",
        `Cannot transition from ${currentStatus} to ${status}`
      );
    }

    await orderRef.update({
      status,
      updatedAt: serverTimestamp(),
    });

    logInfo("updateOrderStatus done", { orderId, from: currentStatus, to: status });
    return { success: true };
  } catch (error) {
    logError("updateOrderStatus failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
