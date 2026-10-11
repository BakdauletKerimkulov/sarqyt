import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
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
    const collections = ["orders", "offers", "storeShips", "stores"];
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

  it("allows cancelling a readyForPickup order and stores the reason", async () => {
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 0,
      pickupEndTime: Timestamp.fromMillis(Date.now() + 60 * 60 * 1000),
    });

    await db.collection("orders").doc("order1").set({
      status: "readyForPickup",
      customerId: "cust1",
      offerId: "offer1",
      itemQuantity: 1,
    });

    await cancelOrder.run({
      auth: { uid: "cust1" },
      data: { orderId: "order1", reason: "Передумал" },
    } as never);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("cancelled");
    expect(orderSnap.data()?.cancellationReason).toBe("Передумал");
  });

  it("marks cancelledBy as store when the store cancels", async () => {
    await db.collection("stores").doc("store1").set({ ownerId: "owner1" });
    await db.collection("offers").doc("offer1").set({
      status: "active",
      quantity: 2,
    });
    await db.collection("orders").doc("order1").set({
      status: "confirmed",
      customerId: "cust1",
      storeId: "store1",
      offerId: "offer1",
      itemQuantity: 1,
    });

    await cancelOrder.run({
      auth: { uid: "owner1" },
      data: { orderId: "order1", reason: "Нет в наличии" },
    } as never);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.cancelledBy).toBe("store");
    expect(orderSnap.data()?.cancellationReason).toBe("Нет в наличии");
  });

  it("reactivates a soldOut offer when the pickup window is still open", async () => {
    const future = Timestamp.fromMillis(Date.now() + 60 * 60 * 1000);
    await db.collection("offers").doc("offer1").set({
      status: "soldOut",
      quantity: 0,
      pickupEndTime: future,
    });
    await db.collection("orders").doc("order1").set({
      status: "confirmed",
      customerId: "cust1",
      offerId: "offer1",
      itemQuantity: 1,
    });

    await cancelOrder.run({
      auth: { uid: "cust1" },
      data: { orderId: "order1" },
    } as never);

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.status).toBe("active");
    expect(offerSnap.data()?.quantity).toBe(1);
  });

  it("leaves a soldOut offer as soldOut when the pickup window already closed", async () => {
    const past = Timestamp.fromMillis(Date.now() - 60 * 60 * 1000);
    await db.collection("offers").doc("offer1").set({
      status: "soldOut",
      quantity: 0,
      pickupEndTime: past,
    });
    await db.collection("orders").doc("order1").set({
      status: "confirmed",
      customerId: "cust1",
      offerId: "offer1",
      itemQuantity: 1,
    });

    await cancelOrder.run({
      auth: { uid: "cust1" },
      data: { orderId: "order1" },
    } as never);

    const offerSnap = await db.collection("offers").doc("offer1").get();
    expect(offerSnap.data()?.status).toBe("soldOut");
    expect(offerSnap.data()?.quantity).toBe(1);
  });
});
