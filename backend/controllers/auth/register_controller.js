/**
 * Controller xử lý đăng ký người dùng.
 * Chức năng: Xử lý request đăng ký, kiểm tra dữ liệu và tạo user mới.
 */

const { registerUser } = require('../../services/auth_service');
const { successResponse, errorResponse } = require('../../utils/response_util');

/**
 * Controller xử lý đăng ký.
 * Nhận email, password, fullName từ request body đã được validate.
 * Tạo user mới và trả về token.
 */
const register = async (req, res) => {
  try {
    const { email, password, fullName } = req.body;

    // Register user using service
    const result = await registerUser({ email, password, fullName });

    // Return success response
    res.status(201).json(successResponse(201, 'User registered successfully', result));
  } catch (error) {
    // Handle specific errors
    if (error.message === 'User with this email already exists') {
      return res.status(409).json(errorResponse(409, error.message));
    }

    // Log error and return generic error response
    console.error('Registration error:', error);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

// Xuất controller để sử dụng trong routes
module.exports = register;
