import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';
import '../dummy_transactions.dart';

/// Transaction Provider
///
/// Quản lý state của transactions và giao tiếp với API
/// Sử dụng ChangeNotifier để notify UI khi data thay đổi
class TransactionProvider extends ChangeNotifier {
  // ============== PRIVATE STATE ==============
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String _error = '';

  // API Service instance
  final ApiService _apiService = ApiService();

  // ============== GETTERS ==============
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // ============== COMPUTED VALUES ==============

  /// Tổng thu nhập
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Tổng chi tiêu
  double get totalExpense {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Số dư hiện tại
  double get balance => totalIncome - totalExpense;

  /// Lọc transactions theo type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  // ============== API METHODS ==============

  /// Lấy danh sách transactions từ API
  ///
  /// Query parameters:
  /// - month: Lọc theo tháng (1-12)
  /// - year: Lọc theo năm (2024, 2025...)
  Future<void> fetchTransactions({int? month, int? year}) async {
    _setLoading(true);
    _clearError();

    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      // Gọi API
      final response = await _apiService.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = response.data;

        // Xử lý response dựa vào format API
        if (data is Map<String, dynamic> && data['success'] == true) {
          final transactionsData = data['data'] as List?;

          if (transactionsData != null) {
            _transactions = transactionsData
                .map((json) => TransactionModel.fromJson(json))
                .toList();

            debugPrint('✅ Loaded ${_transactions.length} transactions');
          } else {
            _transactions = [];
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load transactions');
      }
    } on DioException catch (e) {
      _setError(e.error?.toString() ?? 'Không thể tải dữ liệu');
      debugPrint('❌ Fetch transactions failed: ${e.message}');
    } catch (e) {
      _setError('Có lỗi xảy ra: $e');
      debugPrint('❌ Unexpected error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm transaction mới
  Future<bool> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      final payload = Map<String, dynamic>.from(transaction.toJson())
        ..remove('id');
      final response = await _apiService.post(
        ApiConstants.transactions,
        data: payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Thêm vào list local
        final created = _extractTransactionFromResponse(response.data);
        _transactions.insert(0, created ?? transaction);
        notifyListeners();

        debugPrint('✅ Transaction added successfully');
        return true;
      }

      throw Exception('Failed to add transaction');
    } on DioException catch (e) {
      _setError(e.error?.toString() ?? 'Không thể thêm giao dịch');
      debugPrint('❌ Add transaction failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Có lỗi xảy ra: $e');
      debugPrint('❌ Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Xóa transaction
  Future<bool> deleteTransaction(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.delete(
        ApiConstants.transactionById(id),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Xóa khỏi list local
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();

        debugPrint('✅ Transaction deleted successfully');
        return true;
      }

      throw Exception('Failed to delete transaction');
    } on DioException catch (e) {
      _setError(e.error?.toString() ?? 'Không thể xóa giao dịch');
      debugPrint('❌ Delete transaction failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Có lỗi xảy ra: $e');
      debugPrint('❌ Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  /// Update transaction
  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put(
        ApiConstants.transactionById(transaction.id),
        data: transaction.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updated =
            _extractTransactionFromResponse(response.data) ?? transaction;
        final index = _transactions.indexWhere((t) => t.id == transaction.id);
        if (index >= 0) {
          _transactions[index] = updated;
        } else {
          _transactions.insert(0, updated);
        }
        notifyListeners();

        debugPrint('Transaction updated successfully');
        return true;
      }

      throw Exception('Failed to update transaction');
    } on DioException catch (e) {
      _setError(e.error?.toString() ?? 'Khong the cap nhat giao dich');
      debugPrint('Update transaction failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Co loi xay ra: $e');
      debugPrint('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  TransactionModel? _extractTransactionFromResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        return TransactionModel.fromJson(payload);
      }
      if (data.containsKey('_id') || data.containsKey('amount')) {
        return TransactionModel.fromJson(data);
      }
    }
    return null;
  }

  // ============== DUMMY LOAD ==============

Future<void> loadDummyTransactions() async {
  _setLoading(true);
  _clearError();

  await Future.delayed(const Duration(seconds: 2)); // giả lập loading

  _transactions = dummyTransactions;
  //_transactions = []; // 👈 ÉP RỖNG test empty
  //_setError("Failed to load transactions"); // 👈 ÉP LỖI test error
  _setLoading(false);
}


  // ============== STATE MANAGEMENT ==============

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = '';
  }

  /// Reset toàn bộ state
  void reset() {
    _transactions = [];
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
