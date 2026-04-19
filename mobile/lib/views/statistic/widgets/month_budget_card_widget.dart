import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../theme/colors.dart';
import '../statistic_utils.dart';

class MonthBudgetCardWidget extends StatelessWidget {
  final double monthlyTarget;
  final double actualExpense;
  final VoidCallback onEditPressed;

  const MonthBudgetCardWidget({
    required this.monthlyTarget,
    required this.actualExpense,
    required this.onEditPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = monthlyTarget - actualExpense;
    final ratio = monthlyTarget <= 0
        ? 0.0
        : (actualExpense / monthlyTarget).clamp(0.0, 1.0);

    final statusText = remaining < 0
        ? AppStrings.statisticBudgetStatusOver
        : (ratio >= 0.8
              ? AppStrings.statisticBudgetStatusNear
              : AppStrings.statisticBudgetStatusSafe);

    final statusColor = remaining < 0
        ? AppColors.danger
        : (ratio >= 0.8 ? const Color(0xffE67E22) : AppColors.success);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.statisticMonthlyBudgetTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text(AppStrings.statisticSetUpBudget),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${AppStrings.statisticBudgetTargetPrefix}: ${formatAmount(monthlyTarget)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${AppStrings.statisticBudgetSpentPrefix}: ${formatAmount(actualExpense)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '${AppStrings.statisticBudgetRemainingPrefix}: ${formatAmount(remaining)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: remaining < 0 ? AppColors.danger : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: statusColor,
              backgroundColor: AppColors.surfaceBorder,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.statisticBudgetStatusPrefix}: $statusText',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
