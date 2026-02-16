/**
 * Service xử lý logic thống kê thu chi
 */

const Transaction = require("../models/transaction_schema");
const mongoose = require("mongoose");

/**
 * Tính tổng thu, chi và số dư dựa trên bộ lọc
 */
const getStatistics = async (userId, filters) => {
  const { from, to, month, year, type } = filters;
  const match = { userId: new mongoose.Types.ObjectId(userId) };

  // Xử lý date range
  if (from && to) {
    match.date = { $gte: new Date(from), $lte: new Date(to) };
  } else if (month && year) {
    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 1); // đầu tháng sau
    match.date = { $gte: start, $lt: end };
  }

  if (type) match.type = type;

  const stats = await Transaction.aggregate([
    { $match: match },
    {
      $group: {
        _id: null,
        totalIncome: {
          $sum: { $cond: [{ $eq: ["$type", "income"] }, "$amount", 0] },
        },
        totalExpense: {
          $sum: { $cond: [{ $eq: ["$type", "expense"] }, "$amount", 0] },
        },
      },
    },
  ]);

  return stats.length > 0
    ? {
        totalIncome: stats[0].totalIncome,
        totalExpense: stats[0].totalExpense,
        balance: stats[0].totalIncome - stats[0].totalExpense,
      }
    : { totalIncome: 0, totalExpense: 0, balance: 0 };
};

/**
 * Thống kê chi tiêu theo danh mục (cho biểu đồ tròn)
 */
const getCategoryBreakdown = async (userId, filters) => {
  const match = {
    userId: new mongoose.Types.ObjectId(userId),
    type: "expense",
  };

  if (filters.from && filters.to) {
    match.date = { $gte: new Date(filters.from), $lte: new Date(filters.to) };
  } else if (filters.month && filters.year) {
    const start = new Date(filters.year, filters.month - 1, 1);
    const end = new Date(filters.year, filters.month, 1);
    match.date = { $gte: start, $lt: end };
  }

  return await Transaction.aggregate([
    { $match: match },
    {
      $group: {
        _id: "$category",
        amount: { $sum: "$amount" },
      },
    },
    { $sort: { amount: -1 } },
  ]);
};

/**
 * Lấy thống kê theo tháng (dùng riêng cho controller)
 */
const getMonthlyStatistics = async (userId, month, year) => {
  return getStatistics(userId, { month, year });
};

module.exports = {
  getStatistics,
  getCategoryBreakdown,
  getMonthlyStatistics,
};
