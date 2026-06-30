import * as admin from "firebase-admin";

admin.initializeApp();

// Merchant onboarding
export { completeMerchantOnboarding } from "./features/merchant-onboarding/functions/complete-merchant-onboarding";
export { fakeVerifyBusiness } from "./features/merchant-onboarding/functions/fake-verify-business";
export { startMerchantOnboardingData } from "./features/merchant-onboarding/functions/start-merchant-onboarding";

// Offers
export { syncItemOffers } from "./features/offers/functions/sync-item-offers";
export { dailySyncOffers } from "./features/offers/functions/daily-sync-offers";
export { createOneTimeOffer } from "./features/offers/functions/create-one-time-offer";
export { onItemStatusChanged } from "./features/offers/functions/on-item-status-changed";
export { cleanupOldData } from "./features/offers/functions/cleanup-old-offers";
export { updateOfferQuantity } from "./features/offers/functions/update-offer-quantity";

// Payments
export { reserveOffer } from "./features/payments/functions/reserve-offer";

// Orders
export { expireOrders } from "./features/orders/functions/expire-orders";
export { cancelOrder } from "./features/orders/functions/cancel-order";
export { updateOrderStatus } from "./features/orders/functions/update-order-status";
export { onOrderStatusChanged } from "./features/orders/functions/on-order-status-changed";

// Items
export { deleteItem } from "./features/items/functions/delete-item";

// Stores
export { createAdditionalStore } from "./features/stores/functions/create-additional-store";
export { inviteTeamMember } from "./features/stores/functions/invite-team-member";

// Triggers
export { onOrderCreated } from "./features/triggers/orders";
export { onReviewWritten } from "./features/triggers/reviews";
