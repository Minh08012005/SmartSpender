/**
 * Middleware xác thực dữ liệu request sử dụng Joi schemas.
 * Cung cấp validation tập trung với error responses nhất quán.
 */

/**
 * Higher-order function trả về validation middleware.
 * @param {Joi.ObjectSchema} schema - Joi validation schema
 * @param {string} property - Request property để validate ('body', 'query', 'params')
 * @returns {Function} Express middleware function
 */
const validate = (schema, property = 'body') => {
  return (req, res, next) => {
    const { value, error } = schema.validate(req[property], { 
      abortEarly: false, // Thu thập tất cả lỗi
      convert: true, // Tự ép kiểu dữ liệu
      stripUnknown: true // Loại bỏ các trường không xác định
    });
    
    // Nếu có lỗi, trả về response lỗi với chi tiết
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        success: false,
        statusCode: 400,
        message: 'Validation failed',
        errors
      });
    }

    // Lưu dữ liệu đã validate để controller có thể dùng nguồn đã normalize một cách ổn định.
    req.validated = req.validated || {};
    req.validated[property] = value;

    // Express query thường là object được parse qua getter; mutate in-place để
    // đảm bảo dữ liệu đã normalize thực sự được controller nhìn thấy.
    if (property === 'query' && req.query && typeof req.query === 'object') {
      Object.keys(req.query).forEach((key) => {
        delete req.query[key];
      });
      Object.assign(req.query, value);
    } else {
      req[property] = value; // Cập nhật request với dữ liệu đã được validate và chuyển đổi
    }
    next();
  };
};

module.exports = validate;