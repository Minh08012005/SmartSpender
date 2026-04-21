import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/strings.dart';

/// Statistic Provider
///
/// Quản lý state của thống kê (tổng thu, chi, số dư) từ backend API
/// Sử dụng ChangeNotifier để notify UI khi data thay đổi
class StatisticProvider extends ChangeNotifier {
  // ============== PRIVATE STATE ==============
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;
  bool _isLoading = false;
  String _error = '';

  // Budget state
  double _monthlyTarget = 0.0;
  double _actualExpense = 0.0;
  double _remaining = 0.0;
  String _budgetStatus = 'safe'; // safe | near | over

  // API Service instance (injectable for testing)
  late final ApiService _apiService;

  StatisticProvider({ApiService? apiService}) {
    _apiService = apiService ?? ApiService();
  }

  // ============== GETTERS ==============
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // Budget getters
  double get monthlyTarget => _monthlyTarget;
  double get actualExpense => _actualExpense;
  double get remaining => _remaining;
  String get budgetStatus => _budgetStatus;

  // ============== PRIVATE HELPERS ==============
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  // ============== API METHODS ==============

  /// Lấy thống kê tổng thu/chi từ API backend
  ///
  /// Query parameters:
  /// - month: Tháng (1-12)
  /// - year: Năm (2024, 2025, ...)
  ///
  /// Response example:
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "totalIncome": 10000,
  ///     "totalExpense": 5000,
  ///     "balance": 5000
  ///   }
  /// }
  Future<void> fetchStatistics({required int month, required int year}) async {
    _setLoading(true);
    _clearError();

    try {
      final queryParams = <String, dynamic>{'month': month, 'year': year};

      final response = await _apiService.get(
        ApiConstants.statisticsSummary,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['success'] == true) {
          final stats = data['data'] as Map<String, dynamic>?;

          if (stats != null) {
            _totalIncome = (stats['totalIncome'] as num?)?.toDouble() ?? 0.0;
            _totalExpense = (stats['totalExpense'] as num?)?.toDouble() ?? 0.0;
            _balance = (stats['balance'] as num?)?.toDouble() ?? 0.0;

            debugPrint(
              '✅ Lấy thống kê thành công: '
              'Income=$_totalIncome, Expense=$_totalExpense, Balance=$_balance',
            );
          } else {
            throw Exception('Định dạng dữ liệu thống kê không hợp lệ');
          }
        } else {
          throw Exception('Phản hồi API không hợp lệ');
        }
      } else {
        throw Exception(AppStrings.failedToLoadTransactions);
      }
    } on DioException catch (e) {
      _setError(_extractApiErrorMessage(e, 'Không thể tải thống kê'));
      debugPrint('❌ Tải thống kê thất bại: ${e.message}');
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy budget tháng từ API backend
  ///
  /// Query parameters:
  /// - month: Tháng (1-12)
  /// - year: Năm (2024, 2025, ...)
  Future<void> fetchBudget({required int month, required int year}) async {
    _setLoading(true);
    _clearError();

    try {
      final queryParams = <String, dynamic>{'month': month, 'year': year};

      final response = await _apiService.get(
        ApiConstants.statisticsBudget,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['success'] == true) {
          final budgetData = data['data'] as Map<String, dynamic>?;

          if (budgetData != null) {
            _monthlyTarget =
                (budgetData['targetAmount'] as num?)?.toDouble() ?? 0.0;
            _actualExpense =
                (budgetData['actualExpense'] as num?)?.toDouble() ?? 0.0;
            _remaining = (budgetData['remaining'] as num?)?.toDouble() ?? 0.0;
            _budgetStatus = (budgetData['status'] as String?) ?? 'safe';

            debugPrint(
              '✅ Lấy budget thành công: '
              'Target=$_monthlyTarget, ActualExpense=$_actualExpense, '
              'Remaining=$_remaining, Status=$_budgetStatus',
            );
          } else {
            throw Exception('Định dạng dữ liệu budget không hợp lệ');
          }
        } else {
          throw Exception('Phản hồi API không hợp lệ');
        }
      } else {
        throw Exception(AppStrings.failedToLoadBudget);
      }
    } on DioException catch (e) {
      _setError(_extractApiErrorMessage(e, 'Không thể tải budget'));
      debugPrint('❌ Tải budget thất bại: ${e.message}');
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Lưu budget tháng vào API backend
  ///
  /// Body:
  /// - month: Tháng (1-12)
  /// - year: Năm (2024, 2025, ...)
  /// - targetAmount: Số tiền mục tiêu
  Future<bool> saveBudget({
    required int month,
    required int year,
    required double targetAmount,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        ApiConstants.statisticsBudget,
        data: {
          'month': month,
          'year': year,
          'targetAmount': targetAmount,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['success'] == true) {
          final budgetData = data['data'] as Map<String, dynamic>?;

          if (budgetData != null) {
            _monthlyTarget =
                (budgetData['targetAmount'] as num?)?.toDouble() ?? 0.0;
            _actualExpense =
                (budgetData['actualExpense'] as num?)?.toDouble() ?? 0.0;
            _remaining = (budgetData['remaining'] as num?)?.toDouble() ?? 0.0;
            _budgetStatus = (budgetData['status'] as String?) ?? 'safe';

            debugPrint(
              '✅ Lưu budget thành công: '
              'Target=$_monthlyTarget, ActualExpense=$_actualExpense, '
              'Remaining=$_remaining, Status=$_budgetStatus',
            );
            notifyListeners();
            return true;
          } else {
            throw Exception('Định dạng dữ liệu budget không hợp lệ');
          }
        } else {
          throw Exception('Phản hồi API không hợp lệ');
        }
      } else {
        throw Exception(AppStrings.failedToSaveBudget);
      }
    } on DioException catch (e) {
      _setError(_extractApiErrorMessage(e, 'Không thể lưu budget'));
      debugPrint('❌ Lưu budget thất bại: ${e.message}');
      return false;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Trích xuất message lỗi từ response của API
  String _extractApiErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }

    return fallback;
  }

  /// Reset thống kê
  void reset() {
    _totalIncome = 0.0;
    _totalExpense = 0.0;
    _balance = 0.0;
    _monthlyTarget = 0.0;
    _actualExpense = 0.0;
    _remaining = 0.0;
    _budgetStatus = 'safe';
    _clearError();
    notifyListeners();
  }
}
