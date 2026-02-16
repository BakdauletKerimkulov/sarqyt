import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class AppStyles {
  static const ButtonStyle buttonStyle = ButtonStyle(
    foregroundColor: WidgetStatePropertyAll(AppColors.primary),
  );

  static final ButtonStyle filledButtonStyle = ButtonStyle(
    backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
    foregroundColor: const WidgetStatePropertyAll(Colors.white),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.p12)),
    ),
  );
}
