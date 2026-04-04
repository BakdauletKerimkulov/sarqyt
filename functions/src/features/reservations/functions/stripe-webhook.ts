import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../helpers/stripe-client";
import Stripe from "stripe";

const stripeWebhookSecret = defineSecret("STRIPE_WEBHOOK_SECRET");

export const stripeWebhook = onRequest(
  { secrets: [stripeSecretKey, stripeWebhookSecret] },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const stripe = getStripe();
    const sig = req.headers["stripe-signature"];
    if (!sig) {
      res.status(400).send("Missing stripe-signature header");
      return;
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        sig,
        stripeWebhookSecret.value()
      );
    } catch (err) {
      console.error("Webhook signature verification failed:", err);
      res.status(400).send("Webhook signature verification failed");
      return;
    }

    if (event.type === "payment_intent.succeeded") {
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      const reservationId = paymentIntent.metadata?.reservationId;
      if (!reservationId) {
        console.error("PaymentIntent missing reservationId metadata", paymentIntent.id);
        res.status(200).send("OK (no reservationId)");
        return;
      }

      await fulfillReservation(reservationId, paymentIntent.id);
    }

    res.status(200).send("OK");
  }
);

async function fulfillReservation(
  reservationId: string,
  paymentIntentId: string
): Promise<void> {
  const reservationRef = db
    .collection(FirestoreCollections.RESERVATIONS)
    .doc(reservationId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(reservationRef);
    if (!snap.exists) {
      console.error(`Reservation ${reservationId} not found`);
      return;
    }

    const data = snap.data()!;
    if (data.status !== "pending") {
      console.warn(
        `Reservation ${reservationId} already ${data.status}, skipping`
      );
      return;
    }

    // Mark reservation as paid
    tx.update(reservationRef, { status: "paid" });

    // Read offer to get pickup times
    const offerSnap = await tx.get(
      db.collection(FirestoreCollections.OFFERS).doc(data.offerId as string)
    );
    const offerData = offerSnap.data();

    // Create order
    const orderRef = db.collection(FirestoreCollections.ORDERS).doc();
    tx.set(orderRef, {
      id: orderRef.id,
      itemId: data.itemId,
      storeId: data.storeId,
      customerId: data.customerId,
      itemName: data.itemName,
      storeName: data.storeName,
      itemImageUrl: data.itemImageUrl ?? null,
      unitPrice: data.unitPrice,
      currencyCode: data.currencyCode,
      currencySymbol: data.currencySymbol,
      itemQuantity: data.quantity,
      pickupStartTime: offerData?.pickupStartTime ?? null,
      pickupEndTime: offerData?.pickupEndTime ?? null,
      status: "confirmed",
      paymentStatus: "paid",
      paymentIntentId,
      reservationId,
      createdAt: serverTimestamp(),
    });
  });
}
