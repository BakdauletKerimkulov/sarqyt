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
                  context.loc.filters,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ctrl.reset();
                    Navigator.pop(context);
                  },
                  child: Text(context.loc.reset),
                ),
              ],
            ),
            gapH16,

            // Favorites
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: Text(context.loc.favoritesOnly),
              secondary: const Icon(Icons.favorite, color: Colors.red),
              value: filter.favoritesOnly,
              onChanged: (_) => ctrl.toggleFavoritesOnly(),
            ),
            gapH8,
            const Divider(),
            gapH8,

            // Pickup time
            Text(
              context.loc.pickupTime,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            gapH12,
            Wrap(
              spacing: 8,
              children: PickupTimeFilter.values.map((t) {
                return ChoiceChip(
                  label: Text(switch (t) {
                    PickupTimeFilter.all => context.loc.all,
                    PickupTimeFilter.today => context.loc.today,
                    PickupTimeFilter.tomorrow => context.loc.tomorrow,
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
              context.loc.sortBy,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            gapH12,
            Wrap(
              spacing: 8,
              children: SortBy.values.map((s) {
                return ChoiceChip(
                  label: Text(switch (s) {
                    SortBy.distance => context.loc.nearest,
                    SortBy.price => context.loc.cheapest,
                    SortBy.time => context.loc.soonest,
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
                child: Text(context.loc.apply),
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
