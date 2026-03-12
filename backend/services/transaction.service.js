/**
 * Service xử lý logic liên quan đến giao dịch
 */

const Transaction = require('../models/transaction_schema');
const mongoose = require('mongoose');
const AppError = require('../utils/appError');
const escapeStringRegexp = require('regex-escape');
const { VALID_CATEGORIES } = require('../validators/constants'); // ✅ FIX 1: Import categories
const { parseYYYYMMDD } = require('../utils/date_util');
const logger = require('../utils/logger');

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
    sortBy = 'date',
    order = 'desc',
  } = filters;

  //Khởi tạo query object
  const query = { userId: new mongoose.Types.ObjectId(userId) };

  // Xử lý Date Logic (Priority: from/to > month/year)
  if (from && to) {
    let startDate, endDate;
    if (typeof from === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(from)) {
      startDate = parseYYYYMMDD(from);
    } else {
      startDate = new Date(from);
    }
    if (typeof to === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(to)) {
      endDate = parseYYYYMMDD(to);
    } else {
      endDate = new Date(to);
    }

    // ✅ Validate date trước khi dùng
    if (
      !startDate ||
      isNaN(startDate.getTime()) ||
      !endDate ||
      isNaN(endDate.getTime())
    ) {
      throw new AppError('Invalid date format', 400);
    }

    query.date = { $gte: startDate, $lte: endDate };
  } else if (month && year) {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59); // Ngày cuối cùng của tháng
    query.date = { $gte: startDate, $lte: endDate };
  } else {
    throw new AppError(
      "Please provide either 'from' and 'to' dates or 'month' and 'year' for filtering.",
      400
    );
  }

  // Xử lý Type
  if (type) {
    query.type = type;
  }

  // Xử lý Category (CSV support)
  if (category && typeof category === 'string') {
    const categoryArray = category
      .split(',')
      .map((c) => c.trim().toLowerCase());

    query.category = { $in: categoryArray };
  }

  // Xử lý Search (Partial match trên field 'note')
  if (search && typeof search === 'string') {
    const escapedSearch = escapeStringRegexp(search);
    query.note = { $regex: escapedSearch, $options: 'i' };
  }

  // Thực thi Query với Pagination & Sorting
  // cast pagination parameters to numbers (they may come as strings from query)
  const pageNum = Number(page) || 1;
  const limitNum = Number(limit) || 20;
  const skip = (pageNum - 1) * limitNum;
  const sortOptions = { [sortBy]: order === 'desc' ? -1 : 1 };

  const [transactions, totalCount, statsData] = await Promise.all([
    Transaction.find(query).sort(sortOptions).skip(skip).limit(limitNum).lean(),
    Transaction.countDocuments(query),
    Transaction.aggregate([
      { $match: query },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: '$amount' },
          totalIncome: {
            $sum: { $cond: [{ $eq: ['$type', 'income'] }, '$amount', 0] },
          },
          totalExpense: {
            $sum: { $cond: [{ $eq: ['$type', 'expense'] }, '$amount', 0] },
          },
        },
      },
    ]),
  ]);

  return {
    transactions,
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
 * Create new transaction
 */
exports.createTransaction = async (userId, payload) => {
   /**
   * Validate userId format
   * Prevent BSONError thrown by mongoose
   */
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError("Invalid user id", 400);
  }

  const objectUserId = new mongoose.Types.ObjectId(userId);

  // Defensive sanitize
  if (typeof payload.title !== 'string') {
    throw new AppError('Title must be a string', 400);
  }

  const title = payload.title.trim();

  const amountNum = Number(payload.amount);
  if (!Number.isFinite(amountNum) || amountNum < 0) {
    throw new AppError('Invalid amount', 400);
  }

  const normalizedCategory = payload.category
    ? payload.category.trim().toLowerCase()
    : undefined;

  if (normalizedCategory && !VALID_CATEGORIES.includes(normalizedCategory)) {
    throw new AppError('Invalid category', 400);
  }

  const normalizedType = payload.type
    ? payload.type.trim().toLowerCase()
    : undefined;

  if (normalizedType && !['income', 'expense'].includes(normalizedType)) {
    throw new AppError('Invalid type', 400);
  }

  return await Transaction.create({
    ...payload,
    title,
    amount: amountNum,
    category: normalizedCategory,
    type: normalizedType,
    userId: objectUserId,
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
    logger.debug(
      `[updateTransaction] Invalid transaction id format: ${transactionId}`
    );
    throw new AppError('Invalid transaction id', 400);
  }

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    logger.debug(`[updateTransaction] Invalid user id format: ${userId}`);
    throw new AppError('Invalid user id', 400);
  }

  if (!payload || Object.keys(payload).length === 0) {
    throw new AppError('No fields provided for update', 400);
  }

  const objectUserId = new mongoose.Types.ObjectId(userId);
  const objectTransactionId = new mongoose.Types.ObjectId(transactionId);

  const sanitized = {};

  // Title (optional)
  if (payload.title !== undefined) {
    // ✅ FIX 2: Guard kiểu trước khi dùng .trim()
    if (typeof payload.title !== 'string') {
      throw new AppError('Title must be a string', 400);
    }

    const trimmed = payload.title.trim();

    if (!trimmed) {
      throw new AppError('Title cannot be empty', 400);
    }

    sanitized.title = trimmed;
  }

  // Amount (coerce + validate)
  if (payload.amount !== undefined) {
    const amountNum = Number(payload.amount);

    if (!Number.isFinite(amountNum) || amountNum < 0) {
      throw new AppError('Invalid amount', 400);
    }

    sanitized.amount = amountNum;
  }

  // ✅ FIX 5: ISO parse đồng bộ với Joi, dùng Date.UTC để parse chính xác
  if (payload.date !== undefined) {
    if (typeof payload.date !== 'string') {
      throw new AppError('Date must be a string (ISO format)', 400);
    }

    let parsedDate;
    if (/^\d{4}-\d{2}-\d{2}$/.test(payload.date)) {
      parsedDate = parseYYYYMMDD(payload.date);
    } else {
      parsedDate = new Date(payload.date);
    }
    if (!parsedDate || isNaN(parsedDate.getTime())) {
      throw new AppError('Invalid date format', 400);
    }

    sanitized.date = parsedDate;
  }

  //Category normalize + validate
  if (payload.category !== undefined) {
    if (typeof payload.category !== 'string') {
      // ✅ GUARD TYPE Ở ĐÂY
      throw new AppError('Category must be a string', 400);
    }

    const normalized = payload.category.trim().toLowerCase(); // ✅ Safe

    if (!VALID_CATEGORIES.includes(normalized)) {
      throw new AppError('Invalid category', 400);
    }

    sanitized.category = normalized;
  }

  // Type (income / expense)
  if (payload.type !== undefined) {
    if (typeof payload.type !== 'string') {
      throw new AppError('Type must be a string', 400);
    }

    const normalizedType = payload.type.trim().toLowerCase();

    if (!['income', 'expense'].includes(normalizedType)) {
      throw new AppError('Invalid type', 400);
    }

    sanitized.type = normalizedType;
  }

  // Note (optional)
  if (payload.note !== undefined) {
    if (typeof payload.note !== 'string') {
      throw new AppError('Note must be a string', 400);
    }

    sanitized.note = payload.note.trim();
  }

  //Atomic update + ownership check
  const updated = await Transaction.findOneAndUpdate(
    { _id: objectTransactionId, userId: objectUserId },
    { $set: sanitized },
    { new: true }
  );

  if (!updated) {
    logger.debug(
      `[updateTransaction] Update permission denied or not found: userId=${userId}, transactionId=${transactionId}`
    );
    throw new AppError('Transaction not found or permission denied', 404);
  }

  return updated;
};

/**
 * Delete transaction
 */
exports.deleteTransaction = async (userId, transactionId) => {
  // ✅ FIX 4: Validate id
  if (!mongoose.Types.ObjectId.isValid(transactionId)) {
    logger.debug(
      `[deleteTransaction] Invalid transaction id format: ${transactionId}`
    );
    throw new AppError('Invalid transaction id', 400);
  }

  if (!mongoose.Types.ObjectId.isValid(userId)) {
    logger.debug(`[deleteTransaction] Invalid user id format: ${userId}`);
    throw new AppError('Invalid user id', 400);
  }

  const objectUserId = new mongoose.Types.ObjectId(userId);
  const objectTransactionId = new mongoose.Types.ObjectId(transactionId);

  const deleted = await Transaction.findOneAndDelete({
    _id: objectTransactionId,
    userId: objectUserId,
  });

  if (!deleted) {
    throw new AppError('Transaction not found or permission denied', 404);
  }

  return deleted;
};
