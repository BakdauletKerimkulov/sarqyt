/**
 * Manual test checklist for reserveOffer Cloud Function.
 * Run against Firebase Emulator or test environment.
 *
 * Prerequisites:
 * - Active offer with quantity >= 1
 * - Authenticated user
 *
 * Test cases:
 *
 * 1. Happy path:
 *    Input: { offerId: "valid", quantity: 1 }
 *    Expected: order created, offer.quantity decremented by 1
 *
 * 2. Idempotency:
 *    Input: same idempotencyKey twice
 *    Expected: only 1 order created, quantity decremented once
 *
 * 3. Insufficient quantity:
 *    Input: { offerId: "valid", quantity: 100 } (more than available)
 *    Expected: error "Only N items available"
 *
 * 4. Inactive offer:
 *    Input: { offerId: "paused_offer", quantity: 1 }
 *    Expected: error "Offer is not active"
 *
 * 5. Missing offer:
 *    Input: { offerId: "nonexistent", quantity: 1 }
 *    Expected: error "Offer not found"
 *
 * 6. Unauthenticated:
 *    Input: no auth
 *    Expected: error "Sign in required"
 *
 * 7. Concurrent requests:
 *    Input: 2 requests with quantity=1, offer has quantity=1
 *    Expected: 1 succeeds, 1 fails with "Only 0 items available"
 */
