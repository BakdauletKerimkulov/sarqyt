/**
 * Sends the delayed review-request push after a completed pickup (spec 034, R7).
 */

import { Timestamp } from "firebase-admin/firestore";
import { db, serverTimestamp } from "../../../app/firebase";
import { logError } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";
import { reviewPromptMessage } from "../core/messages";
import { isReviewPromptDue } from "../core/reminders";
import { getCustomerToken } from "../helpers/recipients";
import { sendToTokens } from "../helpers/send-push";

const kMillisPerHour = 60 * 60 * 1000;

/** How long after `completedAt` the review prompt fires (R7). */
const kReviewPromptDelayHours = 2;

/** How far back the review-prompt query looks, to bound the scan (R7). */
const kReviewPromptLookbackHours = 24;

/**
 * Send the delayed review-request push to every eligible completed order.
 *
 * @param {Timestamp} now Current time, shared across the whole run.
 * @return {Promise<number>} Number of review prompts actually sent.
 */
export async function sendReviewPrompts(now: Timestamp): Promise<number> {
  const oldestEligible = Timestamp.fromMillis(
    now.toMillis() - kReviewPromptLookbackHours * kMillisPerHour,
  );
  const newestEligible = Timestamp.fromMillis(
    now.toMillis() - kReviewPromptDelayHours * kMillisPerHour,
  );

  const snap = await db
    .collection(FirestoreCollections.ORDERS)
    .where("status", "==", "completed")
    .where("completedAt", ">=", oldestEligible)
    .where("completedAt", "<=", newestEligible)
    .limit(500)
    .get();

  let sent = 0;
  for (const doc of snap.docs) {
    const didSend = await processReviewPrompt(doc, now.toDate());
    if (didSend) sent++;
  }
  return sent;
}

/**
 * Decide and, if due, send the review-request push for this completed order.
 *
 * Checks for an existing review before claiming the flag, mirroring
 * `ReviewRepository.hasReviewForOrder` (spec 034, R7): a review already
 * left means no push, without marking the order — cheap enough to
 * recheck every 5 minutes until the order ages out of the query window.
 *
 * @param {FirebaseFirestore.QueryDocumentSnapshot} doc Order document.
 * @param {Date} now Current time (shared across the whole run).
 * @return {Promise<boolean>} `true` if a review prompt was sent.
 */
async function processReviewPrompt(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
  now: Date,
): Promise<boolean> {
  const order = doc.data();
  const due = isReviewPromptDue(
    {
      status: order.status as string,
      completedAt: (order.completedAt as Timestamp | undefined)?.toDate(),
      remindersSent: order.remindersSent as { reviewPrompt?: boolean } | undefined,
    },
    now,
  );
  if (!due) return false;

  const reviewSnap = await db
    .collection("reviews")
    .where("orderId", "==", doc.id)
    .limit(1)
    .get();
  if (!reviewSnap.empty) return false;

  const claimed = await claimReviewPrompt(doc.ref);
  if (!claimed) return false;

  await pushReviewPrompt(doc.id, order);
  return true;
}

/**
 * Idempotency guard (R6): re-check the flag inside a transaction before
 * claiming the review prompt, so a concurrent run cannot double-send.
 *
 * @param {FirebaseFirestore.DocumentReference} orderRef Order document ref.
 * @return {Promise<boolean>} `true` if this call claimed the review prompt.
 */
async function claimReviewPrompt(
  orderRef: FirebaseFirestore.DocumentReference,
): Promise<boolean> {
  return db.runTransaction(async (tx) => {
    const fresh = await tx.get(orderRef);
    if (!fresh.exists) return false;

    const freshData = fresh.data()!;
    if (freshData.status !== "completed") return false;
    if ((freshData.remindersSent as Record<string, boolean> | undefined)?.reviewPrompt) {
      return false;
    }

    tx.update(orderRef, {
      "remindersSent.reviewPrompt": true,
      "updatedAt": serverTimestamp(),
    });
    return true;
  });
}

/**
 * Build the text and push the review request. Never throws (spec 034, R10).
 *
 * @param {string} orderId Order document ID.
 * @param {FirebaseFirestore.DocumentData} order Order fields.
 * @return {Promise<void>} Resolves once the push attempt is done.
 */
async function pushReviewPrompt(
  orderId: string,
  order: FirebaseFirestore.DocumentData,
): Promise<void> {
  try {
    const storeName = (order.storeName as string) ?? "Магазин";
    const itemName = (order.itemName as string) ?? "заказ";
    const message = reviewPromptMessage({ storeName, itemName });
    const token = await getCustomerToken(order.customerId as string);
    if (!token) return;

    await sendToTokens([token], {
      ...message,
      data: {
        type: "review_prompt",
        orderId,
        storeId: (order.storeId as string) ?? "",
        storeName,
      },
    });
  } catch (error) {
    logError("Review prompt push failed", { error, orderId });
  }
}
