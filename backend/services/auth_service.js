/**
 * Authentication service.
 * Chức năng: Xử lý business logic cho các operations xác thực người dùng.
 */

const bcrypt = require('bcrypt');
const { SignJWT } = require('jose');
const { TextEncoder } = require('util');
const User = require('../models/users_model');

// Tạo secret key từ biến môi trường
const secretKey = new TextEncoder().encode(process.env.JWT_SECRET);

/**
 * Tạo JWT access token cho userId đã cho.
 * @param {string} userId - User ID để include trong token
 * @returns {Promise<string>} JWT token đã ký
 */
const generateAccessToken = async (userId) => {
  return new SignJWT({ userId })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setIssuedAt()
    .setExpirationTime('1d')
    .sign(secretKey);
};

/**
 * Đăng ký user mới.
 * @param {Object} userData - Dữ liệu đăng ký user
 * @param {string} userData.email - Email user
 * @param {string} userData.password - Mật khẩu user
 * @param {string} userData.fullName - Tên đầy đủ user
 * @returns {Promise<Object>} Dữ liệu user và access token
 */
const registerUser = async ({ email, password, fullName }) => {
  // Kiểm tra user đã tồn tại chưa
  const existingUser = await User.findOne({ email }).lean();
  if (existingUser) {
    throw new Error('User with this email already exists');
  }

  // Hash mật khẩu
  const hashedPassword = await bcrypt.hash(password, 12); // Tăng salt rounds cho bảo mật tốt hơn

  // Tạo user mới
  const user = await User.create({
    email,
    password: hashedPassword,
    fullName,
  });

  // Tạo access token
  const accessToken = await generateAccessToken(user._id.toString());

  return {
    accessToken,
    user: {
      id: user._id,
      email: user.email,
      fullName: user.fullName,
    },
  };
};

/**
 * Xác thực user với email và mật khẩu.
 * @param {string} email - Email user
 * @param {string} password - Mật khẩu user
 * @returns {Promise<Object>} Dữ liệu user và access token
 */
const loginUser = async (email, password) => {
  // Tìm user theo email
  const user = await User.findOne({ email }).select('+password').lean();
  if (!user) {
    throw new Error('Invalid email or password');
  }

  // Xác thực mật khẩu
  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    throw new Error('Invalid email or password');
  }

  // Tạo access token
  const accessToken = await generateAccessToken(user._id.toString());

  return {
    accessToken,
    user: {
      id: user._id,
      email: user.email,
      fullName: user.fullName,
    },
  };
};

module.exports = {
  registerUser,
  loginUser,
};