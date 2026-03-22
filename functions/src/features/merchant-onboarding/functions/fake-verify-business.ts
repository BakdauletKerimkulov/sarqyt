import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections, UserRole } from "../../../shared/constants/constants";

export const fakeVerifyBusiness = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }

    const role = req.auth.token.role;
    if (role !== UserRole.PARTNER && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Only partners or admins can verify");
    }

    const businessId = req.data?.businessId;
    if (typeof businessId !== "string" || businessId.length === 0) {
      throw new AppError("invalid-argument", "businessId is required");
    }

    const businessRef = db.collection(FirestoreCollections.BUSINESSES).doc(businessId);
    const snap = await businessRef.get();
    if (!snap.exists) {
      throw new AppError("not-found", `Business ${businessId} not found`);
    }

    logInfo("fakeVerifyBusiness: starting simulated verification", {
      uid: req.auth.uid,
      businessId,
    });

    // Simulate external government service verification delay (25 seconds)
    await new Promise((r) => setTimeout(r, 25000));

    await businessRef.update({
      verificationStatus: "verified",
      type: "company",
      paymentAccountId: `fake_acc_${businessId}_${Date.now()}`,
      updatedAt: serverTimestamp(),
    });

    logInfo("fakeVerifyBusiness: success", { businessId });

    return { success: true };
  } catch (error) {
    logError("fakeVerifyBusiness failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
