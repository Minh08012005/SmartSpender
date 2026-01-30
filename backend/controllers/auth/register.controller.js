/**
 * Controller xử lý đăng ký người dùng.
 * Chức năng: Xử lý request đăng ký, kiểm tra email trùng lặp, hash mật khẩu, tạo user mới và trả về JWT token.
 */

const users = require("../../models/users.model"); // Model User
const bcrypt = require("bcrypt"); // Thư viện hash mật khẩu
const { SignJWT } = require("jose"); // Thư viện tạo JWT
const { TextEncoder } = require("util"); // Để encode secret key

// Tạo secret key từ biến môi trường
const secretKey = new TextEncoder().encode(process.env.JWT_SECRET);

/**
 * Hàm tạo access token JWT cho user.
 * @param {string} userId - ID của user
 * @returns {string} JWT token
 */
const generateAccessToken = async (userId) => {
  return new SignJWT({ userId }) // Payload chứa userId
    .setProtectedHeader({ alg: "HS256", typ: "JWT" }) // Header với thuật toán HS256
    .setIssuedAt() // Thời gian phát hành
    .setExpirationTime("1d") // Hết hạn sau 1 ngày
    .sign(secretKey); // Ký bằng secret key
};

/**
 * Controller xử lý đăng ký.
 * Nhận email, password, fullName từ request body.
 * Kiểm tra email đã tồn tại, hash password, tạo user và trả về token.
 */
const register = async (req, res) => {
  try {
    // Lấy dữ liệu từ request body
    const { email, password, fullName } = req.body;

    // Kiểm tra xem email đã tồn tại chưa
    const existingUser = await users.findOne({ email });
    if (existingUser) {
      return res.status(409).json({
        success: false,
        statusCode: 409,
        message: "User with this email already exists",
        data: null,
      });
    }

    // Hash mật khẩu với salt rounds = 10
    const hashedPassword = await bcrypt.hash(password, 10);

    // Tạo user mới trong database
    const user = await users.create({
      email,
      password: hashedPassword,
      fullName,
    });

    // Tạo access token
    const accessToken = await generateAccessToken(user._id.toString());

    // Trả về response thành công
    return res.status(201).json({
      success: true,
      statusCode: 201,
      message: "User registered successfully",
      data: { // Sửa từ "date" thành "data"
        accessToken,
        user: {
          id: user._id,
          email: user.email,
          fullName: user.fullName,
        },
      },
    });
  } catch (error) {
    // Log lỗi và trả về response lỗi
    //console.error("REGISTER ERROR:", error);

    return res.status(500).json({
      success: false,
      statusCode: 500,
      message: error.message, // Sửa lỗi syntax
      error: error.message, // Chỉ trả message, không trả toàn bộ error object
    });
  }
};

// Xuất controller để sử dụng trong routes
module.exports = register;
