import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/transaction_model.dart';
import '../../../widgets/category_dropdown.dart';

class EditTransactionForm extends StatefulWidget {
  const EditTransactionForm({
    super.key,
    required this.formKey,
    required this.amountController,
    required this.noteController,
    required this.showValidationErrors,
    required this.selectedType,
    required this.selectedCategory,
    required this.categoryOptions,
    required this.dateText,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onPickDate,
    required this.onSubmit,
    required this.validateAmount,
    required this.validateNote,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final bool showValidationErrors;
  final TransactionType selectedType;
  final String selectedCategory;
  final List<String> categoryOptions;
  final String dateText;
  final bool isLoading;
  final ValueChanged<TransactionType?> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;
  final String? Function(String?) validateAmount;
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
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                validator: widget.validateAmount,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: widget.selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text('Income'),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text('Expense'),
                  ),
                ],
                onChanged: widget.onTypeChanged,
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
                    labelText: 'Date',
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
                  labelText: 'Note',
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
                  onPressed:
                      (widget.isLoading || !_isFormValid)
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
                      : const Text('Update Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
