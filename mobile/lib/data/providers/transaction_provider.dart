import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // Optional stats returned by backend
  double? _remoteTotalIncome;
  double? _remoteTotalExpense;

  // API Service instance (injectable for testing)
  late final ApiService _apiService;

  TransactionProvider({
    ApiService? apiService,
    List<TransactionModel>? initialTransactions,
  }) {
    _apiService = apiService ?? ApiService();
    if (initialTransactions != null) _transactions = initialTransactions;
  }

  // ============== GETTERS ==============
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  // ============== COMPUTED VALUES ==============

  /// Tổng thu nhập
  double get totalIncome {
    if (_remoteTotalIncome != null) return _remoteTotalIncome!;
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Tổng chi tiêu
  double get totalExpense {
    if (_remoteTotalExpense != null) return _remoteTotalExpense!;
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
    // Feature #34: expose loading/error states to Home UI.
    _setLoading(true);
    _clearError();

    try {
      // Build query parameters — default to current month/year when not provided
      final now = DateTime.now();
      final int useMonth = month ?? now.month;
      final int useYear = year ?? now.year;

      // Feature #34: force monthly mode so request matches backend filter rules.
      final queryParams = <String, dynamic>{'month': useMonth, 'year': useYear};

      // Retrieve access token from SharedPreferences and attach to headers
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

      // Feature #34: authenticated fetch using saved access token.
      final Options? options = token.isNotEmpty
          ? Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
          : null;

      // Gọi API
      final response = await _apiService.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
        options: options,
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = response.data;

        // Xử lý response dựa vào format API
        if (data is Map<String, dynamic> && data['success'] == true) {
          // Expected contract: data.transactions (list) + data.stats (summary).
          final responseData = data['data'] as Map<String, dynamic>;

          final transactionsData =
              responseData['transactions'] as List<dynamic>?;

          final stats = responseData['stats'] as Map<String, dynamic>?;

          if (stats != null) {
            _remoteTotalIncome = (stats['totalIncome'] as num?)?.toDouble();
            _remoteTotalExpense = (stats['totalExpense'] as num?)?.toDouble();
          }

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
      _setError(e.error?.toString() ?? 'Cannot fetch transactions');
      debugPrint('❌ Fetch transactions failed: ${e.message}');
    } catch (e) {
      _setError('An unexpected error occurred: $e');
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
      final response = await _apiService.post(
        ApiConstants.transactions,
        data: transaction.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final createdTransaction = _extractTransactionFromResponse(
          response.data,
        );
        if (createdTransaction == null) {
          throw Exception('Invalid create transaction response');
        }
        // Thêm vào list local
        _transactions.insert(0, createdTransaction);
        notifyListeners();

        debugPrint('✅ Transaction added successfully');
        return true;
      }

      throw Exception('Failed to add transaction');
    } on DioException catch (e) {
      _setError(e.error?.toString() ?? 'Cannot add transaction');
      debugPrint('❌ Add transaction failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('An error occurred: $e');
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
      _setError(e.error?.toString() ?? 'Cannot delete transaction');
      debugPrint('❌ Delete transaction failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('An error occurred: $e');
      debugPrint('❌ Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(String id, TransactionModel transaction) async {
    _setLoading(true);
    _clearError();
    final index = _transactions.indexWhere((t) => t.id == id);
    final previousTransaction = index != -1 ? _transactions[index] : null;
    final didOptimisticUpdate = index != -1;
    final requestTransaction =
        transaction.id == id ? transaction : transaction.copyWith(id: id);

    if (didOptimisticUpdate) {
      _transactions[index] = requestTransaction;
      notifyListeners();
    }

    try {
      final response = await _apiService.put(
        ApiConstants.transactionById(id),
        data: requestTransaction.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedTransaction = _extractTransactionFromResponse(
          response.data,
        );
        if (updatedTransaction == null) {
          throw Exception('Invalid update transaction response');
        }

        if (index != -1) {
          _transactions[index] = updatedTransaction;
          notifyListeners();
        }

        debugPrint('Transaction updated successfully');
        return true;
      }

      throw Exception('Failed to update transaction');
    } on DioException catch (e) {
      if (didOptimisticUpdate && previousTransaction != null) {
        _transactions[index] = previousTransaction;
        notifyListeners();
      }
      _setError(e.error?.toString() ?? 'Cannot update transaction');
      debugPrint('Update transaction failed: ${e.message}');
      return false;
    } catch (e) {
      if (didOptimisticUpdate && previousTransaction != null) {
        _transactions[index] = previousTransaction;
        notifyListeners();
      }
      _setError('An error occurred: $e');
      debugPrint('Unexpected error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  TransactionModel? _extractTransactionFromResponse(dynamic data) {
    if (data is! Map<String, dynamic> || data['success'] != true) return null;
    final payload = data['data'];
    if (payload is! Map<String, dynamic>) return null;

    final transaction = TransactionModel.fromJson(payload);
    if (transaction.id.trim().isEmpty) return null;
    return transaction;
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
