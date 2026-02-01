/**
 * Model cho User (Người dùng).
 * Chức năng: Định nghĩa schema cho collection 'users' trong MongoDB.
 * Bao gồm các trường: email, password, fullName, và timestamps tự động.
 */

const mongoose = require("mongoose"); // ODM cho MongoDB

// Định nghĩa schema cho User
const userSchema = new mongoose.Schema(
  {
    // Trường email: bắt buộc, duy nhất, loại bỏ khoảng trắng và chuyển thành chữ thường
    email: {
      type: String,
      required: true, // Bắt buộc phải có
      unique: true, // Duy nhất trong collection
      trim: true, // Loại bỏ khoảng trắng đầu và cuối
      lowercase: true, // Chuyển thành chữ thường
      index: true, // Thêm index cho hiệu suất query
    },
    // Trường password: bắt buộc, lưu mật khẩu đã hash
    password: {
      type: String,
      required: true,
    },
    // Trường fullName: bắt buộc, tên đầy đủ của người dùng
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
  },
  { timestamps: true }, // Tự động thêm createdAt và updatedAt
);

// Xuất model User để sử dụng trong controllers
module.exports = mongoose.model("User", userSchema);
