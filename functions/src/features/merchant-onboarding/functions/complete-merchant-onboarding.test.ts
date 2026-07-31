import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { afterAll, beforeEach, describe, it, expect } from "vitest";

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
process.env.GCLOUD_PROJECT = "sarqyt-complete-onboarding-test";

admin.initializeApp({ projectId: "sarqyt-complete-onboarding-test" });

const { db, auth } = await import("../../../app/firebase");
const { completeMerchantOnboarding } = await import("./complete-merchant-onboarding");

describe("completeMerchantOnboarding", () => {
  afterAll(async () => {
    await admin.app().delete();
  });

  beforeEach(async () => {
    const collections = ["storeShips", "storeDrafts", "businesses", "stores", "business_membership"];
    for (const name of collections) {
      const snap = await db.collection(name).get();
      await Promise.all(snap.docs.map((doc) => doc.ref.delete()));
    }
    for (const user of (await auth.listUsers()).users) {
      await auth.deleteUser(user.uid);
    }
  });

  it(
    "restores partner claims when the user already has a storeShip " +
      "but a prior claim-set attempt failed",
    async () => {
      const uid = "partner-with-stale-claims";
      const storeId = "store1";
      const businessId = "business1";

      await auth.createUser({ uid, email: "partner@example.com", emailVerified: true });
      // No custom claims set — simulates setCustomUserClaims failing after
      // the Firestore batch already succeeded on a prior call.

      const now = Timestamp.now();
      await db
        .collection("storeShips")
        .doc(`${storeId}_${uid}`)
        .set({
          id: `${storeId}_${uid}`,
          storeId,
          businessId,
          userId: uid,
          role: "owner",
          permissions: ["manage_store", "manage_orders", "manage_offers", "manage_team"],
          name: "Test Store",
          logoUrl: null,
          welcomeCompleted: false,
          hasFirstItem: false,
          createdAt: now,
          updatedAt: now,
        });

      const result = await completeMerchantOnboarding.run({
        auth: { uid },
        data: {},
      } as never);

      expect(result).toEqual({ success: true, storeId });

      const userRecord = await auth.getUser(uid);
      expect(userRecord.customClaims?.role).toBe("partner");
      expect(userRecord.customClaims?.canCreateStore).toBe(true);
    },
  );
});
