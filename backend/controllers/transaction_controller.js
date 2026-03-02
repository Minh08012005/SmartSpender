const transactionService = require("../services/transaction_service");
const { successResponse } = require("../utils/response_util");

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

/**
 * @description Create a new transaction for authenticated user
 */
exports.createTransaction = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { title, amount, type, category, date, note } = req.body;

    const transaction = await transactionService.createTransaction(userId, {
      title,
      amount,
      type,
      category,
      date,
      note,
    });

    return res
      .status(201)
      .json(
        successResponse(201, "Transaction created successfully", transaction),
      );
  } catch (error) {
    next(error);
  }
};
