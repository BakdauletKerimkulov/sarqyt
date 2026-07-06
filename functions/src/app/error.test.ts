import { describe, expect, it } from "vitest";
import { HttpsError } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "./error.js";

describe("toHttpsError", () => {
  it("preserves code, message, and details for AppError", () => {
    const appError = new AppError("not-found", "Item not found", {
      itemId: "abc",
    });
    const result = toHttpsError(appError);

    expect(result).toBeInstanceOf(HttpsError);
    expect(result.code).toBe("not-found");
    expect(result.message).toBe("Item not found");
    expect(result.details).toEqual({ itemId: "abc" });
  });

  it("returns HttpsError as-is", () => {
    const httpsError = new HttpsError("permission-denied", "No access");
    const result = toHttpsError(httpsError);

    expect(result).toBe(httpsError);
  });

  it("includes original message for plain Error", () => {
    const plainError = new Error("The query requires an index");
    const result = toHttpsError(plainError);

    expect(result).toBeInstanceOf(HttpsError);
    expect(result.code).toBe("internal");
    expect(result.message).toContain("The query requires an index");
  });

  it("includes stringified value for non-Error thrown value", () => {
    const result = toHttpsError("something broke");

    expect(result).toBeInstanceOf(HttpsError);
    expect(result.code).toBe("internal");
    expect(result.message).toContain("something broke");
  });
});
