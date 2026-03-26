import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/strings.dart';
import '../../../data/models/wallet_model.dart';
import '../../../data/providers/wallet_provider.dart';

class TransferModalWidget extends StatefulWidget {
  final List<WalletModel> wallets;

  const TransferModalWidget({super.key, required this.wallets});

  @override
  State<TransferModalWidget> createState() => _TransferModalWidgetState();
}

class _TransferModalWidgetState extends State<TransferModalWidget> {
  String? _selectedFromWalletId;
  String? _selectedToWalletId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isConfirmed = false;
  bool _isProcessing = false;

  bool get _isAmountValid {
    final parsedAmount = _parseAmount(_amountController.text);
    return parsedAmount != null && parsedAmount > 0;
  }

  bool get _canSubmit => _isConfirmed && _isAmountValid;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TITLE =====
                Center(
                  child: Text(
                    AppStrings.walletTransferModalTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ===== FORM =====

                // From Wallet Dropdown
                _buildDropdownField(
                  label: AppStrings.walletFromLabel,
                  value: _selectedFromWalletId,
                  onChanged: (value) {
                    setState(() {
                      _selectedFromWalletId = value;
                      // Auto clear toWallet nếu trùng
                      if (value == _selectedToWalletId) {
                        _selectedToWalletId = null;
                      }
                    });
                  },
                  items: widget.wallets,
                ),
                const SizedBox(height: 16),

                // To Wallet Dropdown
                _buildDropdownField(
                  label: AppStrings.walletToLabel,
                  value: _selectedToWalletId,
                  onChanged: (value) {
                    setState(() {
                      _selectedToWalletId = value;
                    });
                  },
                  items: widget.wallets,
                  excludeId: _selectedFromWalletId,
                ),
                const SizedBox(height: 16),

                // Amount Input
                TextField(
                  controller: _amountController,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppStrings.walletAmountLabel,
                    hintText: AppStrings.amountHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.money),
                  ),
                ),
                const SizedBox(height: 16),

                // Note Input (optional)
                TextField(
                  controller: _noteController,
                  maxLines: null,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: AppStrings.walletNoteLabel,
                    hintText: 'Ví dụ: Chuyển tiền dự phòng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 16),

                // Checkbox Confirm
                CheckboxListTile(
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                  title: Text(
                    AppStrings.walletConfirmCheckboxLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // ===== ERROR MESSAGE (nếu có) =====
                if (walletProvider.hasError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      walletProvider.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                if (walletProvider.hasError) const SizedBox(height: 16),

                // ===== BUTTON GROUP =====
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(AppStrings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing || !_canSubmit
                            ? null
                            : () => _handleTransfer(walletProvider),
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(AppStrings.walletConfirmButtonLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build dropdown field
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    required List<WalletModel> items,
    String? excludeId,
  }) {
    final filteredItems = excludeId != null
        ? items.where((w) => w.id != excludeId).toList()
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: filteredItems
              .map(
                (wallet) => DropdownMenuItem(
                  value: wallet.id,
                  child: Row(
                    children: [
                      Icon(wallet.icon, color: wallet.color, size: 20),
                      const SizedBox(width: 8),
                      Text(wallet.name),
                      const SizedBox(width: 8),
                      Text(
                        _formatCurrency(wallet.balance),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          hint: const Text('Chọn ví'),
        ),
      ],
    );
  }

  /// Handle transfer logic
  Future<void> _handleTransfer(WalletProvider walletProvider) async {
    // Clear previous error
    walletProvider.clearError();

    // Get amount
    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.amountRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = _parseAmount(amountStr);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.invalidAmount),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFromWalletId == null || _selectedToWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.walletPleaseSelectWallet),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Execute transfer
    final success = await walletProvider.transferBetweenWallets(
      fromWalletId: _selectedFromWalletId!,
      toWalletId: _selectedToWalletId!,
      amount: amount,
      note: _noteController.text.trim(),
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (success) {
      // Show success snackbar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.walletTransferSuccess),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      // Close modal
      if (mounted) Navigator.pop(context);
    } else {
      // Error message displayed by provider
      // Modal stays open để user fix lỗi
    }
  }

  /// Format số tiền sang dạng tiền tệ VND
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  int? _parseAmount(String input) {
    final normalized = input.trim().replaceAll('.', '').replaceAll(',', '');
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }
}
