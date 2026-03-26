import 'package:flutter/material.dart';
import '../statistic_utils.dart';

class CategoryRowWidget extends StatelessWidget {
  final String category;
  final String categoryKey;
  final double percentage;
  final double amount;

  const CategoryRowWidget({
    required this.category,
    required this.categoryKey,
    required this.percentage,
    required this.amount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedPercentage = percentage.clamp(0.0, 1.0);
    final icon = categoryIconMap[categoryKey] ?? Icons.category;
    final accentColor =
        categoryColorMap[categoryKey] ?? const Color(0xff2A7C76);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff333333),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TweenAnimationBuilder<double>(
                key: ValueKey<String>('percent_${categoryKey}_$percentage'),
                tween: Tween<double>(begin: 0, end: normalizedPercentage),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, animatedValue, child) {
                  final percentText =
                      '${(animatedValue * 100).toStringAsFixed(1)}%';
                  return Text(
                    percentText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                formatAmount(amount),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              key: ValueKey<String>('bar_${categoryKey}_$percentage'),
              tween: Tween<double>(begin: 0, end: normalizedPercentage),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, child) {
                return LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: accentColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
