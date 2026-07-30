import { FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../../app/firebase";
import { logError } from "../../app/logger";
import { newOrderMessage } from "../notifications/core/messages";
import { getStoreTeamTokens } from "../notifications/helpers/recipients";
import { sendToTokens } from "../notifications/helpers/send-push";
import { FirestoreCollections } from "../../shared/constants/constants";

export const onOrderCreated = onDocumentCreated(
  { document: "orders/{id}", region: "asia-south1" },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const orderData = snapshot.data();
    const storeId = orderData?.storeId as string | undefined;
    if (!storeId) {
      logError("Order missing storeId", { orderId: snapshot.id });
      return;
    }

    const orderRef = snapshot.ref;
    const counterRef = db.collection(FirestoreCollections.STORES).doc(storeId);

    const orderNumber = await db.runTransaction(async (tx) => {
      const storeSnap = await tx.get(counterRef);
      const currentCounter = (storeSnap.data()?.orderCounter as number) ?? 0;
      const nextNumber = currentCounter + 1;

      tx.update(counterRef, { orderCounter: FieldValue.increment(1) });
      tx.update(orderRef, { orderNumber: nextNumber });
      return nextNumber;
    });

    // Side effect after commit: orderNumber is only known from the transaction,
    // the event snapshot predates it (ai_toolkit/firebase.md).
    await notifyStoreTeam(snapshot.id, storeId, orderData, orderNumber);
  });

/**
 * Tell the store team a new order came in. Never throws (spec 034, R10).
 *
 * @param {string} orderId Order document ID.
 * @param {string} storeId Store the order belongs to.
 * @param {FirebaseFirestore.DocumentData} orderData Order fields.
 * @param {number} orderNumber Per-store number assigned by the transaction.
 * @return {Promise<void>} Resolves once the push attempt is done.
 */
async function notifyStoreTeam(
  orderId: string,
  storeId: string,
  orderData: FirebaseFirestore.DocumentData,
  orderNumber: number,
): Promise<void> {
  try {
    const tokens = await getStoreTeamTokens(storeId);
    const message = newOrderMessage({
      itemName: (orderData.itemName as string) ?? "Заказ",
      itemQuantity: (orderData.itemQuantity as number) ?? 1,
      orderNumber,
    });

    await sendToTokens(tokens, {
      ...message,
      data: {
        type: "new_order",
        orderId,
        storeId,
        storeName: (orderData.storeName as string) ?? "",
      },
    });
  } catch (error) {
    logError("New order push failed", { error, orderId, storeId });
  }
}
