import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";

export const skipOptionalOnboarding = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }

    const uid = req.auth.uid;
    const storeId = req.data?.storeId;

    if (!storeId || typeof storeId !== "string") {
      throw new AppError("invalid-argument", "storeId is required");
    }

    const compositeId = `${storeId}_${uid}`;
    const storeShipRef = db
      .collection(FirestoreCollections.STORE_SHIPS)
      .doc(compositeId);

    const storeShipDoc = await storeShipRef.get();
    if (!storeShipDoc.exists) {
      throw new AppError("not-found", `No store ship found for ${compositeId}`);
    }

    await storeShipRef.update({ onboardingStatus: "completed" });

    logInfo("skipOptionalOnboarding success", { uid });

    return { success: true };
  } catch (error) {
    logError("skipOptionalOnboarding failed", { error });
    throw toHttpsError(error);
  }
});
