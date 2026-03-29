import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Dịch vụ quản lý tất cả debug features
/// Chỉ hoạt động khi ở chế độ debug (kDebugMode)
class DebugService {
  DebugService._();

  /// Kiểm tra app có đang chạy ở chế độ debug không
  static bool get isDebugMode => kDebugMode;

  /// Reset màn hình onboarding - user sẽ thấy lại onboarding lần tới khởi động
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.onboardingSeenKey);
    debugPrint(
      '🔄 [DEBUG] Đã reset onboarding - user sẽ thấy lại onboarding lần tới',
    );
  }

  /// Xóa token đăng nhập - user sẽ quay lại màn đăng nhập
  static Future<void> clearAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.accessTokenKey);
    await prefs.remove(ApiConstants.refreshTokenKey);
    await prefs.remove(ApiConstants.tokenOriginKey);
    debugPrint('🔓 [DEBUG] Đã xóa token - user sẽ quay lại màn đăng nhập');
  }

  /// Xóa toàn bộ dữ liệu lưu trữ (SharedPreferences)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('🗑️ [DEBUG] Đã xóa toàn bộ dữ liệu');
  }

  /// Reset về trạng thái ban đầu (chưa onboarding)
  static Future<void> resetToInitialState() async {
    await clearAllData();
    debugPrint('🔄 [DEBUG] App đã reset về trạng thái ban đầu');
  }
}
