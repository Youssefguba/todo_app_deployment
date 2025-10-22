// environment_config.dart

enum EnvironmentType {
  development,
  staging,
  production,
}

/// www.facebook.com
/// www.dev.facebook.com
/// www.qa.facebook.com
/// www.stg.facebook.com


// DEPI
// DEPI Dev
// DEPI QA
// DEPI Stg
class Environment {
  final String name;
  final String baseUrl;
  final String sentryKey;

  const Environment({
    required this.name,
    required this.baseUrl,
    required this.sentryKey,
  });
}

class EnvironmentConfig {
  static EnvironmentType _currentEnvironment = EnvironmentType.development;

  // Define your environments
  static final Map<EnvironmentType, Environment> _environments = {
    EnvironmentType.development: const Environment(
      name: 'Development',
      baseUrl: 'https://dev-api.example.com',
      sentryKey: 'dev_api_key_12345',
    ),
    EnvironmentType.staging: const Environment(
      name: 'Staging',
      baseUrl: 'https://staging-api.example.com',
      sentryKey: 'staging_api_key_67890',
    ),
    EnvironmentType.production: const Environment(
      name: 'Production',
      baseUrl: 'https://api.example.com',
      sentryKey: String.fromEnvironment('SENTRY_KEY'),
    ),
  };

  // Initialize environment
  static void init(EnvironmentType environment) {
    _currentEnvironment = environment;
  }

  // Get current environment
  static Environment get current => _environments[_currentEnvironment]!;

  // Get current environment type
  static EnvironmentType get currentType => _currentEnvironment;

  // Quick access getters
  static String get baseUrl => current.baseUrl;
  static String get sentryKey => current.sentryKey;
  static String get name => current.name;

  // Check environment type
  static bool get isDevelopment => _currentEnvironment == EnvironmentType.development;
  static bool get isStaging => _currentEnvironment == EnvironmentType.staging;
  static bool get isProduction => _currentEnvironment == EnvironmentType.production;

}

// Usage Example in main.dart:
/*
void main() {
  // Set environment before running the app
  EnvironmentConfig.init(EnvironmentType.development);

  runApp(const MyApp());
}

// Then use it anywhere in your app:
final apiUrl = EnvironmentConfig.baseUrl;
final apiKey = EnvironmentConfig.apiKey;

if (EnvironmentConfig.isDevelopment) {
  print('Running in development mode');
}

// For HTTP client setup:
final client = http.Client();
final response = await Dio().get(
  Uri.parse('${EnvironmentConfig.baseUrl}/users'),
  headers: {
    'Authorization': 'Bearer ${EnvironmentConfig.apiKey}',
  },
).timeout(Duration(milliseconds: EnvironmentConfig.timeout));
*/