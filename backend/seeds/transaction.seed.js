const mongoose = require("mongoose");
require("dotenv").config(); // Load env đúng

const Transaction = require("../models/transaction");

// Thay ObjectId user thật trong DB
const USER_ID = "65ffffff1234567890abcd12";

// Mock data
const mockTransactions = [
  {
    userId: USER_ID,
    amount: 500000,
    type: "expense",
    category: "Food",
    note: "Ăn trưa"
  },
  {
    userId: USER_ID,
    amount: 3000000,
    type: "income",
    category: "Salary",
    note: "Lương tháng 2"
  },
  {
    userId: USER_ID,
    amount: 200000,
    type: "expense",
    category: "Shopping",
    note: "Mua áo"
  }
];

// Auto generate đủ 20 giao dịch
while (mockTransactions.length < 20) {
  mockTransactions.push({
    userId: USER_ID,
    amount: Math.floor(Math.random() * 1000000),
    type: Math.random() > 0.5 ? "income" : "expense",
    category: "Other",
    note: "Mock data"
  });
}

async function seedTransactions() {
  try {
    //  Check URI trước khi connect
    const uri = process.env.MONGO_URI;

    if (!uri) {
      throw new Error("Missing MONGO_URI in .env file");
    }

    console.log("Connecting to MongoDB:", uri);

    await mongoose.connect(uri);

    console.log("Connected successfully!");

    // Reset transactions
    await Transaction.deleteMany();
    console.log("🗑 Old transactions deleted");

    // Insert new data
    await Transaction.insertMany(mockTransactions);
    console.log("✅ Seed Transactions Success!");

    process.exit(0);
  } catch (error) {
    console.error("Seed Failed:", error.message);
    process.exit(1);
  }
}

seedTransactions();
