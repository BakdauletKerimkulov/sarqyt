import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';
import 'package:sarqyt/src/features/business_console/domain/business_verification_draft.dart';

part 'verify_dialog_controller.g.dart';

@riverpod
class BusinessDraftController extends _$BusinessDraftController {
  @override
  BusinessVerificationDraft build() => const BusinessVerificationDraft();

  void selectBusinessType(BusinessType businessType) {
    state = state.copyWith(businessType: businessType);
  }

  void saveCompanyDetails({
    required String bin,
    String? companyName,
    String? vatId,
  }) {
    state = state.copyWith(
      businessType: BusinessType.company,
      company: state.company.copyWith(
        companyName: _normalize(companyName) ?? state.company.companyName,
        bin: _normalize(bin),
        vatId: _normalize(vatId),
      ),
    );
  }

  void saveIndividualDetails({
    String? vatId,
    required String iin,
    required String dateOfBirth,
    required String firstName,
    required String lastName,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String city,
    required String region,
    required String country,
  }) {
    state = state.copyWith(
      businessType: BusinessType.individual,
      individual: IndividualVerificationDraft(
        vatId: _normalize(vatId),
        iin: _normalize(iin),
        dateOfBirth: _normalize(dateOfBirth),
        firstName: _normalize(firstName),
        lastName: _normalize(lastName),
        addressLine1: _normalize(addressLine1),
        addressLine2: _normalize(addressLine2),
        postalCode: _normalize(postalCode),
        city: _normalize(city),
        region: _normalize(region),
        country: _normalize(country),
      ),
    );
  }

  void reset() {
    state = const BusinessVerificationDraft();
  }
}

String? _normalize(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
