import 'package:intl/intl.dart';

enum TransactionType { income, expense }

/// Transaction Model
///
/// Đại diện cho một giao dịch thu/chi
/// Hỗ trợ parse từ JSON API và format hiển thị
class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String note;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.type,
  }) : assert(amount >= 0, 'Amount must be >= 0');

  // ============== JSON PARSING ==============

  /// Parse từ JSON API (với null safety)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: _parseAmount(json['amount']),
      category: json['category'] ?? 'Uncategorized',
      date: _parseDate(json['date']),
      note: json['note'] ?? '',
      type: _parseType(json['type']),
    );
  }

  /// Convert sang JSON để gửi API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'type': type.name,
    };
  }

  // ============== HELPER METHODS ==============

  /// Parse amount với null safety
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Parse date với null safety
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Parse type với null safety
  static TransactionType _parseType(dynamic value) {
    if (value == null) return TransactionType.expense;
    final typeStr = value.toString().toLowerCase();
    return typeStr == 'income'
        ? TransactionType.income
        : TransactionType.expense;
  }

  // ============== DISPLAY FORMATTING ==============

  /// Format date để hiển thị (dd MMM yyyy)
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format amount với dấu phẩy (123,456.00 ₫)
  String get formattedAmount {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} ₫';
  }

  /// Copy với một số trường thay đổi
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, category: $category, '
        'date: $formattedDate, type: ${type.name})';
  }
}
