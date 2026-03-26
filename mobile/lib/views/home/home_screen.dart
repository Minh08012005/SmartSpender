import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/wallet_provider.dart';
import '../../core/strings.dart';
import '../../screens/all_transactions_screen.dart';
import '../../screens/add_transaction_screen.dart';
import '../../screens/edit_transaction_screen.dart';
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
    Future.microtask(_loadTransactions);
  }

  /// Load transactions (used for initial load and retry)
  void _loadTransactions() {
    final now = DateTime.now();
    Future.wait([
      context.read<TransactionProvider>().fetchTransactions(
        month: now.month,
        year: now.year,
      ),
      context.read<WalletProvider>().fetchWallets(forceRefresh: true),
    ]);
  }

  /// Refresh transactions (used for pull-to-refresh)
  Future<void> _refreshTransactions() async {
    final now = DateTime.now();
    await Future.wait([
      context.read<TransactionProvider>().fetchTransactions(
        month: now.month,
        year: now.year,
      ),
      context.read<WalletProvider>().fetchWallets(forceRefresh: true),
    ]);
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

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.homeTransactionHistory,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllTransactionsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      AppStrings.homeSeeAll,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
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
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );

          if (created == true && context.mounted) {
            await _refreshTransactions();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    // 1️⃣ Loading
    if (provider.isLoading && provider.transactions.isEmpty) {
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
          final transaction = provider.transactions[index];
          return TransactionItem(
            transaction: transaction,
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditTransactionScreen(transaction: transaction),
                ),
              );

              if (updated == true && context.mounted) {
                await _refreshTransactions();
              }
            },
          );
        },
      ),
    );
  }
}
