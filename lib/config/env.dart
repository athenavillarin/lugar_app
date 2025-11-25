// Environment configuration
class Env {
  // Environment mode
  static const bool isProduction = false;
  static const bool isDevelopment = !isProduction;

  // Debug settings
  static const bool enableLogging = isDevelopment;
  static const bool enableAnalytics = isProduction;

  // Firebase configuration (set based on environment)
  static const bool useFirebaseEmulator = false;

  // API Configuration
  static const bool useMockData = isDevelopment;
}
