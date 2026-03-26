import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/wallet_model.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback onTap;

  const WalletCard({super.key, required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon với background color
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: wallet.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(wallet.icon, color: wallet.color, size: 28),
              ),
              const SizedBox(width: 16),
              // Wallet name + balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(wallet.balance),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  /// Format số tiền sang dạng tiền tệ VND
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }
}
