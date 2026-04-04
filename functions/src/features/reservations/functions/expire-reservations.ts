import { onSchedule } from "firebase-functions/v2/scheduler";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";

export const expireReservations = onSchedule("every 5 minutes", async () => {
  const now = Timestamp.now();

  const expiredSnaps = await db
    .collection(FirestoreCollections.RESERVATIONS)
    .where("status", "==", "pending")
    .where("expiresAt", "<=", now)
    .get();

  if (expiredSnaps.empty) return;

  const batch = db.batch();

  for (const doc of expiredSnaps.docs) {
    const data = doc.data();
    const offerId = data.offerId as string;
    const quantity = data.quantity as number;

    // Mark reservation as expired
    batch.update(doc.ref, { status: "expired" });

    // Restore offer quantity
    const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);
    batch.update(offerRef, { quantity: FieldValue.increment(quantity) });
  }

  await batch.commit();
  console.log(`Expired ${expiredSnaps.size} reservations`);
});
