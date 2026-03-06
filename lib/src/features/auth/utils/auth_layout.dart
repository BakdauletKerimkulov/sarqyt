// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
    this.startChild,
    this.breakpoint = Breakpoint.desktop,
    this.startFlex = 1,
    this.endFlex = 1,
    this.startBackColor = AppColors.primary,
    this.endBackColor,
    this.startBackground,
  });

  final Widget? startChild;
  final Widget child;
  final double breakpoint;
  final int startFlex;
  final int endFlex;
  final Color startBackColor;
  final Color? endBackColor;
  final String? startBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= breakpoint;

          return Row(
            children: [
              if (isDesktop)
                Expanded(
                  flex: startFlex,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: startBackColor,
                      image: startBackground != null
                          ? DecorationImage(
                              image: AssetImage(startBackground!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: startChild != null
                        ? ResponsiveCenter(child: startChild!)
                        : const SizedBox.expand(),
                  ),
                ),
              Expanded(
                flex: endFlex,
                child: ColoredBox(
                  color: endBackColor ?? Colors.transparent,
                  child: LayoutBuilder(
                    builder: (context, endConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: endConstraints.maxHeight,
                          ),
                          child: ResponsiveCenter(
                            maxContentWidth: 400.0,
                            padding: const EdgeInsets.all(Sizes.p16),
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
