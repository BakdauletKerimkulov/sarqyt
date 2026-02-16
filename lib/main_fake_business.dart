import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/firebase_options.dart';
import 'package:sarqyt/src/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final appBootstrap = AppBootstrap();
}
