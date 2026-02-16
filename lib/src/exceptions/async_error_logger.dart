import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/exceptions/app_exception.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';

base class AsyncErrorLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final errorLogger = context.container.read(errorLoggerProvider);
    final error = _findError(newValue);
    if (error != null) {
      if (error.error is AppException) {
        errorLogger.logAppExcaption(error.error as AppException);
      } else {
        errorLogger.logError(error.error, error.stackTrace);
      }
    }
  }

  AsyncError<dynamic>? _findError(Object? value) {
    if (value is AsyncError) {
      return value;
    } else {
      return null;
    }
  }
}
