/**
 * Service xử lý logic liên quan đến giao dịch
 */

const Transaction = require("../models/transaction_schema");
const mongoose = require("mongoose");
const AppError = require("../utils/app_error");
const { VALID_CATEGORIES } = require("../validators/constants");

let escapeStringRegexp;
try {
  escapeStringRegexp = require("escape-string-regexp");
} catch (primaryError) {
  try {
    escapeStringRegexp = require("regex-escape");
  } catch (fallbackError) {
    escapeStringRegexp = (str) =>
      String(str).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }
}
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

  const pageNum = Math.max(1, Number(page) || 1);
  const limitNum = Math.max(1, Math.min(100, Number(limit) || 20));
  const monthNum = month !== undefined ? Number(month) : undefined;
  const yearNum = year !== undefined ? Number(year) : undefined;

  //Khởi tạo query object
  const query = { userId: new mongoose.Types.ObjectId(userId) };

  // Xử lý Date Logic (Priority: from/to > month/year)
  if (from && to) {
    const fromDate = new Date(from);
    const toDate = new Date(to);

    if (Number.isNaN(fromDate.getTime()) || Number.isNaN(toDate.getTime())) {
      throw new AppError("Invalid 'from' or 'to' date format.", 400);
    }

    query.date = { $gte: fromDate, $lte: toDate };
  } else if (monthNum && yearNum) {
    if (
      !Number.isInteger(monthNum) ||
      !Number.isInteger(yearNum) ||
      monthNum < 1 ||
      monthNum > 12
    ) {
      throw new AppError("Invalid 'month' or 'year' value.", 400);
    }

    const startDate = new Date(Date.UTC(yearNum, monthNum - 1, 1));
    const endDate = new Date(Date.UTC(yearNum, monthNum, 0, 23, 59, 59, 999)); // Ngày cuối cùng của tháng
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
    // Search trong cả title và note để phù hợp với UX
    query.$or = [
      { note: { $regex: escapedSearch, $options: "i" } },
      { title: { $regex: escapedSearch, $options: "i" } },
    ];
  }

  // Thực thi Query với Pagination & Sorting
  const skip = (pageNum - 1) * limitNum;
  const sortOptions = { [sortBy]: order === "desc" ? -1 : 1 };
  // Sử dụng aggregate + $facet để lấy documents (với paging), totalCount và stats trong 1 pipeline.
  const pipeline = [{ $match: query }];

  const facet = {
    docs: [{ $sort: sortOptions }, { $skip: skip }, { $limit: limitNum }],
    totalCount: [{ $count: "count" }],
    stats: [
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
    ],
  };

  const aggregated = await Transaction.aggregate([
    ...pipeline,
    { $facet: facet },
  ]);

  const docs = (aggregated[0] && aggregated[0].docs) || [];
  const totalCount =
    (aggregated[0] &&
      aggregated[0].totalCount[0] &&
      aggregated[0].totalCount[0].count) ||
    0;
  const statsData = (aggregated[0] && aggregated[0].stats) || [];

  return {
    transactions: docs,
    totalCount,
    page: pageNum,
    limit: limitNum,
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
 * Create a new transaction for user
 * @param {string} userId - ID của người dùng
 * @param {object} payload - Dữ liệu giao dịch
 */
exports.createTransaction = async (userId, payload) => {
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError("Invalid user id", 400);
  }

  if (!payload || typeof payload !== "object") {
    throw new AppError("Invalid transaction payload", 400);
  }

  const amount = Number(payload.amount);
  if (!Number.isFinite(amount) || amount < 0) {
    throw new AppError("Amount must be a valid number", 400);
  }

  const datePattern = /^\d{4}-\d{2}-\d{2}$/;
  if (!datePattern.test(payload.date)) {
    throw new AppError("Invalid date value", 400);
  }
  const [y, m, d] = payload.date.split("-").map(Number);
  const parsedDate = new Date(Date.UTC(y, m - 1, d));
  if (
    Number.isNaN(parsedDate.getTime()) ||
    parsedDate.toISOString().slice(0, 10) !== payload.date
  ) {
    throw new AppError("Invalid date value", 400);
  }

  const normalizedCategory = String(payload.category).toLowerCase();
  if (!VALID_CATEGORIES.includes(normalizedCategory)) {
    throw new AppError("Invalid category value", 400);
  }

  if (typeof payload.title !== "string" || payload.title.trim().length === 0) {
    throw new AppError("Invalid title value", 400);
  }

  const transactionToCreate = {
    userId: new mongoose.Types.ObjectId(userId),
    title: payload.title.trim(),
    amount,
    type: payload.type,
    category: normalizedCategory,
    date: parsedDate,
    note: payload.note || "",
  };

  return Transaction.create(transactionToCreate);
};
