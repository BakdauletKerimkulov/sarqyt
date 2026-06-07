import { getFirestore } from "firebase-admin/firestore";
import { AppError } from "../../app/error";
import { FirestoreCollections } from "../constants/constants";
import { StoreShipDoc } from "../types/store-ship-doc";

/**
 * Verify that `uid` has access to `storeId` via storeShips.
 *
 * Phase 1 fallback: if no storeShip exists, checks `stores/{storeId}.ownerId`
 * for backward compatibility with documents created before the migration.
 *
 * @param {string} uid User ID.
 * @param {string} storeId Store ID.
 * @return {Promise<StoreShipDoc>} The storeShip document data.
 */
export async function assertStoreAccess(
  uid: string,
  storeId: string,
): Promise<StoreShipDoc> {
  const db = getFirestore();
  const shipId = `${storeId}_${uid}`;
  const shipSnap = await db
    .collection(FirestoreCollections.STORE_SHIPS)
    .doc(shipId)
    .get();

  if (shipSnap.exists) {
    return shipSnap.data() as StoreShipDoc;
  }

  // Phase 1 fallback: check legacy ownerId on the store document
  const storeSnap = await db
    .collection(FirestoreCollections.STORES)
    .doc(storeId)
    .get();

  if (!storeSnap.exists) {
    throw new AppError("not-found", "Store not found");
  }

  const storeData = storeSnap.data();
  if (storeData?.ownerId !== uid) {
    throw new AppError("permission-denied", "No access to this store");
  }

  // Return a synthetic StoreShipDoc so callers can inspect role/permissions
  return {
    id: shipId,
    storeId,
    businessId: storeData.businessId ?? storeId,
    userId: uid,
    role: "owner",
    permissions: ["manage_store", "manage_orders", "manage_offers", "manage_team"],
    name: storeData.name ?? "",
    logoUrl: storeData.logoUrl ?? null,
    welcomeCompleted: true,
    hasFirstItem: true,
    createdAt: storeSnap.createTime!,
    updatedAt: storeSnap.updateTime!,
  };
}
