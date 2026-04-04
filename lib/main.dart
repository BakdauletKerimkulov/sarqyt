import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/firebase_options.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/app_bootstrap_firebase.dart';
import 'package:sarqyt/src/app_business.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appBootStrap = AppBootstrap();
  //! Uncomment this to connect to the Firebase emulators
  //await appBootStrap.setupEmulators();
  final container = await appBootStrap.createFirebaseProviderContainer();
  final root = appBootStrap.createRootWidget(
    container: container,
    app: const MyAppBusiness(),
  );

  runApp(root);
}
