import { Timestamp } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logInfo } from "../../../app/logger";
import { sendPickupReminders } from "../services/send-pickup-reminders";
import { sendReviewPrompts } from "../services/send-review-prompts";

/**
 * Runs every 5 minutes. Sends the customer up to three pickup-window
 * reminders per order (spec 034, R5) and a delayed review request after
 * pickup (R7).
 */
export const sendOrderReminders = onSchedule(
  { schedule: "every 5 minutes", region: "asia-south1" },
  async () => {
    const now = Timestamp.now();

    const remindersSent = await sendPickupReminders(now);
    const reviewPromptsSent = await sendReviewPrompts(now);

    if (remindersSent > 0 || reviewPromptsSent > 0) {
      logInfo("sendOrderReminders done", { remindersSent, reviewPromptsSent });
    }
  },
);
