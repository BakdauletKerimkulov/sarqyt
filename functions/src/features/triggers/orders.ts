import { FieldValue } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../../app/firebase";
import { FirestoreCollections } from "../../shared/constants/constants";

export const onOrderCreated = onDocumentCreated(
  { document: "orders/{id}", region: "asia-south1" },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const orderData = snapshot.data();
    const storeId = orderData?.storeId as string | undefined;
    if (!storeId) {
      console.error(`Order ${snapshot.id} missing storeId`);
      return;
    }

    const orderRef = snapshot.ref;
    const counterRef = db.collection(FirestoreCollections.STORES).doc(storeId);

    await db.runTransaction(async (tx) => {
      const storeSnap = await tx.get(counterRef);
      const currentCounter = (storeSnap.data()?.orderCounter as number) ?? 0;
      const nextNumber = currentCounter + 1;

      tx.update(counterRef, { orderCounter: FieldValue.increment(1) });
      tx.update(orderRef, { orderNumber: nextNumber });
    });
  });
