import { describe, expect, it } from "vitest";
import { newOrderMessage } from "./messages.js";

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
