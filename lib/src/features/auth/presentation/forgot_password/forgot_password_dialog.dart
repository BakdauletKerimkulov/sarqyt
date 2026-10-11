import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/presentation/forgot_password/forgot_password_controller.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/email_password_sign_in_validators.dart';
import 'package:sarqyt/src/features/auth/presentation/sign_in_client/string_validators.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

/// Reusable "forgot password" dialog — shared by both apps.
Future<void> showForgotPasswordDialog(
  BuildContext context, {
  String? initialEmail,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => ForgotPasswordDialog(initialEmail: initialEmail),
  );
}

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordDialog> createState() =>
      _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog>
    with EmailPasswordValidators {
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _formKey = GlobalKey<FormState>();
  var _submitted = false;
  var _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    final success = await controller.submit(_emailController.text.trim());
    if (success && mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(forgotPasswordControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });
    final state = ref.watch(forgotPasswordControllerProvider);

    return AlertDialog(
      title: Text(context.loc.resetPasswordTitle),
      content: SizedBox(
        width: 360,
        child: _sent
            ? Text(context.loc.resetLinkSent)
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.loc.resetPasswordDescription),
                    gapH16,
                    TextFormField(
                      controller: _emailController,
                      autofocus: true,
                      enabled: !state.isLoading,
                      decoration: InputDecoration(
                        hintText: context.loc.email,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) => !_submitted
                          ? null
                          : emailErrorText(email ?? '', context.loc),
                      inputFormatters: [
                        ValidatorInputFormatter(
                          editingValidator: EmailEditingRegexValidator(),
                        ),
                      ],
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_sent ? context.loc.ok : context.loc.cancel),
        ),
        if (!_sent)
          TextButton(
            onPressed: state.isLoading ? null : _submit,
            child: Text(
              context.loc.sendResetLink,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
