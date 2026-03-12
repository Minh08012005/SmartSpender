const transactionService = require('../services/transaction.service');
const { successResponse } = require('../utils/response.util');

/**
 * @description Get filtered transactions with pagination
 * Hỗ trợ lọc theo date range (from/to) hoặc month/year
 * Hỗ trợ lọc theo category, type, search
 * Hỗ trợ pagination và sorting
 */
exports.getTransactions = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const filter = {
      ...req.query,
      ...(req.query.month !== undefined && { month: Number(req.query.month) }),
      ...(req.query.year !== undefined && { year: Number(req.query.year) }),
      ...(req.query.page !== undefined && { page: Number(req.query.page) }),
      ...(req.query.limit !== undefined && { limit: Number(req.query.limit) }),
    };

    // Call #transaction.service to get filtered transactions
    const result = await transactionService.getFilteredTransactions(
      userId,
      filter
    );

    return res
      .status(200)
      .json(successResponse(200, 'Transactions fetched successfully', result));
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

    return res
      .status(201)
      .json(
        successResponse(201, 'Transaction created successfully', transaction)
      );
  } catch (error) {
    next(error);
  }
};

/**
 * @description Update transaction
 * PUT /api/transactions/:id
 * - Yêu cầu user đã authenticate
 * - Validator đã xử lý input trước khi vào controller
 * - Service sẽ:
 *    + Validate ObjectId
 *    + Defensive checks
 *    + Ownership check
 *    + Atomic update
 */
exports.updateTransaction = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    // Call service layer
    const updatedTransaction = await transactionService.updateTransaction(
      userId,
      id,
      req.body
    );

    // Nếu tới đây tức là update thành công
    return res
      .status(200)
      .json(
        successResponse(
          200,
          'Transaction updated successfully',
          updatedTransaction
        )
      );
  } catch (error) {
    // Delegate toàn bộ lỗi cho global error handler
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

    return res
      .status(200)
      .json(successResponse(200, 'Transaction deleted successfully', deleted));
  } catch (error) {
    next(error);
  }
};
