import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/business_console/presentation/team/invite_member_dialog.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
import 'package:sarqyt/src/features/store/data/store_ship_repository.dart';
import 'package:sarqyt/src/features/store/domain/store_ship.dart';
import 'package:sarqyt/src/routing/business_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: 'Store'),
    Tab(text: 'Account'),
    Tab(text: 'Team'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p32,
              Sizes.p32,
              Sizes.p32,
              Sizes.p16,
            ),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              tabs: _tabs,
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          StoreSettingsContent(),
          AccountSettingsContent(),
          TeamSettingsContent(),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.p32),
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class StoreSettingsContent extends ConsumerWidget {
  const StoreSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShip = ref.watch(currentStoreShipProvider);
    final storeAsync = ref.watch(storeStreamProvider(storeShip.storeId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p32),
        child: OutlinedSectionWidgetWithHeader(
          header: 'Store information',
          child: AsyncValueWidget(
          value: storeAsync,
          data: (store) {
            if (store == null) {
              return const Center(child: Text('Store not found'));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Here you can see the information we have registered about your store. '
                  'If any of this information is incorrect and needs to be changed, please get in touch with us.',
                ),
                gapH24,
                Text(
                  'Store description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(store.description ?? 'No description yet'),
                gapH16,
                Text(
                  'Store details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                gapH8,
                Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(store.name),
                gapH8,
                Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 100, child: Text(store.addressInfo)),
                gapH16,
                Text(
                  'Contact details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
          ),
        ),
      ),
    );
  }
}

class AccountSettingsContent extends StatelessWidget {
  const AccountSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Account settings',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text('Coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class TeamSettingsContent extends ConsumerWidget {
  const TeamSettingsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeShip = ref.watch(currentStoreShipProvider);
    final shipsAsync = ref.watch(storeShipsByStoreIdProvider(storeShip.storeId));
    final textTheme = Theme.of(context).textTheme;

    return AsyncValueWidget(
      value: shipsAsync,
      data: (ships) {
        if (ships.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No team members yet',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(Sizes.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team members',
                    style: textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) =>
                          InviteMemberDialog(storeId: storeShip.storeId),
                    ),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Invite'),
                  ),
                ],
              ),
              gapH16,
              Expanded(
                child: ListView.separated(
                  itemCount: ships.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = ships[index];
                    return _TeamMemberTile(member: member);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamMemberTile extends StatelessWidget {
  const _TeamMemberTile({required this.member});

  final StoreShip member;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(member.name),
      subtitle: Text(member.role.name),
      trailing: member.permissions.isNotEmpty
          ? Chip(
              label: Text(
                '${member.permissions.length} permissions',
                style: textTheme.labelSmall,
              ),
            )
          : null,
    );
  }
}
