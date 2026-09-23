import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SafeHavenCategory {
  police,
  hospital,
  pharmacy,
  other,
}

class SafeHaven {
  final String id;
  final String name;
  final String address;
  final LatLng latLng;
  final double distanceMeters;
  final SafeHavenCategory category;
  final double? rating;

  const SafeHaven({
    required this.id,
    required this.name,
    required this.address,
    required this.latLng,
    required this.distanceMeters,
    required this.category,
    this.rating,
  });

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()}m away';
    } else {
      return '${(distanceMeters / 1000).toStringAsFixed(1)}km away';
    }
  }

  IconData get icon {
    switch (category) {
      case SafeHavenCategory.police:
        return Icons.local_police_rounded;
      case SafeHavenCategory.hospital:
        return Icons.medical_services_rounded;
      case SafeHavenCategory.pharmacy:
        return Icons.local_pharmacy_rounded;
      case SafeHavenCategory.other:
        return Icons.security_rounded;
    }
  }

  Color get badgeColor {
    switch (category) {
      case SafeHavenCategory.police:
        return const Color(0xFF005AC1);
      case SafeHavenCategory.hospital:
        return const Color(0xFFBA1A1A);
      case SafeHavenCategory.pharmacy:
        return const Color(0xFF006874);
      case SafeHavenCategory.other:
        return const Color(0xFF4A6572);
    }
  }

  double get markerHue {
    switch (category) {
      case SafeHavenCategory.police:
        return BitmapDescriptor.hueAzure;
      case SafeHavenCategory.hospital:
        return BitmapDescriptor.hueRose;
      case SafeHavenCategory.pharmacy:
        return BitmapDescriptor.hueCyan;
      case SafeHavenCategory.other:
        return BitmapDescriptor.hueViolet;
    }
  }
}
