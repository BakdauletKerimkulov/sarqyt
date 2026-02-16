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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.chevron_left),
        ),
        title: Text('Account'.hardcoded),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 175,
              child: Center(
                child: user != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: Sizes.p48,
                            backgroundImage: user.avatarUrl != null
                                ? CachedNetworkImageProvider(user.avatarUrl!)
                                : AssetImage('assets/unknown_person.jpg'),
                          ),
                          Text(
                            user.email ?? 'email',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () =>
                            context.goNamed(ClientRoute.signIn.name),
                        child: Text('Sign in'.hardcoded),
                      ),
              ),
            ),

            gapH16,

            Padding(
              padding: const EdgeInsets.all(Sizes.p16),
              child: Column(
                children: [
                  if (user != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'General'.hardcoded,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Account information'.hardcoded),
                              subtitle: Text(
                                'Change your account information'.hardcoded,
                              ),
                              trailing: Icon(Icons.chevron_right),
                            ),
                            Divider(),

                            ListTile(
                              leading: Icon(Icons.lock),
                              title: Text('Password'.hardcoded),
                              subtitle: Text('Change your password'.hardcoded),
                              trailing: Icon(Icons.chevron_right),
                            ),
                            Divider(),

                            ListTile(
                              leading: Icon(Icons.payment),
                              title: Text('Payment methods'.hardcoded),
                              subtitle: Text(
                                'Add your credit & debit cards'.hardcoded,
                              ),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),

                  gapH16,

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications'.hardcoded,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.notifications),
                            title: Text('Notifications'.hardcoded),
                            subtitle: Text(
                              'You will receive daily updates'.hardcoded,
                            ),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  gapH16,

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(Sizes.p16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More'.hardcoded,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Rate us'.hardcoded),
                            subtitle: Text('You will receive daily updates'),
                            trailing: Icon(Icons.chevron_right),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.book),
                            title: Text('FAQ'.hardcoded),
                            subtitle: Text(
                              'Frequently Asked Questions'.hardcoded,
                            ),
                            trailing: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ),

                  gapH16,

                  if (user != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Sizes.p16),
                        child: ListTile(
                          enabled: !state.isLoading,
                          onTap: state.isLoading
                              ? null
                              : () async {
                                  final logout = await showAlertDialog(
                                    context: context,
                                    title: 'Are you sure?'.hardcoded,
                                    cancelActionText: 'Cancel'.hardcoded,
                                    defaultActionText: 'Logout'.hardcoded,
                                  );

                                  if (logout == true) {
                                    ref
                                        .read(
                                          accountScreenControllerProvider
                                              .notifier,
                                        )
                                        .signOut();
                                  }
                                },
                          leading: Icon(Icons.logout_outlined),
                          title: Text('Log out'.hardcoded),
                          trailing: Icon(Icons.chevron_right),
                        ),
                      ),
                    ),

                  gapH48,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
