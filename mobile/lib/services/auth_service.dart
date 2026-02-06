import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';

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
      return AuthResult(success: false, message: 'Sai tài khoản hoặc mật khẩu');
    }

    if (!isLogin && statusCode == 409) {
      return AuthResult(success: false, message: 'Tài khoản đã tồn tại');
    }

    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return AuthResult(success: false, message: serverMessage);
    }

    return AuthResult(success: false, message: 'Lỗi server ($statusCode)');
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
            headers: {'Content-Type': 'application/json'},
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
          message: 'Phản hồi không hợp lệ từ server',
        );
      }

      // Backend trả success = false
      if (body['success'] == false) {
        return AuthResult(
          success: false,
          message: body['message'] ?? 'Đăng nhập thất bại',
        );
      }

      // Login OK
      final accessToken = body['data']?['accessToken'];

      if (accessToken == null) {
        return AuthResult(
          success: false,
          message: 'Không nhận được accessToken',
        );
      }

      // Lưu token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);

      return AuthResult(
        success: true,
        message: body['message'] ?? 'Đăng nhập thành công',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        message: 'Kết nối quá thời gian, vui lòng thử lại',
      );
    } on SocketException {
      return AuthResult(
        success: false,
        message: 'Không thể kết nối tới server',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Lỗi kết nối server');
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
            headers: {'Content-Type': 'application/json'},
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
          message: 'Phản hồi không hợp lệ từ server',
        );
      }

      if (body['success'] == false) {
        return AuthResult(success: false, message: body['message']);
      }

      final accessToken = body['data']?['accessToken'];

      if (accessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
      }

      return AuthResult(
        success: true,
        message: body['message'] ?? 'Đăng ký thành công',
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        message: 'Kết nối quá thời gian, vui lòng thử lại',
      );
    } on SocketException {
      return AuthResult(
        success: false,
        message: 'Không thể kết nối tới server',
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Lỗi kết nối server');
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
