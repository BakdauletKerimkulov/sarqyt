import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/features/store/domain/country.dart';
import 'package:sarqyt/src/features/store/domain/store_type.dart';

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

  String? passwordErrorText(String password, AppLocalizations loc) {
    final bool showErrorText = !canSubmitPassword(password);
    final String errorText = password.isEmpty
        ? loc.passwordCantBeEmpty
        : loc.passwordTooShort;
    return showErrorText ? errorText : null;
  }

  String? emailErrorText(String email, AppLocalizations loc) {
    final bool showErrorText = !canSubmitEmail(email);
    final String errorText = email.isEmpty
        ? loc.emailCantBeEmpty
        : loc.invalidEmail;
    return showErrorText ? errorText : null;
  }

  String? errorText(String value, AppLocalizations loc) {
    final bool showErrorText = !canSubmitted(value);
    return showErrorText ? loc.pleaseFillRequiredField : null;
  }

  String? storeTypeError(StoreType? type, AppLocalizations loc) {
    final bool showErrorText = type == null;
    return showErrorText ? loc.pleaseSelectStoreType : null;
  }

  String? countryErrorText(CountryD? country, AppLocalizations loc) {
    final bool showErrorText = country == null;
    return showErrorText ? loc.pleaseSelectCountry : null;
  }

  String? kzPhoneValidator(String value, AppLocalizations loc) {
    final normalized = kzPhoneFormatter(value);

    if (normalized.isEmpty) {
      return loc.phoneNumberCantBeEmpty;
    }

    final validPattern = RegExp(r'^(\+7|7)\d{10}$');

    if (!validPattern.hasMatch(normalized)) {
      return loc.enterValidPhoneNumber;
    }

    return null;
  }
}

String kzPhoneFormatter(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), '');
  return normalized;
}
