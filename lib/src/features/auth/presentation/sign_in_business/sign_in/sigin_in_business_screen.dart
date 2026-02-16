// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/common_widgets/responsive_center.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_business/sign_in/sign_in_business_controller.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_form_type.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_validators.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class SignInBusinessScreen extends StatelessWidget {
  const SignInBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthLayout(
        startBuilder: (context) => Text(
          'Log in to mystore'.toUpperCase().hardcoded,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Sizes.p40,
            color: Colors.white,
          ),
        ),
        endBuilder: (context) => SignInBusinessContent(),
      ),
    );
  }
}

class SignInBusinessContent extends ConsumerStatefulWidget {
  const SignInBusinessContent({super.key, this.onSignedIn});

  final VoidCallback? onSignedIn;

  @override
  ConsumerState<SignInBusinessContent> createState() =>
      _SignInBusinessContentState();
}

class _SignInBusinessContentState extends ConsumerState<SignInBusinessContent>
    with EmailPasswordValidators {
  final _node = FocusScopeNode();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String get email => _emailController.text;
  String get password => _passwordController.text;

  bool _submitted = false;
  bool _passwordObscured = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'test@test.com';
    _passwordController.text = '12345678';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(signInBusinessControllerProvider.notifier);
      final success = await controller.signIn(email, password);
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
      return;
    }
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(signInBusinessControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });

    final state = ref.watch(signInBusinessControllerProvider);

    return ResponsiveCenter(
      maxContentWidth: 400.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log in to your account'.hardcoded,
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          gapH24,
          FocusScope(
            node: _node,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Email address *'.hardcoded,
                    style: TextStyle(color: Colors.grey),
                  ),
                  gapH8,
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      helperText: ' ',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabled: !state.isLoading,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (email) =>
                        !_submitted ? null : emailErrorText(email ?? ''),
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _emailEditingComplete(),
                    inputFormatters: [
                      ValidatorInputFormatter(
                        editingValidator: EmailEditingRegexValidator(),
                      ),
                    ],
                  ),
                  gapH8,
                  Text(
                    'Password *'.hardcoded,
                    style: TextStyle(color: Colors.grey),
                  ),
                  gapH8,
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      helperText: ' ',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: InkWell(
                        onTap: () => setState(
                          () => _passwordObscured = !_passwordObscured,
                        ),
                        child: Icon(
                          _passwordObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      enabled: !state.isLoading,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (password) => !_submitted
                        ? null
                        : passwordErrorText(
                            password ?? '',
                            EmailPasswordSignInFormType.signIn,
                          ),
                    obscureText: _passwordObscured,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => _passwordEditingComplete(),
                  ),
                  gapH8,
                  GestureDetector(
                    onTap: state.isLoading || !_submitted
                        ? null
                        : () => showNotImplementedAlertDialog(context: context),
                    child: Text(
                      'Forgot password?'.hardcoded,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  gapH48,

                  PrimaryWebButton(
                    isLoading: state.isLoading,
                    text: 'Log in'.hardcoded,
                    onPressed: state.isLoading ? null : () => _submit(),
                  ),
                  gapH16,
                  SizedBox(
                    height: Sizes.p40,
                    child: OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => context.goNamed(
                              BusinessRoute.createAccount.name,
                            ),
                      child: Text(
                        'Sign up your food business'.hardcoded,
                        style: TextStyle(fontSize: Sizes.p16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
