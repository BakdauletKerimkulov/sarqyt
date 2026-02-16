import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/exceptions/app_exception.dart';

part 'error_logger.g.dart';

class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    // * This can be replaced with a call to a crash reporting tool of choice
    log('$error, $stackTrace');
  }

  void logAppExcaption(AppException exception) {
    // * This can be replaced with a call to a crash reporting tool of choice
    log('$exception');
  }
}

@riverpod
ErrorLogger errorLogger(Ref ref) {
  return ErrorLogger();
}
