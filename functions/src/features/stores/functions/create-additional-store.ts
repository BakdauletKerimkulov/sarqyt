import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections, UserRole } from "../../../shared/constants/constants";

interface CreateAdditionalStoreRequest {
  name: string;
  storeType: string;
  address: {
    country: { name: string; isoCode: string };
    address: string;
    locality: string;
    postalCode: string;
  };
  geo: {
    geohash: string;
    geopoint: { latitude: number; longitude: number };
    timezone?: string;
  };
  phoneNumber: string;
  businessId: string;
}

/**
 * Creates an additional store for an existing partner.
 * Requires: partner role, canCreateStore claim, business_membership for businessId.
 * Idempotency: generates a new storeId each call (no deterministic ID).
 */
export const createAdditionalStore = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const role = req.auth.token.role;
    const canCreate = req.auth.token.canCreateStore;

    if (role !== UserRole.PARTNER && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Only partners can create stores");
    }
    if (canCreate !== true && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Store creation not allowed");
    }

    const data = req.data as CreateAdditionalStoreRequest;
    if (!data.name || typeof data.name !== "string") {
      throw new AppError("invalid-argument", "name is required");
    }
    if (!data.businessId || typeof data.businessId !== "string") {
      throw new AppError("invalid-argument", "businessId is required");
    }
    if (!data.phoneNumber || typeof data.phoneNumber !== "string") {
      throw new AppError("invalid-argument", "phoneNumber is required");
    }
    if (!data.address || !data.geo) {
      throw new AppError("invalid-argument", "address and geo are required");
    }

    // Verify business_membership
    const membershipSnap = await db
      .collection(FirestoreCollections.BUSINESSES_MEMBERSHIP)
      .doc(`${data.businessId}_${uid}`)
      .get();
    if (!membershipSnap.exists) {
      throw new AppError("permission-denied", "No membership for this business");
    }

    const now = serverTimestamp();
    const storeRef = db.collection(FirestoreCollections.STORES).doc();
    const storeId = storeRef.id;

    const storeDoc = {
      id: storeId,
      ownerId: uid,
      businessId: data.businessId,
      name: data.name,
      location: {
        address: data.address,
        geo: data.geo,
      },
      storeType: data.storeType ?? null,
      phoneNumber: data.phoneNumber,
      isVisible: true,
      avgRating: 0,
      createdAt: now,
      updatedAt: now,
    };

    const shipId = `${storeId}_${uid}`;
    const storeShipRef = db
      .collection(FirestoreCollections.STORE_SHIPS)
      .doc(shipId);

    const storeShipDoc = {
      id: shipId,
      storeId,
      businessId: data.businessId,
      userId: uid,
      role: "owner",
      storeRole: "owner", // backward compat — Phase 1
      name: data.name,
      logoUrl: null,
      permissions: ["manage_store", "manage_orders", "manage_offers", "manage_team"],
      welcomeCompleted: false,
      hasFirstItem: false,
      createdAt: now,
      updatedAt: now,
    };

    const batch = db.batch();
    batch.set(storeRef, storeDoc);
    batch.set(storeShipRef, storeShipDoc);
    await batch.commit();

    logInfo("createAdditionalStore done", { uid, storeId, businessId: data.businessId });
    return { success: true, storeId };
  } catch (error) {
    logError("createAdditionalStore failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
