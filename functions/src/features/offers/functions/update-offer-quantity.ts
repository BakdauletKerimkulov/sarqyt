import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";

interface UpdateOfferQuantityRequest {
  offerId: string;
  quantity: number;
}

/**
 * Updates offer quantity in real-time. Only store owner/staff can call.
 * Idempotent: sets absolute quantity (not increment).
 */
export const updateOfferQuantity = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const { offerId, quantity } = req.data as UpdateOfferQuantityRequest;

    if (!offerId) throw new AppError("invalid-argument", "offerId required");
    if (typeof quantity !== "number" || quantity < 0) {
      throw new AppError("invalid-argument", "quantity must be >= 0");
    }

    const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);
    const offerSnap = await offerRef.get();
    if (!offerSnap.exists) throw new AppError("not-found", "Offer not found");

    const offer = offerSnap.data()!;
    const storeId = offer.storeId as string;

    await assertStoreAccess(uid, storeId);

    await offerRef.update({ quantity });

    logInfo("updateOfferQuantity done", { offerId, quantity });
    return { success: true };
  } catch (error) {
    logError("updateOfferQuantity failed", { error });
    throw toHttpsError(error);
  }
});
