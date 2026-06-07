import 'package:sarqyt/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/user_profile_repository.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.loc.settings)),
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
                    context.loc.account,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(context.loc.changePassword),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showChangePasswordDialog(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    context.loc.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAlertDialog(
                    context: context,
                    title: context.loc.deleteAccountConfirm,
                    content: context.loc.deleteAccountWarning,
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
                    context.loc.notifications,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(context.loc.pushNotifications),
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
                    context.loc.about,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.loc.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => launchUrl(
                    Uri.parse('https://sarqyt-1ab95.web.app/terms-of-service.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(context.loc.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => launchUrl(
                    Uri.parse('https://sarqyt-1ab95.web.app/privacy-policy.html'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(context.loc.appVersion),
                  trailing: Text(
                    context.loc.versionNumber,
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
        title: Text(context.loc.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.loc.currentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            gapH12,
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.loc.newPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.loc.change),
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
            SnackBar(content: Text(context.loc.passwordUpdated)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(humanReadableError(e))),
          );
        }
      }
    }

    currentCtrl.dispose();
    newCtrl.dispose();
  }
}
