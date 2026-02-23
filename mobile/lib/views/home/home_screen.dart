import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/dummy_transactions.dart';
import '../../data/models/transaction_model.dart';
import '../../screens/add_transaction_screen.dart';
import 'widgets/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    final totalIncome = dummyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (sum, t) => sum + t.amount);

    // TODO: Switch to fetchTransactions() when Backend Task #33 CRUD is completed
    Future.microtask(_loadTransactions);
  }

  /// Load transactions (used for initial load and retry)
  void _loadTransactions() {
    context.read<TransactionProvider>().loadDummyTransactions();
  }

  /// Refresh transactions (used for pull-to-refresh)
  Future<void> _refreshTransactions() async {
    // TODO: Replace with fetchTransactions() when API is ready
    context.read<TransactionProvider>().loadDummyTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
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
                          '${formatter.format(totalBalance)} VND',
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
                              amount: '${formatter.format(totalIncome)} VND',
                            ),
                            _BalanceInfo(
                              icon: Icons.arrow_upward,
                              title: 'Expenses',
                              amount: '${formatter.format(totalExpense)} VND',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transactions History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('See all', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2A7C76),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

class _BalanceInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;

    // 2️⃣ Error
    if (provider.hasError) {
      return HomeError(message: provider.error, onRetry: _loadTransactions);
    }

    // 3️⃣ Empty
    if (provider.transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 100), HomeEmpty()],
        ),
      );
    }

    // 4️⃣ Data
    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(transaction: provider.transactions[index]);
        },
      ),
    );
  }
}
