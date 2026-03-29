import 'package:flutter/foundation.dart';

/// Environment configuration for the app
enum Environment { development, staging, production }

/// App configuration that auto-detects platform and provides correct API URLs
class AppConfig {
  // Runtime overrides from flutter --dart-define
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _environmentOverride = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // Force production for demo builds (set to true for demo, false for development)
  static const bool forceProductionForDemo = false;

  // Force localhost for VM testing (set to true when testing on VM with local backend)
  static const bool forceLocalhostForVM = true;

  static Environment _environment = _resolveEnvironment();

  static Environment _resolveEnvironment() {
    switch (_environmentOverride.toLowerCase()) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      default:
        return Environment.development;
    }
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Set the current environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  /// Get the base API URL based on platform and environment
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.trim().isNotEmpty) {
      return _normalizeBaseUrl(_apiBaseUrlOverride);
    }

    // Force localhost for VM testing
    if (forceLocalhostForVM) {
      return _developmentUrl;
    }

    // Force production for demo builds
    if (forceProductionForDemo) {
      return productionUrl;
    }

    // In release builds, default to production API to avoid accidental
    // localhost calls when APP_ENV/API_BASE_URL are not provided by CI/CD.
    if (kReleaseMode) {
      return productionUrl;
    }

    switch (_environment) {
      case Environment.development:
        return _developmentUrl;
      case Environment.staging:
        return stagingUrl;
      case Environment.production:
        return productionUrl;
    }
  }

  /// Development URL - auto-detects platform
  static String get _developmentUrl {
    // If ngrok URL is set, use it (works everywhere)
    if (ngrokUrl.isNotEmpty) {
      return ngrokUrl;
    }

    // Web should always use host-reachable URL
    if (kIsWeb) {
      return 'http://localhost:$backendPort';
    }

    // If testing on physical device, use local network IP
    if (usePhysicalDevice) {
      return 'http://$localNetworkIP:$backendPort';
    }

    // Auto-detect based on platform (for emulators/simulators)
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator uses 10.0.2.2 to access host machine
        return 'http://10.0.2.2:$backendPort';
      case TargetPlatform.iOS:
        // iOS simulator can use localhost directly
        return 'http://localhost:$backendPort';
      default:
        // Windows, macOS, Linux
        return 'http://localhost:$backendPort';
    }
  }

  // ============== CONFIGURATION - EDIT THESE ==============

  /// Backend port (default: 3000)
  static const int backendPort = 3000;

  /// Your machine's local IP (for physical devices on same WiFi)
  /// Run: ipconfig (Windows) or ifconfig (Mac/Linux) to find it
  static const String localNetworkIP = '172.20.18.151';

  /// Set to true when testing on PHYSICAL devices (not emulator)
  static const bool usePhysicalDevice = false;

  /// Ngrok URL - paste here for remote testing
  /// Example: 'https://abc123.ngrok.io'
  /// Leave empty to use auto-detection
  static const String ngrokUrl = '';

  /// Staging server URL
  static const String stagingUrl = 'https://staging-api.smartspender.com';

  /// Production server URL
  static const String productionUrl = 'https://smartspender-x1fl.onrender.com';

  // =========================================================

  /// Full auth API URL
  static String get authApiUrl => '$apiBaseUrl/api/auth';

  /// Full transactions API URL
  static String get transactionsApiUrl => '$apiBaseUrl/api/transactions';

  /// Print current config (for debugging)
  static void printConfig() {
    debugPrint('╔══════════════════════════════════════╗');
    debugPrint('║       SmartSpender App Config        ║');
    debugPrint('╠══════════════════════════════════════╣');
    debugPrint('║ Environment: ${_environment.name.padRight(21)}║');
    debugPrint('║ APP_ENV: ${_environmentOverride.padRight(25)}║');
    final source = _apiBaseUrlOverride.trim().isNotEmpty
        ? 'dart-define'
        : 'auto-config';
    debugPrint('║ URL Source: ${source.padRight(22)}║');
    debugPrint('║ API Base: ${apiBaseUrl.padRight(24)}║');
    debugPrint('╚══════════════════════════════════════╝');
  }
}
