import 'package:flutter/material.dart';
import '../../../core/strings.dart';
import '../statistic_utils.dart';

class PeriodPickerWidget extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final Future<void> Function(int month, int year) onChanged;

  const PeriodPickerWidget({
    required this.selectedMonth,
    required this.selectedYear,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = getMonthName(selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: Color(0xff2A7C76)),
          const SizedBox(width: 8),
          Text(
            '$monthName $selectedYear',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xff333333),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              await onChanged(now.month, now.year);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              AppStrings.statisticCurrentMonth,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff2A7C76),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final now = DateTime.now();
              final prev = DateTime(now.year, now.month - 1, 1);
              await onChanged(prev.month, prev.year);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              AppStrings.statisticPreviousMonth,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff2A7C76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
