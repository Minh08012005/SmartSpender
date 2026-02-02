/**
 * Controller xử lý đăng nhập người dùng.
 * Chức năng: Xử lý request đăng nhập, xác thực thông tin và trả về JWT token.
 */

const { loginUser } = require('../../services/auth.service');
const { successResponse, errorResponse } = require('../../utils/response.util');

/**
 * Controller xử lý đăng nhập.
 * Nhận email và password từ request body đã được validate.
 * Xác thực thông tin và trả về token nếu thành công.
 */
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Authenticate user using service
    const result = await loginUser(email, password);

    // Return success response
    res.status(200).json(successResponse(200, 'Login successful', result));
  } catch (error) {
    // Handle authentication errors
    if (error.message === 'Invalid email or password') {
      return res.status(401).json(errorResponse(401, error.message));
    }

    // Log error and return generic error response
    console.error('Login error:', error);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

// Xuất controller để sử dụng trong routes
module.exports = login;

