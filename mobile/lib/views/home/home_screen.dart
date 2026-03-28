import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/wallet_provider.dart';
import '../../core/strings.dart';
import '../../screens/all_transactions_screen.dart';
import '../../screens/add_transaction_screen.dart';
import '../../screens/edit_transaction_screen.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SectionReveal(delayMs: 0, child: BalanceCard()),
            const SizedBox(height: 20),

            SectionReveal(
              delayMs: 90,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.homeTransactionHistory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
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
                      child: Text(
                        AppStrings.homeSeeAll,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: SectionReveal(delayMs: 140, child: _buildBody(provider)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 180 + (index * 40).clamp(0, 240)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * 8),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: TransactionItem(
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
            ),
          );
        },
      ),
    );
  }
}
