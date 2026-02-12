/**
 * Global error handling middleware cho.
 * Chức năng: Bắt và xử lý lỗi một cách nhất quán trên toàn bộ ứng dụng.
 */

const handleValidationError = (err) => {
  const errors = Object.values(err.errors).map((e) => e.message);

  return {
    statusCode: 400,
    message: "Validation Error",
    errors,
  };
};

const handleDuplicateKeyError = (err) => {
  const field = Object.keys(err.keyValue)[0];

  return {
    statusCode: 409,
    message: `${field.charAt(0).toUpperCase() + field.slice(1)} already exists`,
  };
};

const handleJWTError = () => ({
  statusCode: 401,
  message: "Invalid token",
});

const handleTokenExpiredError = () => ({
  statusCode: 401,
  message: "Token expired",
});

/**
 * Log error
 */
const logError = (err, req) => {
  console.error("ERROR:", {
    message: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    ip: req.ip,
    time: new Date().toISOString(),
  });
};

/**
 * Error handling middleware.
 * Ghi log lỗi và trả về responses phù hợp.
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log toàn bộ lỗi
  logError(err, req);

  // Default
  let statusCode = err.statusCode || 500;
  let message = err.message || "Internal Server Error";
  let errors;

  //***  Handle specific errors

  // Mongoose Validation
  if (err.name === "ValidationError") {
    const result = handleValidationError(err);
    statusCode = result.statusCode;
    message = result.message;
    errors = result.errors;
  }

  // Mongoose Duplicate
  if (err.code === 11000) {
    const result = handleDuplicateKeyError(err);
    statusCode = result.statusCode;
    message = result.message;
  }

  // JWT
  if (err.name === "JsonWebTokenError") {
    const result = handleJWTError();
    statusCode = result.statusCode;
    message = result.message;
  }

  if (err.name === "TokenExpiredError") {
    const result = handleTokenExpiredError();
    statusCode = result.statusCode;
    message = result.message;
  }

  // *** Development Environment

  if (process.env.NODE_ENV === "development") {
    return res.status(statusCode).json({
      success: false,
      statusCode,
      message,
      errors,
      stack: err.stack,
      error: err,
    });
  }

  // *** Production Environment

  // Operational error → show to client
  if (err.isOperational) {
    return res.status(statusCode).json({
      success: false,
      statusCode,
      message,
      errors,
    });
  }

  // Programming/System error → hide
  return res.status(500).json({
    success: false,
    statusCode: 500,
    message: "Something went wrong. Please try again later.",
  });
};

module.exports = errorHandler;
