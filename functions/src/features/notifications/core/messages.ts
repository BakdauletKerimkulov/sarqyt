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

/** Which side of the order a text is written for. */
export type MessageAudience = "customer" | "store";

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

/** Input for {@link orderAcceptedMessage}. */
export interface OrderAcceptedInput {
  storeName: string;
}

/**
 * Text sent to the customer when the store starts preparing the order.
 *
 * @param {OrderAcceptedInput} input Store details.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderAcceptedMessage(
  input: OrderAcceptedInput,
): NotificationMessage {
  return {
    title: input.storeName,
    body: "Заведение приняло ваш заказ и готовит его",
  };
}

/** Input for {@link orderReadyMessage}. */
export interface OrderReadyInput {
  storeName: string;
  orderNumber: number;
}

/**
 * Text sent to the customer when the order is ready for pickup.
 *
 * @param {OrderReadyInput} input Store and order details.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderReadyMessage(
  input: OrderReadyInput,
): NotificationMessage {
  return {
    title: input.storeName,
    body: `Заказ №${input.orderNumber} готов к выдаче`,
  };
}

/** Input for the messages that only need the order number. */
export interface OrderNumberInput {
  orderNumber: number;
}

/**
 * Text sent to the customer once the order has been handed over.
 *
 * @param {OrderNumberInput} input Order details.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderCompletedCustomerMessage(
  input: OrderNumberInput,
): NotificationMessage {
  return {
    title: "Приятного аппетита!",
    body: `Заказ №${input.orderNumber} получен. Спасибо, что спасаете еду`,
  };
}

/**
 * Text sent to the store team once the order has been handed over.
 *
 * @param {OrderNumberInput} input Order details.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderCompletedStoreMessage(
  input: OrderNumberInput,
): NotificationMessage {
  return {
    title: "Заказ передан",
    body: `Заказ №${input.orderNumber} благополучно передан клиенту`,
  };
}

/** Input for {@link orderCancelledMessage}. */
export interface OrderCancelledInput {
  orderNumber: number;
  audience: MessageAudience;
  reason?: string;
}

/**
 * Text sent to whichever side did not cancel the order.
 *
 * @param {OrderCancelledInput} input Order, audience and optional reason.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderCancelledMessage(
  input: OrderCancelledInput,
): NotificationMessage {
  const { orderNumber, audience, reason } = input;
  if (audience === "store") {
    return {
      title: "Заказ отменён",
      body: `Заказ №${orderNumber} отменён клиентом`,
    };
  }
  return {
    title: "Заказ отменён",
    body: reason ?
      `Заказ №${orderNumber} отменён заведением: ${reason}` :
      `Заказ №${orderNumber} отменён заведением`,
  };
}

/** Input for {@link orderExpiredMessage}. */
export interface OrderExpiredInput {
  orderNumber: number;
  audience: MessageAudience;
}

/**
 * Text sent to both sides when the pickup window closed unused.
 *
 * @param {OrderExpiredInput} input Order and audience.
 * @return {NotificationMessage} Title and body for the push.
 */
export function orderExpiredMessage(
  input: OrderExpiredInput,
): NotificationMessage {
  const { orderNumber, audience } = input;
  if (audience === "store") {
    return {
      title: "Заказ не забрали",
      body: `Заказ №${orderNumber} не забрали до конца окна выдачи`,
    };
  }
  return {
    title: "Окно забора закрылось",
    body: `Заказ №${orderNumber} не был получен`,
  };
}

/** Input for {@link pickupSoonMessage}. */
export interface PickupSoonInput {
  storeName: string;
  /** Pickup window start, pre-formatted as `HH:mm` by the caller. */
  startTime: string;
  /** Pickup window end, pre-formatted as `HH:mm` by the caller. */
  endTime: string;
}

/**
 * Text sent 15 minutes before the pickup window opens.
 *
 * @param {PickupSoonInput} input Store and window bounds.
 * @return {NotificationMessage} Title and body for the push.
 */
export function pickupSoonMessage(input: PickupSoonInput): NotificationMessage {
  const { storeName, startTime, endTime } = input;
  return {
    title: "Скоро можно забрать",
    body: `Забор в ${startTime}–${endTime} в ${storeName}`,
  };
}

/** Input for {@link midWindowMessage} and {@link pickupEndingMessage}. */
export interface OrderPickupReminderInput {
  orderNumber: number;
  /** Pickup window end, pre-formatted as `HH:mm` by the caller. */
  endTime: string;
}

/**
 * Text sent halfway through the pickup window as a nudge.
 *
 * @param {OrderPickupReminderInput} input Order number and window end.
 * @return {NotificationMessage} Title and body for the push.
 */
export function midWindowMessage(
  input: OrderPickupReminderInput,
): NotificationMessage {
  return {
    title: "Не забыли про заказ?",
    body: `Заказ №${input.orderNumber} ждёт вас до ${input.endTime}`,
  };
}

/**
 * Text sent 15 minutes before the pickup window closes.
 *
 * @param {OrderPickupReminderInput} input Order number and window end.
 * @return {NotificationMessage} Title and body for the push.
 */
export function pickupEndingMessage(
  input: OrderPickupReminderInput,
): NotificationMessage {
  return {
    title: "Осталось 15 минут",
    body: `Успейте забрать заказ №${input.orderNumber} до ${input.endTime}`,
  };
}
