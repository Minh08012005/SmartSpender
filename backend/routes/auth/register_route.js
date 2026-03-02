/**
 * Route định nghĩa endpoint cho đăng ký người dùng.
 * Chức năng: Xử lý request POST đến /register và chuyển đến controller xử lý.
 */

const express = require('express'); // Framework routing
const router = express.Router(); // Tạo router instance

// Import validation schema
const { registerSchema } = require('../../validators/auth_validator');
const validate = require('../../middleware/validate_middleware');

// Import controller xử lý đăng ký
const register = require('../../controllers/auth/register_controller');

// Định nghĩa route POST /register với validation
// Khi có request POST đến, validate data rồi gọi hàm register từ controller
router.post('/register', validate(registerSchema), register);

// Xuất router để sử dụng trong server.js
module.exports = router;