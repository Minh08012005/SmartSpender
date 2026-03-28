import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction_model.dart';
import '../../../theme/colors.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;
    final formatter = NumberFormat('#,###', 'vi_VN');

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // LEFT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE (main)
                    Text(
                      transaction.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // CATEGORY + DATE (sub)
                    Text(
                      '${transaction.categoryForUi} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    // NOTE (optional)
                    if (transaction.note.isNotEmpty)
                      Text(
                        transaction.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // RIGHT
              Text(
                '${isIncome ? '+' : '-'} ${formatter.format(transaction.amount)} ₫',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isIncome ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
