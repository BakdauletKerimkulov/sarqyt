import { FieldValue, GeoPoint, Timestamp } from "firebase-admin/firestore";

export interface Country {
  name: string;
  isoCode: string;
}

export interface Address {
  country: Country;
  address: string;
  locality: string;
  postalCode: string;
}

export interface GeoData {
  geohash: string;
  geopoint: GeoPoint;
  /** IANA timezone, for example `Asia/Almaty`. */
  timezone?: string;
}

export interface DraftLocation {
  address: Address;
  geo: GeoData;
}

export interface StoreDraftDoc {
  storeName: string;
  location: DraftLocation;
  phoneNumber: string;
  storeType: string;
  ownerId: string;
  storeId?: string;
  status: "pending" | "consumed" | "expired";
  expiresAt: FieldValue | Timestamp;
}
