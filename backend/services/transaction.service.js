/**
 * Service xử lý logic liên quan đến giao dịch
 */

const Transaction = require('../models/transaction_schema');
const mongoose = require('mongoose');
const AppError = require('../utils/appError');
const escapeStringRegexp = require('regex-escape');
const { VALID_CATEGORIES } = require('../validators/constants');

/**
 * Create a transaction for user
 * @param {string} userId
 * @param {object} body
 */
exports.createTransaction = async (userId, body) => {
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError('Invalid user id', 400);
  }

  // Defensive guard: keep service contract safe even if validator is bypassed.
  if (!body || typeof body !== 'object') {
    throw new AppError('Invalid payload', 400);
  }

  if (typeof body.title !== 'string' || !body.title.trim()) {
    throw new AppError('Title must be a string', 400);
  }

  const amountNum = Number(body.amount);
  if (!Number.isFinite(amountNum) || amountNum < 0) {
    throw new AppError('Invalid amount', 400);
  }

  if (typeof body.category !== 'string') {
    throw new AppError('Category must be a string', 400);
  }

  const normalizedCategory = body.category.trim().toLowerCase();
  if (!VALID_CATEGORIES.includes(normalizedCategory)) {
    throw new AppError('Invalid category', 400);
  }

  if (typeof body.type !== 'string') {
    throw new AppError('Type must be a string', 400);
  }

  const normalizedType = body.type.trim().toLowerCase();
  if (!['income', 'expense'].includes(normalizedType)) {
    throw new AppError('Invalid type', 400);
  }

  let normalizedDate;
  if (body.date !== undefined) {
    normalizedDate = body.date instanceof Date ? body.date : new Date(body.date);
    if (!normalizedDate || Number.isNaN(normalizedDate.getTime())) {
      throw new AppError('Invalid date format', 400);
    }
  }

  const created = await Transaction.create({
    ...body,
    title: body.title.trim(),
    amount: amountNum,
    category: normalizedCategory,
    type: normalizedType,
    ...(normalizedDate && { date: normalizedDate }),
    userId: new mongoose.Types.ObjectId(userId),
  });

  return created.toObject ? created.toObject() : created;
};
/**
 * Fetch filtered transactions with pagination and statistics
 * @param {string} userId - ID của người dùng
 * @param {object} filters - Các tham số lọc từ query string
 */
exports.getFilteredTransactions = async (userId, filters) => {
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError('Invalid user id', 400);
  }

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

  const parseDateOrThrow = (value, fieldName) => {
    const parsed = value instanceof Date ? value : new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      throw new AppError(`Invalid ${fieldName} date format`, 400);
    }
    return parsed;
  };

  const normalizeLowerString = (value) => value.trim().toLowerCase();

  //Khởi tạo query object
  const query = { userId: new mongoose.Types.ObjectId(userId) };

  // Xử lý Date Logic (Priority: from/to > month/year)
  if (from !== undefined || to !== undefined) {
    if (from === undefined || to === undefined) {
      throw new AppError("Both 'from' and 'to' are required when using date range mode", 400);
    }

    const fromDate = parseDateOrThrow(from, 'from');
    const toDate = parseDateOrThrow(to, 'to');
    if (toDate < fromDate) {
      throw new AppError('to date must be after from date', 400);
    }

    query.date = { $gte: fromDate, $lte: toDate };
  } else if (month !== undefined || year !== undefined) {
    if (month === undefined || year === undefined) {
      throw new AppError("Both 'month' and 'year' are required when using monthly mode", 400);
    }

    const monthNumber = Number(month);
    const yearNumber = Number(year);
    if (!Number.isInteger(monthNumber) || monthNumber < 1 || monthNumber > 12) {
      throw new AppError('month must be an integer between 1 and 12', 400);
    }
    if (!Number.isInteger(yearNumber) || yearNumber < 2000) {
      throw new AppError('year must be an integer greater than or equal to 2000', 400);
    }

    const startDate = new Date(yearNumber, monthNumber - 1, 1);
    const endDate = new Date(yearNumber, monthNumber, 0, 23, 59, 59); // Ngày cuối cùng của tháng
    query.date = { $gte: startDate, $lte: endDate };
  } else {
    throw new AppError(
      "Please provide either 'from' and 'to' dates or 'month' and 'year' for filtering.",
      400
    );
  }

  // Xử lý Type
  if (type !== undefined) {
    if (typeof type !== 'string') {
      throw new AppError('Invalid type filter', 400);
    }

    const normalizedType = normalizeLowerString(type);
    if (!['income', 'expense'].includes(normalizedType)) {
      throw new AppError('Invalid type filter', 400);
    }

    query.type = normalizedType;
  }

  // Xử lý Category (CSV support)
  if (category !== undefined) {
    if (typeof category !== 'string') {
      throw new AppError('Invalid category filter', 400);
    }

    const categoryArray = category
      .split(',')
      .map((c) => normalizeLowerString(c))
      .filter(Boolean);

    if (categoryArray.length === 0) {
      throw new AppError('Invalid category filter', 400);
    }

    const invalidCategory = categoryArray.find((cat) => !VALID_CATEGORIES.includes(cat));
    if (invalidCategory) {
      throw new AppError('Invalid category filter', 400);
    }

    query.category = { $in: categoryArray };
  }

  // Xử lý Search (Partial match trên field 'note')
  if (search !== undefined) {
    if (typeof search !== 'string') {
      throw new AppError('Invalid search filter', 400);
    }

    const escapedSearch = escapeStringRegexp(search);
    query.note = { $regex: escapedSearch, $options: 'i' };
  }

  // Thực thi Query với Pagination & Sorting
  const skip = (page - 1) * limit;
  const sortOptions = { [sortBy]: order === 'desc' ? -1 : 1 };

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
          totalIncome: {
            $sum: {
              $cond: [{ $eq: [{ $toLower: '$type' }, 'income'] }, '$amount', 0],
            },
          },
          totalExpense: {
            $sum: {
              $cond: [{ $eq: [{ $toLower: '$type' }, 'expense'] }, '$amount', 0],
            },
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
    stats: (() => {
      if (statsData.length === 0) {
        return {
          totalIncome: 0,
          totalExpense: 0,
          balance: 0,
        };
      }

      const totalIncome = Number(statsData[0].totalIncome || 0);
      const totalExpense = Number(statsData[0].totalExpense || 0);

      return {
        totalIncome,
        totalExpense,
        balance: totalIncome - totalExpense,
      };
    })(),
  };
};

/**
 * Update a transaction by id, scoped to the owning user
 * @param {string} userId
 * @param {string} id - transaction ObjectId
 * @param {object} body - fields to update
 */
exports.updateTransaction = async (userId, id, body) => {
  // Defensive: service phải tự bảo vệ mình dù validator upstream đã kiểm tra.
  // Nếu JWT bị craft với userId không hợp lệ, BSONTypeError sẽ được throw
  // và global handler trả về 500 thay vì 400 rõ ràng.
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError('Invalid user id', 400);
  }
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new AppError('Invalid transaction id', 400);
  }
  if (!body || Object.keys(body).length === 0) {
    throw new AppError('Request body must not be empty', 400);
  }

  // Normalize các string fields trước khi ghi vào DB (defense-in-depth:
  // validator đã normalize nhưng service không nên tin hoàn toàn vào upstream).
  const update = { ...body };
  if (typeof update.title === 'string') update.title = update.title.trim();
  if (typeof update.category === 'string') update.category = update.category.trim().toLowerCase();
  if (typeof update.type === 'string') update.type = update.type.trim().toLowerCase();
  if (update.date !== undefined) {
    const d = update.date instanceof Date ? update.date : new Date(update.date);
    if (Number.isNaN(d.getTime())) throw new AppError('Invalid date format', 400);
    update.date = d;
  }

  const updated = await Transaction.findOneAndUpdate(
    {
      _id: new mongoose.Types.ObjectId(id),
      userId: new mongoose.Types.ObjectId(userId),
    },
    { $set: update },
    { new: true, runValidators: true }
  ).lean();

  if (!updated) {
    throw new AppError('Transaction not found', 404);
  }

  return updated;
};

/**
 * Delete a transaction by id, scoped to the owning user
 * @param {string} userId
 * @param {string} id
 */
exports.deleteTransaction = async (userId, id) => {
  // Defensive: validate ObjectId trước khi truy vấn DB.
  // new mongoose.Types.ObjectId(invalidStr) ném BSONTypeError (không phải AppError),
  // dẫn đến 500 thay vì 400 nếu không kiểm tra.
  if (!mongoose.Types.ObjectId.isValid(userId)) {
    throw new AppError('Invalid user id', 400);
  }
  if (!mongoose.Types.ObjectId.isValid(id)) {
    throw new AppError('Invalid transaction id', 400);
  }

  const deleted = await Transaction.findOneAndDelete({
    _id: new mongoose.Types.ObjectId(id),
    userId: new mongoose.Types.ObjectId(userId),
  }).lean();

  if (!deleted) {
    throw new AppError('Transaction not found', 404);
  }

  return deleted;
};
