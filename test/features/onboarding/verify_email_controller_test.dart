import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/onboarding/data/onboarding_repository.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/verify_email_controller.dart';

import 'fake_onboarding_repository.dart';

/// Minimal fake AppUser whose emailVerified can be toggled.
class _TestAppUser extends AppUser {
  _TestAppUser({required this.verified})
    : super(uid: 'test-uid', email: 'test@test.com');

  bool verified;
  bool reloadCalled = false;
  bool refreshTokenCalled = false;

  @override
  bool get emailVerified => verified;

  @override
  Future<void> reload() async {
    reloadCalled = true;
  }

  @override
  Future<void> forceRefreshIdToken() async {
    refreshTokenCalled = true;
  }

  @override
  Future<void> delete() async {}

  @override
  Future<UserRole> getRole() async => UserRole.partner;
}

/// Minimal fake AuthRepository that returns a controllable user.
class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this.user);
  final _TestAppUser? user;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> authStateChanges() => Stream.value(user);

  @override
  Stream<AppUser?> idTokenChanges() => Stream.value(user);

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithEmailAndPassword(String e, String p) async {}

  @override
  Future<AppUser?> createUserWithEmailAndPassword(String e, String p) async =>
      null;
}

void main() {
  group('VerifyEmailController', () {
    test(
      'checkAndComplete — email verified → calls complete + refreshToken',
      () async {
        final user = _TestAppUser(verified: true);
        final fakeAuth = _FakeAuthRepo(user);
        final fakeOnboarding = FakeOnboardingRepository();

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            onboardingRepositoryProvider.overrideWithValue(fakeOnboarding),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          verifyEmailControllerProvider.notifier,
        );
        await controller.checkAndComplete();

        expect(user.reloadCalled, isTrue);
        expect(fakeOnboarding.completeMerchantCalled, isTrue);
        expect(user.refreshTokenCalled, isTrue);
      },
    );

    test('checkAndComplete — email NOT verified → does nothing', () async {
      final user = _TestAppUser(verified: false);
      final fakeAuth = _FakeAuthRepo(user);
      final fakeOnboarding = FakeOnboardingRepository();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboarding),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(verifyEmailControllerProvider.notifier);
      await controller.checkAndComplete();

      expect(user.reloadCalled, isTrue);
      expect(fakeOnboarding.completeMerchantCalled, isFalse);
      expect(user.refreshTokenCalled, isFalse);
    });

    test(
      'checkAndComplete — completeMerchant fails → state has error',
      () async {
        final user = _TestAppUser(verified: true);
        final fakeAuth = _FakeAuthRepo(user);
        final fakeOnboarding = FakeOnboardingRepository()
          ..failCompleteMerchant = true;

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            onboardingRepositoryProvider.overrideWithValue(fakeOnboarding),
          ],
        );
        addTearDown(container.dispose);

        final controller = container.read(
          verifyEmailControllerProvider.notifier,
        );
        await controller.checkAndComplete();

        final state = container.read(verifyEmailControllerProvider);
        expect(state.hasError, isTrue);
        expect(user.refreshTokenCalled, isFalse);
      },
    );

    test('checkAndComplete — no user → returns early', () async {
      final fakeAuth = _FakeAuthRepo(null);
      final fakeOnboarding = FakeOnboardingRepository();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuth),
          onboardingRepositoryProvider.overrideWithValue(fakeOnboarding),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(verifyEmailControllerProvider.notifier);
      await controller.checkAndComplete();

      expect(fakeOnboarding.completeMerchantCalled, isFalse);
    });
  });
}
