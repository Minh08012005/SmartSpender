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
    // Kết nối MongoDB trước khi khởi động server
    await connectDB();
    console.log('🚀 Ready to start server');
  } catch (err) {
    console.error('❌ FATAL: Cannot start server without MongoDB');
    console.error('Troubleshooting checklist:');
    console.error('  1. MongoDB running? → mongosh hoặc mongod');
    console.error('  2. MONGO_URI đúng? → check .env file');
    console.error('  3. Firewall/Network OK? → kiểm tra port 27017');
    process.exit(1);
  }

  // Khởi động server sau khi kết nối DB thành công
  app.listen(PORT, () => {
    console.log(
      `\n📡 Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode\n`
    );
  });
};

// Gọi hàm khởi động server
startServer();
