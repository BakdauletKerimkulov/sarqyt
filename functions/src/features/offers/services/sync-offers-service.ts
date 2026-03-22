import { Timestamp } from "firebase-admin/firestore";
import { AppError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections, storeItemPath } from "../../../shared/constants/constants";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import {
  buildDateKey,
  buildOfferDocId,
  buildPickupTime,
  buildStoreAddress,
  nowInKZ,
  readOptionalPrice,
  readRequiredPrice,
  readTimestamp,
  requireNonEmptyString,
  requireSchedule,
  sameTimestamp,
  startOfDay,
  toIsoWeekday,
  validateDaySchedule,
} from "../helpers/offer-helpers";

const DAYS_AHEAD = 7;

export interface MaterializedOfferFields {
  storeId: string;
  productId: string;
  quantity: number;
  name: string;
  price: number;
  currencyCode: string;
  currencySymbol: string;
  estimatedValue: number | null;
  storeName: string;
  storeLogo: string | null;
  storeAddress: string | null;
  productImage: string | null;
  pickupStartTime: Timestamp;
  pickupEndTime: Timestamp;
  status: string;
}

export interface SyncResult {
  created: number;
  updated: number;
  paused: number;
}

/**
 * Load and validate item + store documents from Firestore.
 * @param {string} storeId Store document ID.
 * @param {string} itemId Item document ID.
 * @param {string} uid Authenticated user ID (for ownership check).
 * @return {Promise<{ itemData: ItemDoc; storeData: StoreDoc }>} Validated docs.
 */
export async function loadAndValidate(
  storeId: string,
  itemId: string,
  uid: string,
): Promise<{ itemData: ItemDoc; storeData: StoreDoc }> {
  const [itemSnap, storeSnap] = await Promise.all([
    db.doc(storeItemPath(storeId, itemId)).get(),
    db.doc(`${FirestoreCollections.STORES}/${storeId}`).get(),
  ]);

  if (!itemSnap.exists) {
    throw new AppError("not-found", "Item not found");
  }
  if (!storeSnap.exists) {
    throw new AppError("not-found", "Store not found");
  }

  const itemData = itemSnap.data() as ItemDoc;
  const storeData = storeSnap.data() as StoreDoc;

  if (storeData.ownerId !== uid && !(storeData.staffIds ?? []).includes(uid)) {
    throw new AppError("permission-denied", "No access to this store");
  }

  return { itemData, storeData };
}

/**
 * Compute expected offers for the next 7 days based on item schedule.
 * @param {string} storeId Store ID.
 * @param {string} itemId Item ID.
 * @param {ItemDoc} itemData Item document data.
 * @param {StoreDoc} storeData Store document data.
 * @return {{ expectedByDate: Map<string, { docId: string; fields: MaterializedOfferFields }>, now: Date, rangeStart: Date, rangeEnd: Date }}
 */
export function buildExpectedOffers(
  storeId: string,
  itemId: string,
  itemData: ItemDoc,
  storeData: StoreDoc,
): {
  expectedByDate: Map<string, { docId: string; fields: MaterializedOfferFields }>;
  now: Date;
  rangeStart: Date;
  rangeEnd: Date;
} {
  const itemName = requireNonEmptyString(itemData.name, "item.name");
  const storeName = requireNonEmptyString(storeData.name, "store.name");
  const scheduleMap = requireSchedule(itemData.schedule);
  const price = readRequiredPrice(itemData.price, "item.price");
  const estimatedValue = readOptionalPrice(itemData.estimatedValue);
  const currencyCode = storeData.currency?.trim() || "KZT";
  const currencySymbol = currencyCode === "KZT" ? "₸" : currencyCode;
  const storeAddress = buildStoreAddress(storeData);

  const now = nowInKZ();
  const rangeStart = startOfDay(now);
  const rangeEnd = new Date(rangeStart);
  rangeEnd.setDate(rangeEnd.getDate() + DAYS_AHEAD);

  const expectedByDate = new Map<
    string,
    { docId: string; fields: MaterializedOfferFields }
  >();

  for (let i = 0; i < DAYS_AHEAD; i++) {
    const date = new Date(rangeStart);
    date.setDate(date.getDate() + i);

    const weekday = toIsoWeekday(date.getDay()).toString();
    const schedule = scheduleMap[weekday];
    if (!schedule?.enabled) continue;

    const dateKey = buildDateKey(date);
    validateDaySchedule(schedule, dateKey);

    const pickupStart = buildPickupTime(
      date,
      schedule.startHour,
      schedule.startMinute,
    );
    const pickupEnd = buildPickupTime(
      date,
      schedule.endHour,
      schedule.endMinute,
    );

    if (pickupEnd <= pickupStart) {
      throw new AppError(
        "failed-precondition",
        `Schedule for ${dateKey} has invalid pickup window`,
      );
    }
    if (pickupEnd <= now) continue;

    expectedByDate.set(dateKey, {
      docId: buildOfferDocId(storeId, itemId, date),
      fields: {
        storeId,
        productId: itemId,
        quantity: schedule.quantity,
        name: itemName,
        price,
        currencyCode,
        currencySymbol,
        estimatedValue,
        storeName,
        storeLogo: storeData.logoUrl ?? null,
        storeAddress,
        productImage: itemData.imageUrl ?? null,
        pickupStartTime: Timestamp.fromDate(pickupStart),
        pickupEndTime: Timestamp.fromDate(pickupEnd),
        status: "active",
      },
    });
  }

  return { expectedByDate, now, rangeStart, rangeEnd };
}

/**
 * Diff expected offers against existing Firestore offers and apply
 * creates, updates, and pauses in a single batch.
 * @param {object} params Sync parameters.
 * @return {Promise<SyncResult>} Number of created, updated, and paused offers.
 */
export async function diffAndApply(params: {
  storeId: string;
  itemId: string;
  uid: string;
  expectedByDate: Map<string, { docId: string; fields: MaterializedOfferFields }>;
  now: Date;
  rangeStart: Date;
  rangeEnd: Date;
}): Promise<SyncResult> {
  const { storeId, itemId, uid, expectedByDate, now, rangeStart, rangeEnd } =
    params;

  const existingSnap = await db
    .collection(FirestoreCollections.OFFERS)
    .where("storeId", "==", storeId)
    .where("productId", "==", itemId)
    .where("pickupStartTime", ">=", Timestamp.fromDate(rangeStart))
    .where("pickupStartTime", "<", Timestamp.fromDate(rangeEnd))
    .get();

  const existingByDate = new Map<
    string,
    FirebaseFirestore.QueryDocumentSnapshot[]
  >();
  for (const doc of existingSnap.docs) {
    const ts = readTimestamp(doc.data().pickupStartTime, "offer.pickupStartTime");
    const dateKey = buildDateKey(ts.toDate());
    const docs = existingByDate.get(dateKey) ?? [];
    docs.push(doc);
    existingByDate.set(dateKey, docs);
  }

  const batch = db.batch();
  let created = 0;
  let updated = 0;
  let paused = 0;

  // Create or update expected offers
  for (const [dateKey, expected] of expectedByDate) {
    const docs = existingByDate.get(dateKey) ?? [];
    const [primaryDoc, ...duplicates] = docs;

    if (primaryDoc == null) {
      const offerRef = db
        .collection(FirestoreCollections.OFFERS)
        .doc(expected.docId);
      batch.set(offerRef, {
        ...expected.fields,
        createdAt: serverTimestamp(),
        createdBy: uid,
      });
      created++;
    } else {
      const patch = buildOfferPatch(primaryDoc.data(), expected.fields);
      if (Object.keys(patch).length > 0) {
        batch.update(primaryDoc.ref, patch);
        updated++;
      }
    }

    for (const duplicate of duplicates) {
      if (canPause(duplicate.data(), now)) {
        batch.update(duplicate.ref, { status: "paused" });
        paused++;
      }
    }

    existingByDate.delete(dateKey);
  }

  // Pause orphaned offers (dates no longer in schedule)
  for (const docs of existingByDate.values()) {
    for (const doc of docs) {
      if (canPause(doc.data(), now)) {
        batch.update(doc.ref, { status: "paused" });
        paused++;
      }
    }
  }

  if (created > 0 || updated > 0 || paused > 0) {
    await batch.commit();
  }

  return { created, updated, paused };
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

/**
 * Build a patch for fields that changed since the last sync.
 * @param {FirebaseFirestore.DocumentData} existing Existing offer data.
 * @param {MaterializedOfferFields} target Expected fields.
 * @return {Record<string, unknown>} Partial update patch (empty if nothing changed).
 */
function buildOfferPatch(
  existing: FirebaseFirestore.DocumentData,
  target: MaterializedOfferFields,
): Record<string, unknown> {
  const patch: Record<string, unknown> = {};

  if (existing.storeId !== target.storeId) patch.storeId = target.storeId;
  if (existing.productId !== target.productId) patch.productId = target.productId;
  if (existing.quantity !== target.quantity) patch.quantity = target.quantity;
  if (existing.name !== target.name) patch.name = target.name;

  const existingPrice = readOptionalPrice(existing.price);
  if (existingPrice !== target.price) patch.price = target.price;

  if (existing.currencyCode !== target.currencyCode) {
    patch.currencyCode = target.currencyCode;
  }
  if (existing.currencySymbol !== target.currencySymbol) {
    patch.currencySymbol = target.currencySymbol;
  }

  const existingEV = readOptionalPrice(existing.estimatedValue);
  if (existingEV !== target.estimatedValue) {
    patch.estimatedValue = target.estimatedValue;
  }

  if (existing.storeName !== target.storeName) patch.storeName = target.storeName;
  if ((existing.storeLogo ?? null) !== target.storeLogo) {
    patch.storeLogo = target.storeLogo;
  }
  if ((existing.storeAddress ?? null) !== target.storeAddress) {
    patch.storeAddress = target.storeAddress;
  }
  if ((existing.productImage ?? null) !== target.productImage) {
    patch.productImage = target.productImage;
  }
  if (!sameTimestamp(existing.pickupStartTime, target.pickupStartTime)) {
    patch.pickupStartTime = target.pickupStartTime;
  }
  if (!sameTimestamp(existing.pickupEndTime, target.pickupEndTime)) {
    patch.pickupEndTime = target.pickupEndTime;
  }
  if ((existing.status ?? null) !== target.status) patch.status = target.status;

  return patch;
}

/**
 * Check if a future offer can be paused by sync.
 * @param {FirebaseFirestore.DocumentData} data Existing offer data.
 * @param {Date} now Current KZ time.
 * @return {boolean} True if the offer is still in the future and not already paused.
 */
function canPause(
  data: FirebaseFirestore.DocumentData,
  now: Date,
): boolean {
  const end = readTimestamp(data.pickupEndTime, "offer.pickupEndTime").toDate();
  return end > now && data.status !== "paused";
}
