import { beforeEach, describe, expect, it, vi } from "vitest";

const state = vi.hoisted(() => ({
  users: {} as Record<string, Record<string, unknown>>,
  stores: {} as Record<string, Record<string, unknown>>,
  storeShips: [] as Array<{ storeId: string; userId: string }>,
  limits: [] as number[],
  logWarn: vi.fn(),
}));

const logWarn = state.logWarn;

vi.mock("../../../app/logger", () => ({
  logInfo: vi.fn(),
  logWarn: state.logWarn,
  logError: vi.fn(),
}));

vi.mock("../../../app/firebase", () => {
  const docOf = (
    collection: Record<string, Record<string, unknown>>,
    id: string,
  ) => ({
    get: async () => ({
      exists: id in collection,
      id,
      data: () => collection[id],
    }),
  });

  return {
    db: {
      collection: (name: string) => {
        if (name === "users") {
          return { doc: (id: string) => docOf(state.users, id) };
        }
        if (name === "stores") {
          return { doc: (id: string) => docOf(state.stores, id) };
        }
        return {
          where: (_field: string, _op: string, value: string) => ({
            limit: (count: number) => {
              state.limits.push(count);
              return {
                get: async () => {
                  const docs = state.storeShips
                    .filter((ship) => ship.storeId === value)
                    .map((ship) => ({ data: () => ship }));
                  return { empty: docs.length === 0, docs };
                },
              };
            },
          }),
        };
      },
    },
  };
});

import { getCustomerToken, getStoreTeamTokens } from "./recipients.js";

describe("getStoreTeamTokens", () => {
  beforeEach(() => {
    state.users = {};
    state.stores = {};
    state.storeShips = [];
    state.limits = [];
    logWarn.mockReset();
  });

  it("resolves the team through storeShips, capped at 20 members", async () => {
    state.storeShips = [
      { storeId: "store-1", userId: "user-1" },
      { storeId: "store-1", userId: "user-2" },
    ];
    state.users = {
      "user-1": { fcmTokenBusiness: "token-1" },
      "user-2": { fcmTokenBusiness: "token-2" },
    };

    const tokens = await getStoreTeamTokens("store-1");

    expect(tokens.map((recipient) => recipient.token)).toEqual([
      "token-1",
      "token-2",
    ]);
    expect(state.limits).toEqual([20]);
  });

  it("falls back to the legacy stores/{storeId}.ownerId when no storeShip exists", async () => {
    state.stores = { "store-1": { ownerId: "owner-1" } };
    state.users = { "owner-1": { fcmTokenBusiness: "owner-token" } };

    const tokens = await getStoreTeamTokens("store-1");

    expect(tokens).toEqual([
      { uid: "owner-1", token: "owner-token", field: "fcmTokenBusiness" },
    ]);
  });

  it("prefers fcmTokenBusiness over the legacy fcmToken", async () => {
    state.storeShips = [{ storeId: "store-1", userId: "user-1" }];
    state.users = {
      "user-1": { fcmTokenBusiness: "business-token", fcmToken: "legacy-token" },
    };

    const tokens = await getStoreTeamTokens("store-1");

    expect(tokens).toEqual([
      { uid: "user-1", token: "business-token", field: "fcmTokenBusiness" },
    ]);
  });

  it("uses the legacy fcmToken when the business field is missing", async () => {
    state.storeShips = [{ storeId: "store-1", userId: "user-1" }];
    state.users = { "user-1": { fcmToken: "legacy-token" } };

    const tokens = await getStoreTeamTokens("store-1");

    expect(tokens).toEqual([
      { uid: "user-1", token: "legacy-token", field: "fcmToken" },
    ]);
  });

  it("warns and returns nothing when the store has no reachable recipient", async () => {
    const tokens = await getStoreTeamTokens("store-1");

    expect(tokens).toEqual([]);
    expect(logWarn).toHaveBeenCalled();
  });
});

describe("getCustomerToken", () => {
  beforeEach(() => {
    state.users = {};
  });

  it("prefers fcmTokenClient over the legacy fcmToken", async () => {
    state.users = {
      "user-1": { fcmTokenClient: "client-token", fcmToken: "legacy-token" },
    };

    expect(await getCustomerToken("user-1")).toEqual({
      uid: "user-1",
      token: "client-token",
      field: "fcmTokenClient",
    });
  });

  it("returns null when the customer has no token at all", async () => {
    state.users = { "user-1": {} };

    expect(await getCustomerToken("user-1")).toBeNull();
  });
});
