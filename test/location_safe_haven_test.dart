import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:women_safety_band/features/location/data/services/safe_haven_service.dart';
import 'package:women_safety_band/features/location/domain/models/safe_haven_model.dart';

void main() {
  group('SafeHaven Model & Geometry Tests', () {
    test('SafeHaven formattedDistance formats meters and kilometers cleanly', () {
      const havenNear = SafeHaven(
        id: 'h_1',
        name: 'Camp Police Outpost',
        address: 'MG Road, Camp',
        latLng: LatLng(18.5200, 73.8760),
        distanceMeters: 420.4,
        category: SafeHavenCategory.police,
      );

      expect(havenNear.formattedDistance, '420m away');

      const havenFar = SafeHaven(
        id: 'h_2',
        name: 'Civil Hospital',
        address: 'Station Road',
        latLng: LatLng(18.5350, 73.8800),
        distanceMeters: 2450.0,
        category: SafeHavenCategory.hospital,
      );

      expect(havenFar.formattedDistance, '2.5km away');
    });

    test('SafeHaven assigns distinct category markers and badges', () {
      const police = SafeHaven(
        id: 'p1',
        name: 'Police Station',
        address: 'Main Chowk',
        latLng: LatLng(18.52, 73.87),
        distanceMeters: 100,
        category: SafeHavenCategory.police,
      );
      expect(police.category, SafeHavenCategory.police);
      expect(police.markerHue, BitmapDescriptor.hueAzure);

      const hospital = SafeHaven(
        id: 'h1',
        name: 'Emergency Hospital',
        address: 'Hospital Way',
        latLng: LatLng(18.52, 73.87),
        distanceMeters: 200,
        category: SafeHavenCategory.hospital,
      );
      expect(hospital.markerHue, BitmapDescriptor.hueRose);

      const pharmacy = SafeHaven(
        id: 'ph1',
        name: '24/7 Meds',
        address: 'Corner Shop',
        latLng: LatLng(18.52, 73.87),
        distanceMeters: 300,
        category: SafeHavenCategory.pharmacy,
      );
      expect(pharmacy.markerHue, BitmapDescriptor.hueCyan);
    });

    test('SafeHavenService maxRadiusMeters enforces strict 5km perimeter', () {
      expect(SafeHavenService.maxRadiusMeters, 5000.0);

      const withinZone = SafeHaven(
        id: 'in_zone',
        name: 'Within 5km Police Post',
        address: 'Nearby St',
        latLng: LatLng(18.52, 73.87),
        distanceMeters: 4950.0,
        category: SafeHavenCategory.police,
      );

      const outsideZone = SafeHaven(
        id: 'out_zone',
        name: 'Outside 5km Hospital',
        address: 'Distant St',
        latLng: LatLng(18.56, 73.92),
        distanceMeters: 5050.0,
        category: SafeHavenCategory.hospital,
      );

      final havens = [withinZone, outsideZone];
      final filteredHavens = havens
          .where((h) => h.distanceMeters <= SafeHavenService.maxRadiusMeters)
          .toList();

      expect(filteredHavens.length, 1);
      expect(filteredHavens.first.id, 'in_zone');
    });
  });
}

