import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logInfo } from "../../../app/logger";

/**
 * Runs daily at 08:00 Almaty (03:00 UTC — same instant as before the
 * time zone was made explicit).
 * - Deletes expired/paused offers older than 7 days.
 * - Deletes consumed/expired store drafts older than 7 days.
 */
export const cleanupOldData = onSchedule(
  { schedule: "every day 08:00", timeZone: "Asia/Almaty" },
  async () => {
    const cutoff = Timestamp.fromMillis(
      Date.now() - 7 * 24 * 60 * 60 * 1000
    );

    let deletedOffers = 0;

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

    // StoreDrafts: use Firestore TTL policy on expiresAt field instead.

    if (deletedOffers > 0) {
      logInfo("cleanupOldData done", { deletedOffers });
    }
  });
