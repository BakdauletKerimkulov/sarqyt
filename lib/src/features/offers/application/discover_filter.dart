import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/application/offers_with_distance.dart';
import 'package:sarqyt/src/utils/current_date_builder.dart';

part 'discover_filter.g.dart';

enum PickupTimeFilter { all, today, tomorrow }

enum SortBy { distance, price, time }

class DiscoverFilter {
  final PickupTimeFilter pickupTime;
  final double? maxPrice;
  final SortBy sortBy;
  final bool favoritesOnly;
  final String searchQuery;

  const DiscoverFilter({
    this.pickupTime = PickupTimeFilter.all,
    this.maxPrice,
    this.sortBy = SortBy.distance,
    this.favoritesOnly = false,
    this.searchQuery = '',
  });

  DiscoverFilter copyWith({
    PickupTimeFilter? pickupTime,
    double? maxPrice,
    SortBy? sortBy,
    bool? favoritesOnly,
    String? searchQuery,
  }) {
    return DiscoverFilter(
      pickupTime: pickupTime ?? this.pickupTime,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  DiscoverFilter clearMaxPrice() => DiscoverFilter(
    pickupTime: pickupTime,
    sortBy: sortBy,
    favoritesOnly: favoritesOnly,
    searchQuery: searchQuery,
  );
}

@riverpod
class DiscoverFilterController extends _$DiscoverFilterController {
  @override
  DiscoverFilter build() => const DiscoverFilter();

  void setPickupTime(PickupTimeFilter value) =>
      state = state.copyWith(pickupTime: value);

  void setMaxPrice(double? value) => value != null
      ? state = state.copyWith(maxPrice: value)
      : state = state.clearMaxPrice();

  void setSortBy(SortBy value) => state = state.copyWith(sortBy: value);

  void toggleFavoritesOnly() =>
      state = state.copyWith(favoritesOnly: !state.favoritesOnly);

  void setSearchQuery(String value) =>
      state = state.copyWith(searchQuery: value);

  /// Resets pickup-time/price/sort/favorites filters. Search is a separate
  /// app-bar UI concern (survives "clear filters" from the bottom sheet).
  void reset() => state = DiscoverFilter(searchQuery: state.searchQuery);
}

/// Pure function — testable without Riverpod.
List<OfferWithDistance> applyFilter(
  List<OfferWithDistance> offers,
  DiscoverFilter filter,
  Set<String> favoriteStoreIds,
  DateTime now,
) {
  var result = List<OfferWithDistance>.from(offers);

  // Favorites only
  if (filter.favoritesOnly) {
    result = result
        .where((o) => favoriteStoreIds.contains(o.offer.storeId))
        .toList();
  }

  // Pickup time
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  if (filter.pickupTime == PickupTimeFilter.today) {
    result = result.where((o) {
      final d = o.offer.pickupStartTime;
      return DateTime(d.year, d.month, d.day) == today;
    }).toList();
  } else if (filter.pickupTime == PickupTimeFilter.tomorrow) {
    result = result.where((o) {
      final d = o.offer.pickupStartTime;
      return DateTime(d.year, d.month, d.day) == tomorrow;
    }).toList();
  }

  // Max price
  if (filter.maxPrice != null) {
    result = result.where((o) => o.offer.price <= filter.maxPrice!).toList();
  }

  // Search: matches store name or item name, case-insensitive
  final query = filter.searchQuery.trim().toLowerCase();
  if (query.isNotEmpty) {
    result = result.where((o) {
      return o.offer.storeName.toLowerCase().contains(query) ||
          o.offer.name.toLowerCase().contains(query);
    }).toList();
  }

  // Sort
  switch (filter.sortBy) {
    case SortBy.distance:
      result.sort(
        (a, b) => (a.distanceKm ?? double.infinity).compareTo(
          b.distanceKm ?? double.infinity,
        ),
      );
    case SortBy.price:
      result.sort((a, b) => a.offer.price.compareTo(b.offer.price));
    case SortBy.time:
      result.sort(
        (a, b) => a.offer.pickupStartTime.compareTo(b.offer.pickupStartTime),
      );
  }

  return result;
}

@riverpod
List<OfferWithDistance> filteredOffers(
  Ref ref,
  List<OfferWithDistance> offers,
  DiscoverFilter filter,
  Set<String> favoriteStoreIds,
) {
  final now = ref.read(currentDateBuilderProvider)();
  return applyFilter(offers, filter, favoriteStoreIds, now);
}
