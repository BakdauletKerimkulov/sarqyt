import 'package:flutter/material.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Full-screen loading indicator shown between sign-in and dashboard.
///
/// Displayed on the `/loading` route while storeShips and business info
/// are being fetched. The redirect system navigates away once data is ready.
class BusinessLoadingScreen extends StatelessWidget {
  const BusinessLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Semantics(
          label: context.loc.loadingPleaseWait,
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
