import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/transaction_model.dart';
import '../data/providers/transaction_provider.dart';
import '../widgets/category_dropdown.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showValidationErrors = false;

  late TransactionType _selectedType;
  late String _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    _selectedType = transaction.type;
    _selectedCategory = TransactionModel.isCategoryValid(
      transaction.type,
      transaction.category,
    )
        ? transaction.category
        : TransactionModel.defaultCategoryFor(transaction.type);
    _selectedDate = transaction.date;
    _amountController.text = transaction.amount.toStringAsFixed(0);
    _noteController.text = transaction.note;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _categoryOptions {
    return TransactionModel.categoriesByType[_selectedType] ?? [];
  }

  void _onTypeChanged(TransactionType? value) {
    if (value == null) return;

    setState(() {
      _selectedType = value;
      _selectedCategory = TransactionModel.defaultCategoryFor(_selectedType);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  double? _parseAmount(String input) {
    final normalized = input.replaceAll(RegExp(r'[^0-9.]'), '');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số tiền là bắt buộc';
    }

    final amount = _parseAmount(value);
    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }
    if (amount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }
    if (amount > TransactionModel.maxAmount) {
      return 'Số tiền không được vượt quá 1 tỷ';
    }

    return null;
  }

  String? _validateNote(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > TransactionModel.maxNoteLength) {
      return 'Ghi chú tối đa 200 ký tự';
    }

    return null;
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }
    FocusScope.of(context).unfocus();

    final amount = _parseAmount(_amountController.text.trim());
    if (amount == null) return;

    final transaction = widget.transaction.copyWith(
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate ?? DateTime.now(),
      note: _noteController.text.trim(),
    );

    final provider = context.read<TransactionProvider>();
    final success = await provider.updateTransaction(transaction);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật giao dịch thành công')),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error.isEmpty
              ? 'Không thể cập nhật giao dịch'
              : provider.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat('dd/MM/yyyy').format(_selectedDate ?? DateTime.now());
    final baseTheme = Theme.of(context);
    final teal = Colors.teal;

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: teal,
          secondary: teal,
        ),
        inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
          labelStyle: TextStyle(color: teal),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: teal.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: teal, width: 2),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          title: const Text('Edit Transaction'),
        ),
        body: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: _showValidationErrors
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: IgnorePointer(
                  ignoring: provider.isLoading,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TransactionType>(
                      value: _selectedType,
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
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 16),
                    CategoryDropdown(
                      value: _selectedCategory,
                      categories: _categoryOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          dateText,
                          style: TextStyle(color: teal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLength: TransactionModel.maxNoteLength,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateNote,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: provider.isLoading ? null : _submit,
                        child: provider.isLoading
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
                )),
              ),
            );
          },
        ),
      ),
    );
  }
}
