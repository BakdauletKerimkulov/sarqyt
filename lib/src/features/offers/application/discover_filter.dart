import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/src/features/offers/application/offers_with_distance.dart';

part 'discover_filter.g.dart';

enum PickupTimeFilter { all, today, tomorrow }
enum SortBy { distance, price, time }

class DiscoverFilter {
  final PickupTimeFilter pickupTime;
  final double? maxPrice;
  final SortBy sortBy;
  final bool favoritesOnly;

  const DiscoverFilter({
    this.pickupTime = PickupTimeFilter.all,
    this.maxPrice,
    this.sortBy = SortBy.distance,
    this.favoritesOnly = false,
  });

  DiscoverFilter copyWith({
    PickupTimeFilter? pickupTime,
    double? maxPrice,
    SortBy? sortBy,
    bool? favoritesOnly,
  }) {
    return DiscoverFilter(
      pickupTime: pickupTime ?? this.pickupTime,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }

  DiscoverFilter clearMaxPrice() => DiscoverFilter(
        pickupTime: pickupTime,
        sortBy: sortBy,
        favoritesOnly: favoritesOnly,
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

  void reset() => state = const DiscoverFilter();
}

@riverpod
List<OfferWithDistance> filteredOffers(
  Ref ref,
  List<OfferWithDistance> offers,
  DiscoverFilter filter,
  Set<String> favoriteStoreIds,
) {
  var result = List<OfferWithDistance>.from(offers);

  // Favorites only
  if (filter.favoritesOnly) {
    result = result
        .where((o) => favoriteStoreIds.contains(o.offer.storeId))
        .toList();
  }

  // Pickup time
  final now = DateTime.now();
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

  // Sort
  switch (filter.sortBy) {
    case SortBy.distance:
      result.sort((a, b) =>
          (a.distanceKm ?? double.infinity)
              .compareTo(b.distanceKm ?? double.infinity));
    case SortBy.price:
      result.sort((a, b) => a.offer.price.compareTo(b.offer.price));
    case SortBy.time:
      result.sort((a, b) =>
          a.offer.pickupStartTime.compareTo(b.offer.pickupStartTime));
  }

  return result;
}
