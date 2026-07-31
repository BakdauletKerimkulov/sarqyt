import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sarqyt/firebase_options.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/app_bootstrap_firebase.dart';
import 'package:sarqyt/src/app_business.dart';
import 'package:sarqyt/src/features/notifications/domain/push_audience.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // turn off the # in the URLs on the web
  usePathUrlStrategy();

  final appBootStrap = AppBootstrap();
  //! Uncomment this to connect to the Firebase emulators
  //await appBootStrap.setupEmulators();
  final container = await appBootStrap.createFirebaseProviderContainer(
    pushAudience: PushAudience.business,
  );
  appBootStrap.initializeServices(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyAppBusiness(),
    ),
  );
}
