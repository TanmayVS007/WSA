import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/safe_haven_model.dart';

class SafeHavenService {
  final String _apiKey;
  final http.Client _client;

  SafeHavenService({String? apiKey, http.Client? client})
    : _apiKey = apiKey ?? 'AIzaSyD7-6N9JWS2G85NknphQeJjRXl5kqYx_Uw',
      _client = client ?? http.Client();

  /// Fetches real safe havens (Police, Hospitals, Pharmacies) around the user's live position
  Future<List<SafeHaven>> fetchNearbySafeHavens(
    double latitude,
    double longitude,
  ) async {
    // 1. Try Google Places API (New) Nearby Search
    try {
      final googleResults = await _fetchGooglePlacesNearby(latitude, longitude);
      if (googleResults.isNotEmpty) {
        return googleResults;
      }
    } catch (e) {
      debugPrint('Google Places API notice: $e. Using fallback provider.');
    }

    // 2. Fallback to OpenStreetMap Overpass API for real live nearby emergency POIs
    try {
      final overpassResults = await _fetchOverpassNearby(latitude, longitude);
      if (overpassResults.isNotEmpty) {
        return overpassResults;
      }
    } catch (e) {
      debugPrint('Overpass fallback notice: $e');
    }

    return [];
  }

  static const double maxRadiusMeters = 3000.0; // Strict 5km radius limit

  /// Calls Google Places API (New) searchNearby
  Future<List<SafeHaven>> _fetchGooglePlacesNearby(
    double latitude,
    double longitude,
  ) async {
    final uri = Uri.parse(
      'https://places.googleapis.com/v1/places:searchNearby',
    );

    final body = jsonEncode({
      'includedTypes': ['police', 'hospital', 'pharmacy'],
      'maxResultCount': 20,
      'locationRestriction': {
        'circle': {
          'center': {'latitude': latitude, 'longitude': longitude},
          'radius': maxRadiusMeters,
        },
      },
    });

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'places.id,places.displayName,places.formattedAddress,places.location,places.types,places.rating',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>?;
      if (places == null || places.isEmpty) return [];

      final List<SafeHaven> havens = [];
      for (final place in places) {
        final loc = place['location'];
        if (loc == null) continue;
        final pLat = (loc['latitude'] as num).toDouble();
        final pLng = (loc['longitude'] as num).toDouble();

        final types =
            (place['types'] as List<dynamic>?)
                ?.map((e) => e.toString().toLowerCase())
                .toList() ??
            [];

        SafeHavenCategory category = SafeHavenCategory.other;
        if (types.contains('police')) {
          category = SafeHavenCategory.police;
        } else if (types.contains('hospital')) {
          category = SafeHavenCategory.hospital;
        } else if (types.contains('pharmacy')) {
          category = SafeHavenCategory.pharmacy;
        }

        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          pLat,
          pLng,
        );

        // Enforce strict 5km radius filter
        if (distance > maxRadiusMeters) continue;

        final name = place['displayName']?['text'] ?? 'Safe Location';
        final address = place['formattedAddress'] ?? 'Nearby Safety Facility';
        final rating = (place['rating'] as num?)?.toDouble();

        havens.add(
          SafeHaven(
            id: place['id'] ?? 'pl_${havens.length}',
            name: name,
            address: address,
            latLng: LatLng(pLat, pLng),
            distanceMeters: distance,
            category: category,
            rating: rating,
          ),
        );
      }

      havens.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return havens;
    } else {
      throw Exception(
        'Google Places API error ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Live Overpass API fallback to ensure real nearby Police/Hospitals/Pharmacies
  Future<List<SafeHaven>> _fetchOverpassNearby(
    double latitude,
    double longitude,
  ) async {
    const radius = 5000;
    final query =
        '''
[out:json][timeout:10];
(
  node["amenity"="police"](around:$radius,$latitude,$longitude);
  node["amenity"="hospital"](around:$radius,$latitude,$longitude);
  node["amenity"="pharmacy"](around:$radius,$latitude,$longitude);
);
out 20;
''';

    final uri = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}',
    );

    final response = await _client.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>?;
      if (elements == null || elements.isEmpty) return [];

      final List<SafeHaven> havens = [];
      for (final el in elements) {
        final pLat = (el['lat'] as num?)?.toDouble();
        final pLng = (el['lon'] as num?)?.toDouble();
        if (pLat == null || pLng == null) continue;

        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        final amenity = tags['amenity'] as String? ?? '';
        final name =
            tags['name'] ??
            (amenity == 'police'
                ? 'Police Station'
                : amenity == 'hospital'
                ? 'Hospital & ER'
                : '24/7 Pharmacy');

        SafeHavenCategory category = SafeHavenCategory.other;
        if (amenity == 'police') {
          category = SafeHavenCategory.police;
        } else if (amenity == 'hospital') {
          category = SafeHavenCategory.hospital;
        } else if (amenity == 'pharmacy') {
          category = SafeHavenCategory.pharmacy;
        }

        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          pLat,
          pLng,
        );

        // Enforce strict 5km radius filter
        if (distance > maxRadiusMeters) continue;

        final street = tags['addr:street'] ?? '';
        final suburb = tags['addr:suburb'] ?? tags['addr:city'] ?? '';
        final address = street.isNotEmpty
            ? '$street, $suburb'
            : (suburb.isNotEmpty ? suburb : 'Emergency Anchor Point');

        havens.add(
          SafeHaven(
            id: 'osm_${el['id']}',
            name: name,
            address: address,
            latLng: LatLng(pLat, pLng),
            distanceMeters: distance,
            category: category,
          ),
        );
      }

      havens.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
      return havens;
    }
    return [];
  }

  /// Reverse geocodes coordinates to human-readable street/area address
  Future<String> fetchAddressForCoordinates(
    double latitude,
    double longitude,
  ) async {
    // 1. Try Google Geocoding API
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey',
      );
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final formatted = results[0]['formatted_address'] as String?;
          if (formatted != null && formatted.isNotEmpty) {
            return formatted;
          }
        }
      }
    } catch (_) {}

    // 2. Fallback to Nominatim
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
      );
      final response = await _client
          .get(uri, headers: {'User-Agent': 'WomenSafetyBandApp/1.0'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final displayName = data['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (_) {}

    return '${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E';
  }
}
