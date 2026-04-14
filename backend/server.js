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
  // Try to connect to DB but do not block server start for debugging/debug-friendly behavior.
  connectDB()
    .then(() => {
      console.log('Database connected successfully');
    })
    .catch((err) => {
      console.error(
        'MongoDB connection failed (continuing without DB):',
        err.message || err
      );
    })
    .finally(() => {
      // Start server regardless of DB connection outcome so health endpoints respond.
      app.listen(PORT, () => {
        console.log(
          `Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`
        );
      });
    });
};

// Gọi hàm khởi động server
startServer();
