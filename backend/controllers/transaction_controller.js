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

/**
 * Create transaction
 */
exports.createTransaction = async (req, res, next) => {
  try {
    const transaction = await transactionService.createTransaction(
      req.user._id,
      req.body
    );

    return res.status(201).json(
      successResponse(201, "Transaction created successfully", transaction)
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Update transaction
 */
exports.updateTransaction = async (req, res, next) => {
  try {
    const updated = await transactionService.updateTransaction(
      req.user._id,
      req.params.id,
      req.body
    );

    if (!updated) {
      return res.status(404).json(
        successResponse(404, "Transaction not found")
      );
    }

    return res.status(200).json(
      successResponse(200, "Transaction updated successfully", updated)
    );
  } catch (error) {
    next(error);
  }
};

/**
 * Delete transaction
 */
exports.deleteTransaction = async (req, res, next) => {
  try {
    const deleted = await transactionService.deleteTransaction(
      req.user._id,
      req.params.id
    );

    if (!deleted) {
      return res.status(404).json(
        successResponse(404, "Transaction not found")
      );
    }

    return res.status(200).json(
      successResponse(200, "Transaction deleted successfully")
    );
  } catch (error) {
    next(error);
  }
};