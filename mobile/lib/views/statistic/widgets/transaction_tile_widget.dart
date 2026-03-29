import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../statistic_utils.dart';
import '../../../theme/colors.dart';

class TransactionTileWidget extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTileWidget({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountText = formatAmount(transaction.amount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isIncome
                ? AppColors.successSoft
                : AppColors.dangerSoft,
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              size: 18,
              color: isIncome ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isIncome ? '+$amountText' : '-$amountText',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isIncome ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
