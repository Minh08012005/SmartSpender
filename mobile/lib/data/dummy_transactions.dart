import '../models/transaction_model.dart';

final List<TransactionModel> dummyTransactions = [
  TransactionModel(
    id: 'T001',
    amount: 120000,
    category: 'Food',
    date: '2026-01-30',
    note: 'Lunch with friends',
    type: 'expense',
  ),
  TransactionModel(
    id: 'T002',
    amount: 850000,
    category: 'Freelance',
    date: '2026-01-29',
    note: 'Upwork payment',
    type: 'income',
  ),
  TransactionModel(
    id: 'T003',
    amount: 150000,
    category: 'Entertainment',
    date: '2026-01-28',
    note: 'Youtube Premium',
    type: 'expense',
  ),
];
