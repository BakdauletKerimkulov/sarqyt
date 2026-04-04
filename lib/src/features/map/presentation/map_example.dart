import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sarqyt/env.dart';
import 'package:sarqyt/src/constants/app_sizes.dart';
import 'package:sarqyt/src/features/map/application/geolocator_service.dart';

const styleUrl =
    "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png";

class MapExample extends ConsumerStatefulWidget {
  const MapExample({super.key});

  @override
  ConsumerState<MapExample> createState() => _MapExampleState();
}

class _MapExampleState extends ConsumerState<MapExample> {
  late final MapController _controller;

  List<LatLng> get _mapPoints => const [
    LatLng(55.755793, 37.617134),
    LatLng(55.095960, 38.765519),
    LatLng(56.129038, 40.406502),
    LatLng(54.513645, 36.261268),
    LatLng(54.193122, 37.617177),
    LatLng(54.629540, 39.741809),
  ];

  @override
  void initState() {
    _controller = MapController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.chevron_left),
        ),
        title: Text('Map Screen'),
      ),
      body: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: LatLng(43.256523, 76.938549),
          initialZoom: 16,
          minZoom: 5,
          maxZoom: 20,
        ),
        children: [
          TileLayer(
            urlTemplate: '$styleUrl?api_key={api_key}',
            additionalOptions: {'api_key': Env.stadiaMapsApiKey},
            userAgentPackageName: 'com.example.sarqyt',
            maxNativeZoom: 20,
          ),
          MarkerLayer(markers: _getMarkers(_mapPoints)),
        ],
      ),
      floatingActionButton: IconButton(
        iconSize: Sizes.p48,
        onPressed: () {
          positionAsync.whenData((position) {
            if (position != null) {
              _controller.move(
                LatLng(position.latitude, position.longitude),
                16,
              );
            }
          });
        },
        icon: Icon(Icons.location_on),
      ),
    );
  }

  List<Marker> _getMarkers(List<LatLng> points) {
    return List.generate(
      points.length,
      (index) => Marker(
        point: points[index],
        child: Image.asset('assets/icons/map-point.png'),
        width: Sizes.p48,
        height: Sizes.p48,
        alignment: Alignment.center,
      ),
    );
  }
}
