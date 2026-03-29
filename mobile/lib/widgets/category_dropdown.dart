import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../data/models/transaction_model.dart';

class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    super.key,
    required this.value,
    required this.categories,
    required this.onChanged,
    this.labelText = AppStrings.category,
  });

  final String? value;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(Object.hash(value, Object.hashAll(categories))),
      initialValue: value,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(TransactionModel.formatCategoryForUi(category)),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected.isEmpty) {
          return AppStrings.pleaseSelectCategory;
        }
        return null;
      },
    );
  }
}
