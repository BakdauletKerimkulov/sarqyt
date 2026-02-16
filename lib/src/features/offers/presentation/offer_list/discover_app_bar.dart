import 'package:flutter/material.dart';
import 'package:sarqyt/src/common_widgets/alert_dialogs.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class DiscoverAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DiscoverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Сделать аппбар с указанием геолокации
    return AppBar(
      title: Text('Discover'.hardcoded),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          icon: Icon(Icons.location_on),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kTextTabBarHeight),
        child: MyTabBar(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 44);
}

class MyTabBar extends StatelessWidget {
  const MyTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.p40,
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.p16,
        vertical: Sizes.p4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Sizes.p16),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.p16),
          color: Colors.blueAccent,
        ),
        tabs: [
          Tab(text: 'List'),
          Tab(text: 'Map'),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(30.0);
}
