import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';
import 'package:sarqyt/src/features/auth/data/user_metadata_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Helper class to initialize services and configure the error handlers
class AppBootstrap {
  Widget createRootWidget({
    required ProviderContainer container,
    required Widget app,
  }) {
    // * Initialize userRefreshToken service
    container.read(userMetadataRepositoryProvider);
    final errorLogger = container.read(errorLoggerProvider);
    registerErrorHandler(errorLogger);

    return UncontrolledProviderScope(container: container, child: app);
  }

  void registerErrorHandler(ErrorLogger errorLogger) {
    // * Show some error UI if any uncaught exception happens
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      errorLogger.logError(details.exception, details.stack);
    };
    // * Handle errors from the underlying platform/OS
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      errorLogger.logError(error, stack);
      return true;
    };

    // * Show some error UI when any widget in the app fails to build
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('An error occured'.hardcoded),
        ),
        body: Center(child: Text(details.toString())),
      );
    };
  }
}
