/**
 * Transaction Schema
 * Mô tả: Đây là schema định nghĩa cấu trúc của một giao dịch (transaction) trong hệ thống quản lý chi tiêu cá nhân.
 * Mỗi giao dịch sẽ bao gồm thông tin về người dùng, số tiền, loại giao dịch, danh mục, ngày tháng, ghi chú và tiêu đề.
 */

const mongoose = require("mongoose");
const { VALID_CATEGORIES } = require("../validators/constants");

const transactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // Tham chiếu đến model User
      required: true, // Bắt buộc phải có userId
      index: true, // Tạo index cho userId để tăng tốc truy vấn
    },

    amount: {
      type: Number,
      required: [true, "Amount is required"], // Bắt buộc phải có amount
      min: [0, "Amount cannot be negative"], // Số tiền không được âm
    },

    type: {
      type: String,
      required: true,
      enum: ["income", "expense"],
    },

    category: {
      type: String,
      required: true,
      enum: VALID_CATEGORIES, // call trong #validators/constant
    },

    date: {
      type: Date,
      default: Date.now, // Mặc định là ngày hiện tại
    },

    note: {
      type: String,
      trim: true,
      default: "",
    },

    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
    },
  },
  {
    timestamps: true, // Tự động thêm createdAt và updatedAt
  },
);

// Tạo index để tối ưu hóa truy vấn theo userId và date (phổ biến cho việc lấy giao dịch theo ngày)
transactionSchema.index({ userId: 1, date: -1 });
transactionSchema.index({ userId: 1, type: 1, category: 1 });
transactionSchema.index({ title: "text", note: "text" });

module.exports = mongoose.model("Transaction", transactionSchema);
