import 'package:flutter/material.dart';

class PolicyCheckboxFormField extends StatelessWidget {
  final void Function() onPolicyTap;
  final Widget Function(FormFieldState<bool>) builder;

  const PolicyCheckboxFormField({
    super.key,
    required this.onPolicyTap,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: false,
      validator: (value) =>
          value == true ? null : 'You must accept the privacy policy',
      builder: builder,
    );
  }
}
