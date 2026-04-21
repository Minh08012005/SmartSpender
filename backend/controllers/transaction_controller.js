const transactionService = require('../services/transaction.service');
const { successResponse } = require('../utils/response.util');

const DATE_ONLY_REGEX = /^\d{4}-\d{2}-\d{2}$/;

const isValidDateQuery = (dateStr) => {
  if (typeof dateStr !== 'string' || !DATE_ONLY_REGEX.test(dateStr)) {
    return false;
  }

  const [yearPart, monthPart, dayPart] = dateStr.split('-').map(Number);
  const parsed = new Date(Date.UTC(yearPart, monthPart - 1, dayPart));

  return (
    !Number.isNaN(parsed.getTime()) &&
    parsed.getUTCFullYear() === yearPart &&
    parsed.getUTCMonth() === monthPart - 1 &&
    parsed.getUTCDate() === dayPart
  );
};

exports.getTransactionsByDate = async (req, res, next) => {
  try {
    const { date } = req.query;

    if (!isValidDateQuery(date)) {
      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: 'date must be in YYYY-MM-DD format',
      });
    }

    const data = await transactionService.getTransactionsByDate(req.user._id, date);
    return res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
};

/**
 * @description Get filtered transactions with pagination
 * Hỗ trợ lọc theo date range (from/to) hoặc month/year
 * Hỗ trợ lọc theo category, type, search
 * Hỗ trợ pagination và sorting
 */
exports.getTransactions = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const normalizedQuery = (req.validated && req.validated.query) ? req.validated.query : req.query;
    const filter = {
      ...normalizedQuery,
      ...(normalizedQuery.month !== undefined && { month: Number(normalizedQuery.month) }),
      ...(normalizedQuery.year !== undefined && { year: Number(normalizedQuery.year) }),
      ...(normalizedQuery.page !== undefined && { page: Number(normalizedQuery.page) }),
      ...(normalizedQuery.limit !== undefined && { limit: Number(normalizedQuery.limit) }),
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
