enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String date;
  final String note;
  final TransactionType type;

  TransactionModel({
    required this.id,
    required double amount,
    required this.category,
    required this.date,
    required this.note,
    required this.type,
  }) : assert(amount >= 0, 'Amount must be >= 0'),
       amount = amount;

  // ===== JSON =====
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      date: json['date'],
      note: json['note'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense, // Fallback chống crash
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
      'type': type.name,
    };
  }
}
