import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class DashboardPageLayout extends StatelessWidget {
  const DashboardPageLayout({
    super.key,
    required this.title,
    this.onBackPressed,
    required this.subtitle,
    required this.child,
    this.onCreatePressed,
    this.createLabel = 'Create',
    this.padding = const EdgeInsets.all(Sizes.p16),
  });

  final String title;
  final VoidCallback? onBackPressed;

  final String subtitle;
  final Widget child;
  final VoidCallback? onCreatePressed;
  final String createLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Sizes.p16,
            runSpacing: Sizes.p16,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onBackPressed != null)
                    Padding(
                      padding: const EdgeInsets.only(right: Sizes.p8),
                      child: IconButton(
                        onPressed: onBackPressed,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Back',
                      ),
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(subtitle.hardcoded),
                    ],
                  ),
                ],
              ),

              if (onCreatePressed != null)
                ElevatedButton.icon(
                  onPressed: onCreatePressed,
                  icon: const Icon(Icons.add),
                  label: Text(createLabel.hardcoded),
                ),
            ],
          ),
          gapH24,
          child,
        ],
      ),
    );
  }
}
