import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logInfo } from "../../../app/logger";

/**
 * Runs every 5 minutes. Finds confirmed/preparing/readyForPickup orders
 * where pickupEndTime has passed, and marks them as completed.
 */
export const expireOrders = onSchedule("every 5 minutes", async () => {
  const now = Timestamp.now();
  const activeStatuses = ["confirmed", "preparing", "readyForPickup"];

  let totalExpired = 0;

  for (const status of activeStatuses) {
    const snap = await db
      .collection(FirestoreCollections.ORDERS)
      .where("status", "==", status)
      .where("pickupEndTime", "<=", now)
      .get();

    if (snap.empty) continue;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.update(doc.ref, {
        status: "completed",
        updatedAt: now,
      });
    }
    await batch.commit();
    totalExpired += snap.size;
  }

  if (totalExpired > 0) {
    logInfo("expireOrders done", { expired: totalExpired });
  }
});
