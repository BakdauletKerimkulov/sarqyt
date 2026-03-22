import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_repository.g.dart';

class OnboardingRepository {
  const OnboardingRepository(this._functions, this._firestore);
  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;

  Future<String> createStoreDraft(Map<String, dynamic> data) async {
    final function = _functions.httpsCallable('startMerchantOnboardingData');
    final result = await function.call(data);
    return result.data['draftId'];
  }

  Future<void> deleteStoreDraft(String draftId) async {
    await _firestore.doc('storeDrafts/$draftId').delete();
  }

  Future<String> completeMerchantOnboarding() async {
    final function = _functions.httpsCallable('completeMerchantOnboarding');
    final result = await function.call({});
    return result.data['storeId'] as String;
  }

  Future<void> skipOptionalOnboarding(String storeId) async {
    final function = _functions.httpsCallable('skipOptionalOnboarding');
    await function.call({'storeId': storeId});
  }
}

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepository(
    FirebaseFunctions.instance,
    FirebaseFirestore.instance,
  );
}
