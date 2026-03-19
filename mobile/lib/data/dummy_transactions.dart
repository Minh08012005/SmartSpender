import './models/transaction_model.dart';

final List<TransactionModel> dummyTransactions = [
  TransactionModel(
    id: 't1',
    title: 'Monthly salary',
    amount: 120000,
    category: 'Salary',
    date: DateTime(2026, 2, 2),
    note: 'Monthly salary',
    type: TransactionType.income,
  ),
  TransactionModel(
    id: 't2',
    title: 'Lunch',
    amount: 45000,
    category: 'Food',
    date: DateTime(2026, 2, 1),
    note: 'Lunch',
    type: TransactionType.expense,
  ),
  TransactionModel(
  id: 't3',
  amount: 200000,
  category: 'other income',
  title: 'Side project bonus',
  date: DateTime(2026, 1, 30),
  note: 'Side project',
  type: TransactionType.income,
 ),
];
