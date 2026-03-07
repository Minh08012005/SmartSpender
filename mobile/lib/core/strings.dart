class AppStrings {
  const AppStrings._();

  // Validation messages
  static const String amountRequired = 'Amount is required';
  static const String invalidAmount = 'Invalid amount';
  static const String amountMustBeGreaterThanZero = 'Amount must be greater than 0';
  static const String amountMustNotExceedOneBillion = 'Amount must not exceed 1 billion';
  static const String noteMustNotExceed200Characters =
      'Note must not exceed 200 characters';
  static const String titleRequired = 'Title is required';
  static const String titleMustNotExceed100Characters =
      'Title must not exceed 100 characters';
  static const String pleaseSelectCategory = 'Please select a category';
  static const String categoryInvalidForSelectedTransactionType =
      'Category is not valid for selected transaction type';

  // Snackbar and feedback messages
  static const String transactionAddedSuccessfully =
      'Transaction added successfully';
  static const String failedToAddTransaction = 'Failed to add transaction';
  static const String transactionUpdatedSuccessfully =
      'Transaction updated successfully';
  static const String cannotUpdateTransaction = 'Cannot update transaction';
}