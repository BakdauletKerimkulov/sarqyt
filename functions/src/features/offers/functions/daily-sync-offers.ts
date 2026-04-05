import { GeoPoint, Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { logError, logInfo } from "../../../app/logger";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import { buildExpectedOffers } from "../services/build-expected-offers";
import { diffAndApply } from "../services/apply-offer-sync";
import { requireNonEmptyString } from "../helpers/offer-assertions";
import { readRequiredPrice, readOptionalPrice } from "../helpers/offer-values";
import { readStoreTimeZone, buildStoreAddress } from "../helpers/offer-store";
import { buildPickupTime, buildDateKey } from "../helpers/offer-timezone";

/**
 * Runs daily at 00:30 UTC. For every active item:
 * - scheduled: syncs offers for today + tomorrow
 * - oneTime: creates one offer for oneTimeDate if not exists
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

    for (const itemSnap of itemsSnap.docs) {
      const itemId = itemSnap.id;
      const itemData = itemSnap.data() as ItemDoc;

      try {
        if (itemData.type === "oneTime") {
          const created = await syncOneTimeItem(
            storeId, itemId, itemData, storeData
          );
          totalCreated += created;
        } else {
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
        }
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

/**
 * Creates a single offer for a one-time item if not already created.
 * Returns 1 if created, 0 if already exists or date passed.
 */
async function syncOneTimeItem(
  storeId: string,
  itemId: string,
  itemData: ItemDoc,
  storeData: StoreDoc,
): Promise<number> {
  const date = itemData.oneTimeDate;
  if (!date) return 0;

  const timeZone = readStoreTimeZone(storeData);
  const [year, month, day] = date.split("-").map(Number);
  const dateParts = { year, month, day };

  const startHour = itemData.oneTimeStartHour ?? 18;
  const startMinute = itemData.oneTimeStartMinute ?? 0;
  const endHour = itemData.oneTimeEndHour ?? 20;
  const endMinute = itemData.oneTimeEndMinute ?? 0;

  const pickupEnd = buildPickupTime(dateParts, endHour, endMinute, timeZone);

  // Skip if pickup time already passed
  if (pickupEnd <= new Date()) {
    // Deactivate the item
    await db
      .doc(`${FirestoreCollections.STORES}/${storeId}/items/${itemId}`)
      .update({ isActive: false });
    return 0;
  }

  const dateKey = buildDateKey(dateParts);
  const docId = `${storeId}_${itemId}_${dateKey}_onetime`;
  const offerRef = db.collection(FirestoreCollections.OFFERS).doc(docId);

  // Idempotent: skip if already exists
  const existing = await offerRef.get();
  if (existing.exists) return 0;

  const pickupStart = buildPickupTime(
    dateParts, startHour, startMinute, timeZone
  );
  const price = readRequiredPrice(itemData.price, "item.price");
  const estimatedValue = readOptionalPrice(itemData.estimatedValue);
  const currencyCode = storeData.currency?.trim() || "KZT";
  const geohash = storeData.location?.geo?.geohash;
  const geopoint = storeData.location?.geo?.geopoint;

  if (!geohash || !geopoint) return 0;

  await offerRef.set({
    id: docId,
    storeId,
    productId: itemId,
    geohash,
    geopoint: new GeoPoint(geopoint.latitude, geopoint.longitude),
    quantity: itemData.oneTimeQuantity ?? 1,
    name: requireNonEmptyString(itemData.name, "item.name"),
    price,
    currencyCode,
    currencySymbol: currencyCode === "KZT" ? "₸" : currencyCode,
    estimatedValue,
    storeName: requireNonEmptyString(storeData.name, "store.name"),
    storeLogo: storeData.logoUrl ?? null,
    storeAddress: buildStoreAddress(storeData),
    productImage: itemData.imageUrl ?? null,
    pickupStartTime: Timestamp.fromDate(pickupStart),
    pickupEndTime: Timestamp.fromDate(pickupEnd),
    status: "active",
    createdAt: serverTimestamp(),
    createdBy: storeData.ownerId,
  });

  return 1;
}
