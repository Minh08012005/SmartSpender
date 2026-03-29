import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/strings.dart';
import '../../../data/models/transaction_model.dart';
import '../../../widgets/category_dropdown.dart';

class EditTransactionForm extends StatefulWidget {
  const EditTransactionForm({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.titleController,
    required this.noteController,
    required this.showValidationErrors,
    required this.selectedType,
    required this.selectedWalletType,
    required this.selectedCategory,
    required this.categoryOptions,
    required this.dateText,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onWalletTypeChanged,
    required this.onCategoryChanged,
    required this.onPickDate,
    required this.onSubmit,
    required this.onDelete,
    required this.validateAmount,
    required this.validateTitle,
    required this.validateNote,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final bool showValidationErrors;
  final TransactionType selectedType;
  final WalletType selectedWalletType;
  final String selectedCategory;
  final List<String> categoryOptions;
  final String dateText;
  final bool isLoading;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<WalletType?> onWalletTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;
  final String? Function(String?) validateAmount;
  final String? Function(String?) validateTitle;
  final String? Function(String?) validateNote;

  @override
  State<EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormValidity();
    });
  }

  void _updateFormValidity() {
    final isValid = widget.formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teal = Colors.teal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        onChanged: _updateFormValidity,
        autovalidateMode: widget.showValidationErrors
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: IgnorePointer(
          ignoring: widget.isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: AppStrings.amountLabel,
                  border: OutlineInputBorder(),
                ),
                validator: widget.validateAmount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.titleController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: AppStrings.title,
                  hintText: AppStrings.titleHint,
                  border: OutlineInputBorder(),
                ),
                validator: widget.validateTitle,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                key: ValueKey(widget.selectedType),
                initialValue: widget.selectedType,
                decoration: const InputDecoration(
                  labelText: AppStrings.transactionType,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text(AppStrings.income),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text(AppStrings.expense),
                  ),
                ],
                onChanged: widget.onTypeChanged,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WalletType>(
                key: ValueKey(widget.selectedWalletType),
                initialValue: widget.selectedWalletType,
                decoration: const InputDecoration(
                  labelText: AppStrings.transactionWallet,
                  border: OutlineInputBorder(),
                ),
                items: WalletType.values
                    .map(
                      (walletType) => DropdownMenuItem<WalletType>(
                        value: walletType,
                        child: Text(
                          TransactionModel.walletTypeLabel(walletType),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: widget.onWalletTypeChanged,
              ),
              const SizedBox(height: 16),
              CategoryDropdown(
                value: widget.selectedCategory,
                categories: widget.categoryOptions,
                onChanged: widget.onCategoryChanged,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: widget.onPickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: AppStrings.date,
                    border: OutlineInputBorder(),
                  ),
                  child: Text(widget.dateText, style: TextStyle(color: teal)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.noteController,
                maxLength: TransactionModel.maxNoteLength,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.note,
                  border: OutlineInputBorder(),
                ),
                validator: widget.validateNote,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (widget.isLoading || !_isFormValid)
                      ? null
                      : widget.onSubmit,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(AppStrings.updateTransaction),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: widget.isLoading ? null : widget.onDelete,
                  child: const Text(AppStrings.deleteTransaction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
