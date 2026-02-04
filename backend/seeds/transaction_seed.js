/**
 * Transaction Seed Script
 * ------------------------
 * Mục tiêu:
 * - Tạo khoảng 20 giao dịch mẫu (income/expense)
 * - Không hard-code USER_ID
 * - Random category + random date để dễ test filter theo tháng
 * - Đóng connection clean sau khi chạy xong
 */

const mongoose = require("mongoose");
require("dotenv").config();

// Import Models
const Transaction = require("../models/transaction_schema");
const User = require("../models/users.model"); // đúng tên file User model của bạn

// Danh sách category phong phú để mock data sinh động
const categories = [
  "Food",
  "Transport",
  "Shopping",
  "Salary",
  "Entertainment",
  "Health",
  "Education",
  "Other"
];

/**
 * Random 1 category trong list
 */
function getRandomCategory() {
  return categories[Math.floor(Math.random() * categories.length)];
}

/**
 * Random date trong khoảng:
 * - Tháng hiện tại
 * - Tháng trước
 */
function getRandomDate() {
  const now = new Date();

  // Random chọn tháng này hoặc tháng trước
  const monthOffset = Math.random() > 0.5 ? 0 : 1;

  const randomMonth = now.getMonth() - monthOffset;
  const randomDay = Math.floor(Math.random() * 28) + 1;

  return new Date(now.getFullYear(), randomMonth, randomDay);
}

/**
 * Random amount hợp lý
 */
function getRandomAmount() {
  return Math.floor(Math.random() * 2000000) + 50000; // 50k → 2M
}

/**
 * Random type income / expense
 */
function getRandomType() {
  return Math.random() > 0.5 ? "income" : "expense";
}

/**
 * Main Seed Function
 */
async function seedTransactions() {
  try {
    const uri = process.env.MONGO_URI;

    if (!uri) {
      throw new Error("Missing MONGO_URI in .env file");
    }

    console.log(" Connecting to MongoDB...");
    await mongoose.connect(uri);
    console.log("✅ MongoDB Connected!");

    // ================================
    // 1. Get Real User from Database
    // ================================
    const user = await User.findOne();

    if (!user) {
      throw new Error(
        "No user found in DB. Please seed/register a user first!"
      );
    }

    console.log("👤 Using User:", user.email, "| ID:", user._id);

    // ================================
    // 2. Generate Mock Transactions
    // ================================
    const mockTransactions = [];

    for (let i = 0; i < 20; i++) {
      mockTransactions.push({
        userId: user._id,
        amount: getRandomAmount(),
        type: getRandomType(),
        category: getRandomCategory(),
        date: getRandomDate(),
        note: `Mock transaction #${i + 1}`
      });
    }

    // ================================
    // 3. Reset + Insert New Data
    // ================================
    await Transaction.deleteMany();
    console.log("🗑 Old transactions deleted");

    await Transaction.insertMany(mockTransactions);
    console.log("Seed Transactions Success! Inserted:", mockTransactions.length);

    // ================================
    // 4. Close Connection Clean
    // ================================
    await mongoose.connection.close();
    console.log(" MongoDB Connection Closed!");

    process.exit(0);
  } catch (error) {
    console.error("Seed Failed:", error.message);

    // Ensure connection closed even if error happens
    await mongoose.connection.close();
    process.exit(1);
  }
}

// Run script
seedTransactions();
