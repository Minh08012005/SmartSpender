/**
 * File cấu hình kết nối MongoDB.
 * Chức năng: Thiết lập và quản lý kết nối đến cơ sở dữ liệu MongoDB sử dụng Mongoose.
 */

const mongoose = require("mongoose"); // ODM cho MongoDB

/**
 * Hàm kết nối đến MongoDB.
 * Sử dụng URI từ biến môi trường MONGO_URI.
 * Nếu kết nối thất bại, thoát ứng dụng với mã lỗi 1.
 */
const connectDB = async () => {
  try {
    // Kết nối đến MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB connected"); // Thông báo thành công
  } catch (error) {
    // Xử lý lỗi kết nối
    console.error("MongoDB connection failed:", error);
    process.exit(1); // Thoát ứng dụng nếu không kết nối được
  }
};

// Xuất hàm để sử dụng ở nơi khác
module.exports = connectDB;
