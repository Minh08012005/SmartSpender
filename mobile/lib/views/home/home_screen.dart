import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/dummy_transactions.dart';
import 'widgets/transaction_item.dart';
import '../../data/models/transaction_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ===== FORMATTER TIỀN VIỆT =====
    final formatter = NumberFormat('#,###', 'vi_VN');

    // ===== TÍNH TOÁN TIỀN =====
    final totalIncome = dummyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpense = dummyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER + BALANCE =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              decoration: const BoxDecoration(
                color: Color(0xff2A7C76),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Good afternoon,',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Enjelin Morgeana',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Color(0xff2A7C76),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== BALANCE CARD =====
                  Container(
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
                        Text(
                          '${formatter.format(totalBalance)} ₫',
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
                              icon: Icons.arrow_downward,
                              title: 'Income',
                              amount: '${formatter.format(totalIncome)} ₫',
                            ),
                            _BalanceInfo(
                              icon: Icons.arrow_upward,
                              title: 'Expenses',
                              amount: '${formatter.format(totalExpense)} ₫',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= TITLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Transactions History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('See all', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================= LIST =================
            Expanded(
              child: ListView.builder(
                itemCount: dummyTransactions.length,
                itemBuilder: (context, index) {
                  return TransactionItem(transaction: dummyTransactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= BALANCE INFO =================
class _BalanceInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;

  const _BalanceInfo({
    required this.icon,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
