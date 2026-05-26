import { FieldValue, Timestamp } from "firebase-admin/firestore";

export type BusinessMembershipRole = "owner" | "admin";

/** Shape of a document in `business_membership/{businessId}_{uid}`. */
export interface BusinessMembershipDoc {
  id: string;
  businessId: string;
  userId: string;
  role: BusinessMembershipRole;
  createdAt: FieldValue | Timestamp;
  updatedAt: FieldValue | Timestamp;
}
