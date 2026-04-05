import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { logError } from "../../../app/logger";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../../../shared/helpers/stripe-client";

interface CreatePaymentRequest {
  offerId: string;
  quantity: number;
}

/**
 * Validates offer, decrements quantity atomically, creates Stripe PaymentIntent.
 * No reservation collection — quantity held in offer directly.
 * If payment fails, webhook payment_intent.canceled restores quantity.
 */
export const createPayment = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new AppError("unauthenticated", "Sign in required");
    }

    const { offerId, quantity } = request.data as CreatePaymentRequest;
    if (!offerId || typeof offerId !== "string") {
      throw new AppError("invalid-argument", "offerId is required");
    }
    if (!quantity || typeof quantity !== "number" || quantity < 1) {
      throw new AppError("invalid-argument", "quantity must be >= 1");
    }

    try {
      const stripe = getStripe();
      const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);

      // Transaction: validate offer & decrement quantity
      const offerData = await db.runTransaction(async (tx) => {
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

        tx.update(offerRef, { quantity: available - quantity });

        const unitPrice = typeof offer.price === "number" ?
          offer.price :
          (offer.price as { amount: number }).amount;

        return {
          unitPrice,
          currencyCode: (offer.currencyCode as string) ?? "KZT",
          storeId: offer.storeId as string,
          storeName: offer.storeName as string,
          itemId: offer.productId as string,
          itemName: offer.name as string,
          itemImageUrl: (offer.productImage as string) ?? null,
          currencySymbol: (offer.currencySymbol as string) ?? "\u20B8",
          pickupStartTime: offer.pickupStartTime ?? null,
          pickupEndTime: offer.pickupEndTime ?? null,
        };
      });

      // Get or create Stripe Customer
      const userRef = db.collection(FirestoreCollections.USERS).doc(uid);
      const userSnap = await userRef.get();
      const userData = userSnap.data();
      let stripeCustomerId = userData?.stripeCustomerId as string | undefined;

      if (!stripeCustomerId) {
        const customer = await stripe.customers.create({
          metadata: { firebaseUID: uid },
          email: userData?.email as string | undefined,
        });
        stripeCustomerId = customer.id;
        await userRef.set({ stripeCustomerId }, { merge: true });
      }

      // Ephemeral Key
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: stripeCustomerId },
        { apiVersion: "2026-03-25.dahlia" }
      );

      // PaymentIntent (amount in smallest currency unit)
      const totalAmount = Math.round(offerData.unitPrice * quantity * 100);
      const paymentIntent = await stripe.paymentIntents.create({
        amount: totalAmount,
        currency: offerData.currencyCode.toLowerCase(),
        customer: stripeCustomerId,
        metadata: {
          offerId,
          quantity: quantity.toString(),
          storeId: offerData.storeId,
          firebaseUID: uid,
        },
      });

      return {
        paymentIntentId: paymentIntent.id,
        paymentIntentClientSecret: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        stripeCustomerId,
      };
    } catch (error) {
      logError("createPayment failed", { error, uid });
      throw toHttpsError(error);
    }
  }
);
