import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/env.dart';
import 'package:sarqyt/src/common_widgets/async_value_widget.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/auth/data/auth_repository.dart';
import 'package:sarqyt/src/features/map/application/geolocator_service.dart';
import 'package:sarqyt/src/features/map/presentation/map_example.dart';
import 'package:sarqyt/src/features/offers/application/discover_filter.dart';
import 'package:sarqyt/src/features/offers/application/offers_with_distance.dart';
import 'package:sarqyt/src/features/offers/data/favorites_repository.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/discover_app_bar.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/filter_bottom_sheet.dart';
import 'package:sarqyt/src/features/offers/presentation/offer_list/offer_card.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';
import 'package:sarqyt/src/routing/client_router.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offersWithDistanceProvider);
    final filter = ref.watch(discoverFilterControllerProvider);
    final favIds = ref.watch(favoriteStoreIdsProvider).value ?? const {};

    return DefaultTabController(
      length: ListMapToggle.values.length,
      child: Scaffold(
        appBar: DiscoverAppBar(
          bottom: offersAsync.value != null ? ListMapToggleWidget() : null,
          hasActiveFilters: hasActiveFilters(filter),
          onFilterPressed: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const FilterBottomSheet(),
          ),
        ),
        body: AsyncValueWidget(
          value: offersAsync,
          data: (offers) {
            final filtered = ref.watch(
              filteredOffersProvider(offers, filter, favIds),
            );

            if (filtered.isEmpty) {
              return Center(child: Text('No offers found'.hardcoded));
            }

            return TabBarView(
              children: [
                _OfferList(offers: filtered, favIds: favIds, ref: ref),
                DiscoverMapContent(
                  offers: filtered.map((o) => o.offer).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OfferList extends StatelessWidget {
  const _OfferList({
    required this.offers,
    required this.favIds,
    required this.ref,
  });

  final List<OfferWithDistance> offers;
  final Set<String> favIds;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Sizes.p8),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final item = offers[index];
        final isFav = favIds.contains(item.offer.storeId);
        return OfferCard(
          offer: item.offer,
          distanceLabel: item.distanceLabel,
          isFavorite: isFav,
          onFavoriteToggle: () => _toggleFavorite(item.offer.storeId, isFav),
          onPressed: () => context.goNamed(
            ClientRoute.offer.name,
            pathParameters: {'id': item.offer.id},
          ),
        );
      },
      separatorBuilder: (_, __) => gapH12,
    );
  }

  void _toggleFavorite(String storeId, bool isFav) {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;
    final repo = ref.read(favoritesRepositoryProvider);
    if (isFav) {
      repo.removeFavorite(user.uid, storeId);
    } else {
      repo.addFavorite(user.uid, storeId);
    }
  }
}

class DiscoverMapContent extends ConsumerStatefulWidget {
  const DiscoverMapContent({super.key, required this.offers});

  final List<dynamic> offers;

  @override
  ConsumerState<DiscoverMapContent> createState() =>
      _DiscoverMapContentState();
}

class _DiscoverMapContentState extends ConsumerState<DiscoverMapContent> {
  final MapController _controller = MapController();
  double _zoom = 15;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _markerSize => (_zoom * 2.5).clamp(20, 56);

  Future<void> _goToMyLocation() async {
    final position = await ref.read(positionProvider.future);
    if (position != null && mounted) {
      _controller.move(LatLng(position.latitude, position.longitude), 17);
    }
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionProvider);
    final userLatLng = positionAsync.whenOrNull(
      data: (p) => p != null ? LatLng(p.latitude, p.longitude) : null,
    );

    final offerPoints = widget.offers
        .map((o) => o is OfferWithDistance ? o.offer.latLng : (o as dynamic).latLng as LatLng)
        .toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: userLatLng ?? LatLng(43.256523, 76.938549),
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 18,
            onPositionChanged: (position, hasGesture) {
              if (position.zoom != _zoom) {
                setState(() => _zoom = position.zoom);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: '$styleUrl?api_key={api_key}',
              additionalOptions: {'api_key': Env.stadiaMapsApiKey},
              userAgentPackageName: 'com.example.sarqyt',
              maxNativeZoom: 18,
            ),
            MarkerLayer(
              markers: [
                ..._getMarkers(offerPoints),
                if (userLatLng != null)
                  Marker(
                    point: userLatLng,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha(80),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          right: Sizes.p16,
          bottom: Sizes.p16,
          child: FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  List<Marker> _getMarkers(List<LatLng> points) {
    final size = _markerSize;
    return List.generate(
      points.length,
      (index) => Marker(
        point: points[index],
        child: Icon(Icons.location_on, color: AppColors.primary, size: size),
        width: size,
        height: size,
        alignment: Alignment.center,
      ),
    );
  }
}
