import 'package:sarqyt/src/localization/string_hardcoded.dart';

enum EmailPasswordSignInFormType { signIn, register }

extension EmailPasswordSignInFormTypeX on EmailPasswordSignInFormType {
  String get passwordLabelText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Password (8+ characters)'.hardcoded;
    } else {
      return 'Password'.hardcoded;
    }
  }

  // Getters
  String get primaryButtonText {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Create an Account'.hardcoded;
    } else {
      return 'Sign in'.hardcoded;
    }
  }

  String get title {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Hello! Create Account'.hardcoded;
    } else {
      return 'Welcome back!'.hardcoded;
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

  String get errorAlertTitle {
    if (this == EmailPasswordSignInFormType.register) {
      return 'Registration failed'.hardcoded;
    } else {
      return 'Sign in failed'.hardcoded;
    }
  }
}
