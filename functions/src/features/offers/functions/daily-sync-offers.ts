import { onSchedule } from "firebase-functions/v2/scheduler";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logError, logInfo } from "../../../app/logger";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import { buildExpectedOffers } from "../services/build-expected-offers";
import { diffAndApply } from "../services/apply-offer-sync";

/**
 * Runs daily at 06:30 Almaty (01:30 UTC). For every active item, syncs
 * offers for today + tomorrow using buildExpectedOffers + diffAndApply.
 *
 * The hour is expressed in Almaty local time on purpose: it exists to land
 * after midnight but before the morning rush, which is a statement about
 * the local clock, not about UTC. Keeping it implicit made the intent
 * survive only in a comment — and that comment was wrong, since it assumed
 * the UTC+6 Almaty had before March 2024.
 */
export const dailySyncOffers = onSchedule(
  { schedule: "every day 06:30", timeZone: "Asia/Almaty" },
  async () => {
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

      for (const itemSnap of itemsSnap.docs) {
        const itemId = itemSnap.id;
        const itemData = itemSnap.data() as ItemDoc;

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
