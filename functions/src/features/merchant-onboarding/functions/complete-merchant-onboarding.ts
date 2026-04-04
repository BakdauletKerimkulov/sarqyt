import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { auth, db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections, UserRole } from "../../../shared/constants/constants";
import { StoreDraftDoc } from "../types/store-draft-doc";

interface CompleteMerchantOnboardingResponseDto {
  success: true;
  storeId: string;
}

export const completeMerchantOnboarding = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }

    const uid = req.auth.uid;
    const userRecord = await auth.getUser(uid);

    if (!userRecord.emailVerified) {
      throw new AppError("failed-precondition", "Email must be verified");
    }

    if (userRecord.email == null) {
      throw new AppError("failed-precondition", "User email is missing");
    }

    // Check if user already has an active store (idempotency guard)
    const existingStoreShip = await db
      .collection(FirestoreCollections.STORE_SHIPS)
      .where("userId", "==", uid)
      .where("status", "==", "active")
      .limit(1)
      .get();

    if (!existingStoreShip.empty) {
      const existing = existingStoreShip.docs[0].data();
      return { success: true, storeId: existing.storeId } as CompleteMerchantOnboardingResponseDto;
    }

    // Find pending draft (created during startMerchantOnboarding)
    const draftQuery = db
      .collection(FirestoreCollections.STORE_DRAFTS)
      .where("ownerId", "==", uid)
      .where("status", "==", "pending")
      .limit(1);
    const draftSnapshot = await draftQuery.get();

    if (draftSnapshot.empty) {
      throw new AppError("not-found", "Store draft not found");
    }

    const draftDocumentSnapshot = draftSnapshot.docs[0];
    const draftRef = draftDocumentSnapshot.ref;
    const draftDoc = draftDocumentSnapshot.data() as StoreDraftDoc;
    const storeId = draftDoc.storeId;
    if (!storeId) {
      throw new AppError("not-found", "Store ID missing from draft");
    }
    const now = serverTimestamp();

    const userRef = db.collection(FirestoreCollections.USERS).doc(uid);
    const storeRef = db.collection(FirestoreCollections.STORES).doc(storeId);

    const userDoc = {
      uid: uid,
      displayName: userRecord.displayName ?? null,
      email: userRecord.email,
      avatarUrl: userRecord.photoURL ?? null,
      preferences: {
        vegetarian: false,
        halal: false,
      },
      favorites: [],
      stats: {
        savedMoney: 0,
      },
      role: UserRole.PARTNER,
      updatedAt: now,
    };

    const businessId = storeId;
    const businessRef = db.collection(FirestoreCollections.BUSINESSES).doc(businessId);

    const businessDoc = {
      id: businessId,
      ownerId: uid,
      name: draftDoc.storeName,
      plan: "free",
      commissionRate: 0.15,
      createdAt: now,
      updatedAt: now,
    };

    const storeDoc = {
      id: storeId,
      ownerId: uid,
      businessId: businessId,
      name: draftDoc.storeName,
      location: {
        address: draftDoc.location.address,
        geo: draftDoc.location.geo,
      },
      storeType: draftDoc.storeType,
      phoneNumber: draftDoc.phoneNumber,
      staffIds: [],
      isVisible: true,
      avgRating: 0,
      createdAt: now,
      updatedAt: now,
    };

    const storeShipRef = db
      .collection(FirestoreCollections.STORE_SHIPS)
      .doc(`${storeId}_${uid}`);

    const storeShipDoc = {
      storeId,
      businessId,
      userId: uid,
      storeRole: "owner",
      name: draftDoc.storeName,
      logoUrl: null,
      status: "active",
      onboardingStatus: "storeCreated",
      permissions: ["manage_store", "manage_orders", "manage_offers"],
      createdAt: now,
      updatedAt: now,
    };

    const batch = db.batch();
    batch.set(userRef, userDoc, { merge: true });
    batch.set(businessRef, businessDoc);
    batch.set(storeRef, storeDoc);
    batch.set(storeShipRef, storeShipDoc);
    batch.set(
      draftRef,
      {
        status: "consumed",
        consumedAt: now,
        consumedByUid: uid,
        storeId: storeId,
        updatedAt: now,
      },
      { merge: true },
    );

    await batch.commit();

    await auth.setCustomUserClaims(uid, {
      role: UserRole.PARTNER,
      canCreateStore: true,
    });

    logInfo("completeMerchantOnboarding success", {
      uid: uid,
      storeId: storeId,
    });

    const response: CompleteMerchantOnboardingResponseDto = {
      success: true,
      storeId: storeId,
    };
    return response;
  } catch (error) {
    logError("completeMerchantOnboarding failed", { error: error, data: req.data });
    throw toHttpsError(error);
  }
});
