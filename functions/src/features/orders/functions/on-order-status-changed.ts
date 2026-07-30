import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logError } from "../../../app/logger";
import {
  NotificationMessage,
  orderAcceptedMessage,
  orderCancelledMessage,
  orderCompletedCustomerMessage,
  orderCompletedStoreMessage,
  orderExpiredMessage,
  orderReadyMessage,
} from "../../notifications/core/messages";
import {
  getCustomerToken,
  getStoreTeamTokens,
} from "../../notifications/helpers/recipients";
import { PushToken, sendToTokens } from "../../notifications/helpers/send-push";

/** One push to one side of the order. */
interface Delivery {
  audience: "customer" | "store";
  /** `data.type` the app maps to a route name (spec 034, R9). */
  type: string;
  message: NotificationMessage;
}

/** The order fields a delivery is built from. */
interface OrderContext {
  storeName: string;
  orderNumber: number;
  cancelledBy?: string;
  cancellationReason?: string;
}

/**
 * Sends push notifications when order status changes.
 *
 * Retries stay off on purpose: a retried event would replay the same status
 * change and duplicate the push (spec 034, error flows).
 */
export const onOrderStatusChanged = onDocumentUpdated(
  { document: "orders/{orderId}", region: "asia-south1" },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before.status === after.status) return;

    const customerId = after.customerId as string | undefined;
    const storeId = after.storeId as string | undefined;
    if (!customerId || !storeId) return;

    const orderId = event.params.orderId;
    const storeName = (after.storeName as string) ?? "Магазин";

    const deliveries = plannedDeliveries(after.status as string, {
      storeName,
      orderNumber: (after.orderNumber as number) ?? 0,
      cancelledBy: after.cancelledBy as string | undefined,
      cancellationReason: after.cancellationReason as string | undefined,
    });

    for (const delivery of deliveries) {
      await deliver(delivery, { orderId, customerId, storeId, storeName });
    }
  }
);

/**
 * Decide who hears about a status change, and with which text.
 *
 * Pure: no Firestore, no messaging — the branching rules of R4 and R8.
 *
 * @param {string} status The status the order just moved to.
 * @param {OrderContext} order Fields the texts interpolate.
 * @return {Delivery[]} Zero or more pushes to send.
 */
function plannedDeliveries(
  status: string,
  order: OrderContext,
): Delivery[] {
  const { storeName, orderNumber } = order;

  switch (status) {
  case "preparing":
    return [{
      audience: "customer",
      type: "new_status",
      message: orderAcceptedMessage({ storeName }),
    }];
  case "readyForPickup":
    return [{
      audience: "customer",
      type: "new_status",
      message: orderReadyMessage({ storeName, orderNumber }),
    }];
  case "completed":
    return [
      {
        audience: "customer",
        type: "new_status",
        message: orderCompletedCustomerMessage({ orderNumber }),
      },
      {
        audience: "store",
        type: "order_completed",
        message: orderCompletedStoreMessage({ orderNumber }),
      },
    ];
  case "expired":
    return [
      {
        audience: "customer",
        type: "new_status",
        message: orderExpiredMessage({ orderNumber, audience: "customer" }),
      },
      {
        audience: "store",
        type: "order_expired",
        message: orderExpiredMessage({ orderNumber, audience: "store" }),
      },
    ];
  case "cancelled":
    // Only the side that did not cancel gets told (R8).
    return order.cancelledBy === "customer" ?
      [{
        audience: "store",
        type: "order_cancelled",
        message: orderCancelledMessage({ orderNumber, audience: "store" }),
      }] :
      [{
        audience: "customer",
        type: "new_status",
        message: orderCancelledMessage({
          orderNumber,
          audience: "customer",
          reason: order.cancellationReason,
        }),
      }];
  default:
    return [];
  }
}

/** Everything a delivery needs to resolve recipients and build the payload. */
interface DeliveryTarget {
  orderId: string;
  customerId: string;
  storeId: string;
  storeName: string;
}

/**
 * Resolve the recipients of one delivery and push to them.
 *
 * Never throws: a failed push must not fail the trigger (spec 034, R10).
 *
 * @param {Delivery} delivery What to send and to which side.
 * @param {DeliveryTarget} target IDs the payload and lookups need.
 * @return {Promise<void>} Resolves once the push attempt is done.
 */
async function deliver(
  delivery: Delivery,
  target: DeliveryTarget,
): Promise<void> {
  try {
    const tokens = delivery.audience === "customer" ?
      await customerTokens(target.customerId) :
      await getStoreTeamTokens(target.storeId);

    await sendToTokens(tokens, {
      ...delivery.message,
      data: {
        type: delivery.type,
        orderId: target.orderId,
        storeId: target.storeId,
        storeName: target.storeName,
      },
    });
  } catch (error) {
    logError("Status change push failed", {
      error,
      orderId: target.orderId,
      type: delivery.type,
    });
  }
}

/**
 * The customer's token as a list, so both audiences share one send path.
 *
 * @param {string} customerId Customer user ID.
 * @return {Promise<PushToken[]>} Zero or one token.
 */
async function customerTokens(customerId: string): Promise<PushToken[]> {
  const token = await getCustomerToken(customerId);
  return token ? [token] : [];
}
