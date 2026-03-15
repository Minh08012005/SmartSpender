import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/transaction_model.dart';
import '../data/providers/transaction_provider.dart';
import '../features/auth/widgets/edit_transaction_form.dart';
import '../core/strings.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
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
    _selectedCategory =
        TransactionModel.isCategoryValid(transaction.type, transaction.category)
        ? transaction.category
        : TransactionModel.defaultCategoryFor(transaction.type);
    _selectedDate = transaction.date;
    final formatted = (transaction.amount % 1 == 0)
        ? transaction.amount.toStringAsFixed(0)
        : transaction.amount.toStringAsFixed(2);
    _amountController.text = formatted;
    _titleController.text = transaction.title;
    _noteController.text = transaction.note;
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

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCategory = value;
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

  Future<void> _submit() async {
    final provider = context.read<TransactionProvider>();
    if (provider.isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }
    // Add explicit category check
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.pleaseSelectCategory)));
      return;
    }

    FocusScope.of(context).unfocus();

    final amount = _parseAmount(_amountController.text.trim());
    if (amount == null) return;

    final transaction = widget.transaction.copyWith(
      amount: amount,
      type: _selectedType,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      note: _noteController.text.trim(),
    );

    final success = await provider.updateTransaction(transaction);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.transactionUpdatedSuccessfully)),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error.isEmpty ? AppStrings.cannotUpdateTransaction : provider.error,
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
            return EditTransactionForm(
              formKey: _formKey,
              amountController: _amountController,
              titleController: _titleController,
              noteController: _noteController,
              showValidationErrors: _showValidationErrors,
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              categoryOptions: _categoryOptions,
              dateText: dateText,
              isLoading: provider.isLoading,
              onTypeChanged: _onTypeChanged,
              onCategoryChanged: _onCategoryChanged,
              onPickDate: _pickDate,
              onSubmit: _submit,
              validateAmount: _validateAmount,
              validateTitle: _validateTitle,
              validateNote: _validateNote,
            );
          },
        ),
      ),
    );
  }
}
