import 'package:flutter/material.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/verify_email/verify_email_checker.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      endBuilder: (context) => VerifyEmailChecker(),
    );
  }
}
