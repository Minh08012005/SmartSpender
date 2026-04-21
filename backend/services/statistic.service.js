/**
 * Service xử lý logic thống kê thu chi
 */

const Transaction = require("../models/transaction_schema");
const MonthlyBudget = require("../models/monthly_budget.model");
const mongoose = require("mongoose");

/**
 * Tính tổng thu, chi và số dư dựa trên bộ lọc
 */
const getStatistics = async (userId, filters) => {
  const { from, to, month, year, type } = filters;
  const match = { userId: new mongoose.Types.ObjectId(userId) };

  if (from && to) {
    match.date = { $gte: new Date(from), $lte: new Date(to) };
  } else if (month && year) {
    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 0, 23, 59, 59);
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

// ==========================================
// HÀM MỚI (Daily Stats) CỦA BẠN ĐÂY!
// ==========================================
const getDailyStatsByMonth = async (userId, month, year) => {
  const startDate = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0));
  const endDate = new Date(Date.UTC(year, month, 1, 0, 0, 0));

  const rows = await Transaction.aggregate([
    {
      $match: {
        userId: new mongoose.Types.ObjectId(userId),
        date: { $gte: startDate, $lt: endDate },
      },
    },
    {
      $group: {
        _id: {
          y: { $year: "$date" },
          m: { $month: "$date" },
          d: { $dayOfMonth: "$date" },
        },
        totalIncome: {
          $sum: { $cond: [{ $eq: ["$type", "income"] }, "$amount", 0] },
        },
        totalExpense: {
          $sum: { $cond: [{ $eq: ["$type", "expense"] }, "$amount", 0] },
        },
        transactionCount: { $sum: 1 },
      },
    },
    { $sort: { "_id.y": 1, "_id.m": 1, "_id.d": 1 } },
  ]);

  const days = rows.map((r) => {
    const date = `${r._id.y}-${String(r._id.m).padStart(2, "0")}-${String(r._id.d).padStart(2, "0")}`;
    const net = r.totalIncome - r.totalExpense;
    return {
      date,
      totalIncome: r.totalIncome,
      totalExpense: r.totalExpense,
      net,
      transactionCount: r.transactionCount,
    };
  });

  return { month, year, days };
};

const computeBudgetStatus = (targetAmount, actualExpense) => {
  if (targetAmount <= 0) return "safe";
  if (actualExpense > targetAmount) return "over";

  const ratio = actualExpense / targetAmount;
  if (ratio >= 0.8) return "near";

  return "safe";
};

const getBudgetSummary = async (userId, month, year) => {
  const budget = await MonthlyBudget.findOne({ userId, month, year }).lean();
  const targetAmount = budget?.targetAmount ?? 0;

  const stats = await getStatistics(userId, { month, year });
  const actualExpense = stats.totalExpense;
  const remaining = targetAmount - actualExpense;
  const status = computeBudgetStatus(targetAmount, actualExpense);

  return {
    month,
    year,
    targetAmount,
    actualExpense,
    remaining,
    status,
  };
};

const saveBudgetTarget = async (userId, month, year, targetAmount) => {
  await MonthlyBudget.findOneAndUpdate(
    { userId, month, year },
    { $set: { targetAmount } },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );

  return getBudgetSummary(userId, month, year);
};

module.exports = {
  getStatistics,
  getCategoryBreakdown,
  getMonthlyStatistics,
  getDailyStatsByMonth,
  getBudgetSummary,
  saveBudgetTarget,
  computeBudgetStatus,
};
