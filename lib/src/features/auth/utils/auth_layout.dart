// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.endBuilder,
    this.startBuilder,
    this.breakpoint = Breakpoint.desktop,
    this.startFlex = 1,
    this.endFlex = 1,
    this.startBackColor = AppColors.primary,
    this.endBackColor,
    this.startBackground,
  });

  final Widget Function(BuildContext)? startBuilder;
  final Widget Function(BuildContext) endBuilder;
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: startBackColor,
                      image: startBackground != null
                          ? DecorationImage(
                              image: AssetImage(startBackground!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: startBuilder != null
                        ? ResponsiveCenter(child: startBuilder!(context))
                        : null,
                  ),
                ),
              Expanded(
                flex: endFlex,
                child: Container(
                  decoration: BoxDecoration(color: endBackColor),
                  child: SingleChildScrollView(
                    child: ResponsiveCenter(
                      maxContentWidth: isDesktop ? 400.0 : double.infinity,
                      padding: EdgeInsets.all(Sizes.p16),
                      child: endBuilder(context),
                    ),
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
