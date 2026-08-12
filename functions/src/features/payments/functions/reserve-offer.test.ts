import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { afterAll, beforeEach, describe, it, expect } from "vitest";

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
process.env.GCLOUD_PROJECT = "sarqyt-reserve-offer-test";

admin.initializeApp({ projectId: "sarqyt-reserve-offer-test" });

const { db } = await import("../../../app/firebase");
const { reserveOffer } = await import("./reserve-offer");

describe("reserveOffer", () => {
  afterAll(async () => {
    await admin.app().delete();
  });

  beforeEach(async () => {
    const collections = ["orders", "offers"];
    for (const name of collections) {
      const snap = await db.collection(name).get();
      await Promise.all(snap.docs.map((doc) => doc.ref.delete()));
    }
  });

  it("rejects an offer whose pickup window already closed", async () => {
    const past = Timestamp.fromMillis(Date.now() - 60 * 60 * 1000);
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 2,
      price: 100,
      pickupEndTime: past,
    });

    await expect(
      reserveOffer.run({
        auth: { uid: "cust1" },
        data: { offerId: "offer1", quantity: 1, idempotencyKey: "k1" },
      } as never)
    ).rejects.toThrow(/Pickup window has closed/);

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.quantity).toBe(2);
  });

  it("marks the offer soldOut when quantity reaches zero", async () => {
    const future = Timestamp.fromMillis(Date.now() + 60 * 60 * 1000);
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 1,
      price: 100,
      pickupEndTime: future,
    });

    const res = (await reserveOffer.run({
      auth: { uid: "cust1" },
      data: { offerId: "offer1", quantity: 1, idempotencyKey: "k1" },
    } as never)) as { orderId: string };

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.quantity).toBe(0);
    expect(offerSnap.data()?.status).toBe("soldOut");

    const orderSnap = await db.collection("orders").doc(res.orderId).get();
    expect(orderSnap.data()?.status).toBe("confirmed");
    expect(orderSnap.data()?.paymentStatus).toBeUndefined();
  });

  it("is idempotent for the same idempotencyKey", async () => {
    const future = Timestamp.fromMillis(Date.now() + 60 * 60 * 1000);
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 5,
      price: 100,
      pickupEndTime: future,
    });

    const first = (await reserveOffer.run({
      auth: { uid: "cust1" },
      data: { offerId: "offer1", quantity: 2, idempotencyKey: "same-key" },
    } as never)) as { orderId: string };
    const second = (await reserveOffer.run({
      auth: { uid: "cust1" },
      data: { offerId: "offer1", quantity: 2, idempotencyKey: "same-key" },
    } as never)) as { orderId: string };

    expect(second.orderId).toBe(first.orderId);

    // Quantity decremented only once — the second call short-circuited on
    // the existing order doc without re-touching the offer.
    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.quantity).toBe(3);

    const ordersSnap = await db
      .collection("orders")
      .where("offerId", "==", "offer1")
      .get();
    expect(ordersSnap.size).toBe(1);
  });
});
