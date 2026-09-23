enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static const Environment environment = Environment.development;
  static const bool useMockHardware = true;
  static const bool useDummyFirebase = true;
}
