import {GeoPoint, Timestamp} from "firebase-admin/firestore";
import {StoreDraftRequestDto} from "../types/store-draft-request-dto";
import {StoreDraftDoc} from "../types/store-draft-doc";

export function toStoreDraftDoc(
  data: StoreDraftRequestDto,
  ownerId: string,
): StoreDraftDoc {
  const [latitude, longitude] = data.location;
  const expiresAt = Timestamp.fromDate(
    new Date(Date.now() + 1000 * 60 * 60 * 24 * 3),
  );

  return {
    storeName: data.storeName.trim(),
    location: {
      address: {
        country: {
          name: data.country.name.trim(),
          isoCode: data.country.isoCode.trim().toUpperCase(),
        },
        address: data.address.trim(),
        locality: data.locality.trim(),
        postalCode: data.postalCode.trim(),
      },
      location: new GeoPoint(latitude, longitude),
    },
    phoneNumber: data.phoneNumber.trim(),
    storeType: data.storeType.trim(),
    ownerId: ownerId,
    status: "pending",
    expiresAt: expiresAt,
  };
}
