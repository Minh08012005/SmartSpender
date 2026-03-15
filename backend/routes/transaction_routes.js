/**
 * Transaction Routes
 * Define API endpoints related to transactions.
 */

const express = require('express');
const router = express.Router();
const {
  getTransactions,
  createTransaction,
  updateTransaction,
  deleteTransaction,
} = require('../controllers/transaction_controller');
const authenticate = require('../middleware/auth.middleware');
const validate = require('../middleware/validate.middleware');
const {
  getTransactionsSchema,
  createTransactionSchema,
  updateTransactionSchema,
  objectIdParamSchema,
} = require('../validators/transaction.validator');

/**
 * @swagger
 * /transactions:
 *   get:
 *     summary: "Lấy danh sách giao dịch với các bộ lọc tùy chọn"
 *     description: |
 *       Yêu cầu bắt buộc phải có một trong hai cặp tham số:
 *       - `month` và `year` (lọc theo tháng/năm)
 *       - `from` và `to` (lọc theo khoảng ngày)
 *     tags:
 *       - Transactions
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: month
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 12
 *         description: "Tháng (1-12) – bắt buộc nếu dùng mode tháng"
 *       - in: query
 *         name: year
 *         schema:
 *           type: integer
 *           minimum: 2000
 *         description: "Năm (ví dụ 2026) – bắt buộc nếu dùng mode tháng"
 *       - in: query
 *         name: from
 *         schema:
 *           type: string
 *           format: date
 *         description: "Từ ngày (ISO 8601: 2026-03-01T00:00:00Z) hoặc (YYYY-MM-DD: 2026-03-01) – bắt buộc nếu dùng mode khoảng"
 *       - in: query
 *         name: to
 *         schema:
 *           type: string
 *           format: date
 *         description: "Đến ngày (ISO 8601: 2026-03-01T23:59:59Z) hoặc (YYYY-MM-DD: 2026-03-01) – bắt buộc nếu dùng mode khoảng"
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [income, expense]
 *         description: "Loại giao dịch (thu/chi)"
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: "Danh mục, có thể nhập nhiều cách nhau bằng dấu phẩy (ví dụ: food,travel)"
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: "Tìm kiếm theo nội dung ghi chú (không phân biệt hoa thường)"
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: "Số trang"
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *         description: "Số lượng bản ghi mỗi trang"
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           enum: [date, amount, category, createdAt]
 *           default: date
 *         description: "Trường sắp xếp"
 *       - in: query
 *         name: order
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *         description: "Thứ tự sắp xếp (tăng dần/giảm dần)"
 *     responses:
 *       200:
 *         description: "Lấy danh sách thành công"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 statusCode:
 *                   type: integer
 *                   example: 200
 *                 message:
 *                   type: string
 *                   example: "Transactions fetched successfully"
 *                 data:
 *                   type: object
 *                   properties:
 *                     transactions:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           _id:
 *                             type: string
 *                           userId:
 *                             type: string
 *                           amount:
 *                             type: number
 *                           type:
 *                             type: string
 *                             enum: [income, expense]
 *                           category:
 *                             type: string
 *                           date:
 *                             type: string
 *                             format: date-time
 *                           note:
 *                             type: string
 *                           title:
 *                             type: string
 *                           createdAt:
 *                             type: string
 *                             format: date-time
 *                           updatedAt:
 *                             type: string
 *                             format: date-time
 *                       example: []
 *                     totalCount:
 *                       type: integer
 *                       example: 0
 *                     page:
 *                       type: integer
 *                       example: 1
 *                     limit:
 *                       type: integer
 *                       example: 20
 *       400:
 *         description: "Lỗi validation (thiếu tham số, sai định dạng, ...)"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 statusCode:
 *                   type: integer
 *                   example: 400
 *                 message:
 *                   type: string
 *                   example: "Validation failed"
 *                 errors:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       field:
 *                         type: string
 *                       message:
 *                         type: string
 *       401:
 *         description: "Không có token hoặc token không hợp lệ"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 statusCode:
 *                   type: integer
 *                   example: 401
 *                 message:
 *                   type: string
 *                   example: "Access token required"
 *       500:
 *         description: "Lỗi server nội bộ"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: false
 *                 statusCode:
 *                   type: integer
 *                   example: 500
 *                 message:
 *                   type: string
 *                   example: "Internal Server Error"
 */

router.get(
  '/',
  authenticate,
  validate(getTransactionsSchema, 'query'),
  getTransactions
);

/**
 * @swagger
 * /transactions:
 *   post:
 *     summary: "Tạo giao dịch mới"
 *     description: |
 *       - Dữ liệu sẽ được normalize/sanitize (trim title, lowercase category,
 *         coerce amount thành số, kiểm tra type)
 *       - `category` và `type` chấp nhận input hoa/thường từ client, sau đó
 *         sẽ được normalize về lowercase trước khi lưu DB
 *       - `amount` có thể là 0, sau khi validate schema sẽ đồng nhất với service
 *     tags:
 *       - Transactions
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - amount
 *               - category
 *               - type
 *             properties:
 *               title:
 *                 type: string
 *               amount:
 *                 type: number
 *                 minimum: 0
 *               category:
 *                 type: string
 *                 enum: [food, travel, shopping, salary, entertainment, utility, other]
 *               type:
 *                 type: string
 *                 enum: [income, expense]
 *               date:
 *                 type: string
 *                 format: date-time
 *                 description: "ISO 8601 (2026-03-01T00:00:00Z) hoặc YYYY-MM-DD (2026-03-01). Mặc định là ngày hiện tại."
 *               note:
 *                 type: string
 *     responses:
 *       201:
 *         description: "Transaction created successfully"
 *       400:
 *         description: "Validation error"
 *       401:
 *         description: "Unauthorized"
 */
router.post(
  '/',
  authenticate,
  validate(createTransactionSchema, 'body'),
  createTransaction
);

/**
 * @swagger
 * /transactions/{id}:
 *   put:
 *     summary: "Cập nhật giao dịch"
 *     description: |
 *       - Chỉ cho phép user cập nhật transaction của chính mình
 *       - Update atomic bằng findOneAndUpdate
 *       - Validate input và defensive checks tại service layer (trim, normalize, coerce)
 *     tags:
 *       - Transactions
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           description: "ObjectId của giao dịch (24 ký tự hex)"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             description: "Một hoặc nhiều trường để cập nhật. Không gửi payload trống."
 *             properties:
 *               title:
 *                 type: string
 *               amount:
 *                 type: number
 *                 minimum: 0
 *                 description: "Số tiền, có thể là 0"
 *               date:
 *                 type: string
 *                 format: date
 *                 description: "ISO 8601 (2026-03-01T00:00:00Z) hoặc YYYY-MM-DD (2026-03-01)"
 *                 example: "2026-03-01"
 *               category:
 *                 type: string
 *                 description: "Tên danh mục hợp lệ (xem constants)"
 *               type:
 *                 type: string
 *                 enum: [income, expense]
 *               note:
 *                 type: string
 *                 description: "Ghi chú tùy chọn"
 *     responses:
 *       200:
 *         description: "Transaction updated successfully"
 *       400:
 *         description: "Validation error"
 *       401:
 *         description: "Unauthorized"
 *       404:
 *         description: "Transaction not found or permission denied"
 */
router.put(
  '/:id',
  authenticate,
  validate(objectIdParamSchema, 'params'),
  validate(updateTransactionSchema, 'body'),
  updateTransaction
);

/**
 * @swagger
 * /transactions/{id}:
 *   delete:
 *     summary: "Xóa giao dịch"
 *     description: |
 *       - Chỉ cho phép user xóa transaction của chính mình
 *       - Xóa vĩnh viễn, không thể hoàn tác
 *       - ObjectId phải đúng định dạng (24 ký tự hex)
 *     tags:
 *       - Transactions
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           description: "ObjectId của giao dịch (24 ký tự hex, ví dụ: 65c88df8b2f8a1c21c23abcd)"
 *           pattern: "^[0-9a-fA-F]{24}$"
 *           example: "65c88df8b2f8a1c21c23abcd"
 *     responses:
 *       200:
 *         description: "Transaction deleted successfully"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 statusCode:
 *                   type: integer
 *                   example: 200
 *                 message:
 *                   type: string
 *                   example: "Transaction deleted successfully"
 *                 data:
 *                   nullable: true
 *                   example: null
 *       400:
 *         description: "ID không hợp lệ (không phải ObjectId hợp lệ)"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *             example:
 *               success: false
 *               statusCode: 400
 *               message: "Validation failed"
 *               errors:
 *                 - field: "id"
 *                   message: "id must be a valid ObjectId"
 *       401:
 *         description: "Không có token hoặc token không hợp lệ"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *             example:
 *               success: false
 *               statusCode: 401
 *               message: "Access token required"
 *               errorCode: "TOKEN_MISSING"
 *       404:
 *         description: "Transaction không tồn tại hoặc không thuộc về user hiện tại"
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *             example:
 *               success: false
 *               statusCode: 404
 *               message: "Transaction not found or permission denied"
 */
router.delete(
  '/:id',
  authenticate,
  validate(objectIdParamSchema, 'params'),
  deleteTransaction
);

module.exports = router;
