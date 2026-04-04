import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { logError, logInfo } from "../../../app/logger";
import { UserRole } from "../../../shared/constants/constants";
import { requireNonEmptyString } from "../helpers/offer-helpers";
import {
  buildExpectedOffers,
  diffAndApply,
  loadAndValidate,
} from "../services/sync-offers-service";
import { SincOffersRequest } from "../types/sinc-offers-request";

/**
 * Cloud Function handler: synchronize offers for one item for the next 7 days.
 * Validates auth/ownership, delegates business logic to the service layer.
 * @return {Promise<{ created: number, updated: number, paused: number }>}
 */
export const sincItemOffers = onCall(async (req) => {
  try {
    // --- Auth ---
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const role = req.auth.token.role;
    if (role !== UserRole.PARTNER && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Insufficient permissions");
    }

    // --- Parse input ---
    const data = (req.data ?? {}) as Partial<SincOffersRequest>;
    const storeId = requireNonEmptyString(data.storeId, "storeId");
    const itemId = requireNonEmptyString(data.itemId, "itemId");

    // --- Load & validate docs + ownership ---
    const { itemData, storeData } = await loadAndValidate(storeId, itemId, uid);

    // --- Build expected offers from schedule ---
    const { expectedByDate, storeTimeZone, utcNow, rangeStart, rangeEnd } =
      buildExpectedOffers(storeId, itemId, itemData, storeData);

    // --- Diff against existing and apply batch ---
    const result = await diffAndApply({
      storeId,
      itemId,
      uid,
      expectedByDate,
      storeTimeZone,
      utcNow,
      rangeStart,
      rangeEnd,
    });

    logInfo("sincItemOffers done", { storeId, itemId, ...result });
    return result;
  } catch (error) {
    logError("sincItemOffers failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
