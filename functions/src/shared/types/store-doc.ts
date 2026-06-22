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

export interface StoreLocation {
  address: Address;
  geo: GeoData;
}

/** Shape of a document in `stores/{storeId}`. */
export interface StoreDoc {
  id: string;
  name: string;
  location: StoreLocation;
  businessId: string;
  /** Denormalized owner UID — used for list queries, NOT for auth checks. */
  ownerId: string;
  storeType?: string | null;
  phoneNumber?: string | null;
  description?: string | null;
  logoUrl?: string | null;
  coverUrl?: string | null;
  avgRating?: number;
  reviewCount?: number;
  currency?: string;
  isVisible?: boolean;
  createdAt: FieldValue | Timestamp;
  updatedAt: FieldValue | Timestamp;
  /** @deprecated Use storeShips for access checks. Will be removed in Phase 2. */
  staffIds?: string[];
}
