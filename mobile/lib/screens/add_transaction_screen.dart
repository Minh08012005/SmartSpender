import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final _noteController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
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
      return 'So tien la bat buoc';
    }

    final amount = _parseAmount(value);
    if (amount == null) {
      return 'So tien khong hop le';
    }
    if (amount <= 0) {
      return 'So tien phai lon hon 0';
    }
    if (amount > TransactionModel.maxAmount) {
      return 'So tien khong duoc vuot qua 1 ty';
    }

    return null;
  }

  String? _validateNote(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > TransactionModel.maxNoteLength) {
      return 'Ghi chu toi da 200 ky tu';
    }

    return null;
  }

  String? _validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Danh muc la bat buoc';
    }
    if (!TransactionModel.isCategoryValid(_selectedType, value)) {
      return 'Danh muc khong hop le voi loai giao dich';
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
      category: _selectedCategory,
      date: _selectedDate ?? DateTime.now(),
      note: _noteController.text.trim(),
    );

    final provider = context.read<TransactionProvider>();
    final success = await provider.addTransaction(transaction);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Them giao dich thanh cong')),
      );
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.error.isEmpty
              ? 'Khong the them giao dich'
              : provider.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd/MM/yyyy').format(_selectedDate ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Them giao dich'),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'So tien',
                      hintText: 'Nhap so tien',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TransactionType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Loai giao dich',
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
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Danh muc',
                      border: OutlineInputBorder(),
                    ),
                    items: _categoryOptions
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
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
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Ngay giao dich',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(dateText),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    maxLength: TransactionModel.maxNoteLength,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chu (khong bat buoc)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateNote,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _submit,
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Luu giao dich'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
