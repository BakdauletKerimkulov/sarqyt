import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/exceptions/error_logger.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class InviteMemberDialog extends ConsumerStatefulWidget {
  const InviteMemberDialog({super.key, required this.storeId});

  final String storeId;

  @override
  ConsumerState<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends ConsumerState<InviteMemberDialog> {
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
    // Read before the await: `ref` throws once the dialog is disposed.
    final logger = ref.read(errorLoggerProvider);

    try {
      await ref
          .read(storeShipRepositoryProvider)
          .inviteTeamMember(
            storeId: widget.storeId,
            email: _emailController.text.trim(),
            role: _selectedRole,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invitation sent'.hardcoded)));
      }
    } catch (e, st) {
      logger.logError(e, st);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(humanReadableError(e))));
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
