import { GeoPoint, Timestamp } from "firebase-admin/firestore";
import { StoreDoc } from "../../../shared/types/store-doc";
import { ItemDoc } from "./item-doc";

export interface MaterializedOfferFields {
  id: string;
  storeId: string;
  productId: string;
  geohash: string;
  geopoint: GeoPoint;
  visibleFrom: Timestamp;
  quantity: number;
  name: string;
  price: number;
  currencyCode: string;
  currencySymbol: string;
  estimatedValue: number | null;
  storeName: string;
  storeLogo: string | null;
  storeAddress: string | null;
  productImage: string | null;
  pickupStartTime: Timestamp;
  pickupEndTime: Timestamp;
  status: string;
}

export interface ExpectedOffer {
  docId: string;
  fields: MaterializedOfferFields;
}

export type ExpectedOffersByDate = Map<string, ExpectedOffer>;

export interface ExpectedOffersBuildResult {
  expectedByDate: ExpectedOffersByDate;
  storeTimeZone: string;
  utcNow: Date;
  rangeStart: Date;
  rangeEnd: Date;
}

export interface DiffAndApplyParams extends ExpectedOffersBuildResult {
  storeId: string;
  itemId: string;
  uid: string;
}

export interface SyncResult {
  created: number;
  updated: number;
  paused: number;
}

export interface ValidatedOfferSyncContext {
  itemData: ItemDoc;
  storeData: StoreDoc;
}
