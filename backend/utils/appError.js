class AppError extends Error {
  constructor(message, statusCode) {
    super(message);

    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true; // Lỗi do người dùng (sai input, 404, 401...)

    Error.captureStackTrace(this, this.constructor);
  }
}
module.exports = AppError;
