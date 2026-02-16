// Этот виджет можно вынести в common_widgets/map_preview.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/env.dart';
import 'package:sarqyt/src/constants/app_colors.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/localization/string_hardcoded.dart';

class StaticMapPreview extends StatelessWidget {
  const StaticMapPreview({
    super.key,
    required this.location,
    this.height = 200,
    this.zoom = 15,
  });

  final LatLng? location;
  final double height;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return Container(
        height: height,
        color: Colors.grey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined),
              Text('Location not found'.hardcoded),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Sizes.p8),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location!,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key={api_key}',
              additionalOptions: {'api_key': Env.stadiaMapsApiKey},
              userAgentPackageName: 'com.example.sarqyt',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location!,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                  ),
                  height: Sizes.p64,
                  width: Sizes.p64,
                  alignment: Alignment.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
