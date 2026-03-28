import 'package:flutter/material.dart';
import '../../../core/strings.dart';
import '../../../theme/colors.dart';
import '../statistic_utils.dart';

class PeriodPickerWidget extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final Future<void> Function(int month, int year) onChanged;
  final bool isBusy;

  const PeriodPickerWidget({
    required this.selectedMonth,
    required this.selectedYear,
    required this.onChanged,
    this.isBusy = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = getMonthName(selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isBusy ? null : () => _pickMonth(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '$monthName $selectedYear',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (isBusy)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
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
                  color: AppColors.primary,
                ),
              ),
            ),
          TextButton(
            onPressed: isBusy
                ? null
                : () async {
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
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await _showMonthYearPicker(context);

    if (picked == null) return;

    await onChanged(picked.month, picked.year);
  }

  Future<DateTime?> _showMonthYearPicker(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List<int>.generate(8, (index) => 2020 + index)
      ..removeWhere((y) => y > currentYear + 1);

    int tempYear = selectedYear;
    int tempMonth = selectedMonth;

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.statisticSelectMonth,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: tempYear,
                    decoration: InputDecoration(
                      labelText: AppStrings.year,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: years
                        .map(
                          (year) => DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        tempYear = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(12, (index) {
                      final month = index + 1;
                      final isSelected = tempMonth == month;

                      return ChoiceChip(
                        label: Text('T$month'),
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            tempMonth = month;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
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
                            Navigator.pop(
                              context,
                              DateTime(tempYear, tempMonth, 1),
                            );
                          },
                          child: const Text(AppStrings.apply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
