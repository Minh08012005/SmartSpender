/**
 * Authentication middleware cho việc bảo vệ routes.
 * Chức năng: Xác thực JWT tokens và đính kèm thông tin user vào request.
 */

const { jwtVerify } = require('jose');
const { TextEncoder } = require('util');

// Tạo secret key từ biến môi trường
const secretKey = new TextEncoder().encode(process.env.JWT_SECRET);

/**
 * Middleware xác thực requests sử dụng JWT.
 * Trích xuất token từ Authorization header và xác thực nó.
 * Đính kèm userId đã giải mã vào req.user.
 */
const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization; // Lấy Authorization header

    // Kiểm tra nếu header không tồn tại hoặc không bắt đầu bằng
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: 'Access token required'
      });
    }

    const token = authHeader.substring(7); // Loại bỏ 'Bearer ' prefix

    // Xác thực JWT token
    const { payload } = await jwtVerify(token, secretKey);

    // Đảm bảo token chứa userId hợp lệ
    if (!payload.userId) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: 'Invalid token payload'
      });
    }

    // Đính kèm user ID vào request object
    req.user = {_id: payload.userId };

    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      statusCode: 401,
      message: 'Invalid or expired token'
    });
  }
};

module.exports = authenticate;