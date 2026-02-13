const express = require('express'); // Framework web cho Node.js
const helmet = require('helmet'); // Bảo mật HTTP headers
const morgan = require('morgan'); // Ghi log HTTP requests
const swaggerJsdoc = require('swagger-jsdoc'); // Tạo tài liệu Swagger từ JSDoc
const swaggerUi = require('swagger-ui-express'); // Giao diện người dùng Swagger

// Import middleware
const { generalLimiter } = require('./middleware/rateLimit.middleware');
const validate = require('./middleware/validate.middleware');
const errorHandler = require('./middleware/errorHandler.middleware');

// Import validators
const { registerSchema, loginSchema } = require('./validators/auth.validator');

// Import routes
const registerRoute = require('./routes/auth/register.route'); // Routes cho registration
const loginRoute = require('./routes/auth/login.route'); // Routes cho login
const transactionRoutes = require("./routes/transaction_routes");

// Khởi tạo ứng dụng Express
const app = express();

// Bảo mật middleware
app.use(helmet({
  contentSecurityPolicy: false, // Tắt CSP cho API
  crossOriginEmbedderPolicy: false,
}));

// Logging middleware
app.use(morgan('combined')); // Ghi log tất cả requests

// Rate limiting middleware
app.use(generalLimiter);

// Middleware để parse JSON trong request body
app.use(express.json({ limit: '10mb' })); // Giới hạn kích thước body
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Cấu hình Swagger cho tài liệu API
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'SmartSpender API Documentation',
      version: '1.0.0',
      description: 'Tài liệu API cho ứng dụng quản lý chi tiêu',
    },
    servers: [{ url: 'http://localhost:3000' }],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' }
      }
    }
  },
  apis: ['./routes/*.js', './routes/auth/*.js'], // Đường dẫn đến các file định nghĩa API
};

// Thiết lập Swagger UI
const specs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// Định tuyến routes
app.use('/api/auth', registerRoute);
app.use('/api/auth', loginRoute);
app.use("/api/transactions", transactionRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is healthy',
    timestamp: new Date().toISOString(),
  });
});

// Global error handling middleware
app.use(errorHandler);

module.exports = app;