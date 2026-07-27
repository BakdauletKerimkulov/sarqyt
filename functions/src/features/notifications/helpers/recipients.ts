/**
 * Resolves who receives a push and with which token.
 *
 * The only module that knows how the store team is stored (`storeShips` with
 * a legacy fallback to `stores/{storeId}.ownerId`) and which token field
 * belongs to which app (spec 034, R11/R15 and E10).
 */

import { db } from "../../../app/firebase";
import { logWarn } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { PushToken } from "./send-push";

/** Fan-out cap per store, so one busy store cannot blow up a run (E6). */
const kStoreTeamLimit = 20;

/** Token fields in priority order for each app audience. */
const kClientTokenFields = ["fcmTokenClient", "fcmToken"];
const kBusinessTokenFields = ["fcmTokenBusiness", "fcmToken"];

/**
 * Token of the customer's client app, or `null` if they have none.
 *
 * @param {string} uid Customer user ID.
 * @return {Promise<PushToken | null>} The token to push to.
 */
export async function getCustomerToken(uid: string): Promise<PushToken | null> {
  const tokens = await readTokens([uid], kClientTokenFields);
  return tokens[0] ?? null;
}

/**
 * Business-app tokens of everyone who works at the store.
 *
 * @param {string} storeId Store document ID.
 * @return {Promise<PushToken[]>} Up to {@link kStoreTeamLimit} tokens.
 */
export async function getStoreTeamTokens(
  storeId: string,
): Promise<PushToken[]> {
  const uids = await getStoreTeamUids(storeId);
  if (uids.length === 0) {
    logWarn("No store team recipients", { storeId });
    return [];
  }

  const tokens = await readTokens(uids, kBusinessTokenFields);
  if (tokens.length === 0) {
    logWarn("Store team has no push tokens", { storeId, uids });
  }
  return tokens;
}

/**
 * Team member IDs via `storeShips`, falling back to the legacy owner field.
 *
 * @param {string} storeId Store document ID.
 * @return {Promise<string[]>} User IDs, empty if the store is unreachable.
 */
async function getStoreTeamUids(storeId: string): Promise<string[]> {
  const shipsSnap = await db
    .collection(FirestoreCollections.STORE_SHIPS)
    .where("storeId", "==", storeId)
    .limit(kStoreTeamLimit)
    .get();

  if (!shipsSnap.empty) {
    return shipsSnap.docs
      .map((shipDoc) => shipDoc.data().userId as string | undefined)
      .filter((uid): uid is string => !!uid);
  }

  // Legacy fallback, mirroring shared/helpers/assert-store-access.ts
  const storeSnap = await db
    .collection(FirestoreCollections.STORES)
    .doc(storeId)
    .get();
  const ownerId = storeSnap.data()?.ownerId as string | undefined;
  return ownerId ? [ownerId] : [];
}

/**
 * Read one token per user, taking the first field that holds a value.
 *
 * @param {string[]} uids Users to read.
 * @param {string[]} fields Token fields in priority order.
 * @return {Promise<PushToken[]>} Tokens of users that have one.
 */
async function readTokens(
  uids: string[],
  fields: string[],
): Promise<PushToken[]> {
  const snaps = await Promise.all(uids.map((uid) =>
    db.collection(FirestoreCollections.USERS).doc(uid).get()));

  const tokens: PushToken[] = [];
  snaps.forEach((snap, index) => {
    const data = snap.data();
    const field = fields.find((name) => typeof data?.[name] === "string");
    if (!field) return;
    tokens.push({
      uid: uids[index],
      token: data?.[field] as string,
      field,
    });
  });
  return tokens;
}
