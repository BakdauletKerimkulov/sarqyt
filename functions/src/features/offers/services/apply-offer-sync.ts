import { Timestamp } from "firebase-admin/firestore";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { readTimestamp, sameTimestamp } from "../helpers/offer-firestore";
import { buildDateKeyInTimeZone } from "../helpers/offer-timezone";
import { readOptionalPrice } from "../helpers/offer-values";
import {
  DiffAndApplyParams,
  MaterializedOfferFields,
  SyncResult,
} from "../types/offer-sync";

interface BatchMutation {
  type: "set" | "update";
  ref: FirebaseFirestore.DocumentReference;
  data: FirebaseFirestore.DocumentData;
}

type ExistingOffersByDate = Map<string, FirebaseFirestore.QueryDocumentSnapshot[]>;

interface PlannedMutations {
  mutations: BatchMutation[];
  result: SyncResult;
}

async function loadExistingOffersByDate(
  storeId: string,
  itemId: string,
  rangeStart: Date,
  rangeEnd: Date,
  storeTimeZone: string,
): Promise<ExistingOffersByDate> {
  const existingSnap = await db
    .collection(FirestoreCollections.OFFERS)
    .where("storeId", "==", storeId)
    .where("productId", "==", itemId)
    .where("pickupStartTime", ">=", Timestamp.fromDate(rangeStart))
    .where("pickupStartTime", "<", Timestamp.fromDate(rangeEnd))
    .get();

  const existingByDate: ExistingOffersByDate = new Map();
  for (const doc of existingSnap.docs) {
    const pickupStart = readTimestamp(
      doc.data().pickupStartTime,
      "offer.pickupStartTime",
    );
    const dateKey = buildDateKeyInTimeZone(
      pickupStart.toDate(),
      storeTimeZone,
    );
    const docs = existingByDate.get(dateKey) ?? [];
    docs.push(doc);
    existingByDate.set(dateKey, docs);
  }

  return existingByDate;
}

function buildOfferPatch(
  existing: FirebaseFirestore.DocumentData,
  target: MaterializedOfferFields,
): Record<string, unknown> {
  const patch: Record<string, unknown> = {};

  if (existing.id !== target.id) patch.id = target.id;
  if (existing.storeId !== target.storeId) patch.storeId = target.storeId;
  if (existing.productId !== target.productId) patch.productId = target.productId;
  if (existing.geohash !== target.geohash) patch.geohash = target.geohash;
  if (
    !existing.geopoint?.isEqual?.(target.geopoint) ||
    (existing.geopoint == null) !== (target.geopoint == null)
  ) {
    patch.geopoint = target.geopoint;
  }
  if (!sameTimestamp(existing.visibleFrom, target.visibleFrom)) {
    patch.visibleFrom = target.visibleFrom;
  }
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

  const existingEstimatedValue = readOptionalPrice(existing.estimatedValue);
  if (existingEstimatedValue !== target.estimatedValue) {
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

function canPause(
  data: FirebaseFirestore.DocumentData,
  now: Date,
): boolean {
  const end = readTimestamp(data.pickupEndTime, "offer.pickupEndTime").toDate();
  return end > now && data.status !== "paused";
}

function appendPauseMutations(
  docs: FirebaseFirestore.QueryDocumentSnapshot[],
  utcNow: Date,
  mutations: BatchMutation[],
): number {
  let paused = 0;

  for (const doc of docs) {
    if (!canPause(doc.data(), utcNow)) continue;
    mutations.push({
      type: "update",
      ref: doc.ref,
      data: { status: "paused" },
    });
    paused++;
  }

  return paused;
}

function planOfferSyncMutations(
  params: DiffAndApplyParams,
  existingByDate: ExistingOffersByDate,
): PlannedMutations {
  const remainingByDate = new Map(existingByDate);
  const mutations: BatchMutation[] = [];
  let created = 0;
  let updated = 0;
  let paused = 0;

  for (const [dateKey, expected] of params.expectedByDate) {
    const docs = remainingByDate.get(dateKey) ?? [];
    const [primaryDoc, ...duplicates] = docs;

    if (primaryDoc == null) {
      const offerRef = db
        .collection(FirestoreCollections.OFFERS)
        .doc(expected.docId);
      mutations.push({
        type: "set",
        ref: offerRef,
        data: {
          ...expected.fields,
          createdAt: serverTimestamp(),
          createdBy: params.uid,
        },
      });
      created++;
    } else {
      const patch = buildOfferPatch(primaryDoc.data(), expected.fields);
      if (Object.keys(patch).length > 0) {
        mutations.push({
          type: "update",
          ref: primaryDoc.ref,
          data: patch,
        });
        updated++;
      }
    }

    paused += appendPauseMutations(duplicates, params.utcNow, mutations);
    remainingByDate.delete(dateKey);
  }

  for (const docs of remainingByDate.values()) {
    paused += appendPauseMutations(docs, params.utcNow, mutations);
  }

  return {
    mutations,
    result: { created, updated, paused },
  };
}

async function commitMutations(mutations: BatchMutation[]): Promise<void> {
  const batch = db.batch();

  for (const mutation of mutations) {
    if (mutation.type === "set") {
      batch.set(mutation.ref, mutation.data);
      continue;
    }
    batch.update(mutation.ref, mutation.data);
  }

  await batch.commit();
}

/**
 * Diff expected offers against existing Firestore offers and apply
 * creates, updates, and pauses in a single batch.
 * @param {DiffAndApplyParams} params Sync parameters.
 * @return {Promise<SyncResult>} Number of created, updated, and paused offers.
 */
export async function diffAndApply(
  params: DiffAndApplyParams,
): Promise<SyncResult> {
  const existingByDate = await loadExistingOffersByDate(
    params.storeId,
    params.itemId,
    params.rangeStart,
    params.rangeEnd,
    params.storeTimeZone,
  );

  const { mutations, result } = planOfferSyncMutations(params, existingByDate);
  if (mutations.length > 0) {
    await commitMutations(mutations);
  }

  return result;
}
