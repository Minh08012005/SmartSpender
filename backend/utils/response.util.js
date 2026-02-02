/**
 * Utility functions cho standardized API responses.
 */

/**
 * Tạo success response object.
 * @param {number} statusCode - HTTP status code
 * @param {string} message - Thông điệp thành công
 * @param {any} data - Dữ liệu response
 * @returns {Object} Standardized success response
 */
const successResponse = (statusCode, message, data = null) => ({
  success: true,
  statusCode,
  message,
  data,
});

/**
 * Tạo error response object.
 * @param {number} statusCode - HTTP status code
 * @param {string} message - Thông điệp lỗi
 * @param {Array} errors - Optional array chi tiết lỗi
 * @returns {Object} Standardized error response
 */
const errorResponse = (statusCode, message, errors = null) => ({
  success: false,
  statusCode,
  message,
  ...(errors && { errors }),
});

module.exports = {
  successResponse,
  errorResponse,
};