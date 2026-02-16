import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class MyAppClient extends ConsumerWidget {
  const MyAppClient({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(clientRouterProvider);
    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        tabBarTheme: TabBarThemeData(
          unselectedLabelColor: AppColors.primary,
          labelColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColors.primary),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.p24),
              ),
            ),
          ),
        ),
        listTileTheme: ListTileThemeData(iconColor: AppColors.primary),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'appClient',
      onGenerateTitle: (context) => 'Sarqyt'.hardcoded,
    );
  }
}
