import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/icon_title_subtitle.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar(this.user, {super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider).value ?? UserRole.guest;
    return AppBar(
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade200),
      ),
      title: IconTitleSubtitle(
        leading: Icon(Icons.logo_dev_outlined, size: Sizes.p48),
        title: 'Sarqyt data management'.hardcoded,
        subtitle: 'Food analitycs dashboard'.hardcoded,
      ),
      actions: [
        IconButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          icon: Icon(Icons.notifications_outlined),
        ),
        gapW16,
        DashboardMenuButton(user: user, role: role),
        gapW16,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}

class DashboardMenuButton extends ConsumerWidget {
  const DashboardMenuButton({
    super.key,
    required this.user,
    required this.role,
  });

  final AppUser user;
  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(alignment: Alignment.bottomLeft),
      menuChildren: [
        MenuItemButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          child: Text('Account settings'.hardcoded),
        ),
        const Divider(height: 1, thickness: 1),
        MenuItemButton(
          onPressed: () => ref.read(authRepositoryProvider).signOut(),
          child: Text('Logout'.hardcoded, style: TextStyle(color: Colors.red)),
        ),
      ],
      builder: (context, controller, child) {
        return TextButton(
          onPressed: controller.open,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.p8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.p16),
            ),
            foregroundColor: Colors.black,
            backgroundColor: Colors.transparent,
          ),
          child: IconTitleSubtitle(
            leading: CircleAvatar(child: Text(user.userInitial)),
            title: user.email ?? '',
            subtitle: role.name,
          ),
        );
      },
    );
  }
}
