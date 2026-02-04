/**
 * Route định nghĩa endpoint cho đăng nhập người dùng.
 * Chức năng: Xử lý request POST đến /login và chuyển đến controller xử lý.
 */

const express = require('express');
const router = express.Router();

// Import validation schema
const { loginSchema } = require('../../validators/auth.validator');
const validate = require('../../middleware/validate.middleware');

// Import controller xử lý đăng nhập
const login = require('../../controllers/auth/login.controller');

// Định nghĩa route POST /login với validation
// Khi có request POST đến, validate data rồi gọi hàm login từ controller
router.post('/login', validate(loginSchema), login);

// Xuất router để sử dụng trong server.js
module.exports = router;