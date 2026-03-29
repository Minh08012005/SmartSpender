import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/strings.dart';
import '../../../theme/colors.dart';

class TotalBalanceCard extends StatelessWidget {
  final int totalBalance;

  const TotalBalanceCard({super.key, required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff3E8E89), AppColors.primary],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.totalBalance,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(totalBalance),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Wallet Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format số tiền sang dạng tiền tệ VND
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} ₫';
  }
}
