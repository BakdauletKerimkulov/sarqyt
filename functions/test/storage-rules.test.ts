import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { readFileSync } from "fs";
import { resolve } from "path";
import { describe, it, beforeAll, afterAll, beforeEach } from "vitest";
import { ref, uploadBytes, deleteObject } from "firebase/storage";
import { setDoc, doc } from "firebase/firestore";

// Именно дефолтный projectId из .firebaserc, а не отдельный тестовый, как
// в остальных файлах: правила Storage читают Firestore через
// firestore.exists(), а этот cross-service вызов под singleProjectMode
// уходит в дефолтный проект. С чужим projectId storeShips не находится и
// любая запись отклоняется — тесты краснеют, хотя правила верные.
const PROJECT_ID = "sarqyt-1ab95";
const STORAGE_RULES_PATH = resolve(__dirname, "../../storage.rules");
const FIRESTORE_RULES_PATH = resolve(__dirname, "../../firestore.rules");

const ITEM_PATH = "stores/store1/items/photo.jpg";

let testEnv: RulesTestEnvironment;

// ---------- Helpers ----------

function authedStorage(uid: string, claims: Record<string, unknown> = {}) {
  return testEnv.authenticatedContext(uid, claims).storage();
}

function imageBytes(sizeInBytes: number) {
  return new Uint8Array(sizeInBytes).fill(1);
}

// ---------- Setup / Teardown ----------

beforeAll(async () => {
  // Правила Storage ходят в Firestore за storeShips, поэтому эмулятор
  // Firestore здесь тоже обязателен.
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    storage: {
      rules: readFileSync(STORAGE_RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 9199,
    },
    firestore: {
      rules: readFileSync(FIRESTORE_RULES_PATH, "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearStorage();
  await testEnv.clearFirestore();
  // alice — участник store1, bob — посторонний.
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), "storeShips", "store1_alice"), {
      storeId: "store1",
      userId: "alice",
      role: "owner",
    });
  });
});

// ==========================================================================
// Item images
// ==========================================================================
describe("store item images", () => {
  it("allows a store member to upload an image under the size limit", async () => {
    const storage = authedStorage("alice");
    await assertSucceeds(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(1024), {
        contentType: "image/jpeg",
      })
    );
  });

  it("denies an upload from someone outside the store", async () => {
    const storage = authedStorage("bob");
    await assertFails(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(1024), {
        contentType: "image/jpeg",
      })
    );
  });

  it("allows an image just under the 5 MB limit", async () => {
    // Парная к тесту ниже: доказывает, что отказ на 5 MB даёт правило,
    // а не какой-нибудь предел самого эмулятора.
    const storage = authedStorage("alice");
    await assertSucceeds(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(5 * 1024 * 1024 - 1), {
        contentType: "image/jpeg",
      })
    );
  });

  it("denies an image at or over the 5 MB limit", async () => {
    const storage = authedStorage("alice");
    await assertFails(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(5 * 1024 * 1024), {
        contentType: "image/jpeg",
      })
    );
  });

  it("denies a non-image content type", async () => {
    const storage = authedStorage("alice");
    await assertFails(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(1024), {
        contentType: "application/pdf",
      })
    );
  });

  it("denies an upload with no declared image content type", async () => {
    // Клиент строит contentType через lookupMimeType и на нераспознанном
    // файле отдаёт application/octet-stream — такой аплоад тоже отклоняем.
    const storage = authedStorage("alice");
    await assertFails(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(1024), {
        contentType: "application/octet-stream",
      })
    );
  });

  it("still lets a store member delete an existing image", async () => {
    // Регрессия: delete не несёт request.resource, поэтому проверки размера
    // и типа не должны на нём выполняться. Компенсирующее удаление в
    // create_item_form_controller зависит от этого.
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await uploadBytes(ref(ctx.storage(), ITEM_PATH), imageBytes(1024), {
        contentType: "image/jpeg",
      });
    });

    const storage = authedStorage("alice");
    await assertSucceeds(deleteObject(ref(storage, ITEM_PATH)));
  });

  it("denies deletion by someone outside the store", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await uploadBytes(ref(ctx.storage(), ITEM_PATH), imageBytes(1024), {
        contentType: "image/jpeg",
      });
    });

    const storage = authedStorage("bob");
    await assertFails(deleteObject(ref(storage, ITEM_PATH)));
  });

  it("allows an admin to upload regardless of store membership", async () => {
    const storage = authedStorage("carol", { role: "admin" });
    await assertSucceeds(
      uploadBytes(ref(storage, ITEM_PATH), imageBytes(1024), {
        contentType: "image/png",
      })
    );
  });
});
