import 'package:flutter/material.dart';

import '../../../core/strings.dart';
import '../../../data/models/transaction_model.dart';
import '../../../theme/colors.dart';

class MonthCalendarWidget extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final DateTime selectedDate;
  final List<TransactionModel> transactions;
  final ValueChanged<DateTime> onDaySelected;

  const MonthCalendarWidget({
    required this.selectedMonth,
    required this.selectedYear,
    required this.selectedDate,
    required this.transactions,
    required this.onDaySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays(selectedYear, selectedMonth);

    final Map<DateTime, _DailyAmount> amountMap = {};
    for (final tx in transactions) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      final current = amountMap[key] ?? _DailyAmount.empty();
      if (tx.type == TransactionType.income) {
        amountMap[key] = current.copyWith(income: current.income + tx.amount);
      } else {
        amountMap[key] = current.copyWith(expense: current.expense + tx.amount);
      }
    }

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
          Text(
            AppStrings.statisticMonthlyCalendar,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  Container(
                    height: 34,
                    color: const Color(0xFFF3F4F6),
                    child: Row(
                      children: const [
                        _WeekdayLabel(text: 'T2'),
                        _WeekdayLabel(text: 'T3'),
                        _WeekdayLabel(text: 'T4'),
                        _WeekdayLabel(text: 'T5'),
                        _WeekdayLabel(text: 'T6'),
                        _WeekdayLabel(text: 'T7'),
                        _WeekdayLabel(text: 'CN'),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1.02,
                        ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final inCurrentMonth = day.month == selectedMonth;
                      final isSelected = _isSameDay(day, selectedDate);
                      final amount =
                          amountMap[DateTime(day.year, day.month, day.day)] ??
                          _DailyAmount.empty();

                      return InkWell(
                        onTap: inCurrentMonth ? () => onDaySelected(day) : null,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF7F4E8)
                                : Colors.white,
                            border: _buildCellBorder(index),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${day.day}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: _dayNumberColor(
                                        inCurrentMonth,
                                        day,
                                      ),
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                              const Spacer(),
                              if (amount.income > 0)
                                Text(
                                  _compactAmount(amount.income),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.info,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (amount.expense > 0)
                                Text(
                                  _compactAmount(amount.expense),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Border _buildCellBorder(int index) {
    final row = index ~/ 7;
    final col = index % 7;

    return Border(
      top: row == 0
          ? const BorderSide(color: AppColors.surfaceBorder)
          : BorderSide.none,
      left: col == 0
          ? const BorderSide(color: AppColors.surfaceBorder)
          : BorderSide.none,
      right: const BorderSide(color: AppColors.surfaceBorder),
      bottom: const BorderSide(color: AppColors.surfaceBorder),
    );
  }

  Color _dayNumberColor(bool inCurrentMonth, DateTime day) {
    if (!inCurrentMonth) return AppColors.textHint;
    if (day.weekday == DateTime.saturday) return AppColors.info;
    if (day.weekday == DateTime.sunday) return AppColors.danger;
    return AppColors.textPrimary;
  }

  List<DateTime> _buildCalendarDays(int year, int month) {
    final first = DateTime(year, month, 1);
    final startWeekday = first.weekday;
    final start = first.subtract(Duration(days: startWeekday - 1));

    return List.generate(42, (i) {
      return DateTime(start.year, start.month, start.day + i);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _compactAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value >= 10000000 ? 0 : 1)}tr';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(value >= 100000 ? 0 : 1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DailyAmount {
  final double income;
  final double expense;

  const _DailyAmount({required this.income, required this.expense});

  factory _DailyAmount.empty() => const _DailyAmount(income: 0, expense: 0);

  _DailyAmount copyWith({double? income, double? expense}) {
    return _DailyAmount(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }
}
