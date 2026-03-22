import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

const kzDialCode = '+7';
const kzMinLength = 10;
const kzMaxLength = 10;

mixin RegistrationValidators {
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator nonEmptyValidator = NonEmptyStringValidator();
  final StringValidator minLengthStringValidator = MinLengthStringValidator(10);
  final StringValidator passwordRegisterSubmitValidator =
      MinLengthStringValidator(8);

  bool canSubmitted(String value) {
    return nonEmptyValidator.isValid(value);
  }

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(String password) {
    return passwordRegisterSubmitValidator.isValid(password);
  }

  String? passwordErrorText(String password) {
    final bool showErrorText = !canSubmitPassword(password);
    final String errorText = password.isEmpty
        ? 'Password can\'t be empty'.hardcoded
        : 'Password is too short'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? emailErrorText(String email) {
    final bool showErrorText = !canSubmitEmail(email);
    final String errorText = email.isEmpty
        ? 'Email can\'t be empty'.hardcoded
        : 'Invalid email'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? errorText(String value) {
    final bool showErrorText = !canSubmitted(value);
    final String errorText = 'Please, fill in the required field'.hardcoded;
    return showErrorText ? errorText : null;
  }

  String? storeTypeError(StoreType? type) {
    final bool showErrorText = type == null;
    return showErrorText ? 'Please select a store type'.hardcoded : null;
  }

  String? countryErrorText(CountryD? country) {
    final bool showErrorText = country == null;
    return showErrorText ? 'Please select a country'.hardcoded : null;
  }

  String? kzPhoneValidator(String value) {
    final normalized = kzPhoneFormatter(value);

    if (normalized.isEmpty) {
      return 'Phone number can\'t be empty'.hardcoded;
    }

    final validPattern = RegExp(r'^(\+7|7)\d{10}$');

    if (!validPattern.hasMatch(normalized)) {
      return 'Enter a valid phone number'.hardcoded;
    }

    return null;
  }
}

String kzPhoneFormatter(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), '');
  return normalized;
}
