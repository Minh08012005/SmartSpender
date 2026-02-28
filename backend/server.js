/**
 * File chính khởi động server Express.js cho ứng dụng backend.
 * Chức năng: Thiết lập middleware, kết nối database, định tuyến routes và khởi động server.
 */

// Import các module cần thiết
require('dotenv').config(); // Tải biến môi trường từ file .env
const app = require('./app');
const connectDB = require('./config/db'); // Hàm kết nối MongoDB

// Cấu hình cổng server
const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    if (!process.env.JWT_SECRET) {
      console.error('JWT_SECRET is required to start the server');
      process.exit(1);
    }

    // Kết nối đến MongoDB
    await connectDB();

    // Khởi động server sau khi kết nối database thành công
    app.listen(PORT, () => {
    console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
});
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1); // Thoát ứng dụng nếu không kết nối được database
  }
};

// Gọi hàm khởi động server
startServer();
