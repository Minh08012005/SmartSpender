const Joi = require("joi");

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
  category: Joi.string(), //csv format
  search: Joi.string().max(100).allow(""),

  // Pagination & Sorting
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sortBy: Joi.string().valid("date", "amount").default("date"),
  order: Joi.string().valid("asc", "desc").default("desc"),
}).and("from", "to")   // Nếu gửi from thì bắt buộc có to
  .and("month", "year") // Nếu gửi month thì bắt buộc có year
  // Quy tắc: Phải có (from+to) HOẶC (month+year). 
  // Không được gửi cả 2 mode cùng lúc
  .oxor("from", "month");

module.exports = { getTransactionsSchema };
