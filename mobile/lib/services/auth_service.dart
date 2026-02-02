import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://YOUR_BACKEND_URL/api/auth';

  /// =======================
  /// LOGIN
  /// =======================
  static Future<AuthResult> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);

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
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Lỗi kết nối server',
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
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      final body = jsonDecode(response.body);

      if (body['success'] == false) {
        return AuthResult(
          success: false,
          message: body['message'],
        );
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
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Lỗi kết nối server',
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

  AuthResult({
    required this.success,
    required this.message,
  });
}
