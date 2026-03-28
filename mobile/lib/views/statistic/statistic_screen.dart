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
import 'widgets/empty_state_widget.dart';
import 'widgets/kpi_card_widget.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final statProvider = context.watch<StatisticProvider>();
    final transactions = txProvider.transactions;

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
                    });
                    await _reload();
                  },
                ),
              ),
              const SizedBox(height: 20),

              // KPI Cards
              SectionReveal(
                delayMs: 80,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child:
                      (statProvider.isLoading &&
                          totalIncome == 0 &&
                          totalExpense == 0)
                      ? _buildLoadingKpiCards(
                          key: const ValueKey<String>('loading_kpi'),
                        )
                      : _buildKpiCards(
                          totalExpense,
                          totalIncome,
                          balance,
                          key: ValueKey<String>(
                            'kpi_${_selectedMonth}_${_selectedYear}_${totalExpense}_$totalIncome',
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 24),

              // Recent Transactions Section
              SectionReveal(
                delayMs: 200,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildTransactionSection(
                    txProvider,
                    transactions,
                    key: ValueKey<String>(
                      'tx_${_selectedMonth}_${_selectedYear}_${transactions.length}',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCards(
    double totalExpense,
    double totalIncome,
    double balance, {
    Key? key,
  }) {
    return Column(
      key: key,
      children: [
        KpiCardWidget(
          title: AppStrings.statisticKpiTotalExpense,
          value: formatAmount(totalExpense),
          color: AppColors.danger,
          icon: Icons.trending_down,
          subtitle: AppStrings.statisticSpentSubtitle,
        ),
        const SizedBox(height: 12),
        KpiCardWidget(
          title: AppStrings.statisticKpiTotalIncome,
          value: formatAmount(totalIncome),
          color: AppColors.success,
          icon: Icons.trending_up,
          subtitle: AppStrings.statisticReceivedSubtitle,
        ),
        const SizedBox(height: 12),
        KpiCardWidget(
          title: AppStrings.statisticKpiBalance,
          value: formatAmount(balance),
          color: AppColors.info,
          icon: Icons.account_balance_wallet,
          subtitle: balance >= 0
              ? AppStrings.statisticRemaining
              : AppStrings.statisticNegative,
        ),
      ],
    );
  }

  Widget _buildLoadingKpiCards({Key? key}) {
    return Column(
      key: key,
      children: [
        LoadingSkeletonWidget(type: 'card'),
        const SizedBox(height: 12),
        LoadingSkeletonWidget(type: 'card'),
        const SizedBox(height: 12),
        LoadingSkeletonWidget(type: 'card'),
      ],
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
              const SizedBox(height: 12),

              // Content
              if (txProvider.isLoading && txProvider.transactions.isEmpty)
                Column(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoadingSkeletonWidget(type: 'row'),
                    ),
                  ),
                )
              else if (totalExpense <= 0)
                const EmptyStateWidget(
                  message: AppStrings.statisticNoExpenseInPeriod,
                  icon: Icons.trending_down,
                )
              else
                Column(
                  children: categoryBreakdown
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
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

  Widget _buildTransactionSection(
    TransactionProvider txProvider,
    List<TransactionModel> transactions, {
    Key? key,
  }) {
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
                AppStrings.statisticRecentTransactions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.statisticRecentTransactionsHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (txProvider.isLoading && transactions.isEmpty)
                Column(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LoadingSkeletonWidget(type: 'row'),
                    ),
                  ),
                )
              else if (transactions.isEmpty)
                const EmptyStateWidget(
                  message: AppStrings.homeEmptyTransactions,
                  icon: Icons.receipt_long,
                )
              else
                Column(
                  children: transactions
                      .take(5)
                      .map(
                        (tx) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TransactionTileWidget(transaction: tx),
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
    } finally {
      if (mounted) {
        setState(() {
          _isPeriodChanging = false;
        });
      }
    }
  }
}
