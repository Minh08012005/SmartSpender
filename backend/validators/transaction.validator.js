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
const { VALID_CATEGORIES } = require("./constants");

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
        return helpers.error("any.invalid", { value: cat });
      }
    }
    return value;
  }, "Category validation"),
  search: Joi.string().max(100).allow(""),

  // Pagination & Sorting
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string()
    .valid("date", "amount", "category", "createdAt")
    .default("date"),
  order: Joi.string().valid("asc", "desc").default("desc"),
})
  .and("from", "to") // Nếu gửi from thì bắt buộc có to
  .and("month", "year") // Nếu gửi month thì bắt buộc có year
  // Quy tắc: Phải có (from+to) HOẶC (month+year).
  // Không được gửi cả 2 mode cùng lúc
  .oxor("from", "month")
  // Thông báo lỗi tùy chỉnh cho các trường hợp validation thất bại
  .messages({
    "object.and":
      "Both 'from' and 'to' or both 'month' and 'year' must be provided together.",
    "object.oxor":
      "Please provide either 'from' and 'to' dates or 'month' and 'year', not both.",
    "any.invalid": "Category '{{#value}}' is not allowed",
  });

/**
 * Validator for creating a new transaction (POST /transactions)
 * Mục tiêu:
 *   - Validate input data khi tạo giao dịch mới
 *   - Đảm bảo tất cả các trường bắt buộc được cung cấp
 *   - Kiểm tra định dạng và giá trị của từng trường
 *   - Cung cấp thông báo lỗi chi tiết cho client
 */
const createTransactionSchema = Joi.object({
  title: Joi.string().min(1).max(100).required().messages({
    "string.empty": "Title is required",
    "string.max": "Title must not exceed 100 characters",
    "any.required": "Title is required",
  }),
  amount: Joi.number().min(0).max(1000000000).required().messages({
    "number.base": "Amount must be a valid number",
    "number.min": "Amount must be at least 0",
    "any.required": "Amount is required",
  }),
  type: Joi.string().valid("income", "expense").required().messages({
    "any.only": "Type must be either 'income' or 'expense'",
    "any.required": "Type is required",
  }),
  category: Joi.string()
    .valid(...VALID_CATEGORIES)
    .required()
    .messages({
      "any.only": "Category must be one of: {{#valids}}",
      "any.required": "Category is required",
    }),
  date: Joi.date().iso().required().messages({
    "date.base": "Date must be a valid date",
    "date.format": "Date must be in YYYY-MM-DD format",
    "any.required": "Date is required",
  }),
  note: Joi.string().max(200).allow("").optional().messages({
    "string.max": "Note must not exceed 200 characters",
  }),
});

/**
 * Validator for updating a transaction (PUT /transactions/{id})
 * Mục tiêu:
 *   - Validate input data khi cập nhật giao dịch
 *   - Hỗ trợ cập nhật từng trường một hoặc nhiều trường cùng lúc
 *   - Sử dụng cùng các quy tắc validate như createTransactionSchema
 */
const updateTransactionSchema = Joi.object({
  title: Joi.string().min(1).max(100).optional().messages({
    "string.empty": "Title cannot be empty",
    "string.max": "Title must not exceed 100 characters",
  }),
  amount: Joi.number().min(0).max(1000000000).optional().messages({
    "number.base": "Amount must be a valid number",
    "number.min": "Amount must be at least 0",
  }),
  type: Joi.string().valid("income", "expense").optional().messages({
    "any.only": "Type must be either 'income' or 'expense'",
  }),
  category: Joi.string()
    .valid(...VALID_CATEGORIES)
    .optional()
    .messages({
      "any.only": "Category must be one of: {{#valids}}",
    }),
  date: Joi.date().iso().optional().messages({
    "date.base": "Date must be a valid date",
    "date.format": "Date must be in YYYY-MM-DD format",
  }),
  note: Joi.string().max(200).allow("").optional().messages({
    "string.max": "Note must not exceed 200 characters",
  }),
})
  .min(1) // Phải có ít nhất 1 trường để cập nhật
  .messages({
    "object.min": "At least one field must be provided for update",
  });

module.exports = {
  getTransactionsSchema,
  createTransactionSchema,
  updateTransactionSchema,
};
