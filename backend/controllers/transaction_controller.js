// const Transaction = require("../../models/transaction_schema");
const transactionService = require("../services/transaction.service");
const { successResponse } = require("../utils/response.util");

// /**
//  * ✅ GET /api/transactions
//  *
//  * Features:
//  * 1. Security: Only return transactions of the logged-in user
//  * 2. Filter: Support filtering by month & year for chart statistics
//  *
//  * Example:
//  * GET /api/transactions?month=2&year=2026
//  */
exports.getTransactions = async (req, res, next) => {
  try {
    // /* ---------------------------------------------------
    //  * 1. SECURITY CHECK
    //  * ---------------------------------------------------
    //  * req.user is provided by authentication middleware
    //  * We must filter transactions by userId to prevent
    //  * leaking other users' financial data.
    //  */
    // if (!req.user || !req.user._id) {
    //   return res.status(401).json({
    //     success: false,
    //     message: "Unauthorized: User not logged in",
    //   });
    // }

    const userId = req.user._id; // Lấy từ auth middleware
    const filter = req.query;

    const { transactions, totalCount, finalStats } =
      await transactionService.getfetchFilteredTransactions(userId, filter);

    // response
    return res.status(200).json({
      success: true,
      data: transactions,
      meta: {
        page: Number(page),
        limit: Number(limit),
        total: totalCount,
        totalPages: Math.ceil(totalCount / limit),
        statistics: finalStats,
      },
    });
  } catch (error) {
    next(error);
  }
  /* ---------------------------------------------------
   * 2. BUILD QUERY OBJECT
   * ---------------------------------------------------
   * Default: Find transactions of current user only
   */
  //const query = { userId };

  /* ---------------------------------------------------
   * 3. OPTIONAL FILTER: month & year
   * ---------------------------------------------------
   * Used for frontend charts (monthly spending report)
   *
   * Example:
   * ?month=2&year=2026
   */
  // const { month, year } = req.query;

  // if (month && year) {
  //   // Convert month/year to numbers
  //   const m = parseInt(month, 10);
  //   const y = parseInt(year, 10);

  //   // Validate input
  //   if (m < 1 || m > 12) {
  //     return res.status(400).json({
  //       success: false,
  //       message: "Invalid month. Must be between 1 and 12.",
  //     });
  //   }

  //   // Create date range: from start of month to start of next month
  //   const startDate = new Date(y, m - 1, 1);
  //   const endDate = new Date(y, m, 1);

  //   query.date = { $gte: startDate, $lt: endDate };
  // }

  /* ---------------------------------------------------
   * 4. FETCH TRANSACTIONS
   * ---------------------------------------------------
   */
  //   const transactions = await Transaction.find(query).sort({ date: -1 });

  //   return res.status(200).json({
  //     success: true,
  //     count: transactions.length,
  //     data: transactions,
  //   });
  // } catch (error) {
  //   console.error("Error fetching transactions:", error);

  //   return res.status(500).json({
  //     success: false,
  //     message: "Server error while fetching transactions",
  //   });
  // }
};
