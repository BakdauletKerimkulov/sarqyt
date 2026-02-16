import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';

class DecoratedBoxWithShadow extends StatelessWidget {
  const DecoratedBoxWithShadow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, -2.0),
            blurRadius: 5.0,
            color: Colors.grey,
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(Sizes.p16), child: child),
    );
  }
}
