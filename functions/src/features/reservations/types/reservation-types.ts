import { Timestamp } from "firebase-admin/firestore";

export interface ReservationDoc {
  offerId: string;
  storeId: string;
  customerId: string;
  itemId: string;
  itemName: string;
  storeName: string;
  itemImageUrl: string | null;
  unitPrice: number;
  currencyCode: string;
  currencySymbol: string;
  quantity: number;
  status: "pending" | "paid" | "expired" | "cancelled";
  paymentIntentId: string;
  createdAt: Timestamp;
  expiresAt: Timestamp;
}

export interface CreateReservationRequest {
  offerId: string;
  quantity: number;
}

export interface CreateReservationResponse {
  reservationId: string;
  paymentIntentClientSecret: string;
  ephemeralKey: string;
  stripeCustomerId: string;
}
