const transactionService = require("../services/transaction.service");
const { successResponse } = require("../utils/response.util");

/**
 * @description Get filtered transactions with pagination
 * Hỗ trợ lọc theo date range (from/to) hoặc month/year
 * Hỗ trợ lọc theo category, type, search
 * Hỗ trợ pagination và sorting
 */
exports.getTransactions = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const filter = req.query;

    // Call #transaction.service to get filtered transactions
    const result = await transactionService.getFilteredTransactions(userId, filter);

    return res
      .status(200)
      .json(successResponse(200, "Transactions fetched successfully", result));
  } catch (error) {
    next(error);
  }
};
