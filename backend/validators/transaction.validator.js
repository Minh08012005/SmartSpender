/**
 * Validator for transaction-related endpoints.
 * Mục tiêu:
 *   - Validate input parameters cho endpoint lấy danh sách giao dịch với nhiều tùy chọn lọc và phân trang.
 *   - Sử dụng Joi để đảm bảo dữ liệu đầu vào đúng định dạng, hợp lệ và an toàn.
 *   - Hỗ trợ 2 mode lọc: theo khoảng thời gian (from-to) hoặc theo tháng-năm (month-year).
 *   - Cho phép lọc theo loại giao dịch (income/expense), danh mục, và tìm kiếm theo mô tả.
 *   - Cung cấp các thông báo lỗi chi tiết khi validation thất bại.
 *   - Đảm bảo tính linh hoạt và dễ sử dụng cho client khi tương tác với API.
 *   - Hỗ trợ phân trang và sắp xếp kết quả trả về.
 */
const Joi = require("joi");
const { VALID_CATEGORIES } = require('./constants');


const getTransactionsSchema = Joi.object({
  // Date Range Mode
  from: Joi.date().iso().messages({ "date.format": "from must be YYYY-MM-DD" }),
  to: Joi.date()
    .iso()
    .min(Joi.ref("from"))
    .messages({ "date.min": "to date must be after from date" }),

  // Monthly Mode
  month: Joi.number().integer().min(1).max(12),
  year: Joi.number().integer().min(2000),

  // Filters
  type: Joi.string().valid("income", "expense"),
  category: Joi.string().custom((value, helpers) => {
    const categories = value.split(",").map((c) => c.trim());
    for (let cat of categories) {
      if (!VALID_CATEGORIES.includes(cat)) {
       return helpers.message("category not allowed");
    }
  }
    return value;
  }, "Category validation"),
  search: Joi.string().max(100).allow(""),

  // Pagination & Sorting
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string().valid("date", "amount", "category", "createdAt").default("date"),
  order: Joi.string().valid("asc", "desc").default("desc"),
})

  // ❗ Không được dùng đồng thời 2 mode
  .xor("from", "month")

  // Nếu có from → phải có to
  .with("from", "to")

  // Nếu có month → phải có year
  .with("month", "year");

/**
 * Validate body cho API tạo giao dịch
 */
const createTransactionSchema = Joi.object({
  title: Joi.string().trim().min(2).max(100).required(),
  // amount cho phép 0 để đồng bộ với service (service đã kiểm tra >=0)
  amount: Joi.number().min(0).required(),
  type: Joi.string().valid("income", "expense").required(),
  category: Joi.string().valid(...VALID_CATEGORIES).required(),
  date: Joi.date().optional(),
  note: Joi.string().allow("").optional(),
});

/**
 * Validate body cho API cập nhật giao dịch
 */
const updateTransactionSchema = Joi.object({
  title: Joi.string().trim().min(2).max(100).optional(),
  // allow zero so update type can set amount to 0 if desired
  amount: Joi.number().min(0).optional(),
  type: Joi.string().valid("income", "expense").optional(),
  category: Joi.string().valid(...VALID_CATEGORIES).optional(),
  date: Joi.date().optional(),
  note: Joi.string().allow("").optional(),
});

// generic schema for endpoints accepting a single Mongo object id param
const objectIdParamSchema = Joi.object({
  id: Joi.string()
    .length(24)
    .hex()
    .required()
    .messages({
      "string.length": "id must be a 24‑character hex string",
      "string.hex": "id must be a valid hex string",
    }),
});

module.exports = {
  getTransactionsSchema,
  createTransactionSchema,
  updateTransactionSchema,
  objectIdParamSchema,
};

