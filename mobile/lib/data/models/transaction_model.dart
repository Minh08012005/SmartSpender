import 'package:intl/intl.dart';

enum TransactionType { income, expense }

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

  final String id;
  final double amount;
  final String category;
  final String title;
  final DateTime date;
  final String note;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required this.amount,
    required String category,
    required this.title,
    required this.date,
    required this.note,
    required this.type,
  }) : category = _normalizeCategory(category, type) {
    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be > 0');
    }
    if (amount > maxAmount) {
      throw Exception('Amount must be <= $maxAmount');
    }

    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }

    // Validate note length
    if (note.length > maxNoteLength) {
      throw Exception('Note is too long, max $maxNoteLength characters');
    }

    // Validate category
    if (!isCategoryValid(type, category)) {
      throw Exception(
        'Category "$category" is not valid for transaction type "$type"',
      );
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final parsedType = _parseType(json['type']);

    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: _parseAmount(json['amount']),
      category: _normalizeCategory(json['category'], parsedType),
      title: json['title'] ?? 'No Title',
      date: _parseDate(json['date']),
      note: _parseNote(json['note']),
      type: parsedType,
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
    };
  }

  static double _parseAmount(dynamic value) {
    if (value == null) {
      throw Exception('Amount is required');
    }
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }

    throw Exception('Amount must be a valid number');
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
    throw Exception('Invalid category: $parsed');
  }

  static String formatCategoryForUi(String category) {
    final normalized = _normalizeRawCategory(category);
    if (normalized.isEmpty) return '';
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String get categoryForUi {
    return formatCategoryForUi(category);
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String get formattedAmount {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? title,
    DateTime? date,
    String? note,
    TransactionType? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      title: title ?? this.title,
      date: date ?? this.date,
      note: note ?? this.note,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, category: $category, '
        'date: $formattedDate, type: ${type.name})';
  }
}
