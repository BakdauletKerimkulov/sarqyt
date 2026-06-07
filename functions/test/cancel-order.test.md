/**
 * Manual test checklist for cancelOrder Cloud Function.
 *
 * 1. Happy path (customer cancels):
 *    Input: { orderId: "confirmed_order" } as customer
 *    Expected: status=cancelled, offer.quantity restored
 *
 * 2. Happy path (store owner cancels):
 *    Input: { orderId: "confirmed_order" } as store owner
 *    Expected: status=cancelled, offer.quantity restored
 *
 * 3. Idempotency:
 *    Input: cancel same order twice
 *    Expected: second call returns success (no error, no double restore)
 *
 * 4. Cannot cancel completed:
 *    Input: { orderId: "completed_order" }
 *    Expected: error "Cannot cancel order with status: completed"
 *
 * 5. Cannot cancel readyForPickup:
 *    Input: { orderId: "ready_order" }
 *    Expected: error "Cannot cancel order with status: readyForPickup"
 *
 * 6. Permission denied (other user):
 *    Input: { orderId: "other_users_order" } as random user
 *    Expected: error "No access to this order"
 *
 * 7. Quantity restoration:
 *    Before: offer.quantity = 3, order.itemQuantity = 2
 *    After cancel: offer.quantity = 5
 */
