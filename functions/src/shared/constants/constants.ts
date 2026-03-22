export const FirestoreCollections = {
  USERS: "users",
  BUSINESSES: "businesses",
  BUSINESSES_MEMBERSHIP: "business_membership",
  ORDERS: "orders",
  STORE_DRAFTS: "storeDrafts",
  STORES: "stores",
  STORE_SHIPS: "storeShips",
  OFFERS: "offers",
  PRODUCTS: "products",
  PAYMENTS: "payments",
} as const;

/** Store items are a subcollection: stores/{storeId}/items/{itemId} */
export function storeItemPath(storeId: string, itemId: string): string {
  return `${FirestoreCollections.STORES}/${storeId}/items/${itemId}`;
}

export enum UserRole {
  PARTNER = "partner",
  CUSTOMER = "customer",
  ADMIN = "admin",
}
