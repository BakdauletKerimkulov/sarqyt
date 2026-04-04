import { GeoPoint } from "firebase-admin/firestore";

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
  name: string;
  location: StoreLocation;
  ownerId: string;
  phoneNumber?: string | null;
  description?: string | null;
  logoUrl?: string | null;
  coverUrl?: string | null;
  avgRating?: number;
  currency?: string;
  /** UIDs of staff members with access to this store. */
  staffIds?: string[];
}
