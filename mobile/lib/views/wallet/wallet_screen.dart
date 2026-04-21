import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../../data/models/wallet_model.dart';
import '../../data/providers/wallet_provider.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
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
    const teal = AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.walletTitle)),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          final wallets = walletProvider.wallets;

          if (walletProvider.isLoading && wallets.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: teal));
          }

          if (wallets.isEmpty) {
            return Center(
              child: Text(
                'Không có ví nào',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionReveal(
                  delayMs: 0,
                  child: TotalBalanceCard(
                    totalBalance: walletProvider.totalBalance,
                  ),
                ),
                const SizedBox(height: 24),
                SectionReveal(
                  delayMs: 90,
                  child: Text(
                    AppStrings.walletListLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SectionReveal(
                  delayMs: 130,
                  child: ListView.separated(
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
                ),
                const SizedBox(height: 24),
                SectionReveal(
                  delayMs: 180,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () =>
                                _showTransferModal(context, wallets),
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text(
                              AppStrings.walletTransferButtonLabel,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: teal,
                              side: const BorderSide(color: teal),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    AppStrings.walletFeatureComingSoon,
                                  ),
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
                  ),
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
