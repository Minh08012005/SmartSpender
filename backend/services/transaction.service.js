/**
 * Service xử lý logic liên quan đến giao dịch
 */

const Transaction = require("../models/transaction_schema");
const mongoose = require("mongoose");
const AppError = require("../utils/appError");
const escapeStringRegexp = require("regex-escape");
/**
 * Fetch filtered transactions with pagination and statistics
 * @param {string} userId - ID của người dùng
 * @param {object} filters - Các tham số lọc từ query string
 */
exports.getFilteredTransactions = async (userId, filters) => {
  const {
    from,
    to,
    month,
    year,
    type,
    category,
    search,
    page = 1,
    limit = 20,
    sortBy = "date",
    order = "desc",
  } = filters;

  //Khởi tạo query object
  const query = { userId: new mongoose.Types.ObjectId(userId) };

  // Xử lý Date Logic (Priority: from/to > month/year)
  if (from && to) {
    query.date = { $gte: new Date(from), $lte: new Date(to) };
  } else if (month && year) {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59); // Ngày cuối cùng của tháng
    query.date = { $gte: startDate, $lte: endDate };
  } else {
    throw new AppError(
      "Please provide either 'from' and 'to' dates or 'month' and 'year' for filtering.",
      400,
    );
  }

  // Xử lý Type
  if (type) {
    query.type = type;
  }

  // Xử lý Category (CSV support)
  if (category) {
    const categoryArray = category.split(",").map((c) => c.trim());
    query.category = { $in: categoryArray };
  }

  // Xử lý Search (Partial match trên field 'note')
  if (search) {
    const escapedSearch = escapeStringRegexp(search);
    query.note = { $regex: escapedSearch, $options: "i" };
  }

  // Thực thi Query với Pagination & Sorting
  const skip = (page - 1) * limit;
  const sortOptions = { [sortBy]: order === "desc" ? -1 : 1 };

  const [transactions, totalCount, statsData] = await Promise.all([
    Transaction.find(query)
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit))
      .lean(),
    Transaction.countDocuments(query),
    Transaction.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: "$amount" },
          totalIncome: {
            $sum: { $cond: [{ $eq: ["$type", "income"] }, "$amount", 0] },
          },
          totalExpense: {
            $sum: { $cond: [{ $eq: ["$type", "expense"] }, "$amount", 0] },
          },
        },
      },
    ]),
  ]);

  return {
    transactions,
    totalCount,
    page: Number(page),
    limit: Number(limit),
    stats:
      statsData.length > 0
        ? statsData[0]
        : {
            totalAmount: 0,
            totalIncome: 0,
            totalExpense: 0,
          },
  };
};

/**
 * Create new transaction
 */
exports.createTransaction = async (userId, payload) => {
  return await Transaction.create({
    ...payload,
    userId,
  });
};

/**
 * Update transaction (atomic, defensive, ownership-safe)
 * @param {string} userId - ID của user đã xác thực
 * @param {string} transactionId - ID transaction cần update
 * @param {object} payload - Dữ liệu đã qua validator
 */
exports.updateTransaction = async (userId, transactionId, payload) => {

  // Validate ObjectId
  if (!mongoose.Types.ObjectId.isValid(transactionId)) {
    throw new AppError("Invalid transaction id", 400);
  }

  // Defensive null/empty check
  if (!payload || Object.keys(payload).length === 0) {
    throw new AppError("No fields provided for update", 400);
  }

  const sanitized = {};

  // Title (optional)
  if (payload.title !== undefined) {
    const trimmed = payload.title.trim();

    if (!trimmed) {
      throw new AppError("Title cannot be empty", 400);
    }

    sanitized.title = trimmed;
  }

  // Amount (coerce + validate)
  if (payload.amount !== undefined) {
    const amountNum = Number(payload.amount);

    if (!Number.isFinite(amountNum) || amountNum < 0) {
      throw new AppError("Invalid amount", 400);
    }

    sanitized.amount = amountNum;
  }

  // Date strict parse YYYY-MM-DD
  if (payload.date !== undefined) {
    const parts = payload.date.split("-").map(Number);

    if (parts.length !== 3 || parts.some(n => !Number.isInteger(n))) {
      throw new AppError("Invalid date format. Use YYYY-MM-DD", 400);
    }

    const [y, m, d] = parts;
    const parsedDate = new Date(Date.UTC(y, m - 1, d));

    // Strict validation (avoid JS auto-correct)
    if (
      parsedDate.getUTCFullYear() !== y ||
      parsedDate.getUTCMonth() !== m - 1 ||
      parsedDate.getUTCDate() !== d
    ) {
      throw new AppError("Invalid date value", 400);
    }

    sanitized.date = parsedDate;
  }

  //Category normalize + validate
  if (payload.category !== undefined) {
    const normalized = payload.category.toLowerCase();

    if (!VALID_CATEGORIES.includes(normalized)) {
      throw new AppError("Invalid category", 400);
    }

    sanitized.category = normalized;
  }

  //Atomic update + ownership check
  const updated = await Transaction.findOneAndUpdate(
    { _id: transactionId, userId },
    { $set: sanitized },
    { new: true }
  );

  if (!updated) {
    throw new AppError(
      "Transaction not found or permission denied",
      404
    );
  }

  return updated;
};

/**
 * Delete transaction (only owner)
 */
exports.deleteTransaction = async (userId, transactionId) => {
  return await Transaction.findOneAndDelete({
    _id: transactionId,
    userId,
  });
};