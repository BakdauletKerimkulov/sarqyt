import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/domain/fake_app_user.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_router.dart';

GoRouterState _state(String path) => _TestGoRouterState(path);

class _TestGoRouterState extends Fake implements GoRouterState {
  _TestGoRouterState(String path) : _uri = Uri.parse(path);

  final Uri _uri;

  @override
  Uri get uri => _uri;
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

/// StoreShip with item created (pending business registration).
const _itemCreatedShips = [
  StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: [],
    name: 'My Store',
    storeRole: StoreRole.owner,
    onboardingStatus: OnboardingStatus.itemCreated,
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
  // ── Layer 1: Unauthenticated (user == null) ──
  group('Layer 1 — Unauthenticated', () {
    test('/login → stay', () {
      final result = businessRedirect(
        user: null,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/login'),
      );
      expect(result, isNull);
    });

    test('/onboarding/inbound/create-account → stay', () {
      final result = businessRedirect(
        user: null,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/onboarding/inbound/create-account'),
      );
      expect(result, isNull);
    });

    test('/stores → /login', () {
      final result = businessRedirect(
        user: null,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/stores'),
      );
      expect(result, '/login');
    });

    test('/ → /login', () {
      final result = businessRedirect(
        user: null,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/'),
      );
      expect(result, '/login');
    });

    test('/forbidden → /login', () {
      final result = businessRedirect(
        user: null,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/forbidden'),
      );
      expect(result, '/login');
    });
  });

  // ── Layer 2: Email + Role ──
  group('Layer 2 — Email not verified', () {
    late FakeAppUser unverified;

    setUp(() {
      unverified = _user(emailVerified: false);
    });

    test('/onboarding/inbound/verify-email → stay', () {
      final result = businessRedirect(
        user: unverified,
        role: UserRole.partner,
        storeShips: const [],
        state: _state('/onboarding/inbound/verify-email'),
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      final result = businessRedirect(
        user: unverified,
        role: UserRole.partner,
        storeShips: const [],
        state: _state('/stores'),
      );
      expect(result, '/onboarding/inbound/verify-email');
    });

    test('/login → /onboarding/inbound/verify-email', () {
      final result = businessRedirect(
        user: unverified,
        role: UserRole.partner,
        storeShips: const [],
        state: _state('/login'),
      );
      expect(result, '/onboarding/inbound/verify-email');
    });
  });

  group('Layer 2 — Verified but guest (completeMerchant still running)', () {
    late FakeAppUser verified;

    setUp(() {
      verified = _user(emailVerified: true);
    });

    test('/onboarding/inbound/verify-email → stay', () {
      final result = businessRedirect(
        user: verified,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/onboarding/inbound/verify-email'),
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      final result = businessRedirect(
        user: verified,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/stores'),
      );
      expect(result, '/onboarding/inbound/verify-email');
    });

    test('/forbidden → /onboarding/inbound/verify-email', () {
      final result = businessRedirect(
        user: verified,
        role: UserRole.guest,
        storeShips: const [],
        state: _state('/forbidden'),
      );
      expect(result, '/onboarding/inbound/verify-email');
    });
  });

  group('Layer 2 — Admin', () {
    late FakeAppUser admin;

    setUp(() {
      admin = _user(role: UserRole.admin);
    });

    test('/login → /stores', () {
      final result = businessRedirect(
        user: admin,
        role: UserRole.admin,
        storeShips: const [],
        state: _state('/login'),
      );
      expect(result, '/stores');
    });

    test('/onboarding/inbound → /stores', () {
      final result = businessRedirect(
        user: admin,
        role: UserRole.admin,
        storeShips: const [],
        state: _state('/onboarding/inbound'),
      );
      expect(result, '/stores');
    });

    test('/onboarding/create-item → /stores', () {
      final result = businessRedirect(
        user: admin,
        role: UserRole.admin,
        storeShips: const [],
        state: _state('/onboarding/create-item'),
      );
      expect(result, '/stores');
    });

    test('/ → stay', () {
      final result = businessRedirect(
        user: admin,
        role: UserRole.admin,
        storeShips: const [],
        state: _state('/'),
      );
      expect(result, isNull);
    });

    test('/stores/abc/dashboard → stay', () {
      final result = businessRedirect(
        user: admin,
        role: UserRole.admin,
        storeShips: const [],
        state: _state('/stores/abc/dashboard'),
      );
      expect(result, isNull);
    });
  });

  group('Layer 2 — Verified non-partner (customer)', () {
    late FakeAppUser customer;

    setUp(() {
      customer = _user(role: UserRole.customer);
    });

    test('/forbidden → stay', () {
      final result = businessRedirect(
        user: customer,
        role: UserRole.customer,
        storeShips: const [],
        state: _state('/forbidden'),
      );
      expect(result, isNull);
    });

    test('/stores → /forbidden', () {
      final result = businessRedirect(
        user: customer,
        role: UserRole.customer,
        storeShips: const [],
        state: _state('/stores'),
      );
      expect(result, '/forbidden');
    });

    test('/login → /forbidden', () {
      final result = businessRedirect(
        user: customer,
        role: UserRole.customer,
        storeShips: const [],
        state: _state('/login'),
      );
      expect(result, '/forbidden');
    });

    test(
      '/onboarding/inbound/verify-email → /forbidden (completeMerchant transition)',
      () {
        final result = businessRedirect(
          user: customer,
          role: UserRole.customer,
          storeShips: const [],
          state: _state('/onboarding/inbound/verify-email'),
        );
        expect(result, '/forbidden');
      },
    );
  });

  // ── Layer 3: StoreShip + onboarding status ──
  group('Layer 3 — Partner with pending onboarding', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/onboarding/create-item → stay', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        state: _state('/onboarding/create-item'),
      );
      expect(result, isNull);
    });

    test('/onboarding/create-item/pricing → stay', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        state: _state('/onboarding/create-item/pricing'),
      );
      expect(result, isNull);
    });

    test('/stores → /onboarding/create-item', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        state: _state('/stores'),
      );
      expect(result, '/onboarding/create-item');
    });

    test('/login → /onboarding/create-item', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        state: _state('/login'),
      );
      expect(result, '/onboarding/create-item');
    });

    test('/onboarding/inbound/create-account → /onboarding/create-item', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _pendingShips,
        state: _state('/onboarding/inbound/create-account'),
      );
      expect(result, '/onboarding/create-item');
    });
  });

  group('Layer 3 — Partner with itemCreated onboarding', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/stores → /onboarding/create-business', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _itemCreatedShips,
        state: _state('/stores'),
      );
      expect(result, '/onboarding/create-business');
    });

    test('/login → /onboarding/create-business', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _itemCreatedShips,
        state: _state('/login'),
      );
      expect(result, '/onboarding/create-business');
    });

    test('/onboarding/create-business → stay', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _itemCreatedShips,
        state: _state('/onboarding/create-business'),
      );
      expect(result, isNull);
    });
  });

  group('Layer 3 — Partner with empty storeShips', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/stores → stay (no pending, no stores)', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: const [],
        state: _state('/stores'),
      );
      expect(result, isNull);
    });

    test('/login → /stores', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: const [],
        state: _state('/login'),
      );
      expect(result, '/stores');
    });
  });

  group('Layer 3 — Partner with completed onboarding', () {
    late FakeAppUser partner;

    setUp(() {
      partner = _user(role: UserRole.partner);
    });

    test('/stores/abc/dashboard → stay', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        state: _state('/stores/abc/dashboard'),
      );
      expect(result, isNull);
    });

    test('/login → /stores', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        state: _state('/login'),
      );
      expect(result, '/stores');
    });

    test('/onboarding/create-item → /stores', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        state: _state('/onboarding/create-item'),
      );
      expect(result, '/stores');
    });

    test('/forbidden → /stores', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        state: _state('/forbidden'),
      );
      expect(result, '/stores');
    });

    test('/ (root) → stay', () {
      final result = businessRedirect(
        user: partner,
        role: UserRole.partner,
        storeShips: _completedShips,
        state: _state('/'),
      );
      expect(result, isNull);
    });
  });
}
