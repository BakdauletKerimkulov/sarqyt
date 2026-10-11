import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/firebase_functions_provider.dart';
import 'package:sarqyt/src/exceptions/app_exception.dart';

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
    try {
      final result = await function.call({});
      return result.data['storeId'] as String;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') throw DraftNotFoundException();
      rethrow;
    }
  }
}

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  return OnboardingRepository(
    ref.watch(firebaseFunctionsProvider),
    FirebaseFirestore.instance,
  );
}
