import 'package:flutter/cupertino.dart';
import 'package:sarqyt/src/app_bootstrap.dart';
import 'package:sarqyt/src/app_bootstrap_fakes.dart';
import 'package:sarqyt/src/app_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appBootStrap = AppBootstrap();
  final container = await appBootStrap.createsFakeProviderContainer();

  final root = appBootStrap.createRootWidget(
    container: container,
    app: const MyAppClient(),
  );
  runApp(root);
}
