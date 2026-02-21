import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/transaction_provider.dart';
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

    // Gọi API khi màn hình mở
    Future.microtask(() {
      //context.read<TransactionProvider>().fetchTransactions();
      context.read<TransactionProvider>().loadDummyTransactions(); //dummy_trans
    });
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
    );
  }

  Widget _buildBody(TransactionProvider provider) {
    // 1️⃣ Loading
    if (provider.isLoading) {
      return const HomeLoading();
    }

    // 2️⃣ Error
    if (provider.hasError) {
      return HomeError(
        message: provider.error,
        onRetry: () {
          context.read<TransactionProvider>().loadDummyTransactions();
          // Nếu dùng API thật thì gọi fetchTransactions()
        },
      );
    }

    // 3️⃣ Empty
    if (provider.transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<TransactionProvider>().loadDummyTransactions();
          // Sau này dùng API:
          // await context.read<TransactionProvider>().fetchTransactions();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 100), HomeEmpty()],
        ),
      );
    }

    // 4️⃣ Data
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionProvider>().loadDummyTransactions();
        // Sau này dùng API:
        // await context.read<TransactionProvider>().fetchTransactions();
      },
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
