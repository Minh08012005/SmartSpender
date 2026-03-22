import '../config/app_config.dart';

/// API endpoint constants
/// Tập trung quản lý tất cả API endpoints
class ApiConstants {
  ApiConstants._();

  // ============== BASE URLs ==============
  static String get baseUrl => AppConfig.apiBaseUrl;
  static String get authBaseUrl => AppConfig.authApiUrl;

  // ============== AUTH ENDPOINTS ==============
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';

  // ============== TRANSACTION ENDPOINTS ==============
  static const String transactions = '/api/transactions';
  static String transactionById(String id) => '/api/transactions/$id';

  // ============== USER ENDPOINTS ==============
  static const String userProfile = '/api/user/profile';
  static const String userSettings = '/api/user/settings';

  // ============== STORAGE KEYS ==============
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenOriginKey = 'token_origin';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // ============== HTTP TIMEOUTS ==============
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
