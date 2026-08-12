import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { readFileSync } from "fs";
import { resolve } from "path";
import { describe, it, beforeAll, afterAll, beforeEach } from "vitest";
import { setDoc, doc, getDoc, deleteDoc, updateDoc } from "firebase/firestore";

const PROJECT_ID = "sarqyt-rules-test";
const RULES_PATH = resolve(__dirname, "../../firestore.rules");

let testEnv: RulesTestEnvironment;

// ---------- Helpers ----------

function authedDb(uid: string, claims: Record<string, unknown> = {}) {
  return testEnv
    .authenticatedContext(uid, claims)
    .firestore();
}

function unauthDb() {
  return testEnv.unauthenticatedContext().firestore();
}

// ---------- Setup / Teardown ----------

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// ==========================================================================
// Reviews
// ==========================================================================
describe("reviews", () => {
  const reviewData = {
    userId: "alice",
    storeId: "store1",
    orderId: "r1",
    storeRating: 4,
    offerRating: 4,
    text: "Great food!",
  };

  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "orders", "r1"), {
        customerId: "alice",
        storeId: "store1",
      });
    });
  });

  it("allows creating a review with own userId", async () => {
    const db = authedDb("alice");
    await assertSucceeds(
      setDoc(doc(db, "reviews", "r1"), reviewData)
    );
  });

  it("denies creating a review with someone else's userId", async () => {
    const db = authedDb("bob");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), reviewData) // userId: "alice"
    );
  });

  it("denies creating a review when not signed in", async () => {
    const db = unauthDb();
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), reviewData)
    );
  });

  it("denies creating a review with storeRating 0", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, storeRating: 0 })
    );
  });

  it("denies creating a review with storeRating 6", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, storeRating: 6 })
    );
  });

  it("denies creating a review with string storeRating", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, storeRating: "five" })
    );
  });

  it("denies creating a review with offerRating 0", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, offerRating: 0 })
    );
  });

  it("denies creating a review with offerRating 6", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, offerRating: 6 })
    );
  });

  it("denies creating a review with string offerRating", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, offerRating: "five" })
    );
  });

  it("denies creating a review for someone else's order", async () => {
    const db = authedDb("bob", {});
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, userId: "bob" })
    );
  });

  it("denies creating a review whose orderId doesn't match the doc id", async () => {
    const db = authedDb("alice");
    await assertFails(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, orderId: "other-order" })
    );
  });

  it("routes a second write for the same order to update, not a new review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    // Deterministic doc id means a second attempt at reviews/r1 always
    // targets the existing document — evaluated against `allow update`
    // (own-review only), never creates a second review for order r1.
    const db = authedDb("alice");
    await assertSucceeds(
      setDoc(doc(db, "reviews", "r1"), { ...reviewData, storeRating: 5 })
    );
    const bobDb = authedDb("bob");
    await assertFails(
      setDoc(doc(bobDb, "reviews", "r1"), { ...reviewData, userId: "bob", storeRating: 1 })
    );
  });

  it("allows the author to update their review text", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("alice");
    await assertSucceeds(
      updateDoc(doc(db, "reviews", "r1"), { text: "Updated!", storeRating: 5, offerRating: 5 })
    );
  });

  it("denies updating userId on own review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("alice");
    await assertFails(
      updateDoc(doc(db, "reviews", "r1"), { userId: "bob", storeRating: 4, offerRating: 4 })
    );
  });

  it("denies updating storeId on own review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("alice");
    await assertFails(
      updateDoc(doc(db, "reviews", "r1"), { storeId: "store2", storeRating: 4, offerRating: 4 })
    );
  });

  it("denies another user updating someone's review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("bob");
    await assertFails(
      updateDoc(doc(db, "reviews", "r1"), { text: "Hacked!", storeRating: 3, offerRating: 3 })
    );
  });

  it("allows the author to delete their review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("alice");
    await assertSucceeds(deleteDoc(doc(db, "reviews", "r1")));
  });

  it("denies another user deleting someone's review", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = authedDb("bob");
    await assertFails(deleteDoc(doc(db, "reviews", "r1")));
  });

  it("allows unauthenticated read", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "reviews", "r1"), reviewData);
    });
    const db = unauthDb();
    await assertSucceeds(getDoc(doc(db, "reviews", "r1")));
  });
});

// ==========================================================================
// Stores — delete restricted to owner
// ==========================================================================
describe("stores — delete", () => {
  const storeData = { name: "Test Store", ownerId: "owner1" };

  it("allows owner (via storeShip) to delete store", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "stores", "s1"), storeData);
      await setDoc(doc(fs, "storeShips", "s1_owner1"), {
        storeId: "s1",
        userId: "owner1",
        role: "owner",
      });
    });
    const db = authedDb("owner1");
    await assertSucceeds(deleteDoc(doc(db, "stores", "s1")));
  });

  it("denies employee deleting store", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "stores", "s1"), storeData);
      await setDoc(doc(fs, "storeShips", "s1_emp1"), {
        storeId: "s1",
        userId: "emp1",
        role: "employee",
      });
    });
    const db = authedDb("emp1");
    await assertFails(deleteDoc(doc(db, "stores", "s1")));
  });

  it("denies random user deleting store", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "stores", "s1"), storeData);
    });
    const db = authedDb("random");
    await assertFails(deleteDoc(doc(db, "stores", "s1")));
  });

  it("allows admin to delete any store", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "stores", "s1"), storeData);
    });
    const db = authedDb("admin1", { role: "admin" });
    await assertSucceeds(deleteDoc(doc(db, "stores", "s1")));
  });
});

// ==========================================================================
// Stores — update cannot touch avgRating / reviewCount
// ==========================================================================
describe("stores — update", () => {
  const storeData = { name: "Store", ownerId: "owner1", avgRating: 4.0, reviewCount: 10 };

  it("allows employee to update store name", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "stores", "s1"), storeData);
      await setDoc(doc(fs, "storeShips", "s1_emp1"), {
        storeId: "s1",
        userId: "emp1",
        role: "employee",
      });
    });
    const db = authedDb("emp1");
    await assertSucceeds(
      updateDoc(doc(db, "stores", "s1"), { name: "New Name" })
    );
  });

  it("denies employee updating avgRating", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "stores", "s1"), storeData);
      await setDoc(doc(fs, "storeShips", "s1_emp1"), {
        storeId: "s1",
        userId: "emp1",
        role: "employee",
      });
    });
    const db = authedDb("emp1");
    await assertFails(
      updateDoc(doc(db, "stores", "s1"), { avgRating: 5.0 })
    );
  });

  it("denies owner updating reviewCount", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "stores", "s1"), storeData);
      await setDoc(doc(fs, "storeShips", "s1_owner1"), {
        storeId: "s1",
        userId: "owner1",
        role: "owner",
      });
    });
    const db = authedDb("owner1");
    await assertFails(
      updateDoc(doc(db, "stores", "s1"), { reviewCount: 999 })
    );
  });
});

// ==========================================================================
// Orders — CF-only create, scoped update
// ==========================================================================
describe("orders", () => {
  const orderData = {
    customerId: "buyer1",
    storeId: "s1",
    status: "confirmed",
    itemQuantity: 1,
  };

  it("denies client creating an order (CF-only)", async () => {
    const db = authedDb("buyer1");
    await assertFails(
      setDoc(doc(db, "orders", "o1"), orderData)
    );
  });

  it("allows customer to read own order", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "orders", "o1"), orderData);
    });
    const db = authedDb("buyer1");
    await assertSucceeds(getDoc(doc(db, "orders", "o1")));
  });

  it("denies other customer reading order", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "orders", "o1"), orderData);
    });
    const db = authedDb("stranger");
    await assertFails(getDoc(doc(db, "orders", "o1")));
  });

  // Все изменения заказа идут через Cloud Functions (updateOrderStatus,
  // cancelOrder) с admin SDK — см. orders_repository.dart. Клиент в orders
  // не пишет вообще, поэтому персонал магазина не должен мочь ничего,
  // включая безобидный на вид status.
  it("denies store staff updating order status directly", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "orders", "o1"), orderData);
      await setDoc(doc(fs, "storeShips", "s1_staff1"), {
        storeId: "s1",
        userId: "staff1",
        role: "employee",
      });
    });
    const db = authedDb("staff1");
    await assertFails(
      updateDoc(doc(db, "orders", "o1"), { status: "preparing", updatedAt: new Date() })
    );
  });

  it("denies store staff updating itemQuantity", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "orders", "o1"), orderData);
      await setDoc(doc(fs, "storeShips", "s1_staff1"), {
        storeId: "s1",
        userId: "staff1",
        role: "employee",
      });
    });
    const db = authedDb("staff1");
    await assertFails(
      updateDoc(doc(db, "orders", "o1"), { itemQuantity: 100 })
    );
  });

  it("allows admin to update an order", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "orders", "o1"), orderData);
    });
    const db = authedDb("admin1", { role: "admin" });
    await assertSucceeds(
      updateDoc(doc(db, "orders", "o1"), { status: "preparing", updatedAt: new Date() })
    );
  });
});

// ==========================================================================
// Payments — read-only for customer, no client writes
// ==========================================================================
describe("payments", () => {
  const paymentData = { customerId: "buyer1", amount: 1000 };

  it("allows customer to read own payment", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "payments", "p1"), paymentData);
    });
    const db = authedDb("buyer1");
    await assertSucceeds(getDoc(doc(db, "payments", "p1")));
  });

  it("denies client creating a payment", async () => {
    const db = authedDb("buyer1");
    await assertFails(
      setDoc(doc(db, "payments", "p1"), paymentData)
    );
  });

  it("denies other user reading payment", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "payments", "p1"), paymentData);
    });
    const db = authedDb("other");
    await assertFails(getDoc(doc(db, "payments", "p1")));
  });
});

// ==========================================================================
// Users & favorites
// ==========================================================================
describe("users", () => {
  it("allows user to read own profile", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users", "u1"), { name: "Alice" });
    });
    const db = authedDb("u1");
    await assertSucceeds(getDoc(doc(db, "users", "u1")));
  });

  it("denies user reading other's profile", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users", "u2"), { name: "Bob" });
    });
    const db = authedDb("u1");
    await assertFails(getDoc(doc(db, "users", "u2")));
  });

  it("allows user to write own favorites", async () => {
    const db = authedDb("u1");
    await assertSucceeds(
      setDoc(doc(db, "users", "u1", "favorites", "store1"), { added: true })
    );
  });

  it("denies user writing other's favorites", async () => {
    const db = authedDb("u1");
    await assertFails(
      setDoc(doc(db, "users", "u2", "favorites", "store1"), { added: true })
    );
  });
});

// ==========================================================================
// Businesses — member-initiated verification submit
// ==========================================================================
describe("businesses — verification submit", () => {
  const businessData = { name: "Test Biz", ownerId: "owner1", verificationStatus: "unverified" };

  async function seedBusinessAndMembership() {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, "businesses", "b1"), businessData);
      await setDoc(doc(fs, "business_membership", "b1_owner1"), {
        businessId: "b1",
        userId: "owner1",
        role: "owner",
      });
    });
  }

  it("allows a business member to submit verification (unverified -> submitted)", async () => {
    await seedBusinessAndMembership();
    const db = authedDb("owner1");
    await assertSucceeds(
      updateDoc(doc(db, "businesses", "b1"), { verificationStatus: "submitted" })
    );
  });

  it("denies a member setting verificationStatus directly to verified", async () => {
    await seedBusinessAndMembership();
    const db = authedDb("owner1");
    await assertFails(
      updateDoc(doc(db, "businesses", "b1"), { verificationStatus: "verified" })
    );
  });

  it("denies changing other fields alongside verificationStatus", async () => {
    await seedBusinessAndMembership();
    const db = authedDb("owner1");
    await assertFails(
      updateDoc(doc(db, "businesses", "b1"), {
        verificationStatus: "submitted",
        name: "Renamed",
      })
    );
  });

  it("denies a non-member updating the business", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "businesses", "b1"), businessData);
    });
    const db = authedDb("stranger");
    await assertFails(
      updateDoc(doc(db, "businesses", "b1"), { verificationStatus: "submitted" })
    );
  });
});
