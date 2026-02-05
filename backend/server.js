/**
 * File chính khởi động server Express.js cho ứng dụng backend.
 * Chức năng: Thiết lập middleware, kết nối database, định tuyến routes và khởi động server.
 */

// Import các module cần thiết
require('dotenv').config(); // Tải biến môi trường từ file .env
const express = require('express'); // Framework web cho Node.js
const helmet = require('helmet'); // Bảo mật HTTP headers
const morgan = require('morgan'); // Ghi log HTTP requests
const connectDB = require('./config/db'); // Hàm kết nối MongoDB

// Import middleware
const { generalLimiter } = require('./middleware/rateLimit.middleware');
const validate = require('./middleware/validate.middleware');
const errorHandler = require('./middleware/errorHandler.middleware');

// Import validators
const { registerSchema, loginSchema } = require('./validators/auth.validator');

// Import routes
const registerRoute = require('./routes/auth/register.route'); // Routes cho registration
const loginRoute = require('./routes/auth/login.route'); // Routes cho login

// Khởi tạo ứng dụng Express
const app = express();

// Bảo mật middleware
app.use(helmet({
  contentSecurityPolicy: false, // Tắt CSP cho API
  crossOriginEmbedderPolicy: false,
}));

// Logging middleware
app.use(morgan('combined')); // Ghi log tất cả requests

// Rate limiting middleware
app.use(generalLimiter);

// Middleware để parse JSON trong request body
app.use(express.json({ limit: '10mb' })); // Giới hạn kích thước body
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Kết nối đến MongoDB
connectDB();

// Định tuyến routes
app.use('/api/auth', registerRoute);
app.use('/api/auth', loginRoute);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is healthy',
    timestamp: new Date().toISOString(),
  });
});

// Global error handling middleware
app.use(errorHandler);

// Khởi động server
const PORT = process.env.PORT || 3000; // Sử dụng port từ env hoặc mặc định 3000
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
});

// ---------------- Transaction Routes ----------------


const transactionRoutes = require("./routes/transaction_routes");

// API route
app.use("/api/transactions", transactionRoutes);

// module.exports = app; (chỉ export nếu bạn dùng test)
// Khởi động server
//const PORT = process.env.PORT || 3000;
//app.listen(PORT, () => {
//  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode`);
//});
