import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/inline_text_link.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_controller.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_validators.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class EmailPasswordSignInScreen extends StatelessWidget {
  const EmailPasswordSignInScreen({super.key, required this.formType});

  final EmailPasswordSignInFormType formType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(body: EmailPasswordSignInContent(formType: formType)),
    );
  }
}

class EmailPasswordSignInContent extends ConsumerStatefulWidget {
  const EmailPasswordSignInContent({
    super.key,
    required this.formType,
    this.onSignedIn,
  });

  final VoidCallback? onSignedIn;

  /// The default form type to use.
  final EmailPasswordSignInFormType formType;

  @override
  ConsumerState<EmailPasswordSignInContent> createState() =>
      _EmailPasswordSignInContentState();
}

class _EmailPasswordSignInContentState
    extends ConsumerState<EmailPasswordSignInContent>
    with EmailPasswordValidators {
  final _node = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get name => _nameController.text;
  String get email => _emailController.text;
  String get password => _passwordController.text;

  var _submitted = false;
  // track the formType as a local state variable
  late var _formType = widget.formType;
  // hide/show password
  bool _isHidden = true;

  @override
  void dispose() {
    _node.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    // only submit the form if validation passes
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(
        emailPasswordSignInControllerProvider.notifier,
      );
      final success = await controller.submit(
        email: email,
        password: password,
        formType: _formType,
      );
      if (success) {
        widget.onSignedIn?.call();
      }
    }
  }

  void _emailEditingComplete() {
    if (canSubmitEmail(email)) {
      _node.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    if (!canSubmitEmail(email)) {
      _node.previousFocus();
    }
  }

  void _updateFormType() {
    // * toggle between register and sigin form
    setState(() => _formType = _formType.secondaryActionFormType);
    // * clear the password field when doing so
    _passwordController.clear();
    _node.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue>(emailPasswordSignInControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    final state = ref.watch(emailPasswordSignInControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.p24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gapH64,
            CircleAvatar(
              radius: Sizes.p96,
              backgroundImage: AssetImage('assets/app-icon.jpg'),
            ),
            gapH24,
            Text(
              'Hello! Create Account'.hardcoded,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            gapH8,
            InlineTextLink(
              text: _formType.secondaryButtonText,
              linkText: _formType.secondaryButtonClickableText,
              onTap: state.isLoading ? null : _updateFormType,
            ),
            gapH24,
            FocusScope(
              node: _node,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_formType == EmailPasswordSignInFormType.register)
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Your name'.hardcoded,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(Sizes.p16),
                          ),
                          enabled: !state.isLoading,
                        ),
                        textInputAction: TextInputAction.next,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    gapH12,
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email'.hardcoded,
                        filled: true,
                        enabled: !state.isLoading,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                      ),
                      validator: (email) =>
                          !_submitted ? null : emailErrorText(email ?? ''),
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.emailAddress,
                      keyboardAppearance: Brightness.light,
                      onEditingComplete: _emailEditingComplete,
                      inputFormatters: [
                        ValidatorInputFormatter(
                          editingValidator: EmailEditingRegexValidator(),
                        ),
                      ],
                    ),
                    gapH12,
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: _formType.passwordLabelText,
                        filled: true,
                        enabled: !state.isLoading,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(Sizes.p16),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _isHidden = !_isHidden),
                          child: Icon(
                            _isHidden ? Icons.visibility : Icons.visibility_off,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      keyboardAppearance: Brightness.light,
                      obscureText: _isHidden,
                      validator: (password) => !_submitted
                          ? null
                          : passwordErrorText(password ?? '', _formType),
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onEditingComplete: _passwordEditingComplete,
                    ),
                  ],
                ),
              ),
            ),

            gapH16,
            SizedBox(
              width: double.infinity,
              height: Sizes.p48,
              child: PrimaryButton(
                onPressed: state.isLoading ? null : () => _submit(),
                isLoading: state.isLoading,
                text: _formType.primaryButtonText,
              ),
            ),
            gapH64,
          ],
        ),
      ),
    );
  }
}
