import { GeoPoint, Timestamp } from "firebase-admin/firestore";
import { AppError } from "../../../app/error";
import { StoreDoc } from "../../../shared/types/store-doc";
import { requireNonEmptyString } from "../helpers/offer-assertions";
import {
  addDaysToLocalDate,
  buildDateKey,
  buildOfferDocId,
  buildPickupTime,
  currentDateInTimeZone,
  getIsoWeekday,
  LocalDateParts,
  startOfDay,
} from "../helpers/offer-timezone";
import { buildStoreAddress, readStoreTimeZone } from "../helpers/offer-store";
import {
  readOptionalPrice,
  readRequiredPrice,
  requireSchedule,
  validateDaySchedule,
} from "../helpers/offer-values";
import { DaySchedule, ItemDoc } from "../types/item-doc";
import {
  ExpectedOffer,
  ExpectedOffersBuildResult,
  MaterializedOfferFields,
} from "../types/offer-sync";

const DAYS_AHEAD = 2;

interface OfferMaterializationTemplate {
  storeId: string;
  itemId: string;
  itemName: string;
  storeName: string;
  storeTimeZone: string;
  storeGeohash: string;
  storeGeopoint: GeoPoint;
  price: number;
  estimatedValue: number | null;
  currencyCode: string;
  currencySymbol: string;
  storeLogo: string | null;
  storeAddress: string | null;
  productImage: string | null;
}

function buildMaterializationTemplate(
  storeId: string,
  itemId: string,
  itemData: ItemDoc,
  storeData: StoreDoc,
): OfferMaterializationTemplate {
  const itemName = requireNonEmptyString(itemData.name, "item.name");
  const storeName = requireNonEmptyString(storeData.name, "store.name");
  const storeTimeZone = readStoreTimeZone(storeData);
  const storeGeohash = requireNonEmptyString(
    storeData.location?.geo?.geohash,
    "store.location.geo.geohash",
  );
  const storeGeopoint = storeData.location?.geo?.geopoint;
  if (storeGeopoint == null) {
    throw new AppError(
      "failed-precondition",
      "store.location.geo.geopoint is missing",
    );
  }
  const price = readRequiredPrice(itemData.price, "item.price");
  const estimatedValue = readOptionalPrice(itemData.estimatedValue);
  const currencyCode = storeData.currency?.trim() || "KZT";

  return {
    storeId,
    itemId,
    itemName,
    storeName,
    storeTimeZone,
    storeGeohash,
    storeGeopoint,
    price,
    estimatedValue,
    currencyCode,
    currencySymbol: currencyCode === "KZT" ? "₸" : currencyCode,
    storeLogo: storeData.logoUrl ?? null,
    storeAddress: buildStoreAddress(storeData),
    productImage: itemData.imageUrl ?? null,
  };
}

function materializeOfferForDate(
  date: LocalDateParts,
  schedule: DaySchedule,
  template: OfferMaterializationTemplate,
  utcNow: Date,
): ExpectedOffer | null {
  const dateKey = buildDateKey(date);
  validateDaySchedule(schedule, dateKey);

  const pickupStart = buildPickupTime(
    date,
    schedule.startHour,
    schedule.startMinute,
    template.storeTimeZone,
  );
  const pickupEnd = buildPickupTime(
    date,
    schedule.endHour,
    schedule.endMinute,
    template.storeTimeZone,
  );

  if (pickupEnd <= pickupStart) {
    throw new AppError(
      "failed-precondition",
      `Schedule for ${dateKey} has invalid pickup window`,
    );
  }
  if (pickupEnd <= utcNow) return null;

  const visibleFrom = startOfDay(
    addDaysToLocalDate(date, -1),
    template.storeTimeZone,
  );

  const fields: MaterializedOfferFields = {
    id: buildOfferDocId(template.storeId, template.itemId, dateKey),
    storeId: template.storeId,
    productId: template.itemId,
    geohash: template.storeGeohash,
    geopoint: template.storeGeopoint,
    visibleFrom: Timestamp.fromDate(visibleFrom),
    quantity: schedule.quantity,
    name: template.itemName,
    price: template.price,
    currencyCode: template.currencyCode,
    currencySymbol: template.currencySymbol,
    estimatedValue: template.estimatedValue,
    storeName: template.storeName,
    storeLogo: template.storeLogo,
    storeAddress: template.storeAddress,
    productImage: template.productImage,
    pickupStartTime: Timestamp.fromDate(pickupStart),
    pickupEndTime: Timestamp.fromDate(pickupEnd),
    status: "active",
  };

  return {
    docId: fields.id,
    fields,
  };
}

/**
 * Compute expected offers for the next 7 calendar days based on item schedule
 * in the store's timezone.
 * @param {string} storeId Store ID.
 * @param {string} itemId Item ID.
 * @param {ItemDoc} itemData Item document data.
 * @param {StoreDoc} storeData Store document data.
 * @return {ExpectedOffersBuildResult} Timezone-aware expected offers and range.
 */
export function buildExpectedOffers(
  storeId: string,
  itemId: string,
  itemData: ItemDoc,
  storeData: StoreDoc,
): ExpectedOffersBuildResult {
  const scheduleMap = requireSchedule(itemData.schedule);
  const template = buildMaterializationTemplate(
    storeId,
    itemId,
    itemData,
    storeData,
  );

  const utcNow = new Date();
  const today = currentDateInTimeZone(template.storeTimeZone, utcNow);
  const rangeStart = startOfDay(today, template.storeTimeZone);
  const rangeEnd = startOfDay(
    addDaysToLocalDate(today, DAYS_AHEAD),
    template.storeTimeZone,
  );

  const expectedByDate = new Map<string, ExpectedOffer>();

  for (let i = 0; i < DAYS_AHEAD; i++) {
    const date = addDaysToLocalDate(today, i);
    const weekday = getIsoWeekday(date).toString();
    const schedule = scheduleMap[weekday];
    if (!schedule?.enabled || schedule.quantity <= 0) continue;

    const expectedOffer = materializeOfferForDate(
      date,
      schedule,
      template,
      utcNow,
    );
    if (expectedOffer == null) continue;

    expectedByDate.set(buildDateKey(date), expectedOffer);
  }

  return {
    expectedByDate,
    storeTimeZone: template.storeTimeZone,
    utcNow,
    rangeStart,
    rangeEnd,
  };
}
