import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import { CreateOfferRequest } from "./types/create_offer_request";
import { ProductFromDb, StoreFromDb } from "./types/db_documnet_interfaces";

const db = admin.firestore();

/** Создает новый оффер, передавая идентификатор продукта и
 * необходимое количество оффера
 */
export const createOffer = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required");
  }

  const userId = request.auth.uid;
  const userRole = request.auth.token.role;

  if (userRole !== "owner" && userRole !== "manager") {
    throw new HttpsError("permission-denied", "Insuffisient permissions");
  }

  const offerRequestData = request.data as CreateOfferRequest;

  validateOfferRequest(offerRequestData);

  try {
    const { storeId, productId, quantity, pickupStart, pickupEnd } = offerRequestData;

    const storeSnapshot = await db.doc(`stores/${storeId}`).get();

    if (!storeSnapshot.exists) {
      throw new HttpsError("not-found", "Store not found");
    }

    const storeData = storeSnapshot.data() as StoreFromDb;

    if (storeData.ownerId !== userId && !storeData.staffIds?.includes(userId)) {
      throw new HttpsError("permission-denied", "No access to this store");
    }

    const productSnapshot = await db.doc(`stores/${storeId}/products/${productId}`).get();

    if (!productSnapshot.exists) {
      throw new HttpsError("not-found", "Product not found");
    }

    const productData = productSnapshot.data() as ProductFromDb;

    const pickupStartTime = new Date(pickupStart);
    const pickupEndTime = new Date(pickupEnd);

    const createdAt = FieldValue.serverTimestamp();

    const offerRef = db.collection("offers").doc();

    const newOfferData = {
      storeId: storeData.id,
      productId: productData.id,
      quantity: quantity,
      name: productData.name,
      price: productData.money,
      pickupStartTime: Timestamp.fromDate(pickupStartTime),
      pickupEndTime: Timestamp.fromDate(pickupEndTime),
      createdAt: createdAt,
      status: "active",
    };

    await offerRef.set(newOfferData);
    logger.info(`Offer created: ${offerRef.id}`);
    return { success: true };
  } catch (error) {
    logger.error("Offer creating error", error);
    throw new HttpsError("internal", "Could not create offer");
  }
});

function validateOfferRequest(offerRequest: CreateOfferRequest) {
  if (!offerRequest.productId) {
    throw new HttpsError("invalid-argument", "ProductId required");
  }

  if (!offerRequest.storeId) {
    throw new HttpsError("invalid-argument", "StoreId requierd");
  }

  if (!offerRequest.quantity || offerRequest.quantity <= 0) {
    throw new HttpsError("invalid-argument", "Quantity must be > 0");
  }
}
