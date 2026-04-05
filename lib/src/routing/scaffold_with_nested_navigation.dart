// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/common_widgets/custom_image.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class SideMenuItem {
  const SideMenuItem({
    required this.icon,
    required this.title,
    required this.branchIndex,
    required this.allowedRoles,
  });

  final IconData icon;
  final String title;
  final int branchIndex;
  final Set<StoreRole> allowedRoles;
}

/// Section grouping for sidebar.
class SideMenuSection {
  const SideMenuSection({required this.title, required this.items});

  final String title;
  final List<SideMenuItem> items;
}

/// Sections — order of branchIndex must match branches in StatefulShellRoute.
const sideMenuSections = [
  SideMenuSection(
    title: 'Store',
    items: [
      SideMenuItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        branchIndex: 0,
        allowedRoles: {StoreRole.owner, StoreRole.operator},
      ),
      SideMenuItem(
        icon: Icons.bar_chart,
        title: 'Performance',
        branchIndex: 1,
        allowedRoles: {StoreRole.owner, StoreRole.operator},
      ),
      SideMenuItem(
        icon: Icons.account_balance_wallet,
        title: 'Financials',
        branchIndex: 2,
        allowedRoles: {StoreRole.owner},
      ),
      SideMenuItem(
        icon: Icons.settings,
        title: 'Settings',
        branchIndex: 3,
        allowedRoles: {StoreRole.owner, StoreRole.operator},
      ),
    ],
  ),
  SideMenuSection(
    title: 'Support',
    items: [
      SideMenuItem(
        icon: Icons.help_outline,
        title: 'Help Centre',
        branchIndex: 4,
        allowedRoles: {StoreRole.owner, StoreRole.operator},
      ),
    ],
  ),
];

/// Flat list for backward-compat (only items with real branchIndex).
final sideMenuItems = sideMenuSections
    .expand((s) => s.items)
    .where((i) => i.branchIndex >= 0)
    .toList();

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBranch = navigationShell.currentIndex;

    final size = MediaQuery.sizeOf(context);
    if (size.width < 450) {
      return Scaffold(
        appBar: _GlobalAppBar(showMenuButton: true),
        body: navigationShell,
        drawer: Drawer(
          child: _SidebarContent(
            currentBranch: currentBranch,
            onBranchTap: (branchIndex) {
              _goBranch(branchIndex);
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 280.0,
            child: _SidebarContent(
              currentBranch: currentBranch,
              onBranchTap: _goBranch,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Scaffold(appBar: _GlobalAppBar(), body: navigationShell),
          ),
        ],
      ),
    );
  }
}

class _GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GlobalAppBar({this.showMenuButton = false});

  final bool showMenuButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showMenuButton,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        IconButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          icon: const Icon(Icons.notifications_outlined),
        ),
        const SizedBox(width: Sizes.p8),
      ],
    );
  }
}

class _SidebarContent extends ConsumerWidget {
  const _SidebarContent({
    required this.currentBranch,
    required this.onBranchTap,
  });

  final int currentBranch;
  final ValueChanged<int> onBranchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShip = ref.watch(currentStoreShipProvider);
    final textTheme = Theme.of(context).textTheme;
    final menuSectionChildren = <Widget>[
      for (final section in sideMenuSections) ...[
        Padding(
          padding: const EdgeInsets.only(
            left: Sizes.p12,
            bottom: Sizes.p8,
            top: Sizes.p12,
          ),
          child: Text(
            section.title.hardcoded,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        for (final item in section.items)
          _MenuTile(
            item: item,
            isSelected:
                item.branchIndex >= 0 && item.branchIndex == currentBranch,
            onTap: () {
              if (item.branchIndex >= 0) {
                onBranchTap(item.branchIndex);
              }
            },
          ),
      ],
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.p16,
          vertical: Sizes.p20,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/app-icon-2.png',
                        fit: BoxFit.cover,
                        width: Sizes.p64,
                        height: Sizes.p64,
                      ),
                    ),
                  ),
                  gapH16,
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: BorderRadius.circular(Sizes.p16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(Sizes.p16),
                      leading: ClipOval(
                        child: CustomImage(
                          imageUrl: storeShip.logoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(storeShip.name),
                      trailing: IconButton(
                        onPressed: () =>
                            showNotImplementedAlertDialog(context: context),
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  ),
                  gapH24,
                ],
              ),
            ),
            SliverList(delegate: SliverChildListDelegate(menuSectionChildren)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const Spacer(),
                  const Divider(),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.p12),
                    ),
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      'Log out'.hardcoded,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Log out'.hardcoded),
                          content: Text(
                            'Are you sure you want to log out?'.hardcoded,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text('Cancel'.hardcoded),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(
                                'Log out'.hardcoded,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(authRepositoryProvider).signOut();
                      }
                    },
                  ),
                  gapH24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final SideMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.p4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.p12),
        ),
        leading: Icon(item.icon),
        title: Text(item.title),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withAlpha(220),
        selectedColor: Colors.white,
        onTap: onTap,
      ),
    );
  }
}
