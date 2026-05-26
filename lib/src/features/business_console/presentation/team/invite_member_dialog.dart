import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class InviteMemberDialog extends StatefulWidget {
  const InviteMemberDialog({super.key, required this.storeId});

  final String storeId;

  @override
  State<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  StoreRole _selectedRole = StoreRole.employer;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('inviteTeamMember');
      await callable.call<dynamic>({
        'storeId': widget.storeId,
        'email': _emailController.text.trim(),
        'role': _selectedRole.name,
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invitation sent'.hardcoded)),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to invite'.hardcoded)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Invite team member'.hardcoded),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email'.hardcoded,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required'.hardcoded;
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email'.hardcoded;
                }
                return null;
              },
            ),
            gapH16,
            DropdownButtonFormField<StoreRole>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role'.hardcoded,
                border: const OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: StoreRole.operator,
                  child: Text('Operator'),
                ),
                DropdownMenuItem(
                  value: StoreRole.employer,
                  child: Text('Employee'),
                ),
              ],
              onChanged: (role) {
                if (role != null) setState(() => _selectedRole = role);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'.hardcoded),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Invite'.hardcoded),
        ),
      ],
    );
  }
}
