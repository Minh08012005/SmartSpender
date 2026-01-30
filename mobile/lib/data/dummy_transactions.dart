import '../models/transaction_model.dart';

final List<TransactionModel> dummyTransactions = [
  TransactionModel(title: 'Upwork', date: 'Today', amount: 850, isIncome: true),
  TransactionModel(
    title: 'Transfer',
    date: 'Yesterday',
    amount: 85,
    isIncome: false,
  ),
  TransactionModel(
    title: 'Paypal',
    date: 'Jan 30, 2022',
    amount: 1406,
    isIncome: true,
  ),
  TransactionModel(
    title: 'Youtube',
    date: 'Jan 16, 2022',
    amount: 11.99,
    isIncome: false,
  ),
];
