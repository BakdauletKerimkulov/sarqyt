// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class OnboardingPanel extends StatelessWidget {
  const OnboardingPanel({
    super.key,
    this.onBackPressed,
    this.onSkip,
    required this.title,
    this.subtitle,
    this.topSpacerHeight = 0,
    this.bottomSpacerHeight = 0,
    required this.child,
  });

  final VoidCallback? onBackPressed;
  final VoidCallback? onSkip;
  final String title;
  final String? subtitle;
  final double topSpacerHeight;
  final double bottomSpacerHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topSpacerHeight > 0) SizedBox(height: topSpacerHeight),

        if (onBackPressed != null || onSkip != null) ...[
          Row(
            children: [
              if (onBackPressed != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackPressed,
                  ),
                ),
              ],
              const Spacer(),

              if (onSkip != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onSkip,
                  ),
                ),
              ],
            ],
          ),
          gapH8,
        ],

        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[gapH16, Text(subtitle!)],
        gapH24,
        child,
        if (bottomSpacerHeight > 0) SizedBox(height: bottomSpacerHeight),
      ],
    );
  }
}
