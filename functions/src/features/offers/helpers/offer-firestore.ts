import { Timestamp } from "firebase-admin/firestore";
import { AppError } from "../../../app/error";

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
  return value instanceof Timestamp && value.toMillis() === expected.toMillis();
}
