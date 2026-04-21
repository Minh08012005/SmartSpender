import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/statistic_provider.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
import 'statistic_utils.dart';
import 'widgets/category_row_widget.dart';
import 'widgets/day_transactions_sheet.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/month_budget_card_widget.dart';
import 'widgets/month_calendar_widget.dart';
import 'widgets/period_picker_widget.dart';
import 'widgets/transaction_tile_widget.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  bool _initialized = false;
  bool _isPeriodChanging = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  DateTime? _selectedDate;
  double _monthlyTarget = 6000000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final txProvider = context.read<TransactionProvider>();
    final statProvider = context.read<StatisticProvider>();

    Future.microtask(() {
      txProvider.fetchTransactions(month: _selectedMonth, year: _selectedYear);
      statProvider.fetchStatistics(month: _selectedMonth, year: _selectedYear);
    });

    _selectedDate = DateTime(_selectedYear, _selectedMonth, DateTime.now().day);
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final statProvider = context.watch<StatisticProvider>();
    final transactions = txProvider.transactions;
    final monthTransactions = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    // Sử dụng data từ API statistics provider
    final totalIncome = statProvider.totalIncome;
    final totalExpense = statProvider.totalExpense;
    final balance = statProvider.balance;

    final categoryBreakdown = buildCategoryBreakdown(
      transactions,
      totalExpense,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.statisticTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          displacement: 40.0,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Period Picker
              SectionReveal(
                delayMs: 0,
                child: PeriodPickerWidget(
                  selectedMonth: _selectedMonth,
                  selectedYear: _selectedYear,
                  isBusy: _isPeriodChanging,
                  onChanged: (month, year) async {
                    if (_isPeriodChanging ||
                        (_selectedMonth == month && _selectedYear == year)) {
                      return;
                    }
                    setState(() {
                      _selectedMonth = month;
                      _selectedYear = year;
                      _selectedDate = DateTime(year, month, 1);
                    });
                    await _reload();
                  },
                ),
              ),
              const SizedBox(height: 14),

              SectionReveal(
                delayMs: 40,
                child: MonthBudgetCardWidget(
                  monthlyTarget: _monthlyTarget,
                  actualExpense: totalExpense,
                  onEditPressed: _showBudgetEditor,
                ),
              ),

              const SizedBox(height: 12),

              SectionReveal(
                delayMs: 60,
                child: MonthCalendarWidget(
                  selectedMonth: _selectedMonth,
                  selectedYear: _selectedYear,
                  selectedDate:
                      _selectedDate ??
                      DateTime(_selectedYear, _selectedMonth, 1),
                  transactions: monthTransactions,
                  onDaySelected: (day) {
                    setState(() {
                      _selectedDate = day;
                    });
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => DayTransactionsSheet(day: day),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SectionReveal(
                delayMs: 70,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child:
                      (statProvider.isLoading &&
                          totalIncome == 0 &&
                          totalExpense == 0)
                      ? _buildLoadingSummaryStrip(
                          key: const ValueKey<String>('loading_summary'),
                        )
                      : _buildMonthlySummaryStrip(
                          totalIncome,
                          totalExpense,
                          balance,
                          key: ValueKey<String>(
                            'summary_${_selectedMonth}_${_selectedYear}_${totalExpense}_$totalIncome',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Category Breakdown Section
              SectionReveal(
                delayMs: 140,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildCategorySection(
                    categoryBreakdown,
                    totalExpense,
                    key: ValueKey<String>(
                      'cat_${_selectedMonth}_${_selectedYear}_${categoryBreakdown.length}_$totalExpense',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummaryStrip(
    double totalIncome,
    double totalExpense,
    double balance, {
    Key? key,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              label: AppStrings.statisticSummaryIncome,
              value: formatAmount(totalIncome),
              color: AppColors.success,
            ),
          ),
          Expanded(
            child: _SummaryItem(
              label: AppStrings.statisticSummaryExpense,
              value: formatAmount(totalExpense),
              color: AppColors.danger,
            ),
          ),
          Expanded(
            child: _SummaryItem(
              label: AppStrings.statisticSummaryTotal,
              value: formatAmount(balance),
              color: balance >= 0 ? AppColors.info : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSummaryStrip({Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: const [
          Expanded(child: LoadingSkeletonWidget(type: 'row')),
          SizedBox(width: 8),
          Expanded(child: LoadingSkeletonWidget(type: 'row')),
          SizedBox(width: 8),
          Expanded(child: LoadingSkeletonWidget(type: 'row')),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    List<CategoryStat> categoryBreakdown,
    double totalExpense, {
    Key? key,
  }) {
    final txProvider = context.watch<TransactionProvider>();

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.statisticCategorySection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${AppStrings.statisticTotalExpensePrefix}: ${formatAmount(totalExpense)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Content
              if (txProvider.isLoading && txProvider.transactions.isEmpty)
                Column(
                  children: List.generate(
                    2,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LoadingSkeletonWidget(type: 'row'),
                    ),
                  ),
                )
              else if (totalExpense <= 0)
                const EmptyStateWidget(
                  message: AppStrings.statisticNoExpenseInPeriod,
                  icon: Icons.trending_down,
                  compact: true,
                )
              else
                Column(
                  children: categoryBreakdown
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CategoryRowWidget(
                            category:
                                categoryLabelMap[item.category] ??
                                item.category,
                            categoryKey: item.category,
                            percentage: item.percentage,
                            amount: item.amount,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _reload() async {
    if (_isPeriodChanging) return;

    final txProvider = context.read<TransactionProvider>();
    final statProvider = context.read<StatisticProvider>();

    setState(() {
      _isPeriodChanging = true;
    });

    try {
      await Future.wait([
        txProvider.fetchTransactions(
          month: _selectedMonth,
          year: _selectedYear,
        ),
        statProvider.fetchStatistics(
          month: _selectedMonth,
          year: _selectedYear,
        ),
      ]);

      if (_selectedDate == null ||
          _selectedDate!.month != _selectedMonth ||
          _selectedDate!.year != _selectedYear) {
        _selectedDate = DateTime(_selectedYear, _selectedMonth, 1);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPeriodChanging = false;
        });
      }
    }
  }

  void _showBudgetEditor() {
    final controller = TextEditingController(
      text: _monthlyTarget.toStringAsFixed(0),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.statisticBudgetEditorTitlePrefix} $_selectedMonth/$_selectedYear',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.statisticBudgetEditorAmountLabel,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final next = double.tryParse(controller.text.trim());
                        if (next == null || next <= 0) return;
                        setState(() {
                          _monthlyTarget = next;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(AppStrings.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
