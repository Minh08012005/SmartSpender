import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../../data/models/wallet_model.dart';
import '../../data/providers/wallet_provider.dart';
import 'widgets/total_balance_card.dart';
import 'widgets/transfer_modal_widget.dart';
import 'widgets/wallet_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final walletProvider = context.read<WalletProvider>();

    Future.microtask(() {
      walletProvider.fetchWallets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.walletTitle),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          final wallets = walletProvider.wallets;

          if (walletProvider.isLoading && wallets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wallets.isEmpty) {
            return Center(
              child: Text(
                'Không có ví nào',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TotalBalanceCard(totalBalance: walletProvider.totalBalance),
                const SizedBox(height: 24),
                Text(
                  AppStrings.walletListLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wallets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return WalletCard(
                      wallet: wallet,
                      onTap: () => _showTransferModal(context, wallets),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showTransferModal(context, wallets),
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text(AppStrings.walletTransferButtonLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng sẽ được cập nhật'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.walletAddButtonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showTransferModal(
    BuildContext context,
    List<WalletModel> wallets,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransferModalWidget(wallets: wallets),
    );
  }
}
