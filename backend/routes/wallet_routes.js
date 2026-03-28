/**
 * Wallet Routes
 * Define API endpoints cho quản lý ví
 */

const express = require('express');
const router = express.Router();
const {
  getAllWallets,
  transferBetweenWallets,
  getWalletById,
  updateWallet,
} = require('../controllers/wallet.controller');
const authenticate = require('../middleware/auth.middleware');
const {
  validateTransfer,
  validateUpdateWallet,
  validateGetWalletById,
  validateRequest,
} = require('../validators/wallet.validator');

/**
 * @swagger
 * /wallets:
 *   get:
 *     summary: "Lấy danh sách tất cả ví của người dùng"
 *     tags:
 *       - Wallets
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: "Danh sách ví thành công"
 *       401:
 *         description: "Không được xác thực"
 */
router.get('/', authenticate, getAllWallets);

/**
 * @swagger
 * /wallets/{id}:
 *   get:
 *     summary: "Lấy chi tiết một ví"
 *     tags:
 *       - Wallets
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: "ID của ví"
 *     responses:
 *       200:
 *         description: "Chi tiết ví"
 *       404:
 *         description: "Ví không tìm thấy"
 */
router.get(
  '/:id',
  authenticate,
  validateGetWalletById,
  validateRequest,
  getWalletById
);

/**
 * @swagger
 * /wallets/{id}:
 *   patch:
 *     summary: "Cập nhật thông tin ví (tên, mô tả)"
 *     tags:
 *       - Wallets
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: "ID của ví"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: "Cập nhật thành công"
 */
router.patch(
  '/:id',
  authenticate,
  validateUpdateWallet,
  validateRequest,
  updateWallet
);

/**
 * @swagger
 * /wallets/transfer:
 *   post:
 *     summary: "Điều chuyển tiền giữa 2 ví"
 *     tags:
 *       - Wallets
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - fromWalletId
 *               - toWalletId
 *               - amount
 *             properties:
 *               fromWalletId:
 *                 type: string
 *                 description: "ID ví nguồn"
 *               toWalletId:
 *                 type: string
 *                 description: "ID ví đích"
 *               amount:
 *                 type: integer
 *                 description: "Số tiền cần chuyển (VND)"
 *               note:
 *                 type: string
 *                 description: "Ghi chú (tùy chọn)"
 *     responses:
 *       200:
 *         description: "Điều chuyển thành công"
 *       400:
 *         description: "Lỗi validation hoặc logic"
 */
router.post(
  '/transfer',
  authenticate,
  validateTransfer,
  validateRequest,
  transferBetweenWallets
);

module.exports = router;
