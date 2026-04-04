import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logError, logInfo } from "../../../app/logger";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import { buildExpectedOffers } from "../services/build-expected-offers";
import { diffAndApply } from "../services/apply-offer-sync";

/**
 * Fires when any item document is updated.
 * If isActive changed, syncs or pauses related offers.
 */
export const onItemStatusChanged = onDocumentUpdated(
  { document: "stores/{storeId}/items/{itemId}", region: "asia-south1" },
  async (event) => {
    const before = event.data?.before.data() as ItemDoc | undefined;
    const after = event.data?.after.data() as ItemDoc | undefined;
    if (!before || !after) return;

    const wasActive = before.isActive ?? false;
    const isActive = after.isActive ?? false;

    // Only react when isActive changed
    if (wasActive === isActive) return;

    const storeId = event.params.storeId;
    const itemId = event.params.itemId;

    try {
      if (isActive) {
        // Turned ON → create offers for today + tomorrow
        const storeSnap = await db
          .collection(FirestoreCollections.STORES)
          .doc(storeId)
          .get();
        if (!storeSnap.exists) return;

        const storeData = storeSnap.data() as StoreDoc;
        const { expectedByDate, storeTimeZone, utcNow, rangeStart, rangeEnd } =
          buildExpectedOffers(storeId, itemId, after, storeData);

        const result = await diffAndApply({
          storeId,
          itemId,
          uid: storeData.ownerId,
          expectedByDate,
          storeTimeZone,
          utcNow,
          rangeStart,
          rangeEnd,
        });

        logInfo("onItemStatusChanged: activated", { storeId, itemId, ...result });
      } else {
        // Turned OFF → pause all active offers for this item
        const activeOffers = await db
          .collection(FirestoreCollections.OFFERS)
          .where("storeId", "==", storeId)
          .where("productId", "==", itemId)
          .where("status", "==", "active")
          .get();

        if (activeOffers.empty) return;

        const batch = db.batch();
        for (const doc of activeOffers.docs) {
          batch.update(doc.ref, { status: "paused" });
        }
        await batch.commit();

        logInfo("onItemStatusChanged: paused", {
          storeId,
          itemId,
          paused: activeOffers.size,
        });
      }
    } catch (error) {
      logError("onItemStatusChanged failed", { storeId, itemId, error });
    }
  }
);
