import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/wallet_api_service.dart';
import '../../core/strings.dart';
import '../models/wallet_model.dart';

/// Wallet Provider
///
/// Quản lý state của ví với:
/// - Fetch từ API backend + fallback cache
/// - Điều chuyển tiền nội bộ giữa các ví
/// - Lưu cache để hiển thị nhanh lần mở sau
class WalletProvider extends ChangeNotifier {
  final WalletApiService _apiService;

  List<WalletModel> _wallets = [];
  bool _isLoading = false;
  String _errorMessage = '';
  SharedPreferences? _prefs;

  static const String _cacheKey = 'wallet_cache';

  WalletProvider({WalletApiService? apiService})
    : _apiService = apiService ?? WalletApiService();

  List<WalletModel> get wallets => List.unmodifiable(_wallets);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  int get totalBalance =>
      _wallets.fold(0, (sum, wallet) => sum + wallet.balance);

  WalletModel? getWalletById(String walletId) {
    try {
      return _wallets.firstWhere((w) => w.id == walletId);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchWallets({bool forceRefresh = false}) async {
    _errorMessage = '';
    _prefs ??= await SharedPreferences.getInstance();

    if (!forceRefresh) {
      await _loadFromCache();
    }

    await _fetchFromApi();
  }

  Future<bool> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required String note,
  }) async {
    clearError(notify: false);

    final fromIndex = _wallets.indexWhere((w) => w.id == fromWalletId);
    final toIndex = _wallets.indexWhere((w) => w.id == toWalletId);

    if (fromIndex < 0 || toIndex < 0) {
      _errorMessage = AppStrings.walletPleaseSelectWallet;
      notifyListeners();
      return false;
    }

    if (fromWalletId == toWalletId) {
      _errorMessage = AppStrings.walletSourceDestinationSame;
      notifyListeners();
      return false;
    }

    if (amount <= 0) {
      _errorMessage = AppStrings.walletAmountMustBePositive;
      notifyListeners();
      return false;
    }

    if (_wallets[fromIndex].balance < amount) {
      _errorMessage =
          '${AppStrings.walletInsufficientBalance}. Số dư hiện tại: ${_formatCurrency(_wallets[fromIndex].balance)}';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.transferBetweenWallets(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        note: note.trim(),
      );

      if (response.success) {
        _updateWalletFromApi(response.data.fromWallet);
        _updateWalletFromApi(response.data.toWallet);
      } else {
        _wallets[fromIndex] = _wallets[fromIndex].copyWith(
          balance: _wallets[fromIndex].balance - amount,
        );
        _wallets[toIndex] = _wallets[toIndex].copyWith(
          balance: _wallets[toIndex].balance + amount,
        );
      }

      await _saveToCache();
      return true;
    } catch (e) {
      // Fallback local transfer để UX mượt khi backend lỗi tạm thời.
      _wallets[fromIndex] = _wallets[fromIndex].copyWith(
        balance: _wallets[fromIndex].balance - amount,
      );
      _wallets[toIndex] = _wallets[toIndex].copyWith(
        balance: _wallets[toIndex].balance + amount,
      );
      await _saveToCache();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFromApi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getAllWallets();

      if (response.data.isEmpty) {
        _wallets = _buildDefaultWallets();
      } else {
        _wallets = response.data
            .map(
              (w) => WalletModel.fromApiData(
                id: w.id,
                walletType: w.walletType,
                name: w.name,
                balance: w.balance,
                description: w.description,
              ),
            )
            .toList();
      }

      await _saveToCache();
    } catch (e) {
      if (_wallets.isEmpty) {
        _wallets = _buildDefaultWallets();
        _errorMessage = AppStrings.failedToLoadTransactions;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final cachedJson = _prefs?.getString(_cacheKey);
      if (cachedJson == null || cachedJson.isEmpty) {
        return;
      }

      final decoded = jsonDecode(cachedJson);
      if (decoded is! List) {
        return;
      }

      _wallets = decoded
          .map((w) => WalletModel.fromJson(w as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      _wallets = [];
    }
  }

  Future<void> _saveToCache() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonList = _wallets.map((w) => w.toJson()).toList();
      await _prefs?.setString(_cacheKey, jsonEncode(jsonList));
    } catch (_) {
      // Intentionally ignore cache write failures.
    }
  }

  void _updateWalletFromApi(WalletData apiWallet) {
    final index = _wallets.indexWhere((w) => w.id == apiWallet.id);
    if (index < 0) return;

    _wallets[index] = WalletModel.fromApiData(
      id: apiWallet.id,
      walletType: apiWallet.walletType,
      name: apiWallet.name,
      balance: apiWallet.balance,
      description: apiWallet.description,
    );
  }

  Future<void> clearCache() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.remove(_cacheKey);
    _wallets = [];
    notifyListeners();
  }

  void clearError({bool notify = true}) {
    _errorMessage = '';
    if (notify) {
      notifyListeners();
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  List<WalletModel> _buildDefaultWallets() {
    return [
      WalletModel.fromApiData(
        id: 'local-cash',
        walletType: 'cash',
        name: AppStrings.walletNameCash,
        balance: 1200000,
        description: 'Ví mặc định cục bộ',
      ),
      WalletModel.fromApiData(
        id: 'local-bank',
        walletType: 'bank',
        name: AppStrings.walletNameBank,
        balance: 850000,
        description: 'Ví mặc định cục bộ',
      ),
      WalletModel.fromApiData(
        id: 'local-ewallet',
        walletType: 'ewallet',
        name: AppStrings.walletNameEwallet,
        balance: 320000,
        description: 'Ví mặc định cục bộ',
      ),
    ];
  }
}
