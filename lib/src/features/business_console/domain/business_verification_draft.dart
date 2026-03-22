import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sarqyt/src/features/business_console/domain/business.dart';

part 'business_verification_draft.freezed.dart';

@freezed
abstract class BusinessVerificationDraft with _$BusinessVerificationDraft {
  const factory BusinessVerificationDraft({
    @Default(BusinessType.company) BusinessType businessType,
    @Default(CompanyVerificationDraft()) CompanyVerificationDraft company,
    @Default(IndividualVerificationDraft())
    IndividualVerificationDraft individual,
  }) = _BusinessVerificationDraft;

  const BusinessVerificationDraft._();

  bool get hasCompletedRequiredFields {
    return switch (businessType) {
      BusinessType.company => company.isComplete,
      BusinessType.individual => individual.isComplete,
    };
  }

  CompanyVerificationDraft? get activeCompanyDraft =>
      businessType == BusinessType.company ? company : null;

  IndividualVerificationDraft? get activeIndividualDraft =>
      businessType == BusinessType.individual ? individual : null;
}

@freezed
abstract class CompanyVerificationDraft with _$CompanyVerificationDraft {
  const factory CompanyVerificationDraft({
    String? companyName,
    String? bin,
    String? vatId,
  }) = _CompanyVerificationDraft;

  const CompanyVerificationDraft._();

  bool get isComplete => _hasValue(bin);
}

@freezed
abstract class IndividualVerificationDraft with _$IndividualVerificationDraft {
  const factory IndividualVerificationDraft({
    String? vatId,
    String? iin,
    String? dateOfBirth,
    String? firstName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? postalCode,
    String? city,
    String? region,
    String? country,
  }) = _IndividualVerificationDraft;

  const IndividualVerificationDraft._();

  bool get isComplete =>
      _hasValue(iin) &&
      _hasValue(dateOfBirth) &&
      _hasValue(firstName) &&
      _hasValue(lastName) &&
      _hasValue(addressLine1) &&
      _hasValue(postalCode) &&
      _hasValue(city) &&
      _hasValue(region) &&
      _hasValue(country);
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
