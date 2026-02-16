import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class InfoBadge extends StatelessWidget {
  const InfoBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Sizes.p8, vertical: Sizes.p4),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.light,
        borderRadius: BorderRadius.circular(Sizes.p12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
