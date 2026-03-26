/**
 * Transaction Seed Script
 * ------------------------
 * Mục tiêu:
 * - Tạo khoảng 20 giao dịch mẫu (income/expense)
 * - Không hard-code USER_ID
 * - Random category + random date để dễ test filter theo tháng
 * - Đóng connection clean sau khi chạy xong
 */

require('dotenv').config();

// Import MongoDB & Models
const mongoose = require('mongoose');
const Transaction = require('../models/transaction_schema');
const User = require('../models/users.model'); // đúng tên file User model của bạn

// ============================================================
// CATEGORY LISTS - Tách riêng theo loại giao dịch
// ============================================================
// Lý do: Trong thực tế, "salary" chỉ là income, "food" chỉ là expense
// Nếu dùng chung 1 list → có thể tạo data vô lý như "Salary expense"
// IMPORTANT: Categories phải match với VALID_CATEGORIES trong validators/constants.js
const incomeCategories = ['salary', 'other'];
const expenseCategories = [
  'food',
  'travel',
  'shopping',
  'entertainment',
  'utility',
  'other',
];

/**
 * Random category PHÙ HỢP với type
 * @param {string} type - "income" hoặc "expense"
 * @returns {string} category phù hợp với type
 *
 * Ví dụ:
 *   getRandomCategory("income")  → "Salary" hoặc "Bonus" hoặc "Investment"...
 *   getRandomCategory("expense") → "Food" hoặc "Transport" hoặc "Shopping"...
 */
function getRandomCategory(type) {
  const list = type === 'income' ? incomeCategories : expenseCategories;
  return list[Math.floor(Math.random() * list.length)];
}

/**
 * Random date trong khoảng 3 THÁNG gần nhất
 *
 * Tại sao 3 tháng?
 *   - Đủ data để test filter theo tháng (tháng này, tháng trước, 2 tháng trước)
 *   - Dễ verify khi chạy: GET /api/transactions?month=1&year=2026
 *
 * Cách hoạt động:
 *   1. monthOffset = 0, 1, hoặc 2 (random)
 *   2. setMonth() trừ đi số tháng → JavaScript tự xử lý năm nếu cần
 *      Ví dụ: Tháng 1/2026 - 2 tháng = Tháng 11/2025 (JS tự đổi năm)
 *   3. setDate() random ngày 1-28 (tránh lỗi tháng 2 không có ngày 29-31)
 */
function getRandomDate() {
  const now = new Date();

  // Random 0, 1, hoặc 2 → tháng này, tháng trước, hoặc 2 tháng trước
  const monthOffset = Math.floor(Math.random() * 3);

  // Clone date hiện tại và trừ tháng
  const targetDate = new Date(now);
  targetDate.setMonth(targetDate.getMonth() - monthOffset);
  targetDate.setDate(Math.floor(Math.random() * 28) + 1);

  return targetDate;
}

/**
 * Random amount từ 50,000 → 2,000,000 VND
 * Phù hợp với chi tiêu thực tế hàng ngày
 */
function getRandomAmount() {
  return Math.floor(Math.random() * 2000000) + 50000;
}

/**
 * Random type: 50% income, 50% expense
 * Math.random() > 0.5 → true/false với xác suất 50-50
 */
function getRandomType() {
  return Math.random() > 0.5 ? 'income' : 'expense';
}

/**
 * Generate title phù hợp với category
 * @param {string} category - category của transaction
 * @param {string} type - "income" hoặc "expense"
 * @returns {string} title
 */
function getRandomTitle(category, type) {
  const titles = {
    // Thu nhập
    salary: ['Lương tháng', 'Thanh toán lương', 'Phiếu lương'],
    other: ['Thu nhập khác', 'Thu nhập thêm', 'Thu nhập lặt vặt'],

    // Chi tiêu
    food: ['Ăn trưa', 'Ăn tối', 'Ăn sáng', 'Cà phê', 'Đồ ăn vặt', 'Bánh mì'],
    travel: ['Taxi', 'Xe buýt', 'Uber', 'Xăng xe', 'Đỗ xe', 'Vé máy bay'],
    shopping: ['Quần áo', 'Sách', 'Điện tử', 'Đồ gia dụng', 'Mua sắm online'],
    entertainment: [
      'Xem phim',
      'Hòa nhạc',
      'Chơi game',
      'Streaming',
      'Hoạt động giải trí',
    ],
    utility: ['Điện', 'Nước', 'Internet', 'Gas', 'Hóa đơn điện thoại'],
  };

  const categoryTitles = titles[category] || ['Giao dịch'];
  return categoryTitles[Math.floor(Math.random() * categoryTitles.length)];
}

/**
 * Main Seed Function
 */
async function seedTransactions() {
  try {
    const uri = process.env.MONGO_URI;

    if (!uri) {
      throw new Error('Missing MONGO_URI in .env file');
    }

    console.log('⏳ Connecting to MongoDB...');
    await mongoose.connect(uri);
    console.log('✅ MongoDB Connected!');

    // ================================
    // 1. Get Real User from Database
    // ================================
    const user = await User.findOne();

    if (!user) {
      throw new Error(
        'No user found in DB. Please seed/register a user first!'
      );
    }

    console.log('👤 Using User:', user.email, '| ID:', user._id);

    // ================================
    // 2. Generate Mock Transactions
    // ================================
    // Tạo 20 giao dịch với data đa dạng:
    // - type: 50% income, 50% expense
    // - category: phù hợp với type (Salary→income, Food→expense)
    // - date: rải đều trong 3 tháng gần nhất
    const mockTransactions = [];

    for (let i = 0; i < 20; i++) {
      // Quan trọng: Lấy type TRƯỚC, rồi mới lấy category PHÙ HỢP với type
      const type = getRandomType();
      const category = getRandomCategory(type);

      mockTransactions.push({
        userId: user._id,
        title: getRandomTitle(category, type), // ← THÊM title
        amount: getRandomAmount(),
        type: type,
        category: category,
        date: getRandomDate(),
        note: `Mock transaction #${i + 1}`,
      });
    }

    // ================================
    // 3. Reset + Insert New Data
    // ================================
    await Transaction.deleteMany();
    console.log('🗑 Old transactions deleted');

    await Transaction.insertMany(mockTransactions);
    console.log(
      '✅ Seed Transactions Success! Inserted:',
      mockTransactions.length
    );

    // ================================
    // 4. Close Connection Clean
    // ================================
    // Quan trọng: PHẢI đóng connection sau khi seed xong
    // Nếu không → connection bị treo, memory leak
    await mongoose.connection.close();
    console.log('🔌 MongoDB Connection Closed!');

    process.exit(0);
  } catch (error) {
    console.error('Seed Failed:', error.message);

    // Ensure connection closed even if error happens
    await mongoose.connection.close();
    process.exit(1);
  }
}

// Run script
seedTransactions();
