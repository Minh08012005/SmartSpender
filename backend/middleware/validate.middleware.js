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
    const { error } = schema.validate(req[property], { abortEarly: false });

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

    next();
  };
};

module.exports = validate;