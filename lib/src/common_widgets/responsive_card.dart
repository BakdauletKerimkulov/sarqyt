import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(padding: const EdgeInsets.all(Sizes.p16), child: child),
    );
  }
}
