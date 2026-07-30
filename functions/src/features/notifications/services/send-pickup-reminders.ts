/**
 * Sends the up-to-three pickup-window reminders per order (spec 034, R5).
 *
 * Thin orchestration only: {@link dueReminders} decides what is due,
 * this module reads/writes Firestore and sends the push.
 */

import { Timestamp } from "firebase-admin/firestore";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import {
  midWindowMessage,
  NotificationMessage,
  pickupEndingMessage,
  pickupSoonMessage,
} from "../core/messages";
import {
  dueReminders,
  kActiveOrderStatuses,
  kReminderLookaheadHours,
  ReminderKind,
} from "../core/reminders";
import { getCustomerToken } from "../helpers/recipients";
import { sendToTokens } from "../helpers/send-push";
import { formatTimeInZone, resolveStoreTimeZone } from "../helpers/store-timezone";

const kMillisPerHour = 60 * 60 * 1000;

/**
 * Send pickup-window reminders (R5) to every eligible order.
 *
 * @param {Timestamp} now Current time, shared across the whole run.
 * @return {Promise<number>} Number of reminders actually sent.
 */
export async function sendPickupReminders(now: Timestamp): Promise<number> {
  const lookaheadEnd = Timestamp.fromMillis(
    now.toMillis() + kReminderLookaheadHours * kMillisPerHour,
  );

  const snap = await db
    .collection(FirestoreCollections.ORDERS)
    .where("status", "in", kActiveOrderStatuses)
    .where("pickupEndTime", ">=", now)
    .where("pickupEndTime", "<=", lookaheadEnd)
    .limit(500)
    .get();

  let sent = 0;
  for (const doc of snap.docs) {
    const kind = await processOrder(doc, now.toDate());
    if (kind) sent++;
  }
  return sent;
}

/**
 * Decide and, if due, send the one reminder this order needs right now.
 *
 * @param {FirebaseFirestore.QueryDocumentSnapshot} doc Order document.
 * @param {Date} now Current time (shared across the whole run).
 * @return {Promise<ReminderKind | null>} The kind sent, or `null`.
 */
async function processOrder(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
  now: Date,
): Promise<ReminderKind | null> {
  const order = doc.data();
  const due = dueReminders(
    {
      status: order.status as string,
      pickupStartTime: (order.pickupStartTime as Timestamp | undefined)?.toDate(),
      pickupEndTime: (order.pickupEndTime as Timestamp | undefined)?.toDate(),
      remindersSent: order.remindersSent as
        | { beforeStart?: boolean; midWindow?: boolean; beforeEnd?: boolean }
        | undefined,
    },
    now,
  );
  if (due.length === 0) return null;
  const kind = due[0];

  const claimed = await claimReminder(doc.ref, kind);
  if (!claimed) return null;

  await pushReminder(doc.id, order, kind);
  return kind;
}

/**
 * Idempotency guard (R6): re-check the flag inside a transaction before
 * claiming this reminder, so a concurrent run cannot double-send.
 *
 * @param {FirebaseFirestore.DocumentReference} orderRef Order document ref.
 * @param {ReminderKind} kind Reminder kind about to be sent.
 * @return {Promise<boolean>} `true` if this call claimed the reminder.
 */
async function claimReminder(
  orderRef: FirebaseFirestore.DocumentReference,
  kind: ReminderKind,
): Promise<boolean> {
  return db.runTransaction(async (tx) => {
    const fresh = await tx.get(orderRef);
    if (!fresh.exists) return false;

    const freshData = fresh.data()!;
    if (!kActiveOrderStatuses.includes(freshData.status as string)) return false;
    if ((freshData.remindersSent as Record<string, boolean> | undefined)?.[kind]) {
      return false;
    }

    tx.update(orderRef, {
      [`remindersSent.${kind}`]: true,
      updatedAt: serverTimestamp(),
    });
    return true;
  });
}

/**
 * Build the text and push it to the customer. Never throws (spec 034, R10).
 *
 * @param {string} orderId Order document ID.
 * @param {FirebaseFirestore.DocumentData} order Order fields.
 * @param {ReminderKind} kind Which reminder to send.
 * @return {Promise<void>} Resolves once the push attempt is done.
 */
async function pushReminder(
  orderId: string,
  order: FirebaseFirestore.DocumentData,
  kind: ReminderKind,
): Promise<void> {
  try {
    const timeZone = await resolveStoreTimeZone(order.storeId as string | undefined);
    const message = buildReminderMessage(kind, order, timeZone);
    const token = await getCustomerToken(order.customerId as string);
    if (!token) return;

    await sendToTokens([token], {
      ...message,
      timeSensitive: true,
      data: {
        type: "reminder",
        orderId,
        storeId: (order.storeId as string) ?? "",
        storeName: (order.storeName as string) ?? "",
      },
    });
  } catch (error) {
    logError("Reminder push failed", { error, orderId, kind });
  }
}

/**
 * Build the notification text for one reminder kind.
 *
 * @param {ReminderKind} kind Which reminder to build.
 * @param {FirebaseFirestore.DocumentData} order Order fields.
 * @param {string} timeZone Store's IANA timezone for formatting times.
 * @return {NotificationMessage} Title and body for the push.
 */
function buildReminderMessage(
  kind: ReminderKind,
  order: FirebaseFirestore.DocumentData,
  timeZone: string,
): NotificationMessage {
  const orderNumber = (order.orderNumber as number) ?? 0;
  const storeName = (order.storeName as string) ?? "Магазин";
  const endTime = formatTimeInZone(
    (order.pickupEndTime as Timestamp).toDate(),
    timeZone,
  );

  switch (kind) {
  case "beforeStart":
    return pickupSoonMessage({
      storeName,
      startTime: formatTimeInZone(
        (order.pickupStartTime as Timestamp).toDate(),
        timeZone,
      ),
      endTime,
    });
  case "midWindow":
    return midWindowMessage({ orderNumber, endTime });
  case "beforeEnd":
    return pickupEndingMessage({ orderNumber, endTime });
  }
}
