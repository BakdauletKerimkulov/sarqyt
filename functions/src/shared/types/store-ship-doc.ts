import { FieldValue, Timestamp } from "firebase-admin/firestore";

export type StoreShipRole = "owner" | "operator" | "employer";

/** Shape of a document in `storeShips/{storeId}_{uid}`. */
export interface StoreShipDoc {
  id: string;
  storeId: string;
  businessId: string;
  userId: string;
  role: StoreShipRole;
  permissions: string[];
  name: string;
  logoUrl?: string | null;
  welcomeCompleted: boolean;
  hasFirstItem: boolean;
  createdAt: FieldValue | Timestamp;
  updatedAt: FieldValue | Timestamp;
}
