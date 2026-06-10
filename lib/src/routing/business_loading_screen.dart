import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

/// Full-screen loading indicator shown between sign-in and dashboard.
///
/// Displayed on the `/loading` route while storeShips and business info
/// are being fetched. The redirect system navigates away once data is ready.
///
/// Watches [currentPartnerStoreShipsProvider] for errors and shows a retry UI.
class BusinessLoadingScreen extends ConsumerWidget {
  const BusinessLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShipsAsync = ref.watch(currentPartnerStoreShipsProvider);

    return storeShipsAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Semantics(
            label: context.loc.loadingPleaseWait,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      data: (_) => Scaffold(
        body: Center(
          child: Semantics(
            label: context.loc.loadingPleaseWait,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.loc.errorGeneric),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(currentPartnerStoreShipsProvider),
                child: Text(context.loc.retry),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: Text(context.loc.goToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
