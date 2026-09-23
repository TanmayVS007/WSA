class AppConstants {
  AppConstants._();

  static const String appName = 'Women Safety Band';
  static const String appTagline = 'Always Connected, Always Protected';

  // State Machine Timeouts
  static const int anomalyConfirmationTimeoutSeconds = 20;
  static const int locationStalenessThresholdMinutes = 5;
  static const int deviceSyncTimeoutSeconds = 30;

  // Network & Sensor thresholds
  static const int normalHeartRateMin = 55;
  static const int normalHeartRateMax = 110;
  static const int criticalHeartRateSpike = 135;
  static const int lowBatteryThreshold = 20;
  static const int criticalBatteryThreshold = 10;

  // Geofence & Proximity
  static const double nearbyHelperRadiusKm = 2.0;

  // Emergency contact limits
  static const int maxTrustedContacts = 5;
}
