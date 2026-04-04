import 'package:flutter/material.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class DiscoverAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DiscoverAppBar({super.key, this.bottom});

  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    // Сделать кнопку с фильтром
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      title: Text('Discover'.hardcoded),
      centerTitle: true,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}

enum ListMapToggle { list, map }

class ListMapToggleWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const ListMapToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(Sizes.p12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Sizes.p16,
        horizontal: Sizes.p32,
      ),
      child: Material(
        color: Colors.grey.shade300,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: Sizes.p40,
          child: TabBar(
            splashBorderRadius: radius,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              borderRadius: radius,
              color: AppColors.primary,
            ),
            tabs: ListMapToggle.values.map((c) => Tab(text: c.name)).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Sizes.p40 + Sizes.p16 * 2);
}
