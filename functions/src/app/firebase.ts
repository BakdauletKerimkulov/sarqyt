import * as admin from "firebase-admin";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

const app = admin.app();

export const db = getFirestore(app);
export const auth = getAuth(app);
export const serverTimestamp = () => FieldValue.serverTimestamp();
