import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logError, logInfo } from "../../../app/logger";

const statusLabels: Record<string, string> = {
  confirmed: "Your order has been confirmed!",
  preparing: "Your order is being prepared",
  readyForPickup: "Your order is ready for pickup!",
  completed: "Order completed. Leave a review!",
  cancelled: "Your order has been cancelled",
};

/**
 * Sends a push notification when order status changes.
 */
export const onOrderStatusChanged = onDocumentUpdated(
  { document: "orders/{orderId}", region: "asia-south1" },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    if (before.status === after.status) return;

    const customerId = after.customerId as string | undefined;
    if (!customerId) return;

    const storeName = (after.storeName as string) ?? "Store";
    const newStatus = after.status as string;
    const body = statusLabels[newStatus] ?? `Order status: ${newStatus}`;

    try {
      const userSnap = await db
        .collection(FirestoreCollections.USERS)
        .doc(customerId)
        .get();
      const fcmToken = userSnap.data()?.fcmToken as string | undefined;
      if (!fcmToken) return;

      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: storeName,
          body,
        },
        data: {
          orderId: event.params.orderId,
          status: newStatus,
        },
      });

      logInfo("Push sent", {
        orderId: event.params.orderId,
        status: newStatus,
      });
    } catch (error) {
      logError("Push failed", { error, orderId: event.params.orderId });
    }
  }
);
