/**
 * The single place in the project that talks to FCM.
 *
 * Every push goes through {@link sendToTokens}: it multicasts one payload,
 * drops tokens FCM reports as dead and swallows every failure — a push must
 * never roll back the business operation that triggered it (spec 034, R10).
 */

import { FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { db } from "../../../app/firebase";
import { logError, logInfo } from "../../../app/logger";
import { FirestoreCollections } from "../../../shared/constants/constants";

/** A token together with where it is stored, so it can be deleted if stale. */
export interface PushToken {
  uid: string;
  token: string;
  /** Field on `users/{uid}` this token was read from. */
  field: string;
}

/** What a single multicast sends: visible text plus the deep-link data. */
export interface PushPayload {
  title: string;
  body: string;
  data: Record<string, string>;
}

/** FCM error codes that mean the token is gone for good. */
const kDeadTokenCodes = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-argument",
];

/**
 * Send one payload to every given token.
 *
 * @param {PushToken[]} tokens Recipients; an empty list is a no-op.
 * @param {PushPayload} payload Notification text and data.
 * @return {Promise<void>} Always resolves — errors are logged, never thrown.
 */
export async function sendToTokens(
  tokens: PushToken[],
  payload: PushPayload,
): Promise<void> {
  if (tokens.length === 0) return;

  try {
    const response = await getMessaging().sendEachForMulticast({
      tokens: tokens.map((recipient) => recipient.token),
      notification: { title: payload.title, body: payload.body },
      data: payload.data,
    });

    logInfo("Push sent", {
      type: payload.data.type,
      orderId: payload.data.orderId,
      successCount: response.successCount,
      failureCount: response.failureCount,
    });

    await deleteDeadTokens(tokens, response.responses);
  } catch (error) {
    logError("Push failed", {
      error,
      type: payload.data.type,
      orderId: payload.data.orderId,
    });
  }
}

/** Shape of the per-token result inside a multicast response. */
interface SendResponse {
  success: boolean;
  error?: { code?: string };
}

/**
 * Remove tokens FCM rejected as unregistered so the next run skips them.
 *
 * @param {PushToken[]} tokens Recipients, in the order they were sent.
 * @param {SendResponse[]} responses Per-token results from FCM.
 * @return {Promise<void>} Resolves once every stale token is cleared.
 */
async function deleteDeadTokens(
  tokens: PushToken[],
  responses: SendResponse[],
): Promise<void> {
  const stale = tokens.filter((recipient, index) => {
    const result = responses[index];
    if (!result || result.success) return false;
    const code = result.error?.code;
    if (code && kDeadTokenCodes.includes(code)) return true;
    logError("Push rejected for token", { uid: recipient.uid, code });
    return false;
  });

  await Promise.all(stale.map((recipient) => {
    logInfo("Deleting stale FCM token", {
      uid: recipient.uid,
      field: recipient.field,
    });
    return db
      .collection(FirestoreCollections.USERS)
      .doc(recipient.uid)
      .update({ [recipient.field]: FieldValue.delete() });
  }));
}
