import { beforeEach, describe, expect, it, vi } from "vitest";

const sendEachForMulticast = vi.fn();
const updateUser = vi.fn();

vi.mock("firebase-admin/messaging", () => ({
  getMessaging: () => ({ sendEachForMulticast }),
}));

vi.mock("../../../app/firebase", () => ({
  db: {
    collection: () => ({
      doc: () => ({ update: updateUser }),
    }),
  },
}));

import { sendToTokens } from "./send-push.js";

const payload = {
  title: "Новый заказ",
  body: "Комбо-бокс ×2 — заказ №17",
  data: { type: "new_order", orderId: "order-1" },
};

describe("sendToTokens", () => {
  beforeEach(() => {
    sendEachForMulticast.mockReset();
    updateUser.mockReset();
  });

  it("does not call FCM when there are no tokens", async () => {
    await sendToTokens([], payload);

    expect(sendEachForMulticast).not.toHaveBeenCalled();
  });

  it("deletes a token that FCM reports as no longer registered", async () => {
    sendEachForMulticast.mockResolvedValue({
      successCount: 0,
      failureCount: 1,
      responses: [
        { success: false, error: { code: "messaging/registration-token-not-registered" } },
      ],
    });

    await sendToTokens(
      [{ uid: "user-1", token: "stale-token", field: "fcmTokenBusiness" }],
      payload,
    );

    expect(updateUser).toHaveBeenCalledTimes(1);
    expect(Object.keys(updateUser.mock.calls[0][0])).toEqual(["fcmTokenBusiness"]);
  });

  it("keeps the token and does not throw on an unrelated FCM error", async () => {
    sendEachForMulticast.mockResolvedValue({
      successCount: 0,
      failureCount: 1,
      responses: [
        { success: false, error: { code: "messaging/quota-exceeded" } },
      ],
    });

    await expect(
      sendToTokens(
        [{ uid: "user-1", token: "good-token", field: "fcmTokenClient" }],
        payload,
      ),
    ).resolves.toBeUndefined();

    expect(updateUser).not.toHaveBeenCalled();
  });

  it("does not throw when the FCM call itself rejects", async () => {
    sendEachForMulticast.mockRejectedValue(new Error("network down"));

    await expect(
      sendToTokens(
        [{ uid: "user-1", token: "good-token", field: "fcmTokenClient" }],
        payload,
      ),
    ).resolves.toBeUndefined();
  });
});
