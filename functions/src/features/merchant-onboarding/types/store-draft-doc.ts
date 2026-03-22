import { FieldValue, GeoPoint, Timestamp } from "firebase-admin/firestore";

export interface Address {
  country: Country;
  address: string;
  locality: string;
  postalCode: string;
}

export interface Location {
  address: Address;
  location: GeoPoint;
}

export interface Country {
  name: string;
  isoCode: string;
}

export interface StoreDraftDoc {
  storeName: string;
  location: Location;
  phoneNumber: string;
  storeType: string;
  ownerId: string;
  storeId?: string;
  status: "pending" | "consumed" | "expired";
  expiresAt: FieldValue | Timestamp;
}
