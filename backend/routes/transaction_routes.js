/**
 * Transaction Routes
 * Define API endpoints related to transactions.
 */

const express = require("express");
const router = express.Router();
const { getTransactions } = require("../controllers/transaction_controller");
const authenticate = require("../middleware/auth.middleware");
const validate = require("../middleware/validate.middleware");
const {
  getTransactionsSchema,
} = require("../validators/transaction.validator");

/**
 * @swagger
 * /api/transactions:
 *   get:
 *     summary: "Lấy danh sách giao dịch với các bộ lọc tùy chọn"
 *     tags:
 *       - Transactions
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: month
 *         schema:
 *           type: integer
 *         description: "Lọc theo tháng (1-12)"
 *
 *       - in: query
 *         name: year
 *         schema:
 *           type: integer
 *         description: "Lọc theo năm (ví dụ 2026)"
 *
 *       - in: query
 *         name: from
 *         schema:
 *           type: string
 *           format: date
 *         description: "Từ ngày (YYYY-MM-DD)"
 *
 *       - in: query
 *         name: to
 *         schema:
 *           type: string
 *           format: date
 *         description: "Đến ngày (YYYY-MM-DD)"
 *
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [income, expense]
 *
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *
 *     responses:
 *       200:
 *         description: "Lấy danh sách thành công"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 */

router.get(
  "/",
  authenticate,
  validate(getTransactionsSchema, "query"),
  getTransactions,
);

module.exports = router;
