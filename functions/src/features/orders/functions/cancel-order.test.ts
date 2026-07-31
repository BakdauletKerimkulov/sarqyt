import * as admin from "firebase-admin";
import { afterAll, beforeEach, describe, it, expect } from "vitest";

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
process.env.GCLOUD_PROJECT = "sarqyt-cancel-order-test";

admin.initializeApp({ projectId: "sarqyt-cancel-order-test" });

const { db } = await import("../../../app/firebase");
const { cancelOrder } = await import("./cancel-order");

describe("cancelOrder", () => {
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

  it("cancels an order and restores offer quantity", async () => {
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 2,
    });

    await db.collection("orders").doc("order1").set({
      status: "preparing",
      customerId: "cust1",
      offerId: "offer1",
      itemQuantity: 3,
    });

    await cancelOrder.run({
      auth: { uid: "cust1" },
      data: { orderId: "order1" },
    } as never);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("cancelled");
    expect(orderSnap.data()?.cancelledBy).toBe("customer");

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.quantity).toBe(5);
  });
});
