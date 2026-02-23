import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile/data/providers/transaction_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
      decoration: const BoxDecoration(
        color: Color(0xff2A7C76),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff3E8E89), Color(0xff2A7C76)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),

            /// ✅ SỬA Ở ĐÂY
            Text(
              '${formatter.format(provider.balance)} ₫',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _BalanceInfo(
                  title: 'Income',
                  amount: '${formatter.format(provider.totalIncome)} ₫',
                ),
                _BalanceInfo(
                  title: 'Expenses',
                  amount: '${formatter.format(provider.totalExpense)} ₫',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceInfo extends StatelessWidget {
  final String title;
  final String amount;

  const _BalanceInfo({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
