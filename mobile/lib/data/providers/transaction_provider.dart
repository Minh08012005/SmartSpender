import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../views/profile/widgets/notification_widgets.dart';
import 'notifications_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/strings.dart';
import '../models/transaction_model.dart';
import '../dummy_transactions.dart';

/// Transaction Provider
///
/// Quản lý state của transactions và giao tiếp với API
/// Sử dụng ChangeNotifier để notify UI khi data thay đổi
class TransactionProvider extends ChangeNotifier {
  NotificationsProvider? _notificationsProvider;

  void setNotificationsProvider(NotificationsProvider? p) {
    _notificationsProvider = p;
  }

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
      final now = DateTime.now();
      final int useMonth = month ?? now.month;
      final int useYear = year ?? now.year;

      final queryParams = <String, dynamic>{'month': useMonth, 'year': useYear};

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(ApiConstants.accessTokenKey) ?? '';

      final Options? options = token.isNotEmpty
          ? Options(
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
          : null;

      final response = await _apiService.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
        options: options,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['success'] == true) {
          final payload = data['data'];

          List<dynamic>? transactionsData;

          if (payload is List) {
            transactionsData = payload as List<dynamic>?;
          } else if (payload is Map<String, dynamic>) {
            transactionsData =
                (payload['transactions'] as List<dynamic>?) ??
                (payload['data'] as List<dynamic>?);

            final stats = payload['stats'] as Map<String, dynamic>?;
            if (stats != null) {
              _remoteTotalIncome = (stats['totalIncome'] as num?)?.toDouble();
              _remoteTotalExpense = (stats['totalExpense'] as num?)?.toDouble();
            }
          }

          if (transactionsData != null) {
            final List<TransactionModel> parsedList = [];
            for (final json in transactionsData) {
              try {
                final tx = TransactionModel.fromJson(json);
                parsedList.add(tx);
              } catch (e) {
                debugPrint('❌ Bỏ qua giao dịch không hợp lệ: $e');
                debugPrint('👉 Dữ liệu: $json');
              }
            }

            _transactions = parsedList;

            debugPrint('✅ Đã tải ${_transactions.length} giao dịch');
          } else {
            _transactions = [];
          }
        } else {
          throw Exception('Định dạng phản hồi không hợp lệ');
        }
      } else {
        throw Exception(AppStrings.failedToLoadTransactions);
      }
    } on DioException catch (e) {
      _remoteTotalIncome = null;
      _remoteTotalExpense = null;
      _setError(
        _extractApiErrorMessage(e, 'Không thể tải danh sách giao dịch'),
      );
      debugPrint('❌ Tải giao dịch thất bại: ${e.message}');
    } catch (e) {
      // giữ nguyên message gốc để test nhận đúng
      _remoteTotalIncome = null;
      _remoteTotalExpense = null;
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Thêm transaction mới
  Future<bool> addTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    final title = transaction.title.trim();
    if (title.isEmpty) {
      _setError(AppStrings.titleRequired);
      _setLoading(false);
      return false;
    }

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
          throw Exception('Phản hồi tạo giao dịch không hợp lệ');
        }
        _transactions.insert(0, createdTransaction);
        // Create a local in-app notification so Notifications UI updates
        final newNotif = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Giao dịch mới',
          message:
              '${createdTransaction.title} • ${createdTransaction.amount.toString()}',
          timestamp: DateTime.now(),
          type: 'transaction',
          isRead: false,
        );

        try {
          // If NotificationsProvider exists, use it to insert and notify
          if (NotificationsProvider.instance == null) {
            debugPrint(
              '⚠️ NotificationsProvider.instance is NULL when adding notif',
            );
          } else {
            debugPrint('ℹ️ TransactionProvider: adding notif via provider');
          }
          NotificationsProvider.instance?.addLocalNotification(newNotif);
        } catch (_) {
          // fallback: write directly to prefs
          try {
            final prefs = await SharedPreferences.getInstance();
            final raw = prefs.getString('app_notifications') ?? '[]';
            final decoded = (jsonDecode(raw) as List<dynamic>);
            decoded.insert(0, newNotif.toJson());
            await prefs.setString('app_notifications', jsonEncode(decoded));
          } catch (_) {}
        }
        _remoteTotalIncome = null;
        _remoteTotalExpense = null;
        notifyListeners();

        debugPrint('✅ Thêm giao dịch thành công');
        return true;
      }

      throw Exception(AppStrings.failedToAddTransaction);
    } on DioException catch (e) {
      _setError(_extractApiErrorMessage(e, AppStrings.cannotAddTransaction));
      debugPrint('❌ Thêm giao dịch thất bại: ${e.message}');
      return false;
    } catch (e) {
      // giữ nguyên message gốc để test nhận đúng
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
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
        _transactions.removeWhere((t) => t.id == id);
        _remoteTotalIncome = null;
        _remoteTotalExpense = null;
        notifyListeners();

        debugPrint('✅ Xóa giao dịch thành công');
        return true;
      }

      throw Exception(AppStrings.failedToDeleteTransaction);
    } on DioException catch (e) {
      _setError(_extractApiErrorMessage(e, AppStrings.cannotDeleteTransaction));
      debugPrint('❌ Xóa giao dịch thất bại: ${e.message}');
      return false;
    } catch (e) {
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _setLoading(true);
    _clearError();

    final title = transaction.title.trim();
    if (title.isEmpty) {
      _setError(AppStrings.titleRequired);
      _setLoading(false);
      return false;
    }

    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    final previousTransaction = index != -1 ? _transactions[index] : null;
    final didOptimisticUpdate = index != -1;

    if (didOptimisticUpdate) {
      _transactions[index] = transaction;
      notifyListeners();
    }

    try {
      final response = await _apiService.put(
        ApiConstants.transactionById(transaction.id),
        data: transaction.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedTransaction = _extractTransactionFromResponse(
          response.data,
        );
        if (updatedTransaction == null) {
          throw Exception('Phản hồi cập nhật giao dịch không hợp lệ');
        }

        if (index != -1) {
          _transactions[index] = updatedTransaction;
          _remoteTotalIncome = null;
          _remoteTotalExpense = null;
          notifyListeners();
        }

        debugPrint('✅ Cập nhật giao dịch thành công');
        return true;
      }

      throw Exception(AppStrings.failedToUpdateTransaction);
    } on DioException catch (e) {
      if (didOptimisticUpdate && previousTransaction != null) {
        _transactions[index] = previousTransaction;
        notifyListeners();
      }
      _setError(_extractApiErrorMessage(e, AppStrings.cannotUpdateTransaction));
      debugPrint('❌ Cập nhật giao dịch thất bại: ${e.message}');
      return false;
    } catch (e) {
      if (didOptimisticUpdate && previousTransaction != null) {
        _transactions[index] = previousTransaction;
        notifyListeners();
      }
      // giữ nguyên message gốc
      _setError(e.toString());
      debugPrint('❌ Lỗi không mong muốn: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  TransactionModel? _extractTransactionFromResponse(dynamic data) {
    if (data is! Map<String, dynamic> || data['success'] != true) return null;
    final payload = data['data'];
    if (payload is! Map<String, dynamic>) return null;

    try {
      final transaction = TransactionModel.fromJson(payload);

      if (transaction.id.trim().isEmpty) return null;

      return transaction;
    } catch (e) {
      debugPrint('❌ Giao dịch từ API không hợp lệ: $e');
      debugPrint('👉 Dữ liệu: $payload');
      return null;
    }
  }

  // ============== DUMMY LOAD ==============
  Future<void> loadDummyTransactions() async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(seconds: 2));

    _transactions = dummyTransactions;
    _setLoading(false);
  }

  String _extractApiErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      final error = data['error']?.toString().trim();
      if (error != null && error.isNotEmpty) {
        return error;
      }
    } else if (data is String) {
      final message = data.trim();
      if (message.isNotEmpty) {
        return message;
      }
    }

    final error = e.error?.toString().trim();
    if (error != null && error.isNotEmpty && error != 'null') {
      return error;
    }

    return fallback;
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
    _remoteTotalIncome = null;
    _remoteTotalExpense = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
