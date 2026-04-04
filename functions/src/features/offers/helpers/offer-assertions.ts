import { AppError } from "../../../app/error";

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
