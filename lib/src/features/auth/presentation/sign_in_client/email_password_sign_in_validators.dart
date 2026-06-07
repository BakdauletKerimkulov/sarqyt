import 'package:sarqyt/l10n/app_localizations.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';

/// Mixin class to be used for client-side email & password validation
mixin EmailPasswordValidators {
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordRegisterSubmitValidator =
      MinLengthStringValidator(8);
  final StringValidator passwordSignInSubmitValidator =
      NonEmptyStringValidator();

  bool canSubmitEmail(String email) {
    return emailSubmitValidator.isValid(email);
  }

  bool canSubmitPassword(
    String password,
    EmailPasswordSignInFormType formType,
  ) {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  String? emailErrorText(String email, AppLocalizations loc) {
    final bool showErrorText = !canSubmitEmail(email);
    final String errorText = email.isEmpty
        ? loc.emailCantBeEmpty
        : loc.invalidEmail;
    return showErrorText ? errorText : null;
  }

  String? passwordErrorText(
    String password,
    EmailPasswordSignInFormType formType,
    AppLocalizations loc,
  ) {
    final bool showErrorText = !canSubmitPassword(password, formType);
    final String errorText = password.isEmpty
        ? loc.passwordCantBeEmpty
        : loc.passwordTooShort;
    return showErrorText ? errorText : null;
  }
}
