/**
 * Authentication middleware cho việc bảo vệ routes.
 * Chức năng: Xác thực JWT tokens và đính kèm thông tin user vào request.
 */

const { jwtVerify } = require('jose');
const { TextEncoder } = require('util');

const getSecretKey = () => {
  const secret = process.env.JWT_SECRET;
  if (!secret || !secret.trim()) {
    throw new Error('JWT_SECRET is not configured');
  }

  return new TextEncoder().encode(secret);
};

const sendUnauthorized = (res, message, errorCode) => {
  return res.status(401).json({
    success: false,
    statusCode: 401,
    message,
    errorCode,
  });
};

const isExpiredTokenError = (error) => {
  return error?.code === 'ERR_JWT_EXPIRED' || error?.name === 'JWTExpired';
};

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
      return sendUnauthorized(res, 'Access token required', 'TOKEN_MISSING');
    }

    const token = authHeader.substring(7).trim(); // Loại bỏ 'Bearer ' prefix
    if (!token) {
      return sendUnauthorized(res, 'Access token required', 'TOKEN_MISSING');
    }

    // Xác thực JWT token
    const { payload } = await jwtVerify(token, getSecretKey());

    const userId = payload.userId || payload._id;
    if (!userId) {
      return sendUnauthorized(res, 'Invalid token', 'TOKEN_INVALID');
    }

    // Đính kèm user ID vào request object
    req.user = { _id: userId };

    next();
  } catch (error) {
    if (isExpiredTokenError(error)) {
      return sendUnauthorized(res, 'Token expired', 'TOKEN_EXPIRED');
    }

    return sendUnauthorized(res, 'Invalid token', 'TOKEN_INVALID');
  }
};

module.exports = authenticate;