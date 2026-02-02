class TransactionModel {
  final String id;
  final double amount;
  final String category;
  final String date;
  final String note;
  final String type; // income | expense

  TransactionModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.type,
  });
}
