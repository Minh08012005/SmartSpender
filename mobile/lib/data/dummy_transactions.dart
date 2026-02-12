import './models/transaction_model.dart';

final List<TransactionModel> dummyTransactions = [
  TransactionModel(
    id: 't1',
    amount: 120000,
    category: 'Salary',
    date: '02 Feb 2026',
    note: 'Monthly salary',
    type: TransactionType.income,
  ),
  TransactionModel(
    id: 't2',
    amount: 45000,
    category: 'Food',
    date: '01 Feb 2026',
    note: 'Lunch',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't3',
    amount: 200000,
    category: 'Freelance',
    date: '30 Jan 2026',
    note: 'Side project',
    type: TransactionType.income,
  ),
];
