import * as admin from "firebase-admin";

admin.initializeApp();

// Merchant onboarding
export { completeMerchantOnboarding } from "./features/merchant-onboarding/functions/complete-merchant-onboarding";
export { fakeVerifyBusiness } from "./features/merchant-onboarding/functions/fake-verify-business";
export { skipOptionalOnboarding } from "./features/merchant-onboarding/functions/skip-optional-onboarding";
export { startMerchantOnboardingData } from "./features/merchant-onboarding/functions/start-merchant-onboarding";

// Offers
export { sincItemOffers } from "./features/offers/functions/sinc_item_offers";
export { dailySyncOffers } from "./features/offers/functions/daily-sync-offers";
export { createOneTimeOffer } from "./features/offers/functions/create-one-time-offer";
export { onItemStatusChanged } from "./features/offers/functions/on-item-status-changed";
export { cleanupOldData } from "./features/offers/functions/cleanup-old-offers";

// Payments
export { createPayment } from "./features/payments/functions/create-payment";
export { stripeWebhook } from "./features/payments/functions/stripe-webhook";

// Orders
export { expireOrders } from "./features/orders/functions/expire-orders";
export { cancelOrder } from "./features/orders/functions/cancel-order";
export { updateOrderStatus } from "./features/orders/functions/update-order-status";
export { onOrderStatusChanged } from "./features/orders/functions/on-order-status-changed";

// Triggers
export { onOrderCreated } from "./features/triggers/orders";
