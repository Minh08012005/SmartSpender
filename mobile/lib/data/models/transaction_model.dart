import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class TransactionModel {
  static const double maxAmount = 1000000000;
  static const int maxNoteLength = 200;

  static const Map<TransactionType, List<String>> categoriesByType = {
    TransactionType.income: [
      'Salary',
      'Freelance',
      'Bonus',
      'Gift',
      'Investment',
      'Other Income',
    ],
    TransactionType.expense: [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment',
      'Health',
      'Education',
      'Other Expense',
    ],
  };

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
  })  : assert(amount > 0, 'Amount must be > 0'),
        assert(amount <= maxAmount, 'Amount must be <= maxAmount'),
        assert(note.length <= maxNoteLength, 'Note too long'),
        assert(
          isCategoryValid(type, category),
          'Category is not valid for transaction type',
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final parsedType = _parseType(json['type']);

    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      amount: _parseAmount(json['amount']),
      category: _normalizeCategory(json['category'], parsedType),
      date: _parseDate(json['date']),
      note: _parseNote(json['note']),
      type: parsedType,
    );
  }

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

  static double _parseAmount(dynamic value) {
    if (value == null) return 1.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 1.0;
    return 1.0;
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
    return categoriesByType[type]?.contains(category) ?? false;
  }

  static String defaultCategoryFor(TransactionType type) {
    return categoriesByType[type]!.first;
  }

  static String _normalizeCategory(dynamic value, TransactionType type) {
    final parsed = value?.toString() ?? '';
    if (isCategoryValid(type, parsed)) return parsed;
    return defaultCategoryFor(type);
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
