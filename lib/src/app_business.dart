import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class MyAppBusiness extends ConsumerWidget {
  const MyAppBusiness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(businessRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'appBusiness',
      onGenerateTitle: (context) => 'SarqytBusiness'.hardcoded,
      theme: ThemeData(
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(AppColors.primary),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((state) {
            if (state.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return null;
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(Colors.white),
            backgroundColor: WidgetStatePropertyAll(AppColors.primary),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            side: WidgetStatePropertyAll(
              BorderSide(color: AppColors.primary, width: 2.0),
            ),
            foregroundColor: WidgetStatePropertyAll(AppColors.primary),
          ),
        ),
        appBarTheme: AppBarThemeData(backgroundColor: Colors.transparent),
      ),
    );
  }
}
