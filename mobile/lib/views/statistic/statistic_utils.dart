import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';

// Category labels in Vietnamese
const Map<String, String> categoryLabelMap = {
  'salary': 'Lương',
  'food': 'Ăn Uống',
  'travel': 'Giao Thông',
  'shopping': 'Mua Sắm',
  'entertainment': 'Giải Trí',
  'utility': 'Tiện Ích',
  'other': 'Khác',
};

// Category icons
const Map<String, IconData> categoryIconMap = {
  'salary': Icons.attach_money,
  'food': Icons.restaurant,
  'travel': Icons.directions_car,
  'shopping': Icons.shopping_bag,
  'entertainment': Icons.movie,
  'utility': Icons.flash_on,
  'other': Icons.category,
};

// Category colors used by breakdown bars
const Map<String, Color> categoryColorMap = {
  'food': Color(0xffFF7043),
  'travel': Color(0xff42A5F5),
  'shopping': Color(0xffAB47BC),
  'entertainment': Color(0xff26A69A),
  'utility': Color(0xffFFA726),
  'salary': Color(0xff66BB6A),
  'other': Color(0xff78909C),
};

// Month names in Vietnamese
const List<String> monthNames = [
  'Tháng 1',
  'Tháng 2',
  'Tháng 3',
  'Tháng 4',
  'Tháng 5',
  'Tháng 6',
  'Tháng 7',
  'Tháng 8',
  'Tháng 9',
  'Tháng 10',
  'Tháng 11',
  'Tháng 12',
];

/// Format amount to Vietnamese currency format
String formatAmount(double amount) {
  final sign = amount < 0 ? '-' : '';
  final value = amount.abs().round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    final reverseIndex = value.length - i;
    buffer.write(value[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }

  return '$sign₫${buffer.toString()}';
}

/// Get month name from month number (1-12)
String getMonthName(int month) {
  return month >= 1 && month <= 12 ? monthNames[month - 1] : 'Tháng $month';
}

/// Sum all transactions by type (income/expense)
double sumByType(List<TransactionModel> transactions, TransactionType type) {
  return transactions
      .where((t) => t.type == type)
      .fold(0.0, (sum, t) => sum + t.amount);
}

/// Build category breakdown with percentages
List<CategoryStat> buildCategoryBreakdown(
  List<TransactionModel> transactions,
  double totalExpense,
) {
  if (totalExpense <= 0) return const [];

  final expenseTransactions = transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  final Map<String, double> byCategory = {};
  for (final tx in expenseTransactions) {
    byCategory[tx.category] = (byCategory[tx.category] ?? 0) + tx.amount;
  }

  final stats =
      byCategory.entries
          .map(
            (e) => CategoryStat(
              category: e.key,
              amount: e.value,
              percentage: (e.value / totalExpense).clamp(0.0, 1.0),
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));

  return stats;
}

/// Model for category statistics
class CategoryStat {
  final String category;
  final double amount;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}
