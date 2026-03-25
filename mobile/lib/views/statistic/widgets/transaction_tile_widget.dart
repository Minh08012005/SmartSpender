import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';
import '../statistic_utils.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isIncome
                ? const Color(0xff4CAF50).withValues(alpha: 0.12)
                : const Color(0xffFF5252).withValues(alpha: 0.12),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: isIncome
                  ? const Color(0xff4CAF50)
                  : const Color(0xffFF5252),
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
                    color: Color(0xff333333),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff999999),
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
              color: isIncome
                  ? const Color(0xff4CAF50)
                  : const Color(0xffFF5252),
            ),
          ),
        ],
      ),
    );
  }
}
