import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { logError, logInfo } from "../../../app/logger";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";

interface ReserveOfferRequest {
  offerId: string;
  quantity: number;
  idempotencyKey: string;
}

/** Max active (confirmed/preparing/readyForPickup) orders per user. */
const MAX_ACTIVE_ORDERS_PER_USER = 5;

/** Max items a single order can reserve. */
const MAX_QUANTITY_PER_ORDER = 5;

/**
 * Idempotent: uses idempotencyKey to prevent duplicate orders.
 * Creates an order directly without payment processing.
 */
export const reserveOffer = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new AppError("unauthenticated", "Sign in required");
  }

  const { offerId, quantity, idempotencyKey } =
    request.data as ReserveOfferRequest;
  if (!offerId || typeof offerId !== "string") {
    throw new AppError("invalid-argument", "offerId is required");
  }
  if (!quantity || typeof quantity !== "number" || quantity < 1) {
    throw new AppError("invalid-argument", "quantity must be >= 1");
  }
  if (quantity > MAX_QUANTITY_PER_ORDER) {
    throw new AppError(
      "invalid-argument",
      `quantity must be <= ${MAX_QUANTITY_PER_ORDER}`
    );
  }
  if (!idempotencyKey || typeof idempotencyKey !== "string") {
    throw new AppError("invalid-argument", "idempotencyKey is required");
  }

  // Deterministic order ID — prefixed with uid to prevent cross-user collisions
  const orderDocId = `${uid}_${idempotencyKey}`;

  try {
    const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);
    const orderRef = db.collection(FirestoreCollections.ORDERS).doc(orderDocId);

    // Check active order count BEFORE the transaction (read-only query,
    // not part of the transaction lock set — acceptable for a soft limit).
    const activeStatuses = ["confirmed", "preparing", "readyForPickup"];
    const activeSnap = await db
      .collection(FirestoreCollections.ORDERS)
      .where("customerId", "==", uid)
      .where("status", "in", activeStatuses)
      .limit(MAX_ACTIVE_ORDERS_PER_USER)
      .get();

    if (activeSnap.size >= MAX_ACTIVE_ORDERS_PER_USER) {
      throw new AppError(
        "resource-exhausted",
        `You already have ${MAX_ACTIVE_ORDERS_PER_USER} active orders`
      );
    }

    await db.runTransaction(async (tx) => {
      const [offerSnap, orderSnap] = await Promise.all([
        tx.get(offerRef),
        tx.get(orderRef),
      ]);

      // Idempotency: order already exists — return success
      if (orderSnap.exists) return;

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

      tx.update(offerRef, { quantity: available - quantity });

      const unitPrice = typeof offer.price === "number" ?
        offer.price :
        (offer.price as { amount: number }).amount;

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

    logInfo("reserveOffer done", { orderId: orderDocId, offerId });
    return { success: true, orderId: orderDocId };
  } catch (error) {
    logError("reserveOffer failed", { error, uid });
    throw toHttpsError(error);
  }
});
