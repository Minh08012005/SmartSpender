/**
 * Route định nghĩa endpoint cho đăng ký người dùng.
 * Chức năng: Xử lý request POST đến /register và chuyển đến controller xử lý.
 */

const express = require('express'); // Framework routing
const router = express.Router(); // Tạo router instance

// Import controller xử lý đăng ký
const register = require('../../controllers/auth/register.controller');

// Định nghĩa route POST /register
// Khi có request POST đến, gọi hàm register từ controller
router.post('/register', register);

// Xuất router để sử dụng trong server.js
module.exports = router;