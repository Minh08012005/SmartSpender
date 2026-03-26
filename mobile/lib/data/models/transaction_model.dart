import 'package:intl/intl.dart';

enum TransactionType { income, expense }

enum WalletType { cash, bank, ewallet }

class TransactionModel {
  static const double maxAmount = 1000000000;
  static const int maxNoteLength = 200;

  static const Map<TransactionType, List<String>> categoriesByType = {
    TransactionType.income: ['salary', 'other'],
    TransactionType.expense: [
      'food',
      'travel',
      'shopping',
      'entertainment',
      'utility',
      'other',
    ],
  };

  static const Map<String, String> categoryLabelMap = {
    'salary': 'Lương',
    'food': 'Ăn uống',
    'travel': 'Di chuyển',
    'shopping': 'Mua sắm',
    'entertainment': 'Giải trí',
    'utility': 'Tiện ích',
    'other': 'Khác',
  };

  final String id;
  final double amount;
  final String category;
  final String title;
  final DateTime date;
  final String note;
  final TransactionType type;
  final WalletType walletType;

  TransactionModel({
    required this.id,
    required this.amount,
    required String category,
    required this.title,
    required this.date,
    required this.note,
    required this.type,
    this.walletType = WalletType.cash,
  }) : category = _normalizeCategory(category, type) {
    // Validate amount
    if (amount <= 0) {
      throw Exception('Số tiền phải lớn hơn 0');
    }
    if (amount > maxAmount) {
      throw Exception('Số tiền phải nhỏ hơn hoặc bằng $maxAmount');
    }

    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Tiêu đề không được để trống');
    }

    // Validate note length
    if (note.length > maxNoteLength) {
      throw Exception('Ghi chú quá dài, tối đa $maxNoteLength ký tự');
    }

    // Validate category
    if (!isCategoryValid(type, category)) {
      throw Exception(
        'Danh mục "$category" không hợp lệ với loại giao dịch "$type"',
      );
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final parsedType = _parseType(json['type']);

    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: _parseAmount(json['amount']),
      category: _normalizeCategory(json['category'], parsedType),
      title: json['title'] ?? 'Không có tiêu đề',
      date: _parseDate(json['date']),
      note: _parseNote(json['note']),
      type: parsedType,
      walletType: _parseWalletType(json['walletType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': _normalizeCategory(category, type),
      'title': title,
      'date': date.toIso8601String(),
      'note': note,
      'type': type.name,
      'walletType': walletType.name,
    };
  }

  static WalletType _parseWalletType(dynamic value) {
    final raw = value?.toString().toLowerCase().trim();
    switch (raw) {
      case 'bank':
        return WalletType.bank;
      case 'ewallet':
        return WalletType.ewallet;
      case 'cash':
      default:
        return WalletType.cash;
    }
  }

  static String walletTypeLabel(WalletType walletType) {
    switch (walletType) {
      case WalletType.cash:
        return 'Tiền mặt';
      case WalletType.bank:
        return 'Ngân hàng';
      case WalletType.ewallet:
        return 'Ví điện tử';
    }
  }

  static double _parseAmount(dynamic value) {
    if (value == null) {
      throw Exception('Vui lòng nhập số tiền');
    }
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }

    throw Exception('Số tiền phải là một số hợp lệ');
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static TransactionType _parseType(dynamic value) {
    if (value == null) return TransactionType.expense;
    final typeStr = value.toString().toLowerCase();
    return typeStr == 'income'
        ? TransactionType.income
        : TransactionType.expense;
  }

  static String _parseNote(dynamic value) {
    if (value == null) return '';
    final parsed = value.toString();
    if (parsed.length <= maxNoteLength) return parsed;
    return parsed.substring(0, maxNoteLength);
  }

  static bool isCategoryValid(TransactionType type, String category) {
    final normalized = _normalizeRawCategory(category);
    return categoriesByType[type]?.contains(normalized) ?? false;
  }

  static String defaultCategoryFor(TransactionType type) {
    return categoriesByType[type]!.first;
  }

  static String _normalizeRawCategory(dynamic value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  static String _normalizeCategory(dynamic value, TransactionType type) {
    final parsed = _normalizeRawCategory(value);
    if (parsed == 'other income' || parsed == 'other expense') {
      return 'other';
    }
    if (isCategoryValid(type, parsed)) return parsed;
    throw Exception('Danh mục không hợp lệ: $parsed');
  }

  static String formatCategoryForUi(String category) {
    final normalized = _normalizeRawCategory(category);
    if (normalized.isEmpty) return '';
    return categoryLabelMap[normalized] ??
        (normalized[0].toUpperCase() + normalized.substring(1));
  }

  String get categoryForUi {
    return formatCategoryForUi(category);
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String get formattedAmount {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} ₫';
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? title,
    DateTime? date,
    String? note,
    TransactionType? type,
    WalletType? walletType,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
      walletType: walletType ?? this.walletType,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, category: $category, '
        'date: $formattedDate, type: ${type.name})';
  }
}
