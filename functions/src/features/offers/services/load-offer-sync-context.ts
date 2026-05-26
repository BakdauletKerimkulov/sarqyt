import { AppError } from "../../../app/error";
import { db } from "../../../app/firebase";
import {
  FirestoreCollections,
  storeItemPath,
} from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "../types/item-doc";
import { ValidatedOfferSyncContext } from "../types/offer-sync";

/**
 * Load and validate item + store documents from Firestore.
 * @param {string} storeId Store document ID.
 * @param {string} itemId Item document ID.
 * @param {string} uid Authenticated user ID.
 * @return {Promise<ValidatedOfferSyncContext>} Validated item/store pair.
 */
export async function loadAndValidate(
  storeId: string,
  itemId: string,
  uid: string,
): Promise<ValidatedOfferSyncContext> {
  const [itemSnap, storeSnap] = await Promise.all([
    db.doc(storeItemPath(storeId, itemId)).get(),
    db.doc(`${FirestoreCollections.STORES}/${storeId}`).get(),
  ]);

  if (!itemSnap.exists) {
    throw new AppError("not-found", "Item not found");
  }
  if (!storeSnap.exists) {
    throw new AppError("not-found", "Store not found");
  }

  // Auth: verify store access via storeShips (with ownerId fallback)
  await assertStoreAccess(uid, storeId);

  const itemData = itemSnap.data() as ItemDoc;
  const storeData = storeSnap.data() as StoreDoc;

  return { itemData, storeData };
}
