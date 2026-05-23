import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db } from "../../../app/firebase";
import { logError, logInfo, logWarn } from "../../../app/logger";
import {
  FirestoreCollections,
  storeItemPath,
  UserRole,
} from "../../../shared/constants/constants";
import { StoreDoc } from "../../../shared/types/store-doc";
import { requireNonEmptyString } from "../../offers/helpers/offer-assertions";

interface DeleteItemRequest {
  storeId: string;
  itemId: string;
}

const ACTIVE_ORDER_STATUSES = ["confirmed", "preparing", "readyForPickup"];
const BATCH_LIMIT = 500;

export const deleteItem = onCall(async (req) => {
  try {
    // 1. Auth check
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const role = req.auth.token.role;
    if (role !== UserRole.PARTNER && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Insufficient permissions");
    }

    // 2. Input validation
    const data = req.data as DeleteItemRequest;
    const storeId = requireNonEmptyString(data.storeId, "storeId");
    const itemId = requireNonEmptyString(data.itemId, "itemId");

    // 3. Ownership verification
    const storeSnap = await db
      .doc(`${FirestoreCollections.STORES}/${storeId}`)
      .get();
    if (!storeSnap.exists) {
      throw new AppError("not-found", "Store not found");
    }
    const storeData = storeSnap.data() as StoreDoc;
    if (
      storeData.ownerId !== uid &&
      !(storeData.staffIds ?? []).includes(uid)
    ) {
      throw new AppError("permission-denied", "No access to this store");
    }

    // 4. Load item doc
    const itemRef = db.doc(storeItemPath(storeId, itemId));
    const itemSnap = await itemRef.get();
    if (!itemSnap.exists) {
      throw new AppError("not-found", "Item not found");
    }
    const itemData = itemSnap.data()!;

    // 5. Re-check active orders (server-side guard against race condition)
    const activeOrdersSnap = await db
      .collection(FirestoreCollections.ORDERS)
      .where("itemId", "==", itemId)
      .where("status", "in", ACTIVE_ORDER_STATUSES)
      .limit(1)
      .get();
    if (!activeOrdersSnap.empty) {
      throw new AppError(
        "failed-precondition",
        "Cannot delete: there are active reservations",
      );
    }

    // 6. Delete item doc
    await itemRef.delete();

    // 7. Batch-delete all offers with productId == itemId
    let totalOffersDeleted = 0;
    let offersSnap = await db
      .collection(FirestoreCollections.OFFERS)
      .where("productId", "==", itemId)
      .limit(BATCH_LIMIT)
      .get();

    while (!offersSnap.empty) {
      const batch = db.batch();
      for (const doc of offersSnap.docs) {
        batch.delete(doc.ref);
      }
      await batch.commit();
      totalOffersDeleted += offersSnap.size;

      if (offersSnap.size < BATCH_LIMIT) break;
      offersSnap = await db
        .collection(FirestoreCollections.OFFERS)
        .where("productId", "==", itemId)
        .limit(BATCH_LIMIT)
        .get();
    }

    // 8. Delete image from Storage (best-effort)
    const imageUrl = itemData.imageUrl as string | undefined;
    if (imageUrl) {
      try {
        const bucket = admin.storage().bucket();
        const filePath = decodeURIComponent(
          new URL(imageUrl).pathname.split("/o/")[1],
        );
        await bucket.file(filePath).delete();
      } catch (storageError) {
        logWarn("deleteItem: image cleanup failed (best-effort)", {
          storeId,
          itemId,
          imageUrl,
          error: storageError,
        });
      }
    }

    logInfo("deleteItem done", {
      storeId,
      itemId,
      offersDeleted: totalOffersDeleted,
      imageDeleted: !!imageUrl,
    });

    return { success: true };
  } catch (error) {
    logError("deleteItem failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
