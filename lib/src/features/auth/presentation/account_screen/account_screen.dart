import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/presentation/account_screen/account_screen_controller.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';
import 'package:sarqyt/src/utils/async_value_ui.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(accountScreenControllerProvider, (_, state) {
      state.showAlertDialogOnError(context);
    });
    final user = ref.watch(authRepositoryProvider).currentUser;
    final state = ref.watch(accountScreenControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.loc.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          children: [
            // Avatar + name/email
            gapH16,
            Center(
              child: user != null
                  ? Column(
                      children: [
                        CircleAvatar(
                          radius: Sizes.p48,
                          backgroundImage: user.avatarUrl != null
                              ? CachedNetworkImageProvider(user.avatarUrl!)
                              : const AssetImage('assets/unknown_person.jpg'),
                        ),
                        gapH12,
                        Text(
                          user.userInitial.isNotEmpty
                              ? user.userInitial
                              : (user.email ?? ''),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (user.email != null &&
                            user.userInitial.isNotEmpty) ...[
                          gapH4,
                          Text(
                            user.email!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => context.goNamed(ClientRoute.signIn.name),
                      child: Text(context.loc.signIn),
                    ),
            ),
            gapH32,

            // Menu
            if (user != null) ...[
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(context.loc.editProfile),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.pushNamed(ClientRoute.editProfile.name),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: Text(context.loc.favorites),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.pushNamed(ClientRoute.favorites.name),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(context.loc.settings),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.pushNamed(ClientRoute.appSettings.name),
                    ),
                  ],
                ),
              ),
              gapH16,
              Card(
                child: ListTile(
                  enabled: !state.isLoading,
                  onTap: state.isLoading
                      ? null
                      : () async {
                          final logout = await showAlertDialog(
                            context: context,
                            title: context.loc.areYouSure,
                            cancelActionText: context.loc.cancel,
                            defaultActionText: context.loc.logout,
                          );
                          if (logout == true) {
                            ref
                                .read(accountScreenControllerProvider.notifier)
                                .signOut();
                          }
                        },
                  leading: const Icon(Icons.logout_outlined),
                  title: Text(context.loc.logOut),
                ),
              ),
            ],
            gapH48,
          ],
        ),
      ),
    );
  }
}
