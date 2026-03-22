import * as functionsLogger from "firebase-functions/logger";

type LogContext = Record<string, unknown>;

export function logInfo(message: string, context: LogContext = {}): void {
  functionsLogger.info(message, context);
}

export function logWarn(message: string, context: LogContext = {}): void {
  functionsLogger.warn(message, context);
}

export function logError(message: string, context: LogContext = {}): void {
  functionsLogger.error(message, context);
}
