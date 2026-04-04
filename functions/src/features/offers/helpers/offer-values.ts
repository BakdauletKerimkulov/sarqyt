import { AppError } from "../../../app/error";
import { DaySchedule, WeeklySchedule } from "../types/item-doc";

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
  if (numbers.some((value) => !Number.isInteger(value))) {
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
