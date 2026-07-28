import { describe, expect, it } from "vitest";
import { dueReminders, isReviewPromptDue, ReminderOrder } from "./reminders.js";

const kMinute = 60 * 1000;
const kHour = 60 * kMinute;

/**
 * A 2-hour pickup window order fixture: 12:00–14:00 UTC.
 * @param {Partial<ReminderOrder>} overrides Field overrides.
 * @return {ReminderOrder} Order fixture for {@link dueReminders}.
 */
function windowOrder(overrides: Partial<ReminderOrder> = {}): ReminderOrder {
  const start = new Date("2026-07-27T12:00:00Z");
  const end = new Date("2026-07-27T14:00:00Z");
  return {
    status: "confirmed",
    pickupStartTime: start,
    pickupEndTime: end,
    ...overrides,
  };
}

describe("dueReminders", () => {
  it("returns beforeStart in [start-15m, start)", () => {
    const order = windowOrder();
    const start = order.pickupStartTime.getTime();

    expect(dueReminders(order, new Date(start - 15 * kMinute))).toEqual(["beforeStart"]);
    expect(dueReminders(order, new Date(start - 1 * kMinute))).toEqual(["beforeStart"]);
    expect(dueReminders(order, new Date(start))).not.toContain("beforeStart");
  });

  it("returns midWindow after the middle of the pickup window", () => {
    const order = windowOrder();
    const start = order.pickupStartTime.getTime();
    const end = order.pickupEndTime.getTime();
    const mid = start + (end - start) / 2;

    expect(dueReminders(order, new Date(mid))).toEqual(["midWindow"]);
    expect(dueReminders(order, new Date(mid + 5 * kMinute))).toEqual(["midWindow"]);
  });

  it("returns beforeEnd in [end-15m, end)", () => {
    const order = windowOrder();
    const end = order.pickupEndTime.getTime();

    expect(dueReminders(order, new Date(end - 15 * kMinute))).toEqual(["beforeEnd"]);
    expect(dueReminders(order, new Date(end - 1 * kMinute))).toEqual(["beforeEnd"]);
    expect(dueReminders(order, new Date(end))).not.toContain("beforeEnd");
  });

  it("returns nothing when pickupStartTime/pickupEndTime are missing (E1)", () => {
    const order = windowOrder({ pickupStartTime: undefined, pickupEndTime: undefined });
    expect(dueReminders(order, new Date())).toEqual([]);
  });

  it("returns at most one reminder per run when windows overlap (E2)", () => {
    // Short 20-minute window: beforeStart[-15,0), midWindow trigger @10,
    // beforeEnd[5,20) all land close together.
    const start = new Date("2026-07-27T12:00:00Z");
    const end = new Date("2026-07-27T12:20:00Z");
    const order = { status: "confirmed", pickupStartTime: start, pickupEndTime: end };

    // At start+12m: midWindow (trigger +10) and beforeEnd (trigger +5) both due —
    // only the later-triggered one (midWindow) should be returned.
    const result = dueReminders(order, new Date(start.getTime() + 12 * kMinute));
    expect(result).toHaveLength(1);
    expect(result).toEqual(["midWindow"]);
  });

  it("does not fire a reminder late once its window has closed, even after downtime (E4)", () => {
    const order = windowOrder();
    const end = order.pickupEndTime.getTime();

    // Function only runs long after the whole window closed.
    expect(dueReminders(order, new Date(end + 2 * kHour))).toEqual([]);
  });

  it("returns nothing for completed, cancelled or expired orders", () => {
    for (const status of ["completed", "cancelled", "expired"]) {
      const order = windowOrder({ status });
      const mid = order.pickupStartTime.getTime() +
        (order.pickupEndTime.getTime() - order.pickupStartTime.getTime()) / 2;
      expect(dueReminders(order, new Date(mid))).toEqual([]);
    }
  });

  it("skips a reminder already marked sent, even while its window is open (R12/R6)", () => {
    const order = windowOrder({ remindersSent: { midWindow: true } });
    const mid = order.pickupStartTime.getTime() +
      (order.pickupEndTime.getTime() - order.pickupStartTime.getTime()) / 2;
    expect(dueReminders(order, new Date(mid))).toEqual([]);
  });

  it("treats a missing remindersSent field as all-false (R12)", () => {
    const order = windowOrder();
    expect(order.remindersSent).toBeUndefined();
    const start = order.pickupStartTime.getTime();
    expect(dueReminders(order, new Date(start - 5 * kMinute))).toEqual(["beforeStart"]);
  });
});

describe("isReviewPromptDue", () => {
  it("is due 2 hours after completedAt for a completed order", () => {
    const completedAt = new Date("2026-07-27T12:00:00Z");
    const order = { status: "completed", completedAt };

    expect(isReviewPromptDue(order, new Date("2026-07-27T13:59:00Z"))).toBe(false);
    expect(isReviewPromptDue(order, new Date("2026-07-27T14:00:00Z"))).toBe(true);
  });

  it("is not due without completedAt", () => {
    const order = { status: "completed" };
    expect(isReviewPromptDue(order, new Date("2026-07-27T14:00:00Z"))).toBe(false);
  });

  it("is not due for a non-completed order", () => {
    const order = { status: "confirmed", completedAt: new Date("2026-07-27T12:00:00Z") };
    expect(isReviewPromptDue(order, new Date("2026-07-27T14:00:00Z"))).toBe(false);
  });

  it("is not due once the reviewPrompt flag is already set", () => {
    const order = {
      status: "completed",
      completedAt: new Date("2026-07-27T12:00:00Z"),
      remindersSent: { reviewPrompt: true },
    };
    expect(isReviewPromptDue(order, new Date("2026-07-27T14:00:00Z"))).toBe(false);
  });
});
