import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../screens/add_transaction_screen.dart';
import 'widgets/transaction_item.dart';
import 'widgets/balance_card.dart';
import 'states/home_loading.dart';
import 'states/home_error.dart';
import 'states/home_empty.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // TODO: Switch to fetchTransactions() when Backend Task #33 CRUD is completed
    Future.microtask(_loadTransactions);
  }

  /// Load transactions (used for initial load and retry)
  void _loadTransactions() {
    // Switch to real API fetch
    context.read<TransactionProvider>().fetchTransactions(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );
  }

  /// Refresh transactions (used for pull-to-refresh)
  Future<void> _refreshTransactions() async {
    // Refresh from real API
    await context.read<TransactionProvider>().fetchTransactions(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const BalanceCard(),
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
        backgroundColor: const Color(0xff2A7C76),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    // 1️⃣ Loading
    if (provider.isLoading) {
      return const HomeLoading();
    }

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
