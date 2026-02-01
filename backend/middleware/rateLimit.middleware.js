/**
 * Rate limiting middleware cho API endpoints.
 * Chức năng: Ngăn chặn lạm dụng bằng cách giới hạn số lượng requests trên mỗi địa chỉ IP.
 */

const rateLimit = require('express-rate-limit');

/**
 * Rate limiter cho authentication endpoints.
 * Giới hạn 5 requests mỗi 15 phút trên mỗi IP.
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 phút
  max: 5, // Giới hạn mỗi IP tối đa 5 requests trên windowMs
  message: {
    success: false,
    statusCode: 429,
    message: 'Too many authentication attempts, please try again later'
  },
  standardHeaders: true, // Trả về thông tin rate limit trong headers `RateLimit-*`
  legacyHeaders: false, // Tắt headers `X-RateLimit-*`
  skipSuccessfulRequests: true, // Chỉ đếm failed requests
});

/**
 * General rate limiter cho các endpoints khác.
 * Giới hạn 100 requests mỗi 15 phút trên mỗi IP.
 */
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 phút
  max: 100, // Giới hạn mỗi IP tối đa 100 requests trên windowMs
  message: {
    success: false,
    statusCode: 429,
    message: 'Too many requests, please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  authLimiter,
  generalLimiter
};