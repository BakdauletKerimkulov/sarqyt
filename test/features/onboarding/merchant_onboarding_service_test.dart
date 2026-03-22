import 'package:flutter_test/flutter_test.dart';
import 'package:sarqyt/src/features/auth/data/fake_auth_repository.dart';
import 'package:sarqyt/src/features/onboarding/application/merchant_onboarding_service.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_draft.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

import 'fake_onboarding_repository.dart';

void main() {
  late FakeAuthRepository fakeAuth;
  late FakeOnboardingRepository fakeOnboarding;
  late MerchantOnboardingService service;

  const email = 'test@sarqyt.com';
  const password = '12345678';

  final draft = StoreDraft(
    name: 'Test Store',
    storeType: StoreType.bakery,
    address: 'Abay 1',
    locality: 'Almaty',
    postalCode: '050000',
    country: CountryD(isoCode: 'KAZ', name: 'Казахстан'),
    phoneNumber: '+77001234567',
  );

  setUp(() {
    fakeAuth = FakeAuthRepository(addDelay: false);
    fakeOnboarding = FakeOnboardingRepository();
    service = MerchantOnboardingService(fakeAuth, fakeOnboarding);
  });

  group('MerchantOnboardingService.register', () {
    test('happy path: creates user then calls createStoreDraft', () async {
      await service.register(email: email, password: password, draft: draft);

      expect(fakeAuth.currentUser, isNotNull);
      expect(fakeAuth.currentUser!.email, email);
      expect(fakeOnboarding.createDraftCalled, isTrue);
    });

    test('if createStoreDraft fails: exception propagates without secondary errors', () async {
      fakeOnboarding.failCreateDraft = true;

      // The original exception must propagate to the caller
      await expectLater(
        () => service.register(email: email, password: password, draft: draft),
        throwsA(isA<Exception>()),
      );

      // Verify rollback ran without throwing a secondary exception.
      // FakeAppUser.delete() is a no-op; the real Firebase user would be deleted.
      // The key fix here: previously delete() threw UnimplementedError which
      // would swallow the original exception. Now it completes cleanly.
    });

    test('if createUserWithEmailAndPassword fails: does not call createStoreDraft', () async {
      // Register same email twice to trigger EmailAlreadyInUseException
      await service.register(email: email, password: password, draft: draft);
      fakeOnboarding.createDraftCalled = false; // reset

      await expectLater(
        () => service.register(email: email, password: password, draft: draft),
        throwsA(isA<Exception>()),
      );

      expect(fakeOnboarding.createDraftCalled, isFalse,
          reason: 'createStoreDraft must not be called if registration failed');
    });

    test('draft data is passed to createStoreDraft', () async {
      Map<String, dynamic>? capturedData;
      final capturingRepo = _CapturingOnboardingRepository(
        onCreateDraft: (data) => capturedData = data,
      );
      final s = MerchantOnboardingService(fakeAuth, capturingRepo);

      await s.register(email: email, password: password, draft: draft);

      expect(capturedData, isNotNull);
      expect(capturedData!['storeName'], 'Test Store');
    });
  });
}

/// Helper fake that captures arguments passed to createStoreDraft.
class _CapturingOnboardingRepository extends FakeOnboardingRepository {
  _CapturingOnboardingRepository({required this.onCreateDraft});
  final void Function(Map<String, dynamic>) onCreateDraft;

  @override
  Future<String> createStoreDraft(Map<String, dynamic> data) async {
    onCreateDraft(data);
    return 'draft-id';
  }
}
