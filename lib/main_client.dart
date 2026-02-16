import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/firebase_options.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/app_bootstrap_firebase.dart';
import 'package:sarqyt/src/app_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appBootStrap = AppBootstrap();

  final container = await appBootStrap.createFirebaseProviderContainer();

  final root = appBootStrap.createRootWidget(
    container: container,
    app: const MyAppClient(),
  );

  runApp(root);
}
