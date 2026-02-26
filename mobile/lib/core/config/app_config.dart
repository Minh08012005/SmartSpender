import 'dart:io';

/// Environment configuration for the app
enum Environment { development, staging, production }

/// App configuration that auto-detects platform and provides correct API URLs
class AppConfig {
  static Environment _environment = Environment.development;

  /// Set the current environment
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;

  /// Get the base API URL based on platform and environment
  static String get apiBaseUrl {
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
    
    // If testing on physical device, use local network IP
    if (usePhysicalDevice) {
      return 'http://$localNetworkIP:$backendPort';
    }

    // Auto-detect based on platform (for emulators/simulators)
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return 'http://10.0.2.2:$backendPort';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost directly
      return 'http://localhost:$backendPort';
    } else {
      // Web, Windows, macOS, Linux
      return 'http://localhost:$backendPort';
    }
  }

  // ============== CONFIGURATION - EDIT THESE ==============

  /// Backend port (default: 3000)
  static const int backendPort = 3000;

  /// Your machine's local IP (for physical devices on same WiFi)
  /// Run: ipconfig (Windows) or ifconfig (Mac/Linux) to find it
  static const String localNetworkIP = '192.168.1.11';
  
  /// Set to true when testing on PHYSICAL devices (not emulator)
  /// For Android emulator testing on host machine, keep this `false` so
  /// the emulator resolves host via 10.0.2.2.
  static const bool usePhysicalDevice = false;

  /// Ngrok URL - paste here for remote testing
  /// Example: 'https://abc123.ngrok.io'
  /// Leave empty to use auto-detection
  static const String ngrokUrl = '';

  /// Staging server URL
  static const String stagingUrl = 'https://staging-api.smartspender.com';

  /// Production server URL
  static const String productionUrl = 'https://api.smartspender.com';

  // =========================================================

  /// Full auth API URL
  static String get authApiUrl => '$apiBaseUrl/api/auth';

  /// Full transactions API URL
  static String get transactionsApiUrl => '$apiBaseUrl/api/transactions';

  /// Print current config (for debugging)
  static void printConfig() {
    print('╔══════════════════════════════════════╗');
    print('║       SmartSpender App Config        ║');
    print('╠══════════════════════════════════════╣');
    print('║ Environment: ${_environment.name.padRight(21)}║');
    print('║ API Base: ${apiBaseUrl.padRight(24)}║');
    print('╚══════════════════════════════════════╝');
  }
}
