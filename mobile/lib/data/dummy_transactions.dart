class DummyTransaction {
  final String title;
  final String date;
  final double amount;
  final bool isIncome;

  DummyTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
  });
}

final List<DummyTransaction> dummyTransactions = [
  DummyTransaction(title: 'Upwork', date: 'Today', amount: 850, isIncome: true),
  DummyTransaction(
    title: 'Paypal',
    date: 'Yesterday',
    amount: 85,
    isIncome: false,
  ),
  DummyTransaction(
    title: 'Youtube',
    date: 'Jan 16, 2022',
    amount: 11.99,
    isIncome: false,
  ),
  DummyTransaction(
    title: 'Transfer',
    date: 'Jan 15, 2022',
    amount: 420,
    isIncome: true,
  ),
];
