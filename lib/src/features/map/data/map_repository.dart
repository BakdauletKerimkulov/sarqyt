import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sarqyt/env.dart';
import 'package:sarqyt/src/features/map/data/map_constants.dart';

part 'map_repository.g.dart';

class MapRepository {
  const MapRepository();

  String get _apiKey => Env.stadiaMapsApiKey;

  Future<LatLng?> getCoordinates(String query) async {
    final uri = Uri.parse(MapConstants.searchBaseUrl).replace(
      queryParameters: {'text': query, 'size': '1', 'api_key': _apiKey},
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['features'] != null && (data['features'] as List).isNotEmpty) {
          final result = data['features'][0];
          final coordinates = result['geometry']['coordinates'];
          return LatLng(coordinates[1], coordinates[0]);
        }
      } else {
        debugPrint('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error has occured: ${e.toString()}');
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
MapRepository mapRepository(Ref ref) {
  return MapRepository();
}
