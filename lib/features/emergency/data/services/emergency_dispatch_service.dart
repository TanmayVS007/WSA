import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyLocationFix {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool isLiveGps;

  const EmergencyLocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.isLiveGps = true,
  });
}

class EmergencyDispatchService {
  /// Attempts to acquire the real phone GPS fix with high accuracy.
  /// Falls back to last known position or default coordinates if unavailable.
  static Future<EmergencyLocationFix> getAccurateLocation({
    double fallbackLat = 18.52043,
    double fallbackLng = 73.85674,
  }) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled; using fallback position.');
        return EmergencyLocationFix(
          latitude: fallbackLat,
          longitude: fallbackLng,
          accuracyMeters: 25.0,
          isLiveGps: false,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          debugPrint('Location permission denied; using fallback position.');
          return EmergencyLocationFix(
            latitude: fallbackLat,
            longitude: fallbackLng,
            accuracyMeters: 25.0,
            isLiveGps: false,
          );
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );

      return EmergencyLocationFix(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        isLiveGps: true,
      );
    } catch (e) {
      debugPrint('Error getting GPS fix: $e. Using fallback.');
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return EmergencyLocationFix(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            accuracyMeters: lastKnown.accuracy,
            isLiveGps: false,
          );
        }
      } catch (_) {}

      return EmergencyLocationFix(
        latitude: fallbackLat,
        longitude: fallbackLng,
        accuracyMeters: 30.0,
        isLiveGps: false,
      );
    }
  }

  /// Launches phone dialer to call National Emergency 112 or a specified number.
  static Future<bool> launchEmergencyCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        debugPrint('Could not launch emergency dialer: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching emergency dialer: $e');
      return false;
    }
  }

  /// Launches SMS app with pre-filled emergency distress message and Google Maps location URL.
  static Future<bool> launchEmergencySms({
    required List<String> phoneNumbers,
    required double latitude,
    required double longitude,
    String userName = 'Aegis Wearer',
  }) async {
    final mapLink = 'https://maps.google.com/?q=$latitude,$longitude';
    final message = Uri.encodeComponent(
      '🚨 EMERGENCY SOS ALERT!\n'
      '$userName has triggered an urgent emergency beacon.\n'
      'Current GPS Location: $mapLink\n'
      'Please send help immediately!',
    );

    // Filter and clean phone numbers
    final cleanPhones = phoneNumbers
        .map((p) => p.replaceAll(RegExp(r'[^\d+]'), ''))
        .where((p) => p.isNotEmpty)
        .toList();

    final recipients = cleanPhones.join(';');
    final uri = Uri.parse('sms:$recipients?body=$message');

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        // Fallback for some Android/iOS versions that prefer ',' separator or no query parameters
        final fallbackUri = Uri.parse('sms:${cleanPhones.join(',')}?body=$message');
        if (await canLaunchUrl(fallbackUri)) {
          return await launchUrl(fallbackUri);
        }
        debugPrint('Could not launch SMS app: $uri');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching SMS app: $e');
      return false;
    }
  }
}
