/**
 * File chính khởi động server Express.js cho ứng dụng backend.
 * Chức năng: Thiết lập middleware, kết nối database, định tuyến routes và khởi động server.
 */

// Import các module cần thiết
require("dotenv").config(); // Tải biến môi trường từ file .env
const express = require("express"); // Framework web cho Node.js
const connectDB = require("./config/db"); // Hàm kết nối MongoDB

// Import routes
const authRoutes = require("./routes/auth/register.route"); // Routes cho authentication

// Khởi tạo ứng dụng Express
const app = express();

// Middleware để parse JSON trong request body
app.use(express.json());

// Kết nối đến MongoDB
connectDB();

// Định tuyến routes
app.use("/api/auth", authRoutes); // Tất cả routes auth sẽ có prefix /api/auth

// Khởi động server
const PORT = process.env.PORT || 3000; // Sử dụng port từ env hoặc mặc định 3000
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
