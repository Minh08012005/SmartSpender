import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../screens/add_transaction_screen.dart';
import '../../screens/edit_transaction_screen.dart';
import 'widgets/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Feature #34: initial fetch when Home is first opened.
    Future.microtask(_loadTransactions);
  }

  /// Load transactions (used for initial load and retry)
  void _loadTransactions() {
    // Feature #34: call real transactions API with current month/year filter.
    context.read<TransactionProvider>().fetchTransactions(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );
  }

  /// Refresh transactions (used for pull-to-refresh)
  Future<void> _refreshTransactions() async {
    // Feature #34: pull-to-refresh triggers API refetch.
    await context.read<TransactionProvider>().fetchTransactions(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );
  }

  /// Open Add Transaction Screen
  Future<void> _openAddTransactionScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
    );

    if (result == true && mounted) {
      // Refresh after successful add
      await _refreshTransactions();
    }
  }

  /// Open Edit Transaction Screen
  Future<void> _openEditTransactionScreen(index) async {
    final provider = context.read<TransactionProvider>();
    final transaction = provider.transactions[index];

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );

    if (result == true && mounted) {
      // Refresh after successful edit
      await _refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final formatter = NumberFormat('#,###', 'vi_VN');

    final totalIncome = provider.totalIncome;
    final totalExpense = provider.totalExpense;
    final totalBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(
              formatter: formatter,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              totalBalance: totalBalance,
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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

            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransactionScreen(),
        backgroundColor: const Color(0xff2A7C76),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader({
    required NumberFormat formatter,
    required double totalIncome,
    required double totalExpense,
    required double totalBalance,
  }) {
    return Container(
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good afternoon,',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SmartSpender User',
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
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    // Feature #34 state flow: Loading -> Error -> Empty -> Data.
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasError) {
      return RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    provider.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadTransactions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (provider.transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTransactions,
      child: ListView.builder(
        // Feature #34: long-list rendering with builder for performance.
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(
            transaction: provider.transactions[index],
            onTap: () => _openEditTransactionScreen(index),
          );
        },
      ),
    );
  }
}

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
