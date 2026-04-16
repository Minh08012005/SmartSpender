import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/models/group_model.dart';
import '../data/models/transaction_model.dart';
import '../data/providers/transaction_provider.dart';
import '../theme/colors.dart';

class GroupTransactionsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupTransactionsScreen({required this.group, super.key});

  @override
  State<GroupTransactionsScreen> createState() =>
      _GroupTransactionsScreenState();
}

class _GroupTransactionsScreenState extends State<GroupTransactionsScreen> {
  TransactionType? _selectedType;
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Danh sách giao dịch',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ===== FILTER BAR =====
          _buildFilterBar(context),

          // ===== TRANSACTIONS LIST =====
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, _) {
                var transactions = transactionProvider.transactions;

                // Apply filters
                if (_selectedType != null) {
                  transactions = transactions
                      .where((t) => t.type == _selectedType)
                      .toList();
                }

                if (_selectedCategory != null) {
                  transactions = transactions
                      .where((t) => t.category == _selectedCategory)
                      .toList();
                }

                if (_selectedDate != null) {
                  transactions = transactions
                      .where(
                        (t) =>
                            t.date.year == _selectedDate!.year &&
                            t.date.month == _selectedDate!.month &&
                            t.date.day == _selectedDate!.day,
                      )
                      .toList();
                }

                // Sort by date descending
                transactions.sort((a, b) => b.date.compareTo(a.date));

                if (transactions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _buildTransactionCard(context, transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===== FILTER BAR =====
  Widget _buildFilterBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ===== TYPE FILTER =====
            SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => _showTypeFilterSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedType != null
                        ? AppColors.primarySoft
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedType != null
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Loại',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedType == null
                            ? 'Tất cả'
                            : _selectedType == TransactionType.income
                            ? 'Thu'
                            : 'Chi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedType != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ===== CATEGORY FILTER =====
            SizedBox(
              width: 110,
              child: GestureDetector(
                onTap: () => _showCategoryFilterSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedCategory != null
                        ? AppColors.primarySoft
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedCategory != null
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedCategory == null
                            ? 'Tất cả'
                            : TransactionModel.formatCategoryForUi(
                                _selectedCategory!,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedCategory != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ===== DATE FILTER =====
            SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => _pickDate(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedDate != null
                        ? AppColors.primarySoft
                        : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedDate != null
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Ngày',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDate == null
                            ? 'Tất cả'
                            : DateFormat('dd/MM').format(_selectedDate!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _selectedDate != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ===== CLEAR FILTERS BUTTON =====
            if (_selectedType != null ||
                _selectedCategory != null ||
                _selectedDate != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = null;
                    _selectedCategory = null;
                    _selectedDate = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: AppColors.danger,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===== TRANSACTION CARD =====
  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final isIncome = transaction.type == TransactionType.income;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showTransactionDetail(context, transaction);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ===== CATEGORY EMOJI ICON =====
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.successSoft
                        : AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryEmoji(transaction.category),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ===== TITLE & CATEGORY =====
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            transaction.categoryForUi,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy').format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ===== AMOUNT & DELETE BUTTON =====
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isIncome
                          ? '+${_formatCurrency(transaction.amount)}'
                          : '-${_formatCurrency(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isIncome ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () =>
                          _showDeleteConfirmation(context, transaction),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy giao dịch',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc của bạn',
            style: TextStyle(fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ===== FILTER SHEETS =====
  void _showTypeFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loại giao dịch',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Tất cả', null, _selectedType),
            _buildFilterOption(
              'Thu nhập',
              TransactionType.income,
              _selectedType,
            ),
            _buildFilterOption(
              'Chi tiêu',
              TransactionType.expense,
              _selectedType,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilterSheet(BuildContext context) {
    final categories = _selectedType == null
        ? TransactionModel.categoriesByType[TransactionType.expense]!
        : TransactionModel.categoriesByType[_selectedType]!;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterOption('Tất cả', null, _selectedCategory),
            for (var category in categories)
              _buildFilterOption(
                TransactionModel.formatCategoryForUi(category),
                category,
                _selectedCategory,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, dynamic value, dynamic currentValue) {
    final isSelected = value == currentValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (currentValue == value) {
            if (value is TransactionType) {
              _selectedType = null;
            } else if (value is String) {
              _selectedCategory = null;
            }
          } else {
            if (value is TransactionType) {
              _selectedType = value;
            } else if (value is String) {
              _selectedCategory = value;
            }
          }
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ===== DATE PICKER =====
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // ===== TRANSACTION DETAIL DIALOG =====
  void _showTransactionDetail(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết giao dịch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Tiêu đề', transaction.title),
            const SizedBox(height: 12),
            _detailRow('Danh mục', transaction.categoryForUi),
            const SizedBox(height: 12),
            _detailRow(
              'Số tiền',
              _formatCurrency(transaction.amount),
              isAmount: true,
              isIncome: transaction.type == TransactionType.income,
            ),
            const SizedBox(height: 12),
            _detailRow('Ngày', transaction.formattedDate),
            const SizedBox(height: 12),
            _detailRow(
              'Ví',
              TransactionModel.walletTypeLabel(transaction.walletType),
            ),
            if (transaction.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow('Ghi chú', transaction.note),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool isAmount = false,
    bool isIncome = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isAmount
                  ? (isIncome ? AppColors.success : AppColors.danger)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ===== DELETE CONFIRMATION =====
  void _showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa giao dịch này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // ===== HELPER FUNCTIONS =====
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} ₫';
  }

  String _getCategoryEmoji(String category) {
    const emojiMap = {
      'salary': '💰',
      'food': '🍽️',
      'travel': '🚗',
      'shopping': '🛍️',
      'entertainment': '🎬',
      'utility': '⚡',
      'other': '📌',
    };
    return emojiMap[category] ?? '📌';
  }
}
