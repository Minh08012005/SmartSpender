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

  const [transactions, totalCount, stats] = await Promise.all([
    Transaction.find(query)
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit))
      .lean(),
    Transaction.countDocuments(query),
  ]);

  return {
    transactions,
    totalCount,
    page: Number(page),
    limit: Number(limit),
  };
};
