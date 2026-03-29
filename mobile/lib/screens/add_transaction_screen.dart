import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../data/models/transaction_model.dart';
import '../data/providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  WalletType _selectedWalletType = WalletType.cash;
  late String _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedCategory = TransactionModel.defaultCategoryFor(_selectedType);
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
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
      return AppStrings.amountRequired;
    }

    final amount = _parseAmount(value);
    if (amount == null) {
      return AppStrings.invalidAmount;
    }
    if (amount <= 0) {
      return AppStrings.amountMustBeGreaterThanZero;
    }
    if (amount > TransactionModel.maxAmount) {
      return AppStrings.amountMustNotExceedOneBillion;
    }

    return null;
  }

  String? _validateNote(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > TransactionModel.maxNoteLength) {
      return AppStrings.noteMustNotExceed200Characters;
    }

    return null;
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) {
      return AppStrings.titleRequired;
    }
    if (title.length > 100) {
      return AppStrings.titleMustNotExceed100Characters;
    }
    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.pleaseSelectCategory;
    }
    if (!TransactionModel.isCategoryValid(_selectedType, value)) {
      return AppStrings.categoryInvalidForSelectedTransactionType;
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _parseAmount(_amountController.text.trim());
    if (amount == null) return;

    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      type: _selectedType,
      walletType: _selectedWalletType,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      note: _noteController.text.trim(),
    );

    final provider = context.read<TransactionProvider>();
    final success = await provider.addTransaction(transaction);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.transactionAddedSuccessfully)),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error.isEmpty
              ? AppStrings.failedToAddTransaction
              : provider.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      'dd/MM/yyyy',
    ).format(_selectedDate ?? DateTime.now());
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
            borderSide: BorderSide(color: teal.withAlpha(128)),
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
          title: const Text(AppStrings.addTransaction),
        ),
        body: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: AppStrings.amountLabel,
                        hintText: AppStrings.amountHint,
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateAmount,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TransactionType>(
                      initialValue: _selectedType,
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
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: AppStrings.category,
                        border: OutlineInputBorder(),
                      ),
                      items: _categoryOptions
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                TransactionModel.formatCategoryForUi(category),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: _validateCategory,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<WalletType>(
                      initialValue: _selectedWalletType,
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
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedWalletType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: AppStrings.title,
                        hintText: AppStrings.titleHint,
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateTitle,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.date,
                          border: OutlineInputBorder(),
                        ),
                        child: Text(dateText, style: TextStyle(color: teal)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLength: TransactionModel.maxNoteLength,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: AppStrings.note,
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
                            : const Text(AppStrings.saveTransaction),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
