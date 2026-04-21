import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/strings.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../theme/colors.dart';
import '../statistic_utils.dart';
import 'empty_state_widget.dart';
import 'transaction_tile_widget.dart';

class DayTransactionsSheet extends StatefulWidget {
  final DateTime day;

  const DayTransactionsSheet({required this.day, super.key});

  @override
  State<DayTransactionsSheet> createState() => _DayTransactionsSheetState();
}

class _DayTransactionsSheetState extends State<DayTransactionsSheet> {
  @override
  void initState() {
    super.initState();
    // Gọi API khi sheet mở
    final dateStr =
        '${widget.day.year}-${widget.day.month.toString().padLeft(2, '0')}-${widget.day.day.toString().padLeft(2, '0')}';
    Future.microtask(() {
      if (mounted) {
        context.read<TransactionProvider>().fetchTransactionsByDate(dateStr);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, txProvider, _) {
        // Từ state được lưu từ API
        final dayTx = txProvider.dayTransactions;
        final totalIncome = txProvider.dayTotalIncome;
        final totalExpense = txProvider.dayTotalExpense;
        final net = totalIncome - totalExpense;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.statisticDayTransactionsTitlePrefix} ${widget.day.day}/${widget.day.month}/${widget.day.year}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                // Hiển thị loading
                if (txProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                // Hiển thị error
                else if (txProvider.hasError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        txProvider.error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                // Hiển thị dữ liệu
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          message:
                              AppStrings.statisticNoTransactionInSelectedDay,
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
              ],
            ),
          ),
        );
      },
    );
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
