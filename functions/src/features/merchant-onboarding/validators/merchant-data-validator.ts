import { StoreDraftRequestDto } from "../types/store-draft-request-dto";

const PHONE_REGEX = /^\+?[0-9]{7,15}$/;
// const ISO_COUNTRY_CODE_REGEX = /^[A-Z]{2}$/;

export function validateMerchantData(data: StoreDraftRequestDto): string | null {
  if (!isNonEmptyString(data.storeName)) {
    return "Store name is required";
  }

  if (!isNonEmptyString(data.address)) {
    return "Address is required";
  }

  if (!isNonEmptyString(data.locality)) {
    return "Locality is required";
  }

  if (!isNonEmptyString(data.postalCode)) {
    return "Postal code is required";
  }

  if (!isNonEmptyString(data.storeType)) {
    return "Store type is required";
  }

  if (!isNonEmptyString(data.phoneNumber)) {
    return "Phone number is required";
  }

  if (!PHONE_REGEX.test(data.phoneNumber.trim())) {
    return "Phone number format is invalid";
  }

  const country = data.country;
  if (country == null || typeof country !== "object") {
    return "Country is required";
  }

  if (!isNonEmptyString(country.name)) {
    return "Country name is required";
  }

  if (!isNonEmptyString(country.isoCode)) {
    return "Country ISO code is required";
  }

  if (!isValidCoordinates(data.location)) {
    return "Location must contain valid [lat, lng] coordinates";
  }

  if (!isValidGeohash(data.geohash)) {
    return "Geohash is required and must be a non-empty alphanumeric string";
  }

  return null;
}

function isValidCoordinates(value: unknown): value is [number, number] {
  if (!Array.isArray(value) || value.length !== 2) {
    return false;
  }

  const [lat, lng] = value;
  if (typeof lat !== "number" || typeof lng !== "number") {
    return false;
  }

  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return false;
  }

  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

function isValidGeohash(value: unknown): value is string {
  if (typeof value !== "string") return false;
  const trimmed = value.trim();
  return trimmed.length > 0 && /^[0-9a-z]+$/.test(trimmed);
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}
