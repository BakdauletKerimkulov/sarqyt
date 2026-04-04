import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logInfo } from "../../../app/logger";

/**
 * Runs daily at 03:00 UTC.
 * - Deletes expired/paused offers older than 7 days.
 * - Deletes expired/cancelled reservations older than 7 days.
 */
export const cleanupOldData = onSchedule("every day 03:00", async () => {
  const cutoff = Timestamp.fromMillis(
    Date.now() - 7 * 24 * 60 * 60 * 1000
  );

  let deletedOffers = 0;
  let deletedReservations = 0;

  // Cleanup old offers (expired or paused, older than 7 days)
  for (const status of ["expired", "paused"]) {
    const snap = await db
      .collection(FirestoreCollections.OFFERS)
      .where("status", "==", status)
      .where("pickupEndTime", "<", cutoff)
      .get();

    if (!snap.empty) {
      const batch = db.batch();
      for (const doc of snap.docs) {
        batch.delete(doc.ref);
      }
      await batch.commit();
      deletedOffers += snap.size;
    }
  }

  // Cleanup old reservations (expired or cancelled, older than 7 days)
  for (const status of ["expired", "cancelled"]) {
    const snap = await db
      .collection(FirestoreCollections.RESERVATIONS)
      .where("status", "==", status)
      .where("expiresAt", "<", cutoff)
      .get();

    if (!snap.empty) {
      const batch = db.batch();
      for (const doc of snap.docs) {
        batch.delete(doc.ref);
      }
      await batch.commit();
      deletedReservations += snap.size;
    }
  }

  if (deletedOffers > 0 || deletedReservations > 0) {
    logInfo("cleanupOldData done", { deletedOffers, deletedReservations });
  }
});
