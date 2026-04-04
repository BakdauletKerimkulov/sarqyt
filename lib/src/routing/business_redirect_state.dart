import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';

part 'business_redirect_state.g.dart';

class BusinessRedirectState {
  const BusinessRedirectState({
    required this.user,
    required this.role,
    required this.storeShips,
    required this.isLoading,
  });

  final AppUser? user;
  final UserRole role;
  final List<StoreShip> storeShips;
  final bool isLoading;
}

/// Single provider that aggregates all data needed for business redirect.
/// Redirect reads this synchronously — no async in redirect callback.
@Riverpod(keepAlive: true)
BusinessRedirectState businessRedirectState(Ref ref) {
  // Use authRepository.currentUser instead of authStateChanges stream,
  // because authStateChanges doesn't emit on reload() or token refresh.
  // The role and storeShips providers already trigger rebuilds via their streams.
  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  final roleAsync = ref.watch(userRoleProvider);
  final shipsAsync = ref.watch(currentPartnerStoreShipsProvider);

  final role = roleAsync.when(
    data: (r) => r,
    loading: () => UserRole.guest,
    error: (_, __) => UserRole.guest,
  );
  final storeShips = shipsAsync.when(
    data: (s) => s,
    loading: () => const <StoreShip>[],
    error: (_, __) => const <StoreShip>[],
  );
  final isLoading = roleAsync.isLoading || shipsAsync.isLoading;

  return BusinessRedirectState(
    user: user,
    role: role,
    storeShips: storeShips,
    isLoading: isLoading,
  );
}
