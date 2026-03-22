import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { toStoreDraftDoc } from "../mappers/store-draft-mapper";
import { StoreDraftRequestDto } from "../types/store-draft-request-dto";
import { validateMerchantData } from "../validators/merchant-data-validator";

export const startMerchantOnboardingData = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError(
        "failed-precondition",
        "This step only for authenticated users",
      );
    }

    const reqData = req.data as StoreDraftRequestDto;
    const userRecord = await admin.auth().getUser(req.auth.uid);
    logInfo(`request data: ${reqData}`);

    const validationError = validateMerchantData(reqData);
    if (validationError !== null) {
      throw new HttpsError("invalid-argument", validationError);
    }

    const uid = userRecord.uid;
    const storeId = db.collection(FirestoreCollections.STORES).doc().id;
    const draftRef = db.collection(FirestoreCollections.STORE_DRAFTS).doc();
    const draftDoc = toStoreDraftDoc(reqData, uid);
    const userRef = db.collection(FirestoreCollections.USERS).doc(uid);

    const now = serverTimestamp();

    const batch = db.batch();
    batch.set(draftRef, { ...draftDoc, storeId });
    batch.set(userRef,
      {
        uid: uid,
        email: userRecord.email ?? null,
        userName: userRecord.displayName ?? null,
        phoneNumber: userRecord.phoneNumber ?? null,
        createdAt: now,
        updatedAt: now,
      }, { merge: true });
    await batch.commit();

    return { success: true, draftId: draftRef.id, storeId };
  } catch (error) {
    logError("startMerchantOnboarding failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
