import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';
import '../core/constants/api_constants.dart';
import '../core/strings.dart';

class AuthService {
  // Using AppConfig for dynamic URL based on platform/environment
  static String get _baseUrl => AppConfig.authApiUrl;
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, dynamic>? _tryDecodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  static AuthResult _friendlyAuthError({
    required int statusCode,
    required bool isLogin,
    String? serverMessage,
  }) {
    if (isLogin && statusCode == 401) {
      return AuthResult(
        success: false,
        message: AppStrings.invalidEmailOrPassword,
      );
    }

    if (!isLogin && statusCode == 409) {
      return AuthResult(
        success: false,
        message: AppStrings.accountAlreadyExists,
      );
    }

    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return AuthResult(success: false, message: serverMessage);
    }

    return AuthResult(
      success: false,
      message: '${AppStrings.serverErrorPrefix} ($statusCode)',
    );
  }

  /// =======================
  /// LOGIN
  /// =======================
  static Future<AuthResult> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      final body = _tryDecodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _friendlyAuthError(
          statusCode: response.statusCode,
          isLogin: true,
          serverMessage: body?['message'],
        );
      }

      if (body == null) {
        return AuthResult(
          success: false,
          message: AppStrings.invalidServerResponse,
        );
      }

      // Backend trả success = false
      if (body['success'] == false) {
        return AuthResult(
          success: false,
          message: body['message'] ?? AppStrings.loginFailed,
        );
      }

      // Login OK
      final accessToken = body['data']?['accessToken'];

      if (accessToken == null) {
        return AuthResult(
          success: false,
          message: AppStrings.missingAccessToken,
        );
      }

      // Lưu token (sử dụng key chuẩn)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.accessTokenKey, accessToken);
      await prefs.setString(ApiConstants.tokenOriginKey, AppConfig.apiBaseUrl);

      return AuthResult(
        success: true,
        message: body['message'] ?? AppStrings.loginSuccess,
      );
    } on TimeoutException {
      return AuthResult(success: false, message: AppStrings.timeoutTryAgain);
    } on http.ClientException {
      return AuthResult(
        success: false,
        message: AppStrings.cannotConnectServer,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: AppStrings.serverConnectionError,
      );
    }
  }

  /// =======================
  /// REGISTER (chuẩn bị sẵn)
  /// =======================
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final url = Uri.parse('$_baseUrl/register');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
              'fullName': fullName,
            }),
          )
          .timeout(_timeout);

      final body = _tryDecodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _friendlyAuthError(
          statusCode: response.statusCode,
          isLogin: false,
          serverMessage: body?['message'],
        );
      }

      if (body == null) {
        return AuthResult(
          success: false,
          message: AppStrings.invalidServerResponse,
        );
      }

      if (body['success'] == false) {
        return AuthResult(success: false, message: body['message']);
      }

      final accessToken = body['data']?['accessToken'];

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ApiConstants.accessTokenKey, accessToken);
        await prefs.setString(
          ApiConstants.tokenOriginKey,
          AppConfig.apiBaseUrl,
        );
      }

      return AuthResult(
        success: true,
        message: body['message'] ?? AppStrings.registerSuccess,
      );
    } on TimeoutException {
      return AuthResult(success: false, message: AppStrings.timeoutTryAgain);
    } on http.ClientException {
      return AuthResult(
        success: false,
        message: AppStrings.cannotConnectServer,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: AppStrings.serverConnectionError,
      );
    }
  }
}

/// =======================
/// MODEL KẾT QUẢ AUTH
/// =======================
class AuthResult {
  final bool success;
  final String message;

  AuthResult({required this.success, required this.message});
}
