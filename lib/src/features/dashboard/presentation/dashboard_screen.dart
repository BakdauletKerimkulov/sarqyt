// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/constants/breakpoints.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/auth/domain/app_user.dart';
import 'package:sarqyt/src/features/dashboard/presentation/dashboard_app_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser!;
    final role = ref.watch(currentUserRoleProvider).value ?? UserRole.guest;

    // Фильтруем меню по ролям
    final menuItems = sideMenuItems
        .where((item) => item.allowedRoles.contains(role))
        .toList();

    final String location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoint.desktop) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            drawerScrimColor: Colors.white,
            appBar: DashboardAppBar(user),
            body: Row(
              children: [
                // * Боковое меню
                Container(
                  padding: const EdgeInsets.only(top: Sizes.p16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(
                        width: 0.5,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  width: 250,
                  child: SideMenu(
                    items: menuItems,
                    currentLocation: location,
                    onItemClick: (path) => context.go(path),
                  ),
                ),

                // * Экран
                Expanded(child: child),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            drawerScrimColor: Colors.white,
            appBar: AppBar(title: const Text('Sarqyt')),
            drawer: Drawer(
              child: SideMenu(
                items: menuItems,
                currentLocation: location,
                onItemClick: (path) {
                  context.go(path);
                  Navigator.pop(context);
                },
              ),
            ),
            body: child,
          );
        }
      },
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.items,
    required this.currentLocation,
    required this.onItemClick,
  });

  final List<SideMenuItem> items;
  final String currentLocation;
  final Function(String) onItemClick;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: Sizes.p12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: Sizes.p8),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = currentLocation.startsWith(item.routePath);

        return Material(
          color: Colors.transparent,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.p12),
            ),
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            leading: Icon(item.icon),
            title: Text(item.title),
            selected: isSelected,
            selectedTileColor: AppColors.primary.withAlpha(220),
            selectedColor: Colors.white,
            onTap: () => onItemClick(item.routePath),
          ),
        );
      },
    );
  }
}

class SideMenuItem {
  const SideMenuItem({
    required this.icon,
    required this.title,
    required this.routePath,
    required this.allowedRoles,
  });

  final IconData icon;
  final String title;
  final String routePath;
  final Set<UserRole> allowedRoles;
}

const sideMenuItems = [
  SideMenuItem(
    icon: Icons.dashboard,
    title: 'Dashboard',
    routePath: '/dashboard',
    allowedRoles: {UserRole.owner, UserRole.employee},
  ),
  SideMenuItem(
    icon: Icons.inventory,
    title: 'Stores',
    routePath: '/stores',
    allowedRoles: {UserRole.owner},
  ),
  SideMenuItem(
    icon: Icons.people,
    title: 'Employers',
    routePath: '/employers',
    allowedRoles: {UserRole.owner},
  ),
  SideMenuItem(
    icon: Icons.food_bank,
    title: 'Offers',
    routePath: '/offers',
    allowedRoles: {UserRole.owner, UserRole.employee},
  ),
];
