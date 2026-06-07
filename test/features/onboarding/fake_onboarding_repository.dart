import 'package:sarqyt/src/features/onboarding/data/onboarding_repository.dart';

/// In-memory fake for OnboardingRepository. Controls success/failure per method.
class FakeOnboardingRepository implements OnboardingRepository {
  bool failCreateDraft = false;
  bool failCompleteMerchant = false;
  bool createDraftCalled = false;
  bool completeMerchantCalled = false;

  @override
  Future<String> createStoreDraft(Map<String, dynamic> data) async {
    if (failCreateDraft) throw Exception('startMerchantOnboarding CF failed');
    createDraftCalled = true;
    return 'draft-id-test';
  }

  @override
  Future<String> completeMerchantOnboarding() async {
    if (failCompleteMerchant) {
      throw Exception('completeMerchantOnboarding CF failed');
    }
    completeMerchantCalled = true;
    return 'store-id-test';
  }

  @override
  Future<void> deleteStoreDraft(String draftId) {
    // TODO: implement deleteStoreDraft
    throw UnimplementedError();
  }
}
