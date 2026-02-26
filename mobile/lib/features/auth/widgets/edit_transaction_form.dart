import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/transaction_model.dart';
import '../../../widgets/category_dropdown.dart';

class EditTransactionForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final teal = Colors.teal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode: showValidationErrors
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: IgnorePointer(
          ignoring: isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: amountController,
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
                validator: validateAmount,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: selectedType,
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
                onChanged: onTypeChanged,
              ),
              const SizedBox(height: 16),
              CategoryDropdown(
                value: selectedCategory,
                categories: categoryOptions,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: onPickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(dateText, style: TextStyle(color: teal)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                maxLength: TransactionModel.maxNoteLength,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                validator: validateNote,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading ? null : onSubmit,
                  child: isLoading
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
