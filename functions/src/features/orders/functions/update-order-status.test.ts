import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { afterAll, beforeEach, describe, it, expect } from "vitest";

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
process.env.GCLOUD_PROJECT = "sarqyt-update-order-status-test";

admin.initializeApp({ projectId: "sarqyt-update-order-status-test" });

const { db } = await import("../../../app/firebase");
const { updateOrderStatus } = await import("./update-order-status");

describe("updateOrderStatus", () => {
  afterAll(async () => {
    await admin.app().delete();
  });

  beforeEach(async () => {
    const collections = ["orders", "stores"];
    for (const name of collections) {
      const snap = await db.collection(name).get();
      await Promise.all(snap.docs.map((doc) => doc.ref.delete()));
    }
  });

  async function seedStoreAndOrder(overrides: Record<string, unknown>) {
    await db.collection("stores").doc("store1").set({ ownerId: "owner1" });
    await db.collection("orders").doc("order1").set({
      storeId: "store1",
      customerId: "cust1",
      status: "readyForPickup",
      ...overrides,
    });
  }

  it("rejects marking an order completed before the pickup window opens", async () => {
    const future = Timestamp.fromMillis(Date.now() + 60 * 60 * 1000);
    await seedStoreAndOrder({ pickupStartTime: future });

    await expect(
      updateOrderStatus.run({
        auth: { uid: "owner1" },
        data: { orderId: "order1", status: "completed" },
      } as never),
    ).rejects.toThrow(/pickup window/i);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("readyForPickup");
  });

  it("rejects marking an order completed after the pickup window closes", async () => {
    const past = Timestamp.fromMillis(Date.now() - 60 * 60 * 1000);
    await seedStoreAndOrder({ pickupEndTime: past });

    await expect(
      updateOrderStatus.run({
        auth: { uid: "owner1" },
        data: { orderId: "order1", status: "completed" },
      } as never),
    ).rejects.toThrow(/pickup window/i);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("readyForPickup");
  });

  it("allows marking an order completed inside the pickup window", async () => {
    const start = Timestamp.fromMillis(Date.now() - 60 * 1000);
    const end = Timestamp.fromMillis(Date.now() + 60 * 1000);
    await seedStoreAndOrder({ pickupStartTime: start, pickupEndTime: end });

    await updateOrderStatus.run({
      auth: { uid: "owner1" },
      data: { orderId: "order1", status: "completed" },
    } as never);

    const orderSnap = await db.collection("orders").doc("order1").get();
    expect(orderSnap.data()?.status).toBe("completed");
  });
});
