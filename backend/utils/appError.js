/**
 * Custom error class để xử lý lỗi trong ứng dụng. AppError kế thừa từ Error và thêm các thuộc tính như statusCode, status và isOperational để phân biệt giữa lỗi do người dùng và lỗi hệ thống. Khi tạo một instance của AppError, chúng ta có thể cung cấp thông điệp lỗi và mã trạng thái HTTP, giúp việc xử lý lỗi trở nên dễ dàng hơn trong các middleware hoặc controller.
 * Mục tiêu:
 *   - Cung cấp một cách nhất quán để tạo và xử lý lỗi trong ứng dụng
 *   - Phân biệt giữa lỗi do người dùng (4xx) và lỗi hệ thống (5xx)
 *   Giúp việc bắt lỗi và trả về phản hồi lỗi cho client trở nên dễ dàng hơn
 */
class AppError extends Error {
  constructor(message, statusCode) {
    super(message); 

    this.statusCode = statusCode; // Ví dụ: 400, 404, 500
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error'; // Phân loại lỗi: 'fail' cho lỗi do người dùng, 'error' cho lỗi hệ thống
    this.isOperational = true; // Lỗi do người dùng (sai input, 404, 401...)

    Error.captureStackTrace(this, this.constructor); // Giúp loại bỏ constructor khỏi stack trace để dễ đọc hơn
  }
}
module.exports = AppError;
