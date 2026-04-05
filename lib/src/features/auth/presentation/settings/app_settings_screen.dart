import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/user_profile_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings'.hardcoded)),
      body: ListView(
        padding: const EdgeInsets.all(Sizes.p16),
        children: [
          // Account section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sizes.p16, Sizes.p16, Sizes.p16, Sizes.p8,
                  ),
                  child: Text(
                    'Account'.hardcoded,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text('Change password'.hardcoded),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete account'.hardcoded,
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAlertDialog(
                    context: context,
                    title: 'Delete account?'.hardcoded,
                    content:
                        'This action cannot be undone. Contact support to delete your account.'
                            .hardcoded,
                  ),
                ),
              ],
            ),
          ),
          gapH16,

          // Notifications
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sizes.p16, Sizes.p16, Sizes.p16, Sizes.p8,
                  ),
                  child: Text(
                    'Notifications'.hardcoded,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text('Push notifications'.hardcoded),
                  value: true,
                  onChanged: (_) =>
                      showNotImplementedAlertDialog(context: context),
                ),
              ],
            ),
          ),
          gapH16,

          // About
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sizes.p16, Sizes.p16, Sizes.p16, Sizes.p8,
                  ),
                  child: Text(
                    'About'.hardcoded,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text('Terms of service'.hardcoded),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      showNotImplementedAlertDialog(context: context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy policy'.hardcoded),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      showNotImplementedAlertDialog(context: context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('App version'.hardcoded),
                  trailing: Text(
                    '1.0.0'.hardcoded,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change password'.hardcoded),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current password'.hardcoded,
                border: const OutlineInputBorder(),
              ),
            ),
            gapH12,
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New password'.hardcoded,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.hardcoded),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Change'.hardcoded),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(userProfileRepositoryProvider).updatePassword(
              currentPassword: currentCtrl.text,
              newPassword: newCtrl.text,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password updated'.hardcoded)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }

    currentCtrl.dispose();
    newCtrl.dispose();
  }
}
