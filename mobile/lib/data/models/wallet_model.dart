import 'package:flutter/material.dart';

class WalletModel {
  final String id; // MongoDB ObjectId
  final String walletType; // 'cash', 'bank', 'ewallet'
  final String name;
  int balance;
  final String description;
  final IconData icon;
  final Color color;

  WalletModel({
    required this.id,
    required this.walletType,
    required this.name,
    required this.balance,
    required this.description,
    required this.icon,
    required this.color,
  });

  // Factory constructor từ API response
  factory WalletModel.fromApiData({
    required String id,
    required String walletType,
    required String name,
    required int balance,
    required String description,
  }) {
    // Map wallet type to icon và color
    final (icon, color) = _getWalletIconAndColor(walletType);

    return WalletModel(
      id: id,
      walletType: walletType,
      name: name,
      balance: balance,
      description: description,
      icon: icon,
      color: color,
    );
  }

  // Copy with method để tạo instance mới với balance thay đổi
  WalletModel copyWith({int? balance}) {
    return WalletModel(
      id: id,
      walletType: walletType,
      name: name,
      balance: balance ?? this.balance,
      description: description,
      icon: icon,
      color: color,
    );
  }

  @override
  String toString() => 'Wallet($walletType, $name, $balance VND)';

  // Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletType': walletType,
      'name': name,
      'balance': balance,
      'description': description,
    };
  }

  // Create from JSON (for cache loading)
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel.fromApiData(
      id: json['id'] as String,
      walletType: json['walletType'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
      description: json['description'] as String,
    );
  }
}

// Helper function để get icon và color dựa trên wallet type
(IconData, Color) _getWalletIconAndColor(String walletType) {
  switch (walletType) {
    case 'cash':
      return (Icons.wallet_giftcard, Colors.orange);
    case 'bank':
      return (Icons.account_balance, Colors.blue);
    case 'ewallet':
      return (Icons.credit_card, Colors.purple);
    default:
      return (Icons.wallet, Colors.grey);
  }
}
