import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class BusinessNotAuthorizedScreen extends StatelessWidget {
  const BusinessNotAuthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You are not authorized'.hardcoded,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gapH16,
          PrimaryButton(
            text: 'Sign In'.hardcoded,
            onPressed: () => context.goNamed(BusinessRoute.signIn.name),
          ),
        ],
      ),
    );
  }
}
