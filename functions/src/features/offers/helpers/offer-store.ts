import tzLookup from "tz-lookup";
import { AppError } from "../../../app/error";
import { StoreDoc } from "../../../shared/types/store-doc";
import { requireTimeZone } from "./offer-timezone";

/**
 * Read the store timezone from Firestore, falling back to a lookup from
 * coordinates for legacy store documents that do not yet persist it.
 * @param {StoreDoc} store Store document.
 * @return {string} IANA timezone identifier.
 */
export function readStoreTimeZone(store: StoreDoc): string {
  const storedTimeZone = store.location?.geo?.timezone;
  if (typeof storedTimeZone === "string" && storedTimeZone.trim().length > 0) {
    return requireTimeZone(storedTimeZone, "store.location.geo.timezone");
  }

  const geoPoint = store.location?.geo?.geopoint;
  if (geoPoint == null) {
    throw new AppError(
      "failed-precondition",
      "store.location.geo.geopoint is missing",
    );
  }

  return requireTimeZone(
    tzLookup(geoPoint.latitude, geoPoint.longitude),
    "store.location.geo.timezone",
  );
}

/**
 * Build a comma-separated address string from store location.
 * @param {StoreDoc} store Store document.
 * @return {string | null} Formatted address or null if location is missing.
 */
export function buildStoreAddress(store: StoreDoc): string | null {
  const addr = store.location?.address;
  if (!addr) return null;

  const parts: string[] = [];
  if (addr.address) parts.push(addr.address);
  if (addr.locality) parts.push(addr.locality);
  if (addr.country?.name) parts.push(addr.country.name);

  return parts.length > 0 ? parts.join(", ") : null;
}
