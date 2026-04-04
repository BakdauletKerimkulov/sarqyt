import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/offers/application/discover_filter.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class FilterBottomSheet extends ConsumerWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(discoverFilterControllerProvider);
    final ctrl = ref.read(discoverFilterControllerProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Filters'.hardcoded,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ctrl.reset();
                    Navigator.pop(context);
                  },
                  child: Text('Reset'.hardcoded),
                ),
              ],
            ),
            gapH16,

            // Favorites
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: Text('Favorites only'.hardcoded),
              secondary: const Icon(Icons.favorite, color: Colors.red),
              value: filter.favoritesOnly,
              onChanged: (_) => ctrl.toggleFavoritesOnly(),
            ),
            gapH8,
            const Divider(),
            gapH8,

            // Pickup time
            Text(
              'Pickup time'.hardcoded,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            gapH12,
            Wrap(
              spacing: 8,
              children: PickupTimeFilter.values.map((t) {
                return ChoiceChip(
                  label: Text(switch (t) {
                    PickupTimeFilter.all => 'All'.hardcoded,
                    PickupTimeFilter.today => 'Today'.hardcoded,
                    PickupTimeFilter.tomorrow => 'Tomorrow'.hardcoded,
                  }),
                  selected: filter.pickupTime == t,
                  selectedColor: AppColors.primary.withAlpha(30),
                  onSelected: (_) => ctrl.setPickupTime(t),
                );
              }).toList(),
            ),
            gapH16,

            // Sort by
            Text(
              'Sort by'.hardcoded,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            gapH12,
            Wrap(
              spacing: 8,
              children: SortBy.values.map((s) {
                return ChoiceChip(
                  label: Text(switch (s) {
                    SortBy.distance => 'Nearest'.hardcoded,
                    SortBy.price => 'Cheapest'.hardcoded,
                    SortBy.time => 'Soonest'.hardcoded,
                  }),
                  selected: filter.sortBy == s,
                  selectedColor: AppColors.primary.withAlpha(30),
                  onSelected: (_) => ctrl.setSortBy(s),
                );
              }).toList(),
            ),
            gapH24,

            // Apply
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.p12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Apply'.hardcoded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Whether any filter is active (not default)
bool hasActiveFilters(DiscoverFilter filter) {
  return filter.favoritesOnly ||
      filter.pickupTime != PickupTimeFilter.all ||
      filter.sortBy != SortBy.distance ||
      filter.maxPrice != null;
}
