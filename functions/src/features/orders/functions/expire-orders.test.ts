import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { beforeAll, afterAll, beforeEach, describe, it, expect } from "vitest";

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
process.env.GCLOUD_PROJECT = "sarqyt-expire-orders-test";

admin.initializeApp({ projectId: "sarqyt-expire-orders-test" });

const { db } = await import("../../../app/firebase");
const { expireOrders } = await import("./expire-orders");

describe("expireOrders", () => {
  beforeAll(async () => {
    // Smoke-checks the real transaction against the Firestore emulator —
    // per testing.md, server functions are never tested against a mocked
    // SDK client.
  });

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

  it("expires a preparing order past its pickup window and restores offer quantity", async () => {
    const past = Timestamp.fromMillis(Date.now() - 60 * 60 * 1000);

    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 2,
      pickupEndTime: past,
    });

    await db.collection("orders").doc("order1").set({
      status: "preparing",
      pickupEndTime: past,
      offerId: "offer1",
      itemQuantity: 3,
    });

    await expireOrders.run({} as never);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("expired");

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.quantity).toBe(5);
  });
});
