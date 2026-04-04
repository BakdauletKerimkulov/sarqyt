import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/primary_button.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/utils/auth_layout.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/create_account_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/registration_validators.dart';
import 'package:sarqyt/src/features/onboarding/presentation/inbound/store_draft_controller.dart';
import 'package:sarqyt/src/features/onboarding/presentation/onboarding_panel.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      startBackground: 'assets/food-app-business-background.jpg',
      child: OnboardingPanel(
        onBackPressed: () => context.pop(),
        title: 'Add your email and passord'.hardcoded,
        subtitle:
            'You\'ll need your email and password to log in to your account.'
                .hardcoded,
        child: EmailContent(),
      ),
    );
  }
}

class EmailContent extends ConsumerStatefulWidget {
  const EmailContent({super.key, this.onSignedIn});
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailContent();
}

class _EmailContent extends ConsumerState<EmailContent>
    with RegistrationValidators {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitted = false;
  bool _acceptedPolicy = false;
  bool _isOccured = true;

  String get email => _emailController.text;
  String get password => _passwordController.text;

  void _submit() {
    setState(() => _submitted = true);

    if (_formKey.currentState!.validate()) {
      final draft = ref.read(storeDraftControllerProvider);
      ref
          .read(createAccountControllerProvider.notifier)
          .register(email, password, draft);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      createAccountControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final state = ref.watch(createAccountControllerProvider);
    final isLoading = state.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'test@test.com'.hardcoded,
              border: OutlineInputBorder(),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                !_submitted ? null : emailErrorText(value ?? ''),
          ),
          gapH16,

          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              hintText: 'Password'.hardcoded,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _isOccured = !_isOccured),
                icon: Icon(
                  _isOccured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                !_submitted ? null : passwordErrorText(value ?? ''),
            obscureText: _isOccured,
          ),

          gapH24,

          FormField<bool>(
            initialValue: _acceptedPolicy,
            validator: (value) {
              if (value != true) {
                return 'You must accept the privacy policy'.hardcoded;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: state.value,
                        onChanged: (value) {
                          state.didChange(value);
                          setState(() => _acceptedPolicy = value ?? false);
                        },
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptedPolicy = !(_acceptedPolicy);
                              state.didChange(_acceptedPolicy);
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO: открыть страницу политики
                                      showNotImplementedAlertDialog(
                                        context: context,
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          gapH16,

          PrimaryWebButton(
            text: 'Continue',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
