import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/common_widgets/outlined_section_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/store/data/store_repository.dart';
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

    return Padding(
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
                Text('Store description'),
                Text(store.description ?? 'No description yet'),
                gapH16,
                Text('Store details'),
                gapH8,
                Text('Name'),
                Text(store.name),
                gapH8,
                Text('Address'),
                SizedBox(width: 100, child: Text(store.addressInfo)),
                gapH16,
                Text('Contact details'),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AccountSettingsContent extends StatelessWidget {
  const AccountSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TeamSettingsContent extends StatelessWidget {
  const TeamSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
