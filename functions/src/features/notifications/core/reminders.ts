/**
 * Pure scheduling logic for pickup-window reminders (spec 034, R5/R6/R12).
 *
 * Firestore-free by design (ai_toolkit/firebase.md → core/): the scheduler
 * handler reads/writes documents and calls into here; this module only
 * decides which single reminder, if any, is due for one order right now.
 */

/** Which pickup-window reminder a due check can return. */
export type ReminderKind = "beforeStart" | "midWindow" | "beforeEnd";

/** How far ahead the scheduler query looks for candidate orders (R5). */
export const kReminderLookaheadHours = 12;

/** Statuses a pickup-window reminder may still be sent for (R5). */
export const kActiveOrderStatuses = ["confirmed", "preparing", "readyForPickup"];

const kLeadMinutes = 15;
const kLeadMs = kLeadMinutes * 60 * 1000;

/** Which reminders have already been sent (or suppressed) for an order. */
export interface ReminderFlags {
  beforeStart?: boolean;
  midWindow?: boolean;
  beforeEnd?: boolean;
  reviewPrompt?: boolean;
}

/** How long after `completedAt` the review prompt fires (R7). */
const kReviewPromptDelayMs = 2 * 60 * 60 * 1000;

/** Order fields {@link isReviewPromptDue} needs. */
export interface ReviewPromptOrder {
  status: string;
  completedAt?: Date;
  remindersSent?: ReminderFlags;
}

/** Order fields {@link dueReminders} needs. */
export interface ReminderOrder {
  status: string;
  pickupStartTime?: Date;
  pickupEndTime?: Date;
  remindersSent?: ReminderFlags;
}

interface Candidate {
  kind: ReminderKind;
  triggerAt: number;
  closeAt: number;
}

/**
 * Which single pickup-window reminder, if any, should be sent right now.
 *
 * At most one kind is returned (E2): when a short pickup window makes
 * several reminder windows overlap, only the latest-triggered, not-yet-sent
 * kind fires — the others are simply not returned. A reminder whose window
 * has already closed is never returned, even after downtime (E4); it stays
 * unsent forever, which is harmless once the order leaves an active status.
 *
 * @param {ReminderOrder} order Order fields the schedule is computed from.
 * @param {Date} now Current time, injected so this stays pure and testable.
 * @return {ReminderKind[]} Empty, or a single due reminder kind.
 */
export function dueReminders(order: ReminderOrder, now: Date): ReminderKind[] {
  if (!kActiveOrderStatuses.includes(order.status)) return [];
  if (!order.pickupStartTime || !order.pickupEndTime) return [];

  const start = order.pickupStartTime.getTime();
  const end = order.pickupEndTime.getTime();
  const mid = start + (end - start) / 2;
  const nowMs = now.getTime();
  const sent = order.remindersSent ?? {};

  const candidates: Candidate[] = [
    { kind: "beforeStart", triggerAt: start - kLeadMs, closeAt: start },
    { kind: "midWindow", triggerAt: mid, closeAt: end },
    { kind: "beforeEnd", triggerAt: end - kLeadMs, closeAt: end },
  ];

  const due = candidates
    .filter((candidate) => !sent[candidate.kind])
    .filter((candidate) => nowMs >= candidate.triggerAt && nowMs < candidate.closeAt)
    .sort((a, b) => b.triggerAt - a.triggerAt);

  return due.length > 0 ? [due[0].kind] : [];
}

/**
 * Whether a delayed review-request push should fire for this order (R7).
 *
 * @param {ReviewPromptOrder} order Order fields the check is computed from.
 * @param {Date} now Current time, injected so this stays pure and testable.
 * @return {boolean} `true` once 2 hours have passed since `completedAt`.
 */
export function isReviewPromptDue(order: ReviewPromptOrder, now: Date): boolean {
  if (order.status !== "completed") return false;
  if (!order.completedAt) return false;
  if (order.remindersSent?.reviewPrompt) return false;

  return now.getTime() - order.completedAt.getTime() >= kReviewPromptDelayMs;
}
