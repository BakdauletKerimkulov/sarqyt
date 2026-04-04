import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/business_console/data/business_repository.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/routing/scaffold_with_nested_navigation.dart';

part 'store_startup.g.dart';

/// Data loaded once when entering a store scope.
class StoreStartupData {
  const StoreStartupData({required this.storeShip, required this.business});
  final StoreShip storeShip;
  final Business business;
}

@riverpod
Future<StoreStartupData> storeStartup(Ref ref, String storeId) async {
  final user = ref.read(authRepositoryProvider).currentUser;
  if (user == null) throw StateError('User not authenticated');

  final ships = await ref.watch(
    storeShipsListStreamForPartnerProvider(user.uid).future,
  );
  final ship = ships.firstWhere(
    (s) => s.storeId == storeId,
    orElse: () => throw StateError('Store $storeId not found'),
  );

  final business = await ref
      .read(businessRepositoryProvider)
      .fetchBusinessInfo(ship.businessId);
  if (business == null) {
    throw StateError('Business ${ship.businessId} not found');
  }

  return StoreStartupData(storeShip: ship, business: business);
}

/// Scoped provider for the current [Business]. Only valid inside [StoreStartupWidget].
final currentBusinessProvider = Provider<Business>((ref) {
  throw UnimplementedError(
    'currentBusinessProvider must be overridden in StoreStartupWidget scope',
  );
});

/// Scoped stream provider for live [Business] updates. Only valid inside [StoreStartupWidget].
final currentBusinessStreamProvider = StreamProvider<Business>((ref) {
  throw UnimplementedError(
    'currentBusinessStreamProvider must be overridden in StoreStartupWidget scope',
  );
});

class StoreStartupWidget extends ConsumerWidget {
  const StoreStartupWidget({
    super.key,
    required this.storeId,
    required this.navigationShell,
  });

  final String storeId;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(storeStartupProvider(storeId));
    return startup.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).go('/login'),
                child: const Text('Go to login'),
              ),
            ],
          ),
        ),
      ),
      data: (data) => ProviderScope(
        overrides: [
          currentStoreShipProvider.overrideWithValue(data.storeShip),
          currentBusinessProvider.overrideWithValue(data.business),
          currentBusinessStreamProvider.overrideWith((ref) {
            final repo = ref.read(businessRepositoryProvider);
            return repo
                .watchBusiness(data.business.id)
                .map((b) => b ?? data.business);
          }),
        ],
        child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
      ),
    );
  }
}
