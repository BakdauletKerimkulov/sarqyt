import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';
import 'package:sarqyt/src/features/auth/application/user_token_refresh_service.dart';
import 'package:sarqyt/src/features/notifications/data/push_notification_service.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Helper class to initialize services and configure the error handlers
class AppBootstrap {
  /// Initialize services that must start at app launch.
  ///
  /// Call before [runApp]. The caller wraps the app in
  /// [UncontrolledProviderScope] so that `riverpod_lint` can verify
  /// the scope is present at the widget-tree root.
  void initializeServices(ProviderContainer container) {
    // * Initialize user token refresh service (forces ID token refresh
    // * when server updates custom claims via refreshTime in users/{uid})
    container.read(userTokenRefreshServiceProvider);
    // * listen (not read) so the provider stays subscribed and re-runs when
    // * authStateChanges emits a signed-in user.
    container.listen(initPushNotificationsProvider, (_, __) {});
    final errorLogger = container.read(errorLoggerProvider);
    registerErrorHandler(errorLogger);
  }

  void registerErrorHandler(ErrorLogger errorLogger) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      errorLogger.logError(details.exception, details.stack);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      errorLogger.logError(error, stack);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
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
