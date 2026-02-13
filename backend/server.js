/**
 * File chính khởi động server Express.js cho ứng dụng backend.
 * Chức năng: Thiết lập middleware, kết nối database, định tuyến routes và khởi động server.
 */

// Import các module cần thiết
require('dotenv').config(); // Tải biến môi trường từ file .env
const app = require('./app');
const connectDB = require('./config/db'); // Hàm kết nối MongoDB

const PORT = process.env.PORT || 3000;

const startServer = async () => {
  try {
    // Kết nối đến MongoDB
    await connectDB();

    app.listen(PORT, () => {
    console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
});
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1); // Thoát ứng dụng nếu không kết nối được database
  }
};

startServer();
