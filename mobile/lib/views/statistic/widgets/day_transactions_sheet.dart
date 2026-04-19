import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../data/models/transaction_model.dart';
import '../../../theme/colors.dart';
import '../statistic_utils.dart';
import 'empty_state_widget.dart';
import 'transaction_tile_widget.dart';

class DayTransactionsSheet extends StatelessWidget {
  final DateTime day;
  final List<TransactionModel> monthTransactions;

  const DayTransactionsSheet({
    required this.day,
    required this.monthTransactions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dayTx =
        monthTransactions.where((tx) => _isSameDay(tx.date, day)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = dayTx
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = dayTx
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final net = totalIncome - totalExpense;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppStrings.statisticDayTransactionsTitlePrefix} ${day.day}/${day.month}/${day.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MiniChip(
                  label: 'Thu: ${formatAmount(totalIncome)}',
                  color: AppColors.success,
                ),
                _MiniChip(
                  label: 'Chi: ${formatAmount(totalExpense)}',
                  color: AppColors.danger,
                ),
                _MiniChip(
                  label: 'Net: ${formatAmount(net)}',
                  color: net >= 0 ? AppColors.info : AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dayTx.isEmpty)
              const EmptyStateWidget(
                message: AppStrings.statisticNoTransactionInSelectedDay,
                icon: Icons.event_busy,
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, i) =>
                      TransactionTileWidget(transaction: dayTx[i]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: dayTx.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
