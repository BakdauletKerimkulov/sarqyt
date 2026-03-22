import * as admin from "firebase-admin";

admin.initializeApp();

// Merchant onboarding
export { completeMerchantOnboarding } from "./features/merchant-onboarding/functions/complete-merchant-onboarding";
export { fakeVerifyBusiness } from "./features/merchant-onboarding/functions/fake-verify-business";
export { skipOptionalOnboarding } from "./features/merchant-onboarding/functions/skip-optional-onboarding";
export { startMerchantOnboardingData } from "./features/merchant-onboarding/functions/start-merchant-onboarding";

// Offers
export { sincItemOffers } from "./features/offers/functions/sinc_item_offers";

// Triggers
export { onOrderCreated } from "./features/triggers/orders";
