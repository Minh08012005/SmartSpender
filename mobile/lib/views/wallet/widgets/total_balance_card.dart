import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/strings.dart';

class TotalBalanceCard extends StatelessWidget {
  final int totalBalance;

  const TotalBalanceCard({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xfff5f5f5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label: "Tổng số dư"
            Text(
              AppStrings.totalBalance,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Amount: formatted currency
            Text(
              _formatCurrency(totalBalance),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format số tiền sang dạng tiền tệ VND
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }
}
