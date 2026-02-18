/**
 * Định tuyến cho các endpoint liên quan đến thống kê
 */

const express = require("express");
const router = express.Router();
const statisticController = require("../controllers/statistic.controller");
const authenticate = require("../middleware/auth.middleware");
const validate = require("../middleware/validate.middleware");
const { getSummarySchema } = require("../validators/statistic.validator");

/**
 * @swagger
 * /api/statistics/summary:
 *   get:
 *     summary: "Lấy tổng thu, chi và số dư theo tháng"
 *     tags:
 *       - Statistics
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: month
 *         required: true
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 12
 *       - in: query
 *         name: year
 *         required: true
 *         schema:
 *           type: integer
 *           minimum: 2000
 *     responses:
 *       200:
 *         description: Thành công
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalIncome:
 *                       type: number
 *                     totalExpense:
 *                       type: number
 *                     balance:
 *                       type: number
 *       400:
 *         description: Thiếu tham số hoặc tham số không hợp lệ
 *       401:
 *         description: Unauthorized
 */
router.get("/summary", authenticate,validate(getSummarySchema, "query"), statisticController.getSummary);

module.exports = router;
