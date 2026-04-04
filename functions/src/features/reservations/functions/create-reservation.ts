import { Timestamp } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { logError } from "../../../app/logger";
import { db } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../helpers/stripe-client";
import { CreateReservationRequest, ReservationDoc } from "../types/reservation-types";

const RESERVATION_TTL_MINUTES = 15;

export const createReservation = onCall(
  { secrets: [stripeSecretKey] },
  async (request) => {
    // 1. Auth check
    const uid = request.auth?.uid;
    if (!uid) {
      throw new AppError("unauthenticated", "Sign in required");
    }

    // 2. Parse & validate input
    const { offerId, quantity } = request.data as CreateReservationRequest;
    if (!offerId || typeof offerId !== "string") {
      throw new AppError("invalid-argument", "offerId is required");
    }
    if (!quantity || typeof quantity !== "number" || quantity < 1) {
      throw new AppError("invalid-argument", "quantity must be >= 1");
    }

    try {
      const stripe = getStripe();
      const offerRef = db.collection(FirestoreCollections.OFFERS).doc(offerId);
      const reservationRef = db.collection(FirestoreCollections.RESERVATIONS).doc();

      // 3. Transaction: validate offer & decrement quantity
      const reservationData = await db.runTransaction(async (tx) => {
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

        // Decrement quantity atomically
        tx.update(offerRef, { quantity: available - quantity });

        const now = Timestamp.now();
        const expiresAt = Timestamp.fromMillis(
          now.toMillis() + RESERVATION_TTL_MINUTES * 60 * 1000
        );

        const unitPrice = typeof offer.price === "number" ? offer.price :
          (offer.price as { amount: number }).amount;

        const doc: Omit<ReservationDoc, "paymentIntentId"> & { paymentIntentId: string | null } = {
          offerId,
          storeId: offer.storeId as string,
          customerId: uid,
          itemId: offer.productId as string,
          itemName: offer.name as string,
          storeName: offer.storeName as string,
          itemImageUrl: (offer.productImage as string) ?? null,
          unitPrice,
          currencyCode: (offer.currencyCode as string) ?? "KZT",
          currencySymbol: (offer.currencySymbol as string) ?? "\u20B8",
          quantity,
          status: "pending",
          paymentIntentId: null,
          createdAt: now,
          expiresAt,
        };

        tx.set(reservationRef, doc);

        return {
          reservationId: reservationRef.id,
          unitPrice,
          currencyCode: doc.currencyCode,
          storeId: doc.storeId,
          storeName: doc.storeName,
        };
      });

      // 4. Get or create Stripe Customer
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

      // 5. Create Stripe Ephemeral Key
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: stripeCustomerId },
        { apiVersion: "2026-03-25.dahlia" }
      );

      // 6. Create Stripe PaymentIntent (amount in smallest currency unit, e.g. tiyn for KZT)
      const totalAmount = Math.round(reservationData.unitPrice * quantity * 100);
      const paymentIntent = await stripe.paymentIntents.create({
        amount: totalAmount,
        currency: reservationData.currencyCode.toLowerCase(),
        customer: stripeCustomerId,
        metadata: {
          reservationId: reservationData.reservationId,
          offerId,
          storeId: reservationData.storeId,
          firebaseUID: uid,
        },
      });

      // 7. Update reservation with paymentIntentId
      await reservationRef.update({
        paymentIntentId: paymentIntent.id,
      });

      return {
        reservationId: reservationData.reservationId,
        paymentIntentClientSecret: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        stripeCustomerId,
      };
    } catch (error) {
      logError("createReservation failed", { error, uid });
      throw toHttpsError(error);
    }
  }
);
