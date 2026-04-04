import { AppError } from "../../../app/error";
import { requireNonEmptyString } from "./offer-assertions";

export interface LocalDateParts {
  year: number;
  month: number;
  day: number;
}

interface LocalDateTimeParts extends LocalDateParts {
  hour: number;
  minute: number;
  second: number;
}

const zonedDateTimeFormatters = new Map<string, Intl.DateTimeFormat>();

function getZonedDateTimeFormatter(timeZone: string): Intl.DateTimeFormat {
  const cached = zonedDateTimeFormatters.get(timeZone);
  if (cached != null) return cached;

  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hourCycle: "h23",
  });
  zonedDateTimeFormatters.set(timeZone, formatter);
  return formatter;
}

function readDateTimePart(
  parts: Intl.DateTimeFormatPart[],
  type: string,
  timeZone: string,
): number {
  const rawValue = parts.find((part) => part.type === type)?.value;
  if (rawValue == null) {
    throw new AppError(
      "failed-precondition",
      `Cannot resolve ${type} in timezone ${timeZone}`,
    );
  }

  const parsed = Number.parseInt(rawValue, 10);
  if (!Number.isFinite(parsed)) {
    throw new AppError(
      "failed-precondition",
      `Cannot parse ${type} in timezone ${timeZone}`,
    );
  }

  return parsed;
}

function readZonedDateTimeParts(
  date: Date,
  timeZone: string,
): LocalDateTimeParts {
  const parts = getZonedDateTimeFormatter(timeZone).formatToParts(date);
  return {
    year: readDateTimePart(parts, "year", timeZone),
    month: readDateTimePart(parts, "month", timeZone),
    day: readDateTimePart(parts, "day", timeZone),
    hour: readDateTimePart(parts, "hour", timeZone),
    minute: readDateTimePart(parts, "minute", timeZone),
    second: readDateTimePart(parts, "second", timeZone),
  };
}

/**
 * Validate and normalize an IANA timezone string.
 * @param {unknown} value Input timezone value.
 * @param {string} field Field name for the error message.
 * @return {string} Valid IANA timezone identifier.
 */
export function requireTimeZone(
  value: unknown,
  field: string,
): string {
  const timeZone = requireNonEmptyString(value, field);
  try {
    getZonedDateTimeFormatter(timeZone).format(new Date());
  } catch {
    throw new AppError("failed-precondition", `${field} is missing or invalid`);
  }
  return timeZone;
}

/**
 * Get the timezone-local calendar date for the provided UTC instant.
 * @param {string} timeZone IANA timezone identifier.
 * @param {Date=} now Current UTC instant.
 * @return {LocalDateParts} Local year/month/day in the timezone.
 */
export function currentDateInTimeZone(
  timeZone: string,
  now: Date = new Date(),
): LocalDateParts {
  const parts = readZonedDateTimeParts(now, timeZone);
  return {
    year: parts.year,
    month: parts.month,
    day: parts.day,
  };
}

/**
 * Add calendar days to a local date.
 * @param {LocalDateParts} date Source local date.
 * @param {number} days Number of calendar days to add.
 * @return {LocalDateParts} Shifted local date.
 */
export function addDaysToLocalDate(
  date: LocalDateParts,
  days: number,
): LocalDateParts {
  const shifted = new Date(Date.UTC(date.year, date.month - 1, date.day + days));
  return {
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
  };
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
 * Get ISO weekday for a local date.
 * @param {LocalDateParts} date Local date parts.
 * @return {number} ISO weekday number (1-7).
 */
export function getIsoWeekday(date: LocalDateParts): number {
  const jsWeekday = new Date(
    Date.UTC(date.year, date.month - 1, date.day),
  ).getUTCDay();
  return toIsoWeekday(jsWeekday);
}

function zonedDateTimeToUtc(
  day: LocalDateParts,
  hour: number,
  minute: number,
  timeZone: string,
): Date {
  const desiredMs = Date.UTC(day.year, day.month - 1, day.day, hour, minute, 0, 0);
  let guessMs = desiredMs;

  for (let i = 0; i < 4; i++) {
    const actual = readZonedDateTimeParts(new Date(guessMs), timeZone);
    const actualMs = Date.UTC(
      actual.year,
      actual.month - 1,
      actual.day,
      actual.hour,
      actual.minute,
      actual.second,
      0,
    );
    const deltaMs = desiredMs - actualMs;
    if (deltaMs === 0) break;
    guessMs += deltaMs;
  }

  return new Date(guessMs);
}

/**
 * Start of the provided local day expressed as a UTC instant.
 * @param {LocalDateParts} date Source local date.
 * @param {string} timeZone IANA timezone identifier.
 * @return {Date} UTC instant corresponding to local midnight.
 */
export function startOfDay(
  date: LocalDateParts,
  timeZone: string,
): Date {
  return zonedDateTimeToUtc(date, 0, 0, timeZone);
}

/**
 * Build a UTC Date from a local calendar day + local hours/minutes in the
 * store timezone.
 * @param {LocalDateParts} day Store-local calendar day.
 * @param {number} hour Local hour from the weekly schedule.
 * @param {number} minute Local minute from the weekly schedule.
 * @param {string} timeZone IANA timezone identifier.
 * @return {Date} UTC Date corresponding to the local pickup time.
 */
export function buildPickupTime(
  day: LocalDateParts,
  hour: number,
  minute: number,
  timeZone: string,
): Date {
  return zonedDateTimeToUtc(day, hour, minute, timeZone);
}

/**
 * Build a stable date key for one calendar day.
 * @param {LocalDateParts} date Source local date.
 * @return {string} Date key in YYYY-MM-DD format.
 */
export function buildDateKey(date: LocalDateParts): string {
  const year = date.year.toString();
  const month = date.month.toString().padStart(2, "0");
  const day = date.day.toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * Build a stable date key for an instant interpreted in a specific timezone.
 * @param {Date} date UTC instant.
 * @param {string} timeZone IANA timezone identifier.
 * @return {string} Date key in YYYY-MM-DD format.
 */
export function buildDateKeyInTimeZone(
  date: Date,
  timeZone: string,
): string {
  return buildDateKey(currentDateInTimeZone(timeZone, date));
}

/**
 * Build a deterministic offer document id for one store/item/day tuple.
 * @param {string} storeId Store id.
 * @param {string} itemId Item id.
 * @param {string} dateKey Offer date in YYYY-MM-DD format.
 * @return {string} Deterministic Firestore document id.
 */
export function buildOfferDocId(
  storeId: string,
  itemId: string,
  dateKey: string,
): string {
  const compactDate = dateKey.replace(/-/g, "");
  return `${storeId}_${itemId}_${compactDate}`;
}
