/**
 * Route định nghĩa endpoint đổi mật khẩu.
 */
const express = require('express');
const router = express.Router();

const authenticate = require('../../middleware/auth.middleware');
const validate = require('../../middleware/validate.middleware');
const { changePasswordSchema } = require('../../validators/auth.validator');
const changePassword = require('../../controllers/auth/change_password.controller');

// POST /change-password (protected)
router.post(
  '/change-password',
  authenticate,
  validate(changePasswordSchema),
  changePassword
);

module.exports = router;
