import { describe, expect, it } from "vitest";
import {
  NotificationMessage,
  midWindowMessage,
  newOrderMessage,
  orderAcceptedMessage,
  orderCancelledMessage,
  orderCompletedCustomerMessage,
  orderCompletedStoreMessage,
  orderExpiredMessage,
  orderReadyMessage,
  pickupEndingMessage,
  pickupSoonMessage,
  reviewPromptMessage,
} from "./messages.js";

describe("newOrderMessage", () => {
  it("returns a non-empty Russian title and body", () => {
    const message = newOrderMessage({
      itemName: "Комбо-бокс",
      itemQuantity: 2,
      orderNumber: 17,
    });

    expect(message.title.length).toBeGreaterThan(0);
    expect(message.body.length).toBeGreaterThan(0);
    expect(message.title).toMatch(/[а-яА-ЯёЁ]/);
    expect(message.body).toMatch(/[а-яА-ЯёЁ]/);
  });

  it("interpolates itemName, itemQuantity and orderNumber into the body", () => {
    const message = newOrderMessage({
      itemName: "Комбо-бокс",
      itemQuantity: 2,
      orderNumber: 17,
    });

    expect(message.body).toContain("Комбо-бокс");
    expect(message.body).toContain("2");
    expect(message.body).toContain("17");
  });
});

/**
 * Regression guard for R3b: every status the old English `statusLabels` map
 * covered must still have a Russian text builder, so no transition silently
 * stops notifying.
 */
describe("status message coverage", () => {
  const buildersByStatus: Record<string, () => NotificationMessage> = {
    confirmed: () => newOrderMessage({
      itemName: "Комбо-бокс",
      itemQuantity: 1,
      orderNumber: 17,
    }),
    preparing: () => orderAcceptedMessage({ storeName: "Пекарня" }),
    readyForPickup: () => orderReadyMessage({
      storeName: "Пекарня",
      orderNumber: 17,
    }),
    completed: () => orderCompletedCustomerMessage({ orderNumber: 17 }),
    cancelled: () => orderCancelledMessage({
      orderNumber: 17,
      audience: "customer",
    }),
    expired: () => orderExpiredMessage({ orderNumber: 17, audience: "customer" }),
  };

  it.each(Object.keys(buildersByStatus))(
    "has a non-empty Russian text for %s",
    (status) => {
      const message = buildersByStatus[status]();

      expect(message.title.length).toBeGreaterThan(0);
      expect(message.body.length).toBeGreaterThan(0);
      expect(message.title).toMatch(/[а-яА-ЯёЁ]/);
      expect(message.body).toMatch(/[а-яА-ЯёЁ]/);
    },
  );
});

describe("paired completion messages", () => {
  it("tells the customer to enjoy the meal and the store the order was handed over", () => {
    const customer = orderCompletedCustomerMessage({ orderNumber: 17 });
    const store = orderCompletedStoreMessage({ orderNumber: 17 });

    expect(customer.body).toContain("17");
    expect(store.body).toContain("17");
    expect(customer.title).not.toEqual(store.title);
  });
});

describe("audience-dependent messages", () => {
  it("blames the store to the customer and the customer to the store on cancel", () => {
    const toCustomer = orderCancelledMessage({
      orderNumber: 17,
      audience: "customer",
    });
    const toStore = orderCancelledMessage({
      orderNumber: 17,
      audience: "store",
    });

    expect(toCustomer.body).not.toEqual(toStore.body);
    expect(toStore.body).toContain("клиент");
  });

  it("includes the cancellation reason for the customer when there is one", () => {
    const message = orderCancelledMessage({
      orderNumber: 17,
      audience: "customer",
      reason: "закончились продукты",
    });

    expect(message.body).toContain("закончились продукты");
  });

  it("uses different wording per audience when the pickup window closes", () => {
    const toCustomer = orderExpiredMessage({
      orderNumber: 17,
      audience: "customer",
    });
    const toStore = orderExpiredMessage({ orderNumber: 17, audience: "store" });

    expect(toCustomer.body).not.toEqual(toStore.body);
  });
});

describe("pickup-window reminder messages", () => {
  it("substitutes the pickup window bounds in HH:mm format", () => {
    const message = pickupSoonMessage({
      storeName: "Пекарня",
      startTime: "18:00",
      endTime: "18:30",
    });

    expect(message.body).toContain("18:00");
    expect(message.body).toContain("18:30");
    expect(message.body).toContain("Пекарня");
  });

  it("substitutes the order number and end time in the mid-window nudge", () => {
    const message = midWindowMessage({ orderNumber: 17, endTime: "18:30" });

    expect(message.body).toContain("17");
    expect(message.body).toContain("18:30");
  });

  it("substitutes the order number and end time in the closing-soon reminder", () => {
    const message = pickupEndingMessage({ orderNumber: 17, endTime: "18:30" });

    expect(message.body).toContain("17");
    expect(message.body).toContain("18:30");
  });
});

describe("reviewPromptMessage", () => {
  it("substitutes the store name and item name", () => {
    const message = reviewPromptMessage({
      storeName: "Пекарня",
      itemName: "Комбо-бокс",
    });

    expect(message.body).toContain("Пекарня");
    expect(message.body).toContain("Комбо-бокс");
  });
});
