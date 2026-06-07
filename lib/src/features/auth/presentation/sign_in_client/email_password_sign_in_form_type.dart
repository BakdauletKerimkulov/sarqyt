import 'package:sarqyt/l10n/app_localizations.dart';

enum EmailPasswordSignInFormType { signIn, register }

extension EmailPasswordSignInFormTypeX on EmailPasswordSignInFormType {
  String passwordLabelText(AppLocalizations loc) {
    if (this == EmailPasswordSignInFormType.register) {
      return loc.passwordHint;
    } else {
      return loc.password;
    }
  }

  String primaryButtonText(AppLocalizations loc) {
    if (this == EmailPasswordSignInFormType.register) {
      return loc.createAnAccount;
    } else {
      return loc.signIn;
    }
  }

  String title(AppLocalizations loc) {
    if (this == EmailPasswordSignInFormType.register) {
      return loc.helloCreateAccount;
    } else {
      return loc.welcomeBack;
    }
  }

  String get secondaryButtonText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Already have an account? ';
    } else {
      return 'Hello, sign in to continue or ';
    }
  }

  String get secondaryButtonClickableText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Sign in';
    } else {
      return 'Create new account';
    }
  }

  EmailPasswordSignInFormType get secondaryActionFormType {
    if (this == EmailPasswordSignInFormType.register) {
      return EmailPasswordSignInFormType.signIn;
    } else {
      return EmailPasswordSignInFormType.register;
    }
  }

  String errorAlertTitle(AppLocalizations loc) {
    if (this == EmailPasswordSignInFormType.register) {
      return loc.registrationFailed;
    } else {
      return loc.signInFailed;
    }
  }
}
