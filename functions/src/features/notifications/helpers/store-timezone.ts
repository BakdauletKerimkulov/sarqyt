/**
 * Store timezone lookup + `HH:mm` formatting shared by reminder pushes.
 *
 * Stores may lack a stored timezone (spec 034); Kazakhstan spans several
 * zones, so a single hardcoded default would be wrong for some stores —
 * `Asia/Almaty` is only used when the store has nothing better.
 */

import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";

/** Fallback when a store has no stored/derivable timezone (spec 034). */
const kDefaultTimeZone = "Asia/Almaty";

/**
 * Store's IANA timezone, falling back to a default when unset.
 *
 * @param {string} [storeId] Store document ID.
 * @return {Promise<string>} IANA timezone identifier.
 */
export async function resolveStoreTimeZone(storeId?: string): Promise<string> {
  if (!storeId) return kDefaultTimeZone;
  const storeSnap = await db
    .collection(FirestoreCollections.STORES)
    .doc(storeId)
    .get();
  const timeZone = storeSnap.data()?.location?.geo?.timezone as string | undefined;
  return typeof timeZone === "string" && timeZone.trim().length > 0 ?
    timeZone :
    kDefaultTimeZone;
}

/**
 * Render a `Date` as `HH:mm` in the given timezone.
 *
 * @param {Date} date UTC instant.
 * @param {string} timeZone IANA timezone identifier.
 * @return {string} Time formatted as `HH:mm`.
 */
export function formatTimeInZone(date: Date, timeZone: string): string {
  return new Intl.DateTimeFormat("ru-RU", {
    timeZone,
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).format(date);
}
