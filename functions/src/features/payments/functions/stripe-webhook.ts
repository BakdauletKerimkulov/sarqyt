import { FieldValue } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { db, serverTimestamp } from "../../../app/firebase";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { getStripe, stripeSecretKey } from "../../../shared/helpers/stripe-client";
import { logError, logInfo } from "../../../app/logger";
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
      logError("Webhook signature verification failed", { error: err });
      res.status(400).send("Webhook signature verification failed");
      return;
    }

    const paymentIntent = event.data.object as Stripe.PaymentIntent;
    const offerId = paymentIntent.metadata?.offerId;
    const quantity = parseInt(paymentIntent.metadata?.quantity ?? "0", 10);

    if (event.type === "payment_intent.succeeded") {
      if (!offerId) {
        res.status(200).send("OK (no offerId)");
        return;
      }

      const uid = paymentIntent.metadata?.firebaseUID;
      const storeId = paymentIntent.metadata?.storeId;

      // Read offer for order data
      const offerSnap = await db
        .collection(FirestoreCollections.OFFERS)
        .doc(offerId)
        .get();
      const offer = offerSnap.data();

      // Create order
      const orderRef = db.collection(FirestoreCollections.ORDERS).doc();
      await orderRef.set({
        id: orderRef.id,
        itemId: offer?.productId ?? null,
        storeId: storeId ?? offer?.storeId ?? null,
        customerId: uid ?? null,
        itemName: offer?.name ?? "Unknown",
        storeName: offer?.storeName ?? "Unknown",
        itemImageUrl: offer?.productImage ?? null,
        unitPrice: offer?.price ?? 0,
        currencyCode: offer?.currencyCode ?? "KZT",
        currencySymbol: offer?.currencySymbol ?? "₸",
        itemQuantity: quantity,
        pickupStartTime: offer?.pickupStartTime ?? null,
        pickupEndTime: offer?.pickupEndTime ?? null,
        status: "confirmed",
        paymentStatus: "paid",
        paymentIntentId: paymentIntent.id,
        offerId,
        createdAt: serverTimestamp(),
      });

      logInfo("Order created", { orderId: orderRef.id, offerId });
    }

    if (event.type === "payment_intent.canceled") {
      // Restore offer quantity
      if (offerId && quantity > 0) {
        await db
          .collection(FirestoreCollections.OFFERS)
          .doc(offerId)
          .update({ quantity: FieldValue.increment(quantity) });

        logInfo("Quantity restored (payment canceled)", { offerId, quantity });
      }
    }

    res.status(200).send("OK");
  }
);
