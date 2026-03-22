import 'package:flutter/material.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

enum ItemTab { overview, calendar, schedule, customerRatings, settings }

extension ItemTabX on ItemTab {
  String get param {
    return switch (this) {
      ItemTab.overview => 'overview',
      ItemTab.calendar => 'calendar',
      ItemTab.schedule => 'schedule',
      ItemTab.customerRatings => 'ratings',
      ItemTab.settings => 'settings',
    };
  }

  String get title {
    return switch (this) {
      ItemTab.overview => 'Overview'.hardcoded,
      ItemTab.calendar => 'Calendar'.hardcoded,
      ItemTab.schedule => 'Schedule'.hardcoded,
      ItemTab.customerRatings => 'Customer ratings'.hardcoded,
      ItemTab.settings => 'Settings'.hardcoded,
    };
  }

  IconData get icon {
    return switch (this) {
      ItemTab.overview => Icons.watch_later_outlined,
      ItemTab.calendar => Icons.calendar_month_outlined,
      ItemTab.schedule => Icons.view_carousel_outlined,
      ItemTab.customerRatings => Icons.rate_review_outlined,
      ItemTab.settings => Icons.settings_outlined,
    };
  }

  IconData get selectedIcon {
    return switch (this) {
      ItemTab.overview => Icons.watch_later,
      ItemTab.calendar => Icons.calendar_month,
      ItemTab.schedule => Icons.view_carousel,
      ItemTab.customerRatings => Icons.rate_review,
      ItemTab.settings => Icons.settings,
    };
  }

  static ItemTab fromParam(String? value) {
    return ItemTab.values.firstWhere(
      (tab) => tab.param == value,
      orElse: () => ItemTab.overview,
    );
  }
}
