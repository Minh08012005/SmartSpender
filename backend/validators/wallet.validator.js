/**
 * Wallet Validators
 * Validation schemas cho wallet endpoints
 */

const { body, param, validationResult } = require('express-validator');

// Transfer validation schema
const validateTransfer = [
  body('fromWalletId')
    .trim()
    .notEmpty()
    .withMessage('fromWalletId là bắt buộc')
    .isMongoId()
    .withMessage('fromWalletId phải là ID hợp lệ'),

  body('toWalletId')
    .trim()
    .notEmpty()
    .withMessage('toWalletId là bắt buộc')
    .isMongoId()
    .withMessage('toWalletId phải là ID hợp lệ'),

  body('amount')
    .notEmpty()
    .withMessage('amount là bắt buộc')
    .isInt({ min: 1 })
    .withMessage('amount phải là số nguyên dương'),

  body('note')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('note không được vượt quá 200 ký tự'),
];

// Update wallet schema
const validateUpdateWallet = [
  param('id').isMongoId().withMessage('ID ví không hợp lệ'),

  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Tên ví phải từ 1-50 ký tự'),

  body('description')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Mô tả không được vượt quá 200 ký tự'),
];

// Get wallet by ID schema
const validateGetWalletById = [
  param('id').isMongoId().withMessage('ID ví không hợp lệ'),
];

module.exports = {
  validateTransfer,
  validateUpdateWallet,
  validateGetWalletById,
};
