/**
 * File cấu hình kết nối MongoDB.
 * Chức năng: Thiết lập và quản lý kết nối đến cơ sở dữ liệu MongoDB sử dụng Mongoose.
 */

const mongoose = require('mongoose'); // ODM cho MongoDB

/**
 * Hàm kết nối đến MongoDB.
 * Sử dụng URI từ biến môi trường MONGO_URI.
 * Cấu hình pool tối ưu cho development local.
 */
const connectDB = async () => {
  try {
    const mongoURL =
      process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/smartspender';

    // Cấu hình cho Mongoose development:
    // - maxPoolSize: 5 (đủ cho dev local, không tiêu tốn resources)
    // - minPoolSize: 2 (luôn có 2 connections sẵn sàng)
    // - connectTimeoutMS: 10s (fail fast nếu MongoDB không sẵn sàng)
    // - socketTimeoutMS: 45s (prevent hanging queries)
    await mongoose.connect(mongoURL, {
      maxPoolSize: 5,
      minPoolSize: 2,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      retryWrites: true,
      retryReads: true,
    });

    console.log('✅ MongoDB connected successfully');
    return true;
  } catch (error) {
    console.error('❌ MongoDB connection failed:', {
      message: error.message,
      code: error.code,
      URI: process.env.MONGO_URI,
    });
    throw error; // Throw để server.js xử lý
  }
};

// Xuất hàm để sử dụng ở nơi khác
module.exports = connectDB;
