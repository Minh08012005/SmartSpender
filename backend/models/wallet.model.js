/**
 * Wallet Schema
 * Mô tả: Schema định nghĩa cấu trúc ví của người dùng.
 * Mỗi người dùng có được 3 ví mặc định: Tiền mặt, Ngân hàng, Ví điện tử
 * Balance được quản lý riêng biệt để có thể track điều chuyển tiền nội bộ
 */

const mongoose = require('mongoose');

const walletSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },

    // Wallet type: 'cash', 'bank', 'ewallet'
    walletType: {
      type: String,
      required: true,
      enum: ['cash', 'bank', 'ewallet'],
    },

    // Current balance in this wallet (VND)
    balance: {
      type: Number,
      required: true,
      default: 0,
      min: [0, 'Balance cannot be negative'],
    },

    // Display name: Tiền mặt, Ngân hàng, Ví điện tử
    name: {
      type: String,
      required: true,
    },

    // Optional description
    description: {
      type: String,
      default: '',
    },

    // Track when balance was last modified
    lastUpdated: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true, // createdAt, updatedAt
  }
);

// Compound index: (userId, walletType) để tìm ví nhanh
walletSchema.index({ userId: 1, walletType: 1 }, { unique: true });

const Wallet = mongoose.model('Wallet', walletSchema);

module.exports = Wallet;
