import { Timestamp } from "firebase-admin/firestore";
import { AppError } from "../../../app/error";
import { StoreDoc } from "../../../shared/types/store-doc";
import { DaySchedule, WeeklySchedule } from "../types/item-doc";

/** Kazakhstan UTC+6 (Almaty, Astana). */
export const KZ_OFFSET_HOURS = 6;

/**
 * Get the current wall-clock time in Kazakhstan (UTC+6) as a Date
 * whose year/month/day/hour/minute match local KZ values.
 * @return {Date} Date representing current KZ wall-clock time.
 */
export function nowInKZ(): Date {
  const utcNow = new Date();
  return new Date(utcNow.getTime() + KZ_OFFSET_HOURS * 60 * 60 * 1000);
}

/**
 * Start of day (00:00:00.000) for a given date.
 * @param {Date} date Source date.
 * @return {Date} New date with time set to midnight.
 */
export function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

/**
 * JS Date.getDay() returns 0=Sun,1=Mon..6=Sat.
 * ISO weekday (used in schedule keys) is 1=Mon..7=Sun.
 * @param {number} jsDay JavaScript weekday number from `Date.getDay()`.
 * @return {number} ISO weekday number (1-7).
 */
export function toIsoWeekday(jsDay: number): number {
  return jsDay === 0 ? 7 : jsDay;
}

/**
 * Build a UTC Date from a KZ-shifted calendar day + local hours/minutes.
 * @param {Date} day KZ-shifted calendar day.
 * @param {number} hour Local hour from the weekly schedule.
 * @param {number} minute Local minute from the weekly schedule.
 * @return {Date} UTC Date corresponding to the KZ local time.
 */
export function buildPickupTime(
  day: Date,
  hour: number,
  minute: number,
): Date {
  const kzLocal = new Date(
    Date.UTC(
      day.getFullYear(),
      day.getMonth(),
      day.getDate(),
      hour,
      minute,
      0,
      0,
    ),
  );
  return new Date(kzLocal.getTime() - KZ_OFFSET_HOURS * 60 * 60 * 1000);
}

/**
 * Build a stable date key for one calendar day.
 * @param {Date} date Source date.
 * @return {string} Date key in YYYY-MM-DD format.
 */
export function buildDateKey(date: Date): string {
  const year = date.getFullYear().toString();
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * Build a deterministic offer document id for one store/item/day tuple.
 * @param {string} storeId Store id.
 * @param {string} itemId Item id.
 * @param {Date} date Offer date.
 * @return {string} Deterministic Firestore document id.
 */
export function buildOfferDocId(
  storeId: string,
  itemId: string,
  date: Date,
): string {
  const compactDate = buildDateKey(date).replace(/-/g, "");
  return `${storeId}_${itemId}_${compactDate}`;
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

// ---------------------------------------------------------------------------
// Validation helpers
// ---------------------------------------------------------------------------

/**
 * Ensure a value is a non-empty string.
 * @param {unknown} value Input value.
 * @param {string} field Field name for the error message.
 * @return {string} Trimmed non-empty string.
 */
export function requireNonEmptyString(
  value: unknown,
  field: string,
): string {
  if (typeof value === "string" && value.trim().length > 0) {
    return value.trim();
  }
  throw new AppError("invalid-argument", `${field} required`);
}

/**
 * Ensure a value is a positive finite number (plain or `{ amount }` map).
 * @param {unknown} value Input value.
 * @param {string} field Field name for the error message.
 * @return {number} Parsed positive number.
 */
export function readRequiredPrice(value: unknown, field: string): number {
  const parsed = readOptionalPrice(value);
  if (parsed != null) return parsed;
  throw new AppError("failed-precondition", `${field} is missing or invalid`);
}

/**
 * Read an optional positive price value.
 * @param {unknown} value Input value.
 * @return {number | null} Parsed positive number or null.
 */
export function readOptionalPrice(value: unknown): number | null {
  if (value == null) return null;
  if (typeof value === "number" && Number.isFinite(value) && value > 0) {
    return value;
  }
  if (
    value != null &&
    typeof value === "object" &&
    "amount" in value &&
    typeof value.amount === "number" &&
    Number.isFinite(value.amount) &&
    value.amount > 0
  ) {
    return value.amount;
  }
  return null;
}

/**
 * Ensure a value is a weekly schedule map.
 * @param {unknown} value Input schedule value.
 * @return {WeeklySchedule} Weekly schedule map.
 */
export function requireSchedule(value: unknown): WeeklySchedule {
  if (value != null && typeof value === "object") {
    return value as WeeklySchedule;
  }
  throw new AppError("failed-precondition", "item.schedule is missing");
}

/**
 * Validate one day schedule before materializing an offer.
 * @param {DaySchedule} schedule Day schedule to validate.
 * @param {string} dateKey Day identifier for error messages.
 * @return {void}
 */
export function validateDaySchedule(
  schedule: DaySchedule,
  dateKey: string,
): void {
  const numbers = [
    schedule.startHour,
    schedule.startMinute,
    schedule.endHour,
    schedule.endMinute,
    schedule.quantity,
  ];
  if (numbers.some((v) => !Number.isInteger(v))) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} contains non-integer values`,
    );
  }
  if (schedule.startHour < 0 || schedule.startHour > 23) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} has invalid startHour`,
    );
  }
  if (schedule.endHour < 0 || schedule.endHour > 23) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} has invalid endHour`,
    );
  }
  if (schedule.startMinute < 0 || schedule.startMinute > 59) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} has invalid startMinute`,
    );
  }
  if (schedule.endMinute < 0 || schedule.endMinute > 59) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} has invalid endMinute`,
    );
  }
  if (schedule.quantity <= 0) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} must have positive quantity`,
    );
  }
}

// ---------------------------------------------------------------------------
// Offer diff helpers
// ---------------------------------------------------------------------------

/**
 * Read a Firestore timestamp from an existing document.
 * @param {unknown} value Stored timestamp value.
 * @param {string} field Field name for error messages.
 * @return {Timestamp} Firestore timestamp.
 */
export function readTimestamp(value: unknown, field: string): Timestamp {
  if (value instanceof Timestamp) return value;
  if (value instanceof Date) return Timestamp.fromDate(value);
  throw new AppError("failed-precondition", `${field} is missing or invalid`);
}

/**
 * Compare a stored timestamp with the expected one.
 * @param {unknown} value Existing stored value.
 * @param {Timestamp} expected Expected timestamp.
 * @return {boolean} True if both timestamps represent the same moment.
 */
export function sameTimestamp(
  value: unknown,
  expected: Timestamp,
): boolean {
  return (
    value instanceof Timestamp && value.toMillis() === expected.toMillis()
  );
}
