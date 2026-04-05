import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { logError, logInfo } from "../../../app/logger";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";

interface ReserveOfferRequest {
  offerId: string;
  quantity: number;
}

/**
 * Creates an order directly without payment processing.
 * Used for testing with real restaurants before payment system is ready.
 * Decrements offer quantity atomically.
 */
export const reserveOffer = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new AppError("unauthenticated", "Sign in required");
  }

  const { offerId, quantity } = request.data as ReserveOfferRequest;
  if (!offerId || typeof offerId !== "string") {
    throw new AppError("invalid-argument", "offerId is required");
  }
  if (!quantity || typeof quantity !== "number" || quantity < 1) {
    throw new AppError("invalid-argument", "quantity must be >= 1");
  }

  try {
    const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);
    const orderRef = db.collection(FirestoreCollections.ORDERS).doc();

    await db.runTransaction(async (tx) => {
      const offerSnap = await tx.get(offerRef);
      if (!offerSnap.exists) {
        throw new AppError("not-found", "Offer not found");
      }

      const offer = offerSnap.data()!;
      if (offer.status !== "active") {
        throw new AppError("failed-precondition", "Offer is not active");
      }

      const available = (offer.quantity as number) ?? 0;
      if (available < quantity) {
        throw new AppError(
          "failed-precondition",
          `Only ${available} items available, requested ${quantity}`
        );
      }

      // Decrement quantity
      tx.update(offerRef, { quantity: available - quantity });

      const unitPrice = typeof offer.price === "number" ?
        offer.price :
        (offer.price as { amount: number }).amount;

      // Create order directly
      tx.set(orderRef, {
        id: orderRef.id,
        itemId: offer.productId ?? null,
        storeId: offer.storeId ?? null,
        customerId: uid,
        itemName: offer.name ?? "Unknown",
        storeName: offer.storeName ?? "Unknown",
        itemImageUrl: offer.productImage ?? null,
        unitPrice,
        currencyCode: offer.currencyCode ?? "KZT",
        currencySymbol: offer.currencySymbol ?? "₸",
        itemQuantity: quantity,
        pickupStartTime: offer.pickupStartTime ?? null,
        pickupEndTime: offer.pickupEndTime ?? null,
        status: "confirmed",
        paymentStatus: "paid",
        offerId,
        createdAt: serverTimestamp(),
      });
    });

    logInfo("reserveOffer done", { orderId: orderRef.id, offerId });
    return { success: true, orderId: orderRef.id };
  } catch (error) {
    logError("reserveOffer failed", { error, uid });
    throw toHttpsError(error);
  }
});
