import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../data/providers/transaction_provider.dart';
import '../screens/edit_transaction_screen.dart';
import '../views/home/states/home_empty.dart';
import '../views/home/states/home_error.dart';
import '../views/home/states/home_loading.dart';
import '../views/home/widgets/transaction_item.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  Future<void> _refreshTransactions() async {
    final now = DateTime.now();
    await context.read<TransactionProvider>().fetchTransactions(
      month: now.month,
      year: now.year,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xff2A7C76),
        foregroundColor: Colors.white,
        title: const Text(AppStrings.allTransactionsTitle),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    if (provider.isLoading && provider.transactions.isEmpty) {
      return const HomeLoading();
    }

    if (provider.hasError) {
      return HomeError(message: provider.error, onRetry: _refreshTransactions);
    }

    if (provider.transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 100), HomeEmpty()],
        ),
      );
    }

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
