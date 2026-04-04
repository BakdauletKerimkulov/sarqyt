import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';
import 'package:sarqyt/src/features/auth/application/user_token_refresh_service.dart';
import 'package:sarqyt/src/features/notifications/data/push_notification_service.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Helper class to initialize services and configure the error handlers
class AppBootstrap {
  Widget createRootWidget({
    required ProviderContainer container,
    required Widget app,
  }) {
    // * Initialize user token refresh service (forces ID token refresh
    // * when server updates custom claims via refreshTime in users/{uid})
    container.read(userTokenRefreshServiceProvider);
    container.read(initPushNotificationsProvider);
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
