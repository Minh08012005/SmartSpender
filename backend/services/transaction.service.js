const Transaction = require("../models/transaction_schema");
const mongoose = require("mongoose");

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
    page,
    limit,
    sortBy,
    order,
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
    query.note = { $regex: search, $options: "i" };
    query.text = { $regex: search, $options: "i" };
  }

  // Thực thi Query với Pagination & Sorting
  const skip = (Number(page) - 1) * Number(limit);
  const sortOptions = { [sortBy]: order === "desc" ? -1 : 1 };

  const [transactions, totalCount, stats] = await Promise.all([
    Transaction.find(query).sort(sortOptions).skip(skip).limit(Number(limit)),
    Transaction.countDocuments(query),
    // Statistics (Income/Expense/Balance)
    Transaction.aggregate([
      { $match: query },
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
    ]),
  ]);

  const finalStats =
    stats.length > 0
      ? {
          totalIncome: stats[0].totalIncome,
          totalExpense: stats[0].totalExpense,
          balance: stats[0].totalIncome - stats[0].totalExpense,
        }
      : { totalIncome: 0, totalExpense: 0, balance: 0 };

    return { 
        transactions, 
        totalCount, 
        finalStats
    };
};
