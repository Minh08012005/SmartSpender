import 'package:dio/dio.dart';
import 'api_service.dart';

/// Wallet API Service
/// Xử lý tất cả các API calls liên quan đến wallet
class WalletApiService {
  static final WalletApiService _instance = WalletApiService._internal();
  factory WalletApiService() => _instance;
  WalletApiService._internal();

  final _apiService = ApiService();
  static const String _walletEndpoint = '/api/wallets';

  /// Lấy danh sách tất cả ví của user
  /// GET /wallets
  Future<GetWalletsResponse> getAllWallets() async {
    try {
      final response = await _apiService.get(_walletEndpoint);
      return GetWalletsResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy chi tiết một ví
  /// GET /wallets/:id
  Future<GetWalletResponse> getWalletById(String walletId) async {
    try {
      final response = await _apiService.get('$_walletEndpoint/$walletId');
      return GetWalletResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Điều chuyển tiền giữa 2 ví
  /// POST /wallets/transfer
  Future<TransferResponse> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    String? note,
  }) async {
    try {
      final response = await _apiService.post(
        '$_walletEndpoint/transfer',
        data: {
          'fromWalletId': fromWalletId,
          'toWalletId': toWalletId,
          'amount': amount,
          if (note != null) 'note': note,
        },
      );
      return TransferResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Cập nhật thông tin ví
  /// PATCH /wallets/:id
  Future<UpdateWalletResponse> updateWallet({
    required String walletId,
    String? name,
    String? description,
  }) async {
    try {
      final response = await _apiService.put(
        '$_walletEndpoint/$walletId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return UpdateWalletResponse.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Xử lý lỗi API
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final message = error.response?.data?['message'] ?? 'Unknown error';
        return Exception('API Error: $message');
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return Exception('Kết nối timeout');
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return Exception('Nhận dữ liệu timeout');
      }
    }
    return Exception('Lỗi không xác định: $error');
  }
}

// ============== RESPONSE MODELS ==============

class GetWalletsResponse {
  final bool success;
  final List<WalletData> data;
  final int totalBalance;
  final String? message;

  GetWalletsResponse({
    required this.success,
    required this.data,
    required this.totalBalance,
    this.message,
  });

  factory GetWalletsResponse.fromJson(Map<String, dynamic> json) {
    return GetWalletsResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((w) => WalletData.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      totalBalance: json['totalBalance'] ?? 0,
      message: json['message'],
    );
  }
}

class GetWalletResponse {
  final bool success;
  final WalletData data;

  GetWalletResponse({required this.success, required this.data});

  factory GetWalletResponse.fromJson(Map<String, dynamic> json) {
    return GetWalletResponse(
      success: json['success'] ?? false,
      data: WalletData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TransferResponse {
  final bool success;
  final String message;
  final TransferData data;

  TransferResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TransferData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class TransferData {
  final WalletData fromWallet;
  final WalletData toWallet;
  final int amount;
  final String note;

  TransferData({
    required this.fromWallet,
    required this.toWallet,
    required this.amount,
    required this.note,
  });

  factory TransferData.fromJson(Map<String, dynamic> json) {
    return TransferData(
      fromWallet: WalletData.fromJson(
        json['fromWallet'] as Map<String, dynamic>,
      ),
      toWallet: WalletData.fromJson(json['toWallet'] as Map<String, dynamic>),
      amount: json['amount'] ?? 0,
      note: json['note'] ?? '',
    );
  }
}

class UpdateWalletResponse {
  final bool success;
  final String message;
  final WalletData data;

  UpdateWalletResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UpdateWalletResponse.fromJson(Map<String, dynamic> json) {
    return UpdateWalletResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: WalletData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class WalletData {
  final String id;
  final String userId;
  final String walletType;
  final int balance;
  final String name;
  final String description;
  final String lastUpdated;
  final String createdAt;
  final String updatedAt;

  WalletData({
    required this.id,
    required this.userId,
    required this.walletType,
    required this.balance,
    required this.name,
    required this.description,
    required this.lastUpdated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      walletType: json['walletType'] ?? '',
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'walletType': walletType,
      'balance': balance,
      'name': name,
      'description': description,
      'lastUpdated': lastUpdated,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
