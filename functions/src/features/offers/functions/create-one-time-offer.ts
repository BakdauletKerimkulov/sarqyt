import { GeoPoint, Timestamp } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";
import { AppError, toHttpsError } from "../../../app/error";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import {
  FirestoreCollections,
  UserRole,
} from "../../../shared/constants/constants";
import { assertStoreAccess } from "../../../shared/helpers/assert-store-access";
import { StoreDoc } from "../../../shared/types/store-doc";
import { requireNonEmptyString } from "../helpers/offer-assertions";
import { readStoreTimeZone, buildStoreAddress } from "../helpers/offer-store";
import {
  addDaysToLocalDate,
  buildDateKey,
  buildPickupTime,
  currentDateInTimeZone,
  startOfDay,
} from "../helpers/offer-timezone";

interface CreateOneTimeOfferRequest {
  storeId: string;
  name: string;
  price: number;
  date: string; // "YYYY-MM-DD"
  startHour: number;
  startMinute: number;
  endHour: number;
  endMinute: number;
  quantity: number;
}

/**
 * Creates a standalone flash offer. Does not require an item.
 * Uses store data for location/branding, name and price from input.
 */
export const createOneTimeOffer = onCall(async (req) => {
  try {
    if (req.auth == null) {
      throw new AppError("unauthenticated", "Login required");
    }
    const uid = req.auth.uid;
    const role = req.auth.token.role;
    if (role !== UserRole.PARTNER && role !== UserRole.ADMIN) {
      throw new AppError("permission-denied", "Insufficient permissions");
    }

    const data = req.data as CreateOneTimeOfferRequest;
    const storeId = requireNonEmptyString(data.storeId, "storeId");
    const name = requireNonEmptyString(data.name, "name");
    const date = requireNonEmptyString(data.date, "date");

    if (typeof data.price !== "number" || data.price <= 0) {
      throw new AppError("invalid-argument", "price must be > 0");
    }
    if (!data.quantity || data.quantity < 1) {
      throw new AppError("invalid-argument", "quantity must be >= 1");
    }
    if (data.startHour == null || data.startMinute == null ||
        data.endHour == null || data.endMinute == null) {
      throw new AppError("invalid-argument", "start/end time is required");
    }

    // Auth: verify store access via storeShips
    await assertStoreAccess(uid, storeId);

    // Load store data for location/branding
    const storeSnap = await db
      .doc(`${FirestoreCollections.STORES}/${storeId}`)
      .get();
    if (!storeSnap.exists) throw new AppError("not-found", "Store not found");
    const storeData = storeSnap.data() as StoreDoc;

    // Build offer
    const timeZone = readStoreTimeZone(storeData);
    const [year, month, day] = date.split("-").map(Number);
    const dateParts = { year, month, day };

    const pickupStart = buildPickupTime(
      dateParts, data.startHour, data.startMinute, timeZone
    );
    const pickupEnd = buildPickupTime(
      dateParts, data.endHour, data.endMinute, timeZone
    );

    if (pickupEnd <= pickupStart) {
      throw new AppError("invalid-argument", "End time must be after start time");
    }
    const durationMs = pickupEnd.getTime() - pickupStart.getTime();
    if (durationMs > 120 * 60 * 1000) {
      throw new AppError("invalid-argument", "Pickup window cannot exceed 2 hours");
    }
    if (pickupEnd <= new Date()) {
      throw new AppError("invalid-argument", "Pickup time is in the past");
    }

    // visibleFrom: offers for future dates become visible the day before
    const today = currentDateInTimeZone(timeZone);
    const isToday =
      dateParts.year === today.year &&
      dateParts.month === today.month &&
      dateParts.day === today.day;
    const visibleFrom = isToday ?
      null :
      startOfDay(addDaysToLocalDate(dateParts, -1), timeZone);

    const currencyCode = storeData.currency?.trim() || "KZT";
    const geohash = storeData.location?.geo?.geohash;
    const geopoint = storeData.location?.geo?.geopoint;

    if (!geohash || !geopoint) {
      throw new AppError("failed-precondition", "Store location is incomplete");
    }

    const dateKey = buildDateKey(dateParts);
    const docId = `${storeId}_flash_${dateKey}_${Date.now()}`;
    const offerRef = db.collection(FirestoreCollections.OFFERS).doc(docId);

    await offerRef.set({
      id: docId,
      storeId,
      productId: "flash",
      geohash,
      geopoint: new GeoPoint(geopoint.latitude, geopoint.longitude),
      quantity: data.quantity,
      name,
      price: data.price,
      currencyCode,
      currencySymbol: currencyCode === "KZT" ? "₸" : currencyCode,
      storeName: requireNonEmptyString(storeData.name, "store.name"),
      storeLogo: storeData.logoUrl ?? null,
      storeAddress: buildStoreAddress(storeData),
      visibleFrom: visibleFrom ? Timestamp.fromDate(visibleFrom) : null,
      pickupStartTime: Timestamp.fromDate(pickupStart),
      pickupEndTime: Timestamp.fromDate(pickupEnd),
      status: "active",
      createdAt: serverTimestamp(),
      createdBy: uid,
    });

    logInfo("createOneTimeOffer done", { storeId, docId });
    return { success: true, offerId: docId };
  } catch (error) {
    logError("createOneTimeOffer failed", { error, data: req.data });
    throw toHttpsError(error);
  }
});
