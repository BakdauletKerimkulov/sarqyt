/**
 * Pure builders for user-visible push notification texts.
 *
 * All texts are Russian (see spec 034: user locale is not stored anywhere,
 * so the server picks the language). This module must stay free of Firestore
 * and messaging imports so it can be unit-tested without an emulator.
 */

/** User-visible text of a single push notification. */
export interface NotificationMessage {
  title: string;
  body: string;
}

/** Input for {@link newOrderMessage}. */
export interface NewOrderInput {
  itemName: string;
  itemQuantity: number;
  orderNumber: number;
}

/**
 * Text sent to the store team when a customer reserves an offer.
 *
 * @param {NewOrderInput} input Order details.
 * @return {NotificationMessage} Title and body for the push.
 */
export function newOrderMessage(input: NewOrderInput): NotificationMessage {
  const { itemName, itemQuantity, orderNumber } = input;
  return {
    title: "Новый заказ",
    body: `${itemName} ×${itemQuantity} — заказ №${orderNumber}`,
  };
}
