/** Transaction validators */
const Joi = require("joi");
const { VALID_CATEGORIES } = require("./constants");

const strictDateValidator = Joi.string()
  .pattern(/^\d{4}-\d{2}-\d{2}$/)
  .custom((value, helpers) => {
    const parsedDate = new Date(`${value}T00:00:00.000Z`);
    if (
      Number.isNaN(parsedDate.getTime()) ||
      parsedDate.toISOString().slice(0, 10) !== value
    ) {
      return helpers.error("date.format");
    }
    return value;
  }, "Strict YYYY-MM-DD date validation");

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

/** POST /transactions */
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
    .lowercase()
    .valid(...VALID_CATEGORIES)
    .required()
    .messages({
      "any.only": "Category must be one of: {{#valids}}",
      "any.required": "Category is required",
    }),
  date: strictDateValidator.required().messages({
    "string.pattern.base": "Date must be in YYYY-MM-DD format",
    "date.format": "Date must be in YYYY-MM-DD format",
    "any.required": "Date is required",
  }),
  note: Joi.string().max(200).allow("").optional().messages({
    "string.max": "Note must not exceed 200 characters",
  }),
});

/** PUT /transactions/:id */
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
    .lowercase()
    .valid(...VALID_CATEGORIES)
    .optional()
    .messages({
      "any.only": "Category must be one of: {{#valids}}",
    }),
  date: strictDateValidator.optional().messages({
    "string.pattern.base": "Date must be in YYYY-MM-DD format",
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
  objectIdParamSchema: Joi.object({
    id: Joi.string().regex(/^[0-9a-fA-F]{24}$/).required().messages({
      "string.pattern.base": "Invalid ObjectId format",
      "any.required": "ID is required",
    }),
  }),
};
