import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logError, logInfo } from "../../../app/logger";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import { buildExpectedOffers } from "../services/build-expected-offers";
import { diffAndApply } from "../services/apply-offer-sync";

/**
 * Runs daily at 00:30 UTC. For every item where isActive == true,
 * syncs offers for today + tomorrow.
 */
export const dailySyncOffers = onSchedule("every day 00:30", async () => {
  const storesSnap = await db.collection(FirestoreCollections.STORES).get();

  let totalCreated = 0;
  let totalUpdated = 0;
  let totalPaused = 0;

  for (const storeDoc of storesSnap.docs) {
    const storeId = storeDoc.id;
    const storeData = storeDoc.data() as StoreDoc;

    const itemsSnap = await db
      .collection(`${FirestoreCollections.STORES}/${storeId}/items`)
      .where("isActive", "==", true)
      .get();

    for (const itemDoc of itemsSnap.docs) {
      const itemId = itemDoc.id;
      const itemData = itemDoc.data() as ItemDoc;

      try {
        const { expectedByDate, storeTimeZone, utcNow, rangeStart, rangeEnd } =
          buildExpectedOffers(storeId, itemId, itemData, storeData);

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

        totalCreated += result.created;
        totalUpdated += result.updated;
        totalPaused += result.paused;
      } catch (error) {
        logError("dailySyncOffers: failed for item", {
          storeId,
          itemId,
          error,
        });
      }
    }
  }

  logInfo("dailySyncOffers done", {
    created: totalCreated,
    updated: totalUpdated,
    paused: totalPaused,
  });
});
