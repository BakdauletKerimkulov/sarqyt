import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/domain/fake_app_user.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_redirect_state.dart';
import 'package:sarqyt/src/routing/business_router.dart';

/// Shorthand to call [businessRedirect] with the new signature.
String? _redirect({
  AppUser? user,
  UserRole role = UserRole.guest,
  List<StoreShip> storeShips = const [],
  bool isLoading = false,
  required String path,
}) {
  return businessRedirect(
    redirectState: BusinessRedirectState(
      user: user,
      role: role,
      storeShips: storeShips,
      isLoading: isLoading,
    ),
    path: path,
  );
}

/// Helper to build a [FakeAppUser] with common defaults.
FakeAppUser _user({
  UserRole role = UserRole.partner,
  bool emailVerified = true,
}) {
  return FakeAppUser(
    uid: 'uid-1',
    email: 'test@example.com',
    password: 'pass',
    role: role,
    emailVerified: emailVerified,
  );
}

/// StoreShip with pending onboarding (storeCreated).
const _pendingShips = [
  StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: [],
    name: 'My Store',
    storeRole: StoreRole.owner,
    onboardingStatus: OnboardingStatus.storeCreated,
  ),
];

/// StoreShip with completed onboarding.
const _completedShips = [
  StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: [],
    name: 'My Store',
    storeRole: StoreRole.owner,
    onboardingStatus: OnboardingStatus.completed,
  ),
];

void main() {
  // ── Layer 1: Loading ──
  group('Layer 1 — Loading', () {
    test('isLoading → stay (no redirect)', () {
      final result = _redirect(
        user: null,
        isLoading: true,
        path: '/login',
      );
      expect(result, isNull);
    });
  });

  // ── Layer 2: Unauthenticated (user == null) ──
  group('Layer 2 — Unauthenticated', () {
    test('/login → stay', () {
      final result = _redirect(path: '/login');
      expect(result, isNull);
    });

    test('/onboarding/inbound/create-account → stay', () {
      final result = _redirect(
        path: '/onboarding/inbound/create-account',
      );
      expect(result, isNull);
    });

    test('/stores → /login', () {
      final result = _redirect(path: '/stores');
      expect(result, '/login');
    });

    test('/ → /login', () {
      final result = _redirect(path: '/');
      expect(result, '/login');
    });

    test('/forbidden → /login', () {
      final result = _redirect(path: '/forbidden');
      expect(result, '/login');
    });
  });

  // ── Layer 3: Email + Role ──
  group('Layer 3 — Email not verified', () {
    late FakeAppUser unverified;

    setUp(() {
      unverified = _user(emailVerified: false);
    });

    test('/onboarding/inbound/verify-email → stay', () {
      final result = _redirect(
        user: unverified,
        role: UserRole.partner,
        path: '/onboarding/inbound/verify-email',
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      final result = _redirect(
        user: unverified,
        role: UserRole.partner,
        path: '/stores',
      );
      expect(result, '/onboarding/inbound/verify-email');
    });

    test('/login → /onboarding/inbound/verify-email', () {
      final result = _redirect(
        user: unverified,
        role: UserRole.partner,
        path: '/login',
      );
      expect(result, '/onboarding/inbound/verify-email');
    });
  });

  group('Layer 3 — Verified but guest (completeMerchant still running)', () {
    late FakeAppUser verified;

    setUp(() {
      verified = _user(emailVerified: true);
    });

    test('/onboarding/inbound/verify-email → stay', () {
      final result = _redirect(
        user: verified,
        role: UserRole.guest,
        path: '/onboarding/inbound/verify-email',
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      final result = _redirect(
        user: verified,
        role: UserRole.guest,
        path: '/stores',
      );
      expect(result, '/onboarding/inbound/verify-email');
    });

    test('/forbidden → /onboarding/inbound/verify-email', () {
      final result = _redirect(
        user: verified,
        role: UserRole.guest,
        path: '/forbidden',
      );
      expect(result, '/onboarding/inbound/verify-email');
    });
  });

  group('Layer 4 — Admin', () {
    late FakeAppUser admin;

    setUp(() {
      admin = _user(role: UserRole.admin);
    });

    test('/login → /stores', () {
      final result = _redirect(
        user: admin,
        role: UserRole.admin,
        path: '/login',
      );
      expect(result, '/stores');
    });

    test('/onboarding/inbound → /stores', () {
      final result = _redirect(
        user: admin,
        role: UserRole.admin,
        path: '/onboarding/inbound',
      );
      expect(result, '/stores');
    });

    test('/onboarding/create-item → /stores', () {
      final result = _redirect(
        user: admin,
        role: UserRole.admin,
        path: '/onboarding/create-item',
      );
      expect(result, '/stores');
    });

    test('/ → stay', () {
      final result = _redirect(
        user: admin,
        role: UserRole.admin,
        path: '/',
      );
      expect(result, isNull);
    });

    test('/stores/abc/dashboard → stay', () {
      final result = _redirect(
        user: admin,
        role: UserRole.admin,
        path: '/stores/abc/dashboard',
      );
      expect(result, isNull);
    });
  });

  group('Layer 5 — Verified non-partner (customer)', () {
    late FakeAppUser customer;

    setUp(() {
      customer = _user(role: UserRole.customer);
    });

    test('/forbidden → stay', () {
      final result = _redirect(
        user: customer,
        role: UserRole.customer,
        path: '/forbidden',
      );
      expect(result, isNull);
    });

    test('/stores → /forbidden', () {
      final result = _redirect(
        user: customer,
        role: UserRole.customer,
        path: '/stores',
      );
      expect(result, '/forbidden');
    });

    test('/login → /forbidden', () {
      final result = _redirect(
        user: customer,
        role: UserRole.customer,
        path: '/login',
      );
      expect(result, '/forbidden');
    });

    test(
      '/onboarding/inbound/verify-email → /forbidden (completeMerchant transition)',
      () {
        final result = _redirect(
          user: customer,
          role: UserRole.customer,
          path: '/onboarding/inbound/verify-email',
        );
        expect(result, '/forbidden');
      },
    );
  });

  // ── Layer 6: StoreShip + onboarding status ──
  group('Layer 6 — Partner with pending onboarding', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/onboarding/create-item → stay', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        path: '/onboarding/create-item',
      );
      expect(result, isNull);
    });

    test('/onboarding/create-item/pricing → stay', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        path: '/onboarding/create-item/pricing',
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/create-item', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        path: '/stores',
      );
      expect(result, '/onboarding/create-item');
    });

    test('/login → /onboarding/create-item', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        path: '/login',
      );
      expect(result, '/onboarding/create-item');
    });

    test('/onboarding/inbound/create-account → /onboarding/create-item', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        path: '/onboarding/inbound/create-account',
      );
      expect(result, '/onboarding/create-item');
    });
  });

  group('Layer 6 — Partner with empty storeShips', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/stores → stay (no pending, no stores)', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        path: '/stores',
      );
      expect(result, isNull);
    });

    test('/login → /stores', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        path: '/login',
      );
      expect(result, '/stores');
    });
  });

  group('Layer 7 — Partner with completed onboarding', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/stores/abc/dashboard → stay', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        path: '/stores/abc/dashboard',
      );
      expect(result, isNull);
    });

    test('/login → /stores', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        path: '/login',
      );
      expect(result, '/stores');
    });

    test('/onboarding/create-item → /stores', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        path: '/onboarding/create-item',
      );
      expect(result, '/stores');
    });

    test('/forbidden → /stores', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        path: '/forbidden',
      );
      expect(result, '/stores');
    });

    test('/ (root) → stay', () {
      final result = _redirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        path: '/',
      );
      expect(result, isNull);
    });
  });
}
