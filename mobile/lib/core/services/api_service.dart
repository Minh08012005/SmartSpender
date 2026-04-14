import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../../screens/login.dart';
import '../strings.dart';

/// Centralized API Service
///
/// Tính năng:
/// - Tự động thêm Authorization header với token
/// - Xử lý lỗi tập trung (401, 500...)
/// - Retry logic khi gặp lỗi network
/// - Logging chi tiết để debug
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Global navigator key — dùng để navigate từ ngoài widget tree (vd: interceptor)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  late final Dio _dio;

  /// Get Dio instance để sử dụng trực tiếp nếu cần
  Dio get dio => _dio;

  /// Khởi tạo Dio với cấu hình
  Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Prevent ngrok interstitial HTML from breaking web XHR requests.
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    // Thêm interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  // ============== CONVENIENCE METHODS ==============

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return _dio.post(path, data: data, options: options);
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data, Options? options}) async {
    return _dio.put(path, data: data, options: options);
  }

  /// PATCH request
  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return _dio.patch(path, data: data, options: options);
  }

  /// DELETE request
  Future<Response> delete(String path, {Options? options}) async {
    return _dio.delete(path, options: options);
  }
}

// ================================================================
// AUTHENTICATION INTERCEPTOR
// ================================================================
/// Tự động thêm Authorization header cho mọi request
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.accessTokenKey);

    // Nếu có token, thêm vào header
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      developer.log('🔑 Added token to request: ${options.path}');
    }

    options.headers['ngrok-skip-browser-warning'] = 'true';

    handler.next(options);
  }
}

// ================================================================
// LOGGING INTERCEPTOR
// ================================================================
/// Ghi log chi tiết về request/response để debug
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('🚀 REQUEST [${options.method}] ${options.uri}', name: 'API');
    developer.log('Headers: ${options.headers}', name: 'API');
    if (options.data != null) {
      developer.log('Body: ${options.data}', name: 'API');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '✅ RESPONSE [${response.statusCode}] ${response.requestOptions.uri}',
      name: 'API',
    );
    developer.log('Data: ${response.data}', name: 'API');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}',
      name: 'API',
      error: err.message,
    );
    handler.next(err);
  }
}

// ================================================================
// ERROR INTERCEPTOR
// ================================================================
/// Xử lý lỗi tập trung
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    String errorMessage = _getErrorMessage(err);

    // Xử lý các mã lỗi đặc biệt
    switch (err.response?.statusCode) {
      case 401:
        // Token hết hạn hoặc không hợp lệ
        developer.log(
          '🔒 Unauthorized - Token expired or invalid',
          name: 'API',
        );
        await _handleTokenExpired();
        break;

      case 403:
        developer.log('🚫 Forbidden - No permission', name: 'API');
        break;

      case 404:
        developer.log('🔍 Not Found', name: 'API');
        break;

      case 500:
        developer.log('💥 Server Error', name: 'API');
        break;

      default:
        developer.log('⚠️ Error: $errorMessage', name: 'API');
    }

    // Throw lỗi với message dễ hiểu
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: errorMessage,
      ),
    );
  }

  /// Convert DioException thành message dễ hiểu
  String _getErrorMessage(DioException err) {
    final serverMessage = _extractServerMessage(err.response?.data);

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return AppStrings.timeoutTryAgain;
      case DioExceptionType.connectionError:
        return AppStrings.cannotConnectServer;
      case DioExceptionType.sendTimeout:
        return AppStrings.timeoutTryAgain;
      case DioExceptionType.receiveTimeout:
        return AppStrings.serverConnectionError;
      case DioExceptionType.badResponse:
        return serverMessage ?? AppStrings.serverErrorPrefix;
      case DioExceptionType.cancel:
        return AppStrings.requestCancelled;
      case DioExceptionType.unknown:
        return AppStrings.cannotConnectServer;
      default:
        return serverMessage ?? AppStrings.unexpectedErrorOccurred;
    }
  }

  String? _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      final error = data['error']?.toString().trim();
      if (error != null && error.isNotEmpty) {
        return error;
      }
    }

    if (data is String) {
      final message = data.trim();
      if (message.isNotEmpty) {
        return message;
      }
    }

    return null;
  }

  /// Xử lý khi token hết hạn — xóa token và điều hướng về LoginScreen
  Future<void> _handleTokenExpired() async {
    await AuthService.clearSession();

    developer.log('🔓 Token expired — redirecting to Login', name: 'API');

    // Điều hướng về Login, xóa toàn bộ navigation stack
    ApiService.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
