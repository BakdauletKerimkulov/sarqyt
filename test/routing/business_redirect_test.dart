import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/auth/domain/fake_app_user.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_redirect_state.dart';
import 'package:sarqyt/src/routing/business_router.dart';

/// Shorthand to call [businessRedirect] with the Uri-based signature.
String? _redirect({
  AppUser? user,
  UserRole role = UserRole.guest,
  List<StoreShip> storeShips = const [],
  bool storeShipsLoaded = true,
  bool roleLoaded = true,
  required String path,
  Map<String, String> queryParameters = const {},
}) {
  return businessRedirect(
    redirectState: BusinessRedirectState(
      user: user,
      role: role,
      storeShips: storeShips,
      storeShipsLoaded: storeShipsLoaded,
      roleLoaded: roleLoaded,
    ),
    uri: Uri(path: path, queryParameters: queryParameters.isEmpty ? null : queryParameters),
  );
}

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

const _pendingShips = [
  StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: [],
    name: 'My Store',
    role: StoreRole.owner,
    welcomeCompleted: false,
  ),
];

const _completedShips = [
  StoreShip(
    storeId: 'store-1',
    businessId: 'biz-1',
    userId: 'uid-1',
    permissions: [],
    name: 'My Store',
    role: StoreRole.owner,
    welcomeCompleted: true,
  ),
];

void main() {
  group('Layer 1 — Unauthenticated', () {
    test('/login → stay', () {
      expect(_redirect(path: '/login'), isNull);
    });

    test('/onboarding/inbound/create-account → stay', () {
      expect(
        _redirect(path: '/onboarding/inbound/create-account'),
        isNull,
      );
    });

    test('/stores → /login', () {
      expect(_redirect(path: '/stores'), '/login');
    });

    test('/forbidden → /login', () {
      expect(_redirect(path: '/forbidden'), '/login');
    });
  });

  group('Layer 2 — Email not verified', () {
    late FakeAppUser unverified;
    setUp(() => unverified = _user(emailVerified: false));

    test('/onboarding/inbound/verify-email → stay', () {
      expect(
        _redirect(
          user: unverified,
          role: UserRole.partner,
          path: '/onboarding/inbound/verify-email',
        ),
        isNull,
      );
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      expect(
        _redirect(
          user: unverified,
          role: UserRole.partner,
          path: '/stores',
        ),
        '/onboarding/inbound/verify-email',
      );
    });
  });

  group('Layer 3 — Role loading (roleLoaded: false)', () {
    late FakeAppUser verified;
    setUp(() => verified = _user(emailVerified: true));

    test('/login → /loading', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          roleLoaded: false,
          path: '/login',
        ),
        '/loading',
      );
    });

    test('/stores/x/dashboard → /loading', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          roleLoaded: false,
          path: '/stores/x/dashboard',
        ),
        '/loading',
      );
    });

    test('/loading → stay', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          roleLoaded: false,
          path: '/loading',
        ),
        isNull,
      );
    });

    test('roleLoaded: true → falls through to guest layer', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          roleLoaded: true,
          path: '/onboarding/inbound/verify-email',
        ),
        isNull,
      );
    });
  });

  group('Layer 4 — Verified guest allows inbound paths', () {
    late FakeAppUser verified;
    setUp(() => verified = _user(emailVerified: true));

    test('/onboarding/inbound/verify-email → stay', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/onboarding/inbound/verify-email',
        ),
        isNull,
      );
    });

    test('/onboarding/inbound/create-account → stay', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/onboarding/inbound/create-account',
        ),
        isNull,
      );
    });

    test('/onboarding/inbound/review-details → stay', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/onboarding/inbound/review-details',
        ),
        isNull,
      );
    });

    test('/onboarding/inbound/email → stay', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/onboarding/inbound/email',
        ),
        isNull,
      );
    });

    test('/stores → /onboarding/inbound/verify-email', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/stores',
        ),
        '/onboarding/inbound/verify-email',
      );
    });

    test('/login → /onboarding/inbound/verify-email', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/login',
        ),
        '/onboarding/inbound/verify-email',
      );
    });

    test('/onboarding/welcome → /onboarding/inbound/verify-email', () {
      expect(
        _redirect(
          user: verified,
          role: UserRole.guest,
          path: '/onboarding/welcome',
        ),
        '/onboarding/inbound/verify-email',
      );
    });
  });

  group('Layer 4 — Non-partner / non-admin (customer)', () {
    late FakeAppUser customer;
    setUp(() => customer = _user(role: UserRole.customer));

    test('/forbidden → stay', () {
      expect(
        _redirect(
          user: customer,
          role: UserRole.customer,
          path: '/forbidden',
        ),
        isNull,
      );
    });

    test('/stores → /forbidden', () {
      expect(
        _redirect(
          user: customer,
          role: UserRole.customer,
          path: '/stores',
        ),
        '/forbidden',
      );
    });

    test('/login → /forbidden', () {
      expect(
        _redirect(
          user: customer,
          role: UserRole.customer,
          path: '/login',
        ),
        '/forbidden',
      );
    });
  });

  group('Layer 5 — Admin', () {
    late FakeAppUser admin;
    setUp(() => admin = _user(role: UserRole.admin));

    test('/login → /stores', () {
      expect(
        _redirect(user: admin, role: UserRole.admin, path: '/login'),
        '/stores',
      );
    });

    test('/onboarding/inbound → /stores', () {
      expect(
        _redirect(
          user: admin,
          role: UserRole.admin,
          path: '/onboarding/inbound',
        ),
        '/stores',
      );
    });

    test('/onboarding/welcome → /stores', () {
      expect(
        _redirect(
          user: admin,
          role: UserRole.admin,
          path: '/onboarding/welcome',
        ),
        '/stores',
      );
    });

    test('/stores/abc/dashboard → stay', () {
      expect(
        _redirect(
          user: admin,
          role: UserRole.admin,
          path: '/stores/abc/dashboard',
        ),
        isNull,
      );
    });
  });

  group('Layer 6 — Partner with storeShips not yet loaded', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/stores → stay (do not bounce while loading)', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShipsLoaded: false,
          path: '/stores',
        ),
        isNull,
      );
    });

    test('/login → /loading (redirects to loading screen)', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShipsLoaded: false,
          path: '/login',
        ),
        '/loading',
      );
    });
  });

  group('Layer 7 — Partner with pending welcome', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/onboarding/welcome → stay', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _pendingShips,
          path: '/onboarding/welcome',
        ),
        isNull,
      );
    });

    test('/stores → /onboarding/welcome', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _pendingShips,
          path: '/stores',
        ),
        '/onboarding/welcome',
      );
    });

    test('/login → /onboarding/welcome', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _pendingShips,
          path: '/login',
        ),
        '/onboarding/welcome',
      );
    });
  });

  group('Layer 8 — Partner with completed welcome', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/stores/abc/dashboard → stay', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/stores/abc/dashboard',
        ),
        isNull,
      );
    });

    test('/login → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/login',
        ),
        '/stores',
      );
    });

    test('/onboarding/welcome → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/onboarding/welcome',
        ),
        '/stores',
      );
    });

    test('/forbidden → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/forbidden',
        ),
        '/stores',
      );
    });
  });

  group('Layer 6 — Partner on /login with storeShips not yet loaded', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/login → /loading (immediate transition to loading screen)', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShipsLoaded: false,
          path: '/login',
        ),
        '/loading',
      );
    });
  });

  group('Layer 8 — Partner done redirects away from /loading', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/loading → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/loading',
        ),
        '/stores',
      );
    });
  });

  group('Layer 5 — Admin redirects away from /loading', () {
    late FakeAppUser admin;
    setUp(() => admin = _user(role: UserRole.admin));

    test('/loading → /stores', () {
      expect(
        _redirect(user: admin, role: UserRole.admin, path: '/loading'),
        '/stores',
      );
    });
  });

  group('Layer 1 — Unauthenticated on /loading', () {
    test('/loading → /login', () {
      expect(_redirect(path: '/loading'), '/login');
    });
  });

  group('Admin dev menu — /dev route guard', () {
    late FakeAppUser admin;
    late FakeAppUser partner;
    setUp(() {
      admin = _user(role: UserRole.admin);
      partner = _user(role: UserRole.partner);
    });

    test('admin at /dev → stay', () {
      expect(
        _redirect(user: admin, role: UserRole.admin, path: '/dev'),
        isNull,
      );
    });

    test('partner at /dev → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          storeShips: _completedShips,
          path: '/dev',
        ),
        '/stores',
      );
    });

    test('admin at onboarding with devMenu=true → stay (bypass)', () {
      expect(
        _redirect(
          user: admin,
          role: UserRole.admin,
          path: '/onboarding/inbound/review-details',
          queryParameters: {'devMenu': 'true'},
        ),
        isNull,
      );
    });
  });

  group('Edge — partner with no storeShips at all (loaded, empty)', () {
    late FakeAppUser partner;
    setUp(() => partner = _user(role: UserRole.partner));

    test('/stores → stay (no pending, no completed)', () {
      // This is an unusual state — partner has been provisioned a role
      // but no storeShip was created yet. Treat as "done": the /stores
      // screen will show an empty list.
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          path: '/stores',
        ),
        isNull,
      );
    });

    test('/login → /stores', () {
      expect(
        _redirect(
          user: partner,
          role: UserRole.partner,
          path: '/login',
        ),
        '/stores',
      );
    });
  });
}
