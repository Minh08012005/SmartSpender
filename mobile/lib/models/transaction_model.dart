class TransactionModel {
  final String title;
  final String date;
  final double amount;
  final bool isIncome;

  TransactionModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });
}
