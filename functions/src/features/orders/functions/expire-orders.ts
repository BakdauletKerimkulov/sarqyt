import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logInfo, logWarn } from "../../../app/logger";

/**
 * Runs every 5 minutes. Finds confirmed/preparing/readyForPickup orders
 * where pickupEndTime has passed, marks them as expired, and restores
 * offer quantity in a per-order transaction.
 *
 * "expired" means the pickup window closed without the customer picking up.
 * This is distinct from "completed" which means a successful pickup.
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
      .limit(500)
      .get();

    if (snap.empty) continue;

    for (const doc of snap.docs) {
      const order = doc.data();
      const offerId = order.offerId as string | undefined;
      const qty = order.itemQuantity as number | undefined;

      await db.runTransaction(async (tx) => {
        const orderSnap = await tx.get(doc.ref);
        if (!orderSnap.exists || orderSnap.data()?.status !== status) {
          return; // Already changed by another process
        }

        // All reads must happen before any writes in a Firestore transaction.
        const shouldRestoreOffer = Boolean(offerId && qty);
        const offerRef = shouldRestoreOffer ?
          db.collection(FirestoreCollections.OFFERS).doc(offerId!) :
          undefined;
        const offerSnap = offerRef ? await tx.get(offerRef) : undefined;

        tx.update(doc.ref, {
          status: "expired",
          updatedAt: serverTimestamp(),
        });

        if (!offerRef) return;

        if (!offerSnap!.exists) {
          logWarn("Offer not found during expiry, skipping quantity restore", {
            orderId: doc.id,
            offerId,
          });
          return;
        }

        const offerData = offerSnap!.data()!;
        const currentQty = (offerData.quantity as number) ?? 0;
        const offerUpdate: Record<string, unknown> = {
          quantity: currentQty + qty!,
          updatedAt: serverTimestamp(),
        };
        // R7: reactivate soldOut offer only if pickup window is still open
        if (offerData.status === "soldOut") {
          const pickupEnd = offerData.pickupEndTime as Timestamp | undefined;
          if (pickupEnd && pickupEnd.toMillis() > now.toMillis()) {
            offerUpdate.status = "active";
          }
        }
        tx.update(offerRef, offerUpdate);
      });

      totalExpired++;
    }
  }

  if (totalExpired > 0) {
    logInfo("expireOrders done", { expired: totalExpired });
  }
});
