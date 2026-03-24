import './models/transaction_model.dart';

final List<TransactionModel> dummyTransactions = [
  // ========== INCOME (Tháng 3/2026) ==========
  TransactionModel(
    id: 't1',
    title: 'Lương tháng 3',
    amount: 8000000,
    category: 'salary',
    date: DateTime(2026, 3, 1),
    note: 'Lương tháng 3/2026',
    type: TransactionType.income,
  ),
  TransactionModel(
    id: 't2',
    title: 'Freelance project',
    amount: 2500000,
    category: 'other',
    date: DateTime(2026, 3, 10),
    note: 'Dự án web design',
    type: TransactionType.income,
  ),
  TransactionModel(
    id: 't3',
    title: 'Thưởng hiệu suất',
    amount: 1500000,
    category: 'other',
    date: DateTime(2026, 3, 15),
    note: 'Thưởng hoàn thành dự án',
    type: TransactionType.income,
  ),

  // ========== EXPENSE - Food (Ăn uống) ==========
  TransactionModel(
    id: 't4',
    title: 'Breakfast tại quán A',
    amount: 45000,
    category: 'food',
    date: DateTime(2026, 3, 2),
    note: 'Cơm tấm',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't5',
    title: 'Lunch tại restorant',
    amount: 125000,
    category: 'food',
    date: DateTime(2026, 3, 3),
    note: 'Ăn trưa',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't6',
    title: 'Dinner gia đình',
    amount: 350000,
    category: 'food',
    date: DateTime(2026, 3, 5),
    note: 'Ăn tối cuối tuần',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't7',
    title: 'Cà phê sáng',
    amount: 35000,
    category: 'food',
    date: DateTime(2026, 3, 8),
    note: 'Cà phê & bánh',
    type: TransactionType.expense,
  ),

  // ========== EXPENSE - Travel (Giao thông) ==========
  TransactionModel(
    id: 't8',
    title: 'Xăng xe máy',
    amount: 250000,
    category: 'travel',
    date: DateTime(2026, 3, 4),
    note: 'Đổ xăng máy',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't9',
    title: 'Grab đi làm',
    amount: 85000,
    category: 'travel',
    date: DateTime(2026, 3, 6),
    note: 'Taxi về nhà',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't10',
    title: 'Vé tàu điện ngầm',
    amount: 60000,
    category: 'travel',
    date: DateTime(2026, 3, 12),
    note: 'Tháng vé tàu',
    type: TransactionType.expense,
  ),

  // ========== EXPENSE - Shopping (Mua sắm) ==========
  TransactionModel(
    id: 't11',
    title: 'Quần áo tại mall',
    amount: 650000,
    category: 'shopping',
    date: DateTime(2026, 3, 9),
    note: 'Áo thun, quần jean',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't12',
    title: 'Giày thể thao',
    amount: 1200000,
    category: 'shopping',
    date: DateTime(2026, 3, 14),
    note: 'Giày Nike',
    type: TransactionType.expense,
  ),

  // ========== EXPENSE - Entertainment (Giải trí) ==========
  TransactionModel(
    id: 't13',
    title: 'Vé xem phim',
    amount: 150000,
    category: 'entertainment',
    date: DateTime(2026, 3, 7),
    note: 'Xem phim rạp',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't14',
    title: 'Game online topup',
    amount: 200000,
    category: 'entertainment',
    date: DateTime(2026, 3, 11),
    note: 'Nạp gem game',
    type: TransactionType.expense,
  ),

  // ========== EXPENSE - Utility (Tiện ích) ==========
  TransactionModel(
    id: 't15',
    title: 'Hóa đơn điện tháng 3',
    amount: 350000,
    category: 'utility',
    date: DateTime(2026, 3, 1),
    note: 'Tiền điện nhà',
    type: TransactionType.expense,
  ),
  TransactionModel(
    id: 't16',
    title: 'Internet & TV',
    amount: 250000,
    category: 'utility',
    date: DateTime(2026, 3, 1),
    note: 'Hóa đơn mạng và TV cáp',
    type: TransactionType.expense,
  ),

  // ========== EXPENSE - Other (Khác) ==========
  TransactionModel(
    id: 't17',
    title: 'Sửa điện thoại',
    amount: 450000,
    category: 'other',
    date: DateTime(2026, 3, 13),
    note: 'Thay pin điện thoại',
    type: TransactionType.expense,
  ),
];
