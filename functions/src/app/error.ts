import { FunctionsErrorCode, HttpsError } from "firebase-functions/v2/https";

export class AppError extends Error {
  constructor(
    public readonly code: FunctionsErrorCode,
    message: string,
    public readonly details?: unknown,
  ) {
    super(message);
    this.name = "AppError";
  }
}

export function toHttpsError(error: unknown): HttpsError {
  if (error instanceof HttpsError) {
    return error;
  }

  if (error instanceof AppError) {
    return new HttpsError(error.code, error.message, error.details);
  }

  return new HttpsError("internal", "Unexpected server error");
}
