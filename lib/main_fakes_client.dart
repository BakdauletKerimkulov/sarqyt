import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/app_bootstrap_fakes.dart';
import 'package:sarqyt/src/app_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appBootStrap = AppBootstrap();
  final container = await appBootStrap.createsFakeProviderContainer();

  appBootStrap.initializeServices(container);
  runApp(
    UncontrolledProviderScope(container: container, child: const MyAppClient()),
  );
}
