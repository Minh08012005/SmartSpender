/**
 * File: app.js
 * Mục tiêu:
 *   - Thiết lập ứng dụng Express với các middleware cần thiết (helmet, morgan, rate limiting)
 *   - Cấu hình Swagger để tạo tài liệu API tự động
 *   Định tuyến các route cho authentication, transactions, và statistics
 *   Cung cấp endpoint health check để kiểm tra trạng thái server
 *   Sử dụng middleware xử lý lỗi toàn cục để đảm bảo phản hồi lỗi nhất quán
 */
const express = require('express'); // Framework web cho Node.js
const cors = require('cors');
const helmet = require('helmet'); // Bảo mật HTTP headers
const morgan = require('morgan'); // Ghi log HTTP requests
const swaggerJsdoc = require('swagger-jsdoc'); // Tạo tài liệu Swagger từ JSDoc
const swaggerUi = require('swagger-ui-express'); // Giao diện người dùng Swagger

// Import middleware
const { generalLimiter } = require('./middleware/rateLimit.middleware');
const errorHandler = require('./middleware/errorHandler.middleware');

// Import routes
const registerRoute = require('./routes/auth/register.route'); // Routes cho registration
const loginRoute = require('./routes/auth/login.route'); // Routes cho login
const transactionRoutes = require('./routes/transaction_routes'); // Routes cho transactions
const statisticRoutes = require('./routes/statistic_routes'); // Routes cho thống kê
const walletRoutes = require('./routes/wallet_routes'); // Routes cho wallets

// Khởi tạo ứng dụng Express
const app = express();

// Trust first proxy (ngrok) so rate-limit and client IP handling work correctly
app.set('trust proxy', 1);

// Bảo mật middleware
app.use(
  helmet({
    contentSecurityPolicy: false, // Tắt CSP cho API
    crossOriginEmbedderPolicy: false,
  })
);

// CORS cho Flutter Web/dev browsers
const localOriginPattern = /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i;
const vercelOriginPattern = /^https:\/\/[a-z0-9-]+\.vercel\.app$/i;
const pagesOriginPattern = /^https:\/\/[a-z0-9-]+\.pages\.dev$/i;
const renderOriginPattern = /^https:\/\/[a-z0-9-]+\.onrender\.com$/i;
const githubPagesPattern = /^https:\/\/[a-z0-9-]+\.github\.io$/i;
const extraAllowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || '')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(
  cors({
    origin(origin, callback) {
      // Allow forcing open CORS for quick testing (set CORS_ALLOW_ALL=true in env)
      if (process.env.CORS_ALLOW_ALL === 'true') {
        return callback(null, true);
      }

      // Allow non-browser requests (curl/postman) and configured browser origins
      if (
        !origin ||
        localOriginPattern.test(origin) ||
        vercelOriginPattern.test(origin) ||
        pagesOriginPattern.test(origin) ||
        githubPagesPattern.test(origin) ||
        renderOriginPattern.test(origin) ||
        extraAllowedOrigins.includes(origin)
      ) {
        return callback(null, true);
      }

      // Log blocked origin for easier debugging in production logs
      console.warn('Blocked CORS origin:', origin);

      const corsError = new Error(
        'CORS origin blocked: this mobile/web origin is not allowed. Contact backend team to whitelist it via CORS_ALLOWED_ORIGINS.'
      );
      corsError.statusCode = 403;
      corsError.errorCode = 'CORS_ORIGIN_NOT_ALLOWED';
      corsError.isOperational = true;
      return callback(corsError);
    },
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Origin',
      'Content-Type',
      'Authorization',
      'ngrok-skip-browser-warning',
    ],
    credentials: false,
  })
);

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
    servers: [
      { url: 'http://localhost:3000/api' },
      { url: 'http://localhost:3000/api/v1' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      },
    },
  },
  // Use backend/swagger.yaml as the single source of truth for API contract docs.
  // Keep auth route annotations for login/register docs until they are also moved into YAML.
  apis: ['./routes/auth/*.js', './swagger.yaml'],
};

// Thiết lập Swagger UI
const specs = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));

// Định tuyến routes
const apiPrefixes = ['/api', '/api/v1'];
apiPrefixes.forEach((prefix) => {
  app.use(`${prefix}/auth`, registerRoute);
  app.use(`${prefix}/auth`, loginRoute);
  app.use(`${prefix}/transactions`, transactionRoutes);
  app.use(`${prefix}/statistics`, statisticRoutes);
  app.use(`${prefix}/wallets`, walletRoutes);
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is healthy',
    timestamp: new Date().toISOString(),
  });
});

// Root endpoint: return a simple status page to avoid 404 from monitors
app.get('/', (req, res) => {
  res
    .status(200)
    .send(
      `<!doctype html><html><head><meta charset="utf-8"><title>SmartSpender API</title></head><body><h1>SmartSpender Backend</h1><p><a href="/health">Health</a> | <a href="/api-docs">API Docs</a></p></body></html>`
    );
});

// Global error handling middleware
app.use(errorHandler);

module.exports = app;
