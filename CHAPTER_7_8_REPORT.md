# CHƯƠNG 7: CÀI ĐẶT VÀ TÍCH HỢP

## 7.1. Môi trường phát triển

### 7.1.1 Yêu cầu hệ thống tối thiểu

| Thành phần         | Yêu cầu        | Phiên bản       | Ghi chú            |
| ------------------ | -------------- | --------------- | ------------------ |
| **Node.js**        | Bắt buộc       | v18.x trở lên   | Backend server     |
| **Flutter SDK**    | Bắt buộc       | v3.10.7 trở lên | Mobile development |
| **Dart**           | Theo Flutter   | v3.10.7+        | Ngôn ngữ Flutter   |
| **MongoDB**        | Bắt buộc       | v5.x+           | Database           |
| **Git**            | Bắt buộc       | v2.30+          | Version control    |
| **Android Studio** | Tùy chọn       | Mới nhất        | Android emulator   |
| **Xcode**          | Tùy chọn (Mac) | v14+            | iOS development    |

### 7.1.2 Cài đặt môi trường

#### Backend (Node.js + Express + MongoDB)

**Bước 1: Cài đặt dependencies**

```bash
cd backend
npm install
```

**Dependencies chính:**

- **express** (^5.2.1): Web framework chính
- **mongoose** (^9.1.5): MongoDB ODM (Object Document Mapper)
- **bcrypt** (^6.0.0): Mã hóa mật khẩu
- **jose** (^4.15.9) & **jsonwebtoken**: JWT authentication
- **express-validator**: Validation middleware
- **joi**: Schema validation library
- **helmet** (^7.1.0): Bảo mật HTTP headers
- **morgan** (^1.10.0): HTTP request logging
- **express-rate-limit** (^7.4.1): Rate limiting
- **cors** (^2.8.6): Cross-Origin Resource Sharing
- **swagger-jsdoc** & **swagger-ui-express**: API documentation
- **dotenv** (^17.2.3): Environment variables management

**Bước 2: Tạo file `.env` (trong thư mục `backend/`)**

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/smartspender?retryWrites=true&w=majority

# JWT Authentication
JWT_SECRET=your_super_secret_jwt_key_change_in_production

# CORS Configuration
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5000,http://10.0.2.2:3000
CORS_ALLOW_ALL=false

# Optional: Rate Limiting
RATE_LIMIT_WINDOW_MS=15000000
RATE_LIMIT_MAX_REQUESTS=100
```

**Bước 3: Chạy server development**

```bash
# Chạy với auto-restart khi có thay đổi file
npm run dev

# Hoặc chạy production
npm start
```

Output mong đợi:

```
Server running on port 3000 in development mode
Database connected successfully
```

#### Mobile (Flutter)

**Bước 1: Cài đặt dependencies**

```bash
cd mobile
flutter pub get
```

**Dependencies chính:**

- **http** (^1.2.0): HTTP client cho REST API
- **provider** (^6.1.1): State management
- **dio** (^5.4.0): Advanced HTTP client
- **shared_preferences** (^2.2.2): Local storage (lưu token)
- **intl** (^0.19.0): Internationalization & date formatting
- **shimmer** (^3.0.0): Loading skeleton UI
- **cupertino_icons** (^1.0.8): iOS style icons

**Bước 2: Cấu hình API URL (`mobile/lib/core/config/app_config.dart`)**

Tùy theo môi trường test:

```dart
// Cho Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

// Cho iOS Simulator
static const String baseUrl = 'http://localhost:3000/api/v1';

// Cho thiết bị thật (WiFi LAN)
static const String baseUrl = 'http://192.168.x.x:3000/api/v1';

// Cho Render production
static const String baseUrl = 'https://smartspender-x1fl.onrender.com/api/v1';
```

**Bước 3: Chạy ứng dụng**

```bash
# Build cache
flutter clean

# Tải dependencies
flutter pub get

# Chọn thiết bị & chạy
flutter run
```

### 7.1.3 Công cụ và IDE được sử dụng

| Công cụ           | Phiên bản | Mục đích                             |
| ----------------- | --------- | ------------------------------------ |
| **VS Code**       | Mới nhất  | Code editor chính                    |
| **Postman**       | Latest    | API testing, collection management   |
| **MongoDB Atlas** | Cloud     | Database hosting (optional)          |
| **Render**        | -         | Backend hosting (production)         |
| **GitHub Pages**  | -         | Flutter Web hosting (demo công khai) |
| **Git/GitHub**    | -         | Version control & CI/CD              |

---

## 7.2. Cấu trúc Source Code

### 7.2.1 Cấu trúc Backend (`backend/`)

```
backend/
│
├── config/
│   └── db.js                          # Kết nối MongoDB
│
├── controllers/
│   ├── auth/                          # Xác thực
│   │   ├── register.controller.js
│   │   └── login.controller.js
│   ├── transaction_controller.js      # Quản lý giao dịch
│   ├── wallet.controller.js           # Quản lý ví
│   └── statistic.controller.js        # Thống kê
│
├── middleware/
│   ├── auth.middleware.js             # JWT authentication middleware
│   ├── validate.middleware.js         # Validation middleware
│   ├── errorHandler.middleware.js     # Xử lý lỗi toàn cục
│   └── rateLimit.middleware.js        # Rate limiting
│
├── models/
│   ├── users.model.js                 # Schema: User
│   ├── transaction.js                 # Schema: Transaction
│   ├── wallet.model.js                # Schema: Wallet
│   └── wallet_transfer.model.js       # Schema: Transfer history
│
├── routes/
│   ├── auth/
│   │   ├── register.route.js
│   │   └── login.route.js
│   ├── transaction_routes.js          # Routes: /api/transactions
│   ├── wallet_routes.js               # Routes: /api/wallets
│   └── statistic_routes.js            # Routes: /api/statistics
│
├── services/
│   ├── auth.service.js                # Business logic: auth
│   ├── transaction.service.js         # Business logic: transactions
│   ├── wallet.service.js              # Business logic: wallets
│   └── statistic.service.js           # Business logic: statistics
│
├── validators/
│   ├── auth.validator.js              # Joi schema: auth input
│   ├── transaction.validator.js       # Joi schema: transaction input
│   ├── wallet.validator.js            # Joi schema: wallet input
│   ├── statistic.validator.js         # Joi schema: statistic filters
│   └── constants.js                   # Validation constants
│
├── tests/
│   ├── setupEnv.js                    # Jest test setup
│   ├── unit/                          # Unit tests
│   └── integration/                   # Integration tests
│
├── utils/
│   ├── appError.js                    # Custom error class
│   ├── logger.js                      # Logging utility
│   ├── response.util.js               # Unified response format
│   └── date_util.js                   # Date utilities
│
├── seeds/
│   └── transaction_seed.js            # Sample data seeding
│
├── postman/
│   ├── *.postman_collection.json      # API testing collections
│   └── *.postman_environment.json     # Environment configurations
│
├── app.js                             # Express app initialization
├── server.js                          # Server entry point
├── swagger.yaml                       # OpenAPI 3.0 specification
├── package.json                       # Dependencies & scripts
└── .env                               # Environment variables (không commit)
```

**Lưu ý quan trọng:**

- Tất cả controller methods đều sử dụng `try-catch` và gọi `next(error)` để ErrorHandler xử lý
- Validators dùng **Joi** (schema validation) hoặc **express-validator** (field validation)
- Responses được chuẩn hóa qua `response.util.js`: `{ success, statusCode, data, message }`

### 7.2.2 Cấu trúc Mobile (`mobile/lib/`)

```
mobile/lib/
│
├── core/
│   ├── config/
│   │   └── app_config.dart            # API URL, constants
│   ├── services/
│   │   └── api_service.dart           # HTTP client (Dio)
│   └── constants/
│       ├── app_strings.dart           # Hardcoded strings
│       ├── app_colors.dart            # Color palette
│       └── app_sizes.dart             # Responsive sizes
│
├── data/
│   ├── models/
│   │   ├── user_model.dart            # User data model + JSON parse
│   │   ├── transaction_model.dart     # Transaction model
│   │   ├── wallet_model.dart          # Wallet model
│   │   └── statistic_model.dart       # Statistics model
│   └── providers/
│       ├── auth_provider.dart         # State: login/register/logout
│       ├── transaction_provider.dart  # State: CRUD transactions
│       ├── wallet_provider.dart       # State: wallets & transfers
│       └── statistic_provider.dart    # State: statistics
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart               # Dashboard & home
│   ├── transaction_screen.dart        # Transaction list
│   ├── wallet_screen.dart             # Wallet management
│   ├── transaction_detail_screen.dart # Transaction detail
│   └── settings_screen.dart           # User settings
│
├── widgets/
│   ├── common/
│   │   ├── app_bar_widget.dart
│   │   ├── bottom_nav_bar.dart
│   │   └── loading_widget.dart
│   ├── transaction/
│   │   ├── transaction_list_item.dart
│   │   ├── transaction_form.dart
│   │   └── filter_panel.dart
│   ├── wallet/
│   │   ├── wallet_card.dart
│   │   ├── wallet_list.dart
│   │   └── transfer_modal.dart
│   └── statistic/
│       ├── summary_card.dart
│       └── stat_chart.dart
│
├── views/
│   ├── home_view.dart                 # Home tab
│   ├── transaction_view.dart          # Transactions tab
│   ├── wallet_view.dart               # Wallets tab
│   └── profile_view.dart              # Profile tab
│
├── navigation/
│   └── app_navigation.dart            # Navigation routes
│
├── theme/
│   └── app_theme.dart                 # Material theme config
│
├── main.dart                          # App entry point
└── pubspec.yaml                       # Dependencies
```

**Lưu ý quan trọng:**

- Tất cả providers extend **ChangeNotifier** để state management
- Models có methods `fromJson()` & `toJson()` cho JSON parsing
- Screens sử dụng `Consumer<ProviderClass>` để listen state changes
- Responsive design dùng `MediaQuery` để adapt Android/iOS

### 7.2.3 Luồng dữ liệu Backend (Request → Response)

```
Client (Mobile/Web)
    ↓ HTTP Request (với JWT token)
Routes (URL matching + method check)
    ↓
Middleware (Auth validation, Rate limit)
    ↓
Validators (Joi schema validation)
    ↓
Controllers (Xử lý business logic)
    ↓
Services (Gọi Model, xử lý logic phức tạp)
    ↓
Models (Truy vấn MongoDB qua Mongoose)
    ↓
Database (MongoDB)
    ↓ Response
Services (Format data)
    ↓
Controllers (Gọi response.util để chuẩn hóa)
    ↓
Middleware (ErrorHandler nếu có lỗi)
    ↓ HTTP Response (JSON)
Client (Mobile/Web)
```

---

## 7.3. Tài liệu API (Swagger Docs)

### 7.3.1 Truy cập Swagger UI

**Development (Local):**

```
http://localhost:3000/api-docs
```

**Production (Render):**

```
https://smartspender-x1fl.onrender.com/api-docs
```

### 7.3.2 Cấu trúc API Specification

SmartSpender sử dụng **OpenAPI 3.0** được khai báo trong `backend/swagger.yaml` và tạo động từ JSDoc comments trong routes.

**Lệnh rebuild Swagger:**

```bash
cd backend
node app.js  # Swagger được sinh tự động khi app start
```

### 7.3.3 API Endpoints chính

#### **1. Authentication Endpoints**

| Method | Endpoint             | Mô tả               | Auth |
| ------ | -------------------- | ------------------- | ---- |
| POST   | `/api/auth/register` | Đăng ký tài khoản   | ❌   |
| POST   | `/api/auth/login`    | Đăng nhập, nhận JWT | ❌   |

**Request Example (Register):**

```json
POST /api/auth/register
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePass@123"
}
```

**Response (Success):**

```json
{
  "success": true,
  "statusCode": 201,
  "data": {
    "userId": "507f1f77bcf86cd799439011",
    "email": "john@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Đăng ký thành công"
}
```

#### **2. Transaction Endpoints**

| Method | Endpoint                | Mô tả                               | Auth |
| ------ | ----------------------- | ----------------------------------- | ---- |
| GET    | `/api/transactions`     | Lấy danh sách giao dịch (có filter) | ✅   |
| POST   | `/api/transactions`     | Tạo giao dịch mới                   | ✅   |
| PUT    | `/api/transactions/:id` | Cập nhật giao dịch                  | ✅   |
| DELETE | `/api/transactions/:id` | Xóa giao dịch                       | ✅   |

**Query Parameters (GET):**

```
Cách 1 - Lọc theo tháng/năm:
GET /api/transactions?month=3&year=2026

Cách 2 - Lọc theo khoảng ngày:
GET /api/transactions?from=2026-03-01&to=2026-03-31

Thêm filters:
- type: income|expense
- category: food,travel,utilities (comma-separated)
- search: chuỗi tìm kiếm
- page: số trang (mặc định 1)
- limit: số item/trang (mặc định 20, tối đa 100)
- sortBy: date|amount|category|createdAt (mặc định date)
- order: asc|desc (mặc định desc)
```

**Request Example (Create):**

```json
POST /api/transactions
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "type": "expense",
  "category": "food",
  "amount": 150000,
  "note": "Cơm trưa ở nhà hàng",
  "date": "2026-03-31T12:30:00Z",
  "walletType": "CASH"
}
```

**Response Example:**

```json
{
  "success": true,
  "statusCode": 201,
  "data": {
    "id": "507f1f77bcf86cd799439012",
    "userId": "507f1f77bcf86cd799439011",
    "type": "expense",
    "category": "food",
    "amount": 150000,
    "note": "Cơm trưa ở nhà hàng",
    "date": "2026-03-31T12:30:00.000Z",
    "walletType": "CASH",
    "createdAt": "2026-03-31T12:30:00.000Z",
    "updatedAt": "2026-03-31T12:30:00.000Z"
  },
  "message": "Tạo giao dịch thành công"
}
```

#### **3. Wallet Endpoints**

| Method | Endpoint                | Mô tả                    | Auth |
| ------ | ----------------------- | ------------------------ | ---- |
| GET    | `/api/wallets`          | Lấy danh sách ví         | ✅   |
| GET    | `/api/wallets/:id`      | Lấy chi tiết một ví      | ✅   |
| PATCH  | `/api/wallets/:id`      | Cập nhật ví (tên, mô tả) | ✅   |
| POST   | `/api/wallets/transfer` | Chuyển tiền giữa ví      | ✅   |

**Request Example (Transfer):**

```json
POST /api/wallets/transfer
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "sourceWalletId": "507f1f77bcf86cd799439011",
  "destinationWalletId": "507f1f77bcf86cd799439012",
  "amount": 1000000,
  "note": "Chuyển từ tiền mặt sang ngân hàng"
}
```

#### **4. Statistics Endpoints**

| Method | Endpoint                  | Mô tả                           | Auth |
| ------ | ------------------------- | ------------------------------- | ---- |
| GET    | `/api/statistics/summary` | Tổng thu, chi, số dư theo tháng | ✅   |

**Request Example:**

```
GET /api/statistics/summary?month=3&year=2026
Authorization: Bearer <JWT_TOKEN>
```

**Response Example:**

```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "month": 3,
    "year": 2026,
    "totalIncome": 50000000,
    "totalExpense": 15000000,
    "balance": 35000000,
    "transactions": [
      {
        "id": "...",
        "type": "income",
        "category": "salary",
        "amount": 50000000
      }
    ]
  },
  "message": "Lấy thống kê thành công"
}
```

### 7.3.4 Xác thực (Authentication)

**Loại xác thực: Bearer Token (JWT)**

```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Quy trình:**

1. Client gọi `/api/auth/login` → nhận `token` trong response
2. Client lưu token vào `shared_preferences` (mobile) hoặc `localStorage` (web)
3. Mỗi request sau sử dụng header `Authorization: Bearer <token>`
4. Server validate token ở middleware `auth.middleware.js`
5. Nếu token hết hạn hoặc invalid → trả lỗi 401

**Token Lifetime:** 7 ngày (có thể cấu hình trong `.env`)

### 7.3.5 Chuẩn hóa Error Response

Tất cả error responses tuân theo format:

```json
{
  "success": false,
  "statusCode": 400,
  "message": "Mô tả lỗi",
  "errorCode": "VALIDATION_ERROR",
  "details": [
    {
      "field": "email",
      "message": "Email không hợp lệ"
    }
  ]
}
```

**HTTP Status Codes:**

- `200`: OK
- `201`: Created
- `400`: Bad Request (validation failed)
- `401`: Unauthorized (token missing/invalid)
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

### 7.3.6 Rate Limiting

- **Giới hạn:** 100 requests per 15 minutes per IP
- **Headers response:**
  - `X-RateLimit-Limit`
  - `X-RateLimit-Remaining`
  - `X-RateLimit-Reset`

---

# CHƯƠNG 8: KẾT QUẢ ĐẠT ĐƯỢC

## 8.1. Giao diện ứng dụng thực tế (Screenshots Mobile App)

### 8.1.1 Màn hình Xác thực

#### Login Screen

- **Chức năng:** Đăng nhập với email/password
- **Thành phần UI:**
  - Logo ứng dụng (SmartSpender)
  - Input field Email (validation: định dạng email)
  - Input field Password (ẩn ký tự, có nút show/hide)
  - Nút "Đăng nhập" (disable khi loading)
  - Link "Chưa có tài khoản? Đăng ký"
  - Loading indicator khi gửi request
  - Error toast notification nếu đăng nhập thất bại

**Trạng thái:**

- ✅ Loading: Hiển thị spinner + text "Đang đăng nhập..."
- ✅ Success: Chuyển hướng sang Home Screen, lưu token
- ✅ Error: Hiển thị message lỗi rõ ràng (email sai/password sai)

#### Register Screen

- **Chức năng:** Tạo tài khoản mới
- **Thành phần UI:**
  - Input Username
  - Input Email (validation realtime)
  - Input Password (validation: độ mạnh mật khẩu)
  - Input Confirm Password (kiểm tra khớp)
  - Checkbox chấp nhận điều khoản
  - Nút "Đăng ký"
  - Link "Đã có tài khoản? Đăng nhập"

**Trạng thái:**

- ✅ Validation realtime: Hiển thị icon ✓/✗ cạnh mỗi field
- ✅ Success: Hiển thị thông báo, chuyển về Login
- ✅ Error: Hiển thị lỗi từ server (email đã tồn tại, v.v.)

### 8.1.2 Màn hình Home (Dashboard)

**Bố cục chính:**

```
┌─────────────────────────┐
│  Header: Tên user       │
├─────────────────────────┤
│  💰 Số dư: 35,000,000₫  │  ← Tổng từ tất cả ví
├─────────────────────────┤
│  │ Thu: 50,000,000₫ │   │
│  │ Chi: 15,000,000₫ │   │  ← Thống kê tháng hiện tại
├─────────────────────────┤
│  Giao dịch gần nhất     │
│  ┌───────────────────┐  │
│  │ 🍔 Cơm trưa       │  │
│  │    -150,000₫ ↓   │  │  ← Last 5-10 transactions
│  │    hôm nay       │  │
│  └───────────────────┘  │
├─────────────────────────┤
│ [Tab Navigation]        │
│ Home | Transaction      │
│ Wallet | Profile        │
└─────────────────────────┘
```

**Tính năng:**

- ✅ Lấy số dư từ danh sách ví
- ✅ Lấy thống kê thu/chi tháng hiện tại
- ✅ Hiển thị 10 giao dịch gần nhất
- ✅ Pull-to-refresh để cập nhật
- ✅ Chuyển sang Transaction tab khi tap giao dịch

### 8.1.3 Màn hình Giao dịch (Transaction List)

**Bố cục:**

```
┌─────────────────────────┐
│ 🔍 [Search]             │
│ [Filter] [Sort]         │
├─────────────────────────┤
│ March 2026              │  ← Separator theo tháng
├─────────────────────────┤
│ ✓ 🍔 Cơm trưa           │
│   -150,000₫ 12:30       │
├─────────────────────────┤
│ ✓ 💼 Lương tháng        │
│   +50,000,000₫ 10:00    │
├─────────────────────────┤
│ [+ Thêm giao dịch]      │
└─────────────────────────┘
```

**Tính năng lọc:**

- ✅ Lọc theo loại (Thu/Chi)
- ✅ Lọc theo danh mục (Food, Travel, Salary, v.v.)
- ✅ Lọc theo khoảng ngày
- ✅ Tìm kiếm theo nội dung ghi chú
- ✅ Sắp xếp (Ngày, Số tiền, Danh mục)

**Tương tác:**

- Tap giao dịch → Chi tiết + chỉnh sửa
- Swipe/long-press → Xóa
- Floating Action Button → Tạo giao dịch mới

### 8.1.4 Màn hình Tạo/Chỉnh sửa Giao dịch (Modal Form)

```
┌─────────────────────────┐
│ ✕ Thêm giao dịch        │
├─────────────────────────┤
│ Loại:                   │
│ [Thu] [Chi] ← toggle    │
├─────────────────────────┤
│ Danh mục:               │
│ [Dropdown: Food/...]    │
├─────────────────────────┤
│ Số tiền:                │
│ [______] (formatted)    │
├─────────────────────────┤
│ Ghi chú:                │
│ [______________]        │
├─────────────────────────┤
│ Ngày:                   │
│ [picker: 31/03/2026]    │
├─────────────────────────┤
│ Ví:                     │
│ [Dropdown: Cash/...]    │
├─────────────────────────┤
│ [Hủy]  [Lưu]            │
└─────────────────────────┘
```

**Validation realtime:**

- ✅ Số tiền > 0
- ✅ Danh mục bắt buộc
- ✅ Ngày không được trong tương lai
- ✅ Ví phải có số dư đủ (khi chỉnh sửa thành chi)

### 8.1.5 Màn hình Ví (Wallet Management)

**Tab: Danh sách ví**

```
┌─────────────────────────┐
│ Số dư toàn bộ:          │
│ 35,000,000₫             │
├─────────────────────────┤
│ 💵 Tiền mặt             │
│    15,000,000₫          │
├─────────────────────────┤
│ 🏧 Ngân hàng            │
│    20,000,000₫          │
├─────────────────────────┤
│ [+ Thêm ví mới]         │
└─────────────────────────┘
```

**Tab: Chuyển tiền**

```
┌─────────────────────────┐
│ Từ ví:                  │
│ [Dropdown: Tiền mặt]    │
├─────────────────────────┤
│ Sang ví:                │
│ [Dropdown: Ngân hàng]   │
├─────────────────────────┤
│ Số tiền:                │
│ [______]                │
├─────────────────────────┤
│ Ghi chú (tùy chọn):     │
│ [____________]          │
├─────────────────────────┤
│ [Hủy] [Chuyển]          │
└─────────────────────────┘
```

**Tính năng:**

- ✅ Hiển thị tất cả ví + số dư
- ✅ Tap ví để xem chi tiết & lịch sử giao dịch
- ✅ Edit tên/mô tả ví
- ✅ Chuyển tiền với validation số dư
- ✅ Toast confirmation sau chuyển thành công

### 8.1.6 Màn hình Văn bản (Profile/Settings)

```
┌─────────────────────────┐
│ 👤 [Avatar]             │
│ Tên: John Doe           │
│ Email: john@example.com │
├─────────────────────────┤
│ Theme: [Light/Dark]     │
│ Ngôn ngữ: [Việt]        │
├─────────────────────────┤
│ [Đổi mật khẩu]          │
│ [Đăng xuất]             │
└─────────────────────────┘
```

---

## 8.2. Luồng chức năng cốt lõi (CRUD Giao dịch End-to-End)

### 8.2.1 Sequence Diagram: CRUD Transaction Flow

**Diagram chi tiết:**

![CRUD Transaction Sequence Diagram](docs/diagrams/sequence_crud_transaction.png)

**Luồng chi tiết:**

```
┌─────────────┐         ┌──────────────┐      ┌─────────────┐
│   Flutter   │         │  Node.js API │      │  MongoDB    │
│   Mobile    │         │   (Express)  │      │             │
└─────────────┘         └──────────────┘      └─────────────┘
       │                        │                     │
       │  1. POST /transactions │                     │
       │  (with JWT token)      │                     │
       ├─────────────────────>  │                     │
       │                        │  2. Validate JWT    │
       │                        │  3. Parse request   │
       │                        │  4. Validate schema │
       │                        │                     │
       │                        │  5. Create document │
       │                        ├────────────────────>│
       │                        │                     │  6. Save to DB
       │                        │<────────────────────┤
       │ 7. Success response    │                     │
       │<─────────────────────  │                     │
       │ { id, type, amount... }│                     │
       │                        │                     │
       │  8. Save locally       │                     │
       │  9. Update UI          │                     │
       │                        │                     │
       │  10. GET /transactions │                     │
       │  (with filters)        │                     │
       ├─────────────────────>  │                     │
       │                        │  11. Query with filter
       │                        ├────────────────────>│
       │                        │                     │ 12. Find documents
       │                        │<────────────────────┤
       │ 13. Transactions list  │                     │
       │<─────────────────────  │                     │
       │ [{ id, ...}, ...]      │                     │
       │                        │                     │
       │  14. Tap to edit       │                     │
       │  15. PUT /transactions │                     │
       │  /:id                  │                     │
       ├─────────────────────>  │                     │
       │                        │  16. Update document
       │                        ├────────────────────>│
       │                        │                     │ 17. Update in DB
       │                        │<────────────────────┤
       │ 18. Updated data       │                     │
       │<─────────────────────  │                     │
       │                        │                     │
       │  19. Confirm update    │                     │
       │  on local state        │                     │
       │                        │                     │
       │  20. DELETE request    │                     │
       ├─────────────────────>  │                     │
       │  /transactions/:id     │                     │
       │                        │  21. Delete document
       │                        ├────────────────────>│
       │                        │                     │ 22. Remove from DB
       │                        │<────────────────────┤
       │ 23. Success           │                     │
       │<─────────────────────  │                     │
       │                        │                     │
```

### 8.2.2 Test Case: CREATE Transaction

**Preconditions:**

- ✅ User đã đăng nhập (có JWT token)
- ✅ Token còn hạn (< 7 ngày)
- ✅ Kiểm tra connection → Backend

**Test Steps:**

| Bước | Thao tác                 | Kỳ vọng                     | Kết quả |
| ---- | ------------------------ | --------------------------- | ------- |
| 1    | Mở app → Home            | Home screen hiển thị        | ✅ PASS |
| 2    | Tap "Thêm giao dịch"     | Modal form mở               | ✅ PASS |
| 3    | Chọn loại: "Chi"         | Toggle active "Chi"         | ✅ PASS |
| 4    | Chọn danh mục: "Food"    | Danh mục hiển thị "Food"    | ✅ PASS |
| 5    | Nhập số tiền: "150,000"  | Input nhận giá trị          | ✅ PASS |
| 6    | Nhập ghi chú: "Cơm trưa" | Input nhận giá trị          | ✅ PASS |
| 7    | Chọn ngày: hôm nay       | Ngày picker mở & set        | ✅ PASS |
| 8    | Chọn ví: "Tiền mặt"      | Dropdown set "Tiền mặt"     | ✅ PASS |
| 9    | Tap "Lưu"                | Nút bị disable (loading)    | ✅ PASS |
| 10   | Chờ API response         | - Loading indicator -       | ✅ PASS |
| 11   | API trả về success       | Modal đóng tự động          | ✅ PASS |
| 12   | Giao dịch xuất hiện list | Cơm trưa -150,000₫ hiển thị | ✅ PASS |
| 13   | Số dư ví cập nhật        | Tiền mặt: -150,000₫         | ✅ PASS |
| 14   | Số dư Home cập nhật      | Tổng -150,000₫              | ✅ PASS |

**Expected API Request:**

```json
POST https://smartspender-x1fl.onrender.com/api/v1/transactions
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "type": "expense",
  "category": "food",
  "amount": 150000,
  "note": "Cơm trưa",
  "date": "2026-03-31T12:00:00Z",
  "walletType": "CASH"
}
```

**Expected API Response:**

```json
{
  "success": true,
  "statusCode": 201,
  "data": {
    "_id": "65h7j8k9l0m1n2p3q4r5s6t7",
    "userId": "60h7j8k9l0m1n2p3q4r5s6t7",
    "type": "expense",
    "category": "food",
    "amount": 150000,
    "note": "Cơm trưa",
    "date": "2026-03-31T12:00:00.000Z",
    "walletType": "CASH",
    "createdAt": "2026-03-31T12:00:00.000Z",
    "updatedAt": "2026-03-31T12:00:00.000Z"
  },
  "message": "Tạo giao dịch thành công"
}
```

### 8.2.3 Test Case: READ Transaction (List with Filters)

**Preconditions:**

- ✅ User đã đăng nhập
- ✅ DB có ít nhất 5 giao dịch tháng hiện tại

**Test Steps:**

| Bước | Thao tác                 | Kỳ vọng                         | Kết quả |
| ---- | ------------------------ | ------------------------------- | ------- |
| 1    | Tap tab "Giao dịch"      | Transaction screen mở           | ✅ PASS |
| 2    | Autofetch giao dịch      | Bộ lọc mặc định: tháng hiện tại | ✅ PASS |
| 3    | Hiển thị loading         | Shimmer placeholders            | ✅ PASS |
| 4    | API response             | 5-10 giao dịch hiển thị         | ✅ PASS |
| 5    | Filter type = "Chi"      | Chỉ giao dịch chi hiển thị      | ✅ PASS |
| 6    | Filter category = "Food" | Chỉ Food categories             | ✅ PASS |
| 7    | Sort by amount DESC      | Số tiền lớn trước               | ✅ PASS |
| 8    | Search "cơm"             | Giao dịch có "cơm" hiển thị     | ✅ PASS |
| 9    | Pull to refresh          | Refetch data từ server          | ✅ PASS |

**Expected API Request:**

```
GET /api/v1/transactions?month=3&year=2026&type=expense&category=food&sortBy=amount&order=desc
Authorization: Bearer <JWT_TOKEN>
```

**Expected Response:**

```json
{
  "success": true,
  "statusCode": 200,
  "data": {
    "transactions": [
      {
        "_id": "...",
        "type": "expense",
        "category": "food",
        "amount": 250000,
        "note": "Cơm tối"
      },
      {
        "_id": "...",
        "type": "expense",
        "category": "food",
        "amount": 150000,
        "note": "Cơm trưa"
      }
    ],
    "total": 2,
    "page": 1,
    "limit": 20
  },
  "message": "Lấy giao dịch thành công"
}
```

### 8.2.4 Test Case: UPDATE Transaction

**Preconditions:**

- ✅ Giao dịch đã tồn tại
- ✅ User là chủ nhân transaction

**Test Steps:**

| Bước | Thao tác                       | Kỳ vọng                  | Kết quả |
| ---- | ------------------------------ | ------------------------ | ------- |
| 1    | Tap giao dịch trong list       | Chi tiết transaction mở  | ✅ PASS |
| 2    | Tap "Chỉnh sửa"                | Form edit mở với data cũ | ✅ PASS |
| 3    | Sửa số tiền: 150,000 → 200,000 | Input cập nhật           | ✅ PASS |
| 4    | Tap "Lưu"                      | Loading indicator        | ✅ PASS |
| 5    | API success                    | Form đóng, list refresh  | ✅ PASS |
| 6    | Kiểm tra list                  | Giao dịch show 200,000   | ✅ PASS |
| 7    | Kiểm tra ví                    | Số dư cập nhật (-50,000) | ✅ PASS |

**Expected API Request:**

```json
PUT /api/v1/transactions/65h7j8k9l0m1n2p3q4r5s6t7
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "amount": 200000,
  "note": "Cơm trưa (sửa)"
}
```

### 8.2.5 Test Case: DELETE Transaction

**Preconditions:**

- ✅ Giao dịch tồn tại trong list
- ✅ Backend API khả dụng

**Test Steps:**

| Bước | Thao tác             | Kỳ vọng              | Kết quả |
| ---- | -------------------- | -------------------- | ------- |
| 1    | Long-press giao dịch | Confirm dialog mở    | ✅ PASS |
| 2    | Tap "Xóa"            | Confirmation dialog  | ✅ PASS |
| 3    | Tap "Có, xóa"        | Loading indicator    | ✅ PASS |
| 4    | API success          | Dialog đóng          | ✅ PASS |
| 5    | Giao dịch biến mất   | List refresh tự động | ✅ PASS |
| 6    | Số dư ví restore     | Tiền mặt +150,000    | ✅ PASS |
| 7    | Toast notification   | "Xóa thành công"     | ✅ PASS |

**Expected API Request:**

```
DELETE /api/v1/transactions/65h7j8k9l0m1n2p3q4r5s6t7
Authorization: Bearer <JWT_TOKEN>
```

### 8.2.6 Error Handling & Edge Cases

#### Case 1: Network Error

- **Tình huống:** API không phản hồi / timeout
- **Expected behavior:**
  - ✅ Hiển thị error toast: "Kết nối thất bại"
  - ✅ Nút "Retry" để thử lại
  - ✅ Local data vẫn được lưu (offline support)
  - ✅ Sync khi online trở lại

#### Case 2: Token Expired

- **Tình huống:** JWT token hết hạn
- **Expected behavior:**
  - ✅ API trả 401 Unauthorized
  - ✅ Mobile redirect sang Login screen
  - ✅ Toast message: "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại"
  - ✅ Token được xóa khỏi shared_preferences

#### Case 3: Validation Error

- **Tình huống:** Form submit với dữ liệu không hợp lệ (số tiền = 0)
- **Expected behavior:**
  - ✅ Mobile reject trước khi gửi request
  - ✅ Highlight field lỗi (red border)
  - ✅ Tooltip message: "Số tiền phải > 0"
  - ✅ Nút submit disabled

#### Case 4: Insufficient Balance

- **Tình huống:** Chuyển tiền nhưng ví không đủ số dư
- **Expected behavior:**
  - ✅ Server validates & trả 400 Bad Request
  - ✅ Mobile hiển thị error: "Số dư không đủ"
  - ✅ Transaction không được tạo
  - ✅ Ví balance không thay đổi

### 8.2.7 Performance Metrics

| Metric                   | Target  | Actual     |
| ------------------------ | ------- | ---------- |
| **API Response Time**    | < 500ms | 200-300ms  |
| **List Load (10 items)** | < 1s    | 400-600ms  |
| **Create Transaction**   | < 1.5s  | 800-1000ms |
| **Update Transaction**   | < 1.5s  | 800-1000ms |
| **Delete Transaction**   | < 1s    | 500-700ms  |
| **App Launch Time**      | < 2s    | 1.2-1.5s   |
| **Memory Usage**         | < 100MB | 60-80MB    |

### 8.2.8 Testing Coverage

**Backend:**

- ✅ 13/13 test suites pass
- ✅ 149/149 unit/integration tests pass
- ✅ Code coverage: 85%+

**Mobile:**

- ✅ Widget tests: 40+ test cases pass
- ✅ Provider tests: State management validated
- ✅ Form validation: All validators tested
- ✅ Error scenarios: Network, auth, validation covered

---

## 8.3. Activity Diagram: Luồng thống kê (Statistics)

**Diagram chi tiết:**

![Activity Statistics Diagram](docs/diagrams/activity_statistics.png)

**Mô tả luồng:**

1. **User mở màn hình Statistics**
   - App gọi API: `GET /api/statistics/summary?month=3&year=2026&JWT`

2. **Validate JWT**
   - ✅ JWT hợp lệ → Tiếp tục
   - ❌ JWT không hợp lệ → Trả lỗi 401, redirect Login

3. **Backend xử lý**
   - Validate input (month/year)
   - Query DB: Lấy tất cả transactions của user trong tháng
   - Tính toán:
     - `totalIncome`: Tổng giao dịch type=income
     - `totalExpense`: Tổng giao dịch type=expense
     - `Balance`: totalIncome - totalExpense

4. **Return Response 200**
   - Trả JSON: { totalIncome, totalExpense, balance, transactions[] }

5. **Mobile UI render**
   - Vẽ Pie Chart (Thu% vs Chi%)
   - Vẽ Bar Chart (Ngày → Số tiền)
   - Hiển thị số dư tính toán

6. **User thay đổi filter**
   - Chọn "From-To" hoặc "Month-Year"
   - App tạo query mới
   - Gọi lại API với params mới
   - UI update lại charts

7. **Error handling**
   - Nếu lỗi → Hiển thị error message
   - Nút Retry

---

## 8.3. Kết luận (UPDATED)

Ứng dụng SmartSpender đã hoàn thiện các chức năng cốt lõi:

✅ **Authentication:** Đăng ký/Đăng nhập với JWT  
✅ **CRUD Transactions:** Tạo/Sửa/Xóa/Lọc giao dịch  
✅ **Wallet Management:** Quản lý ví, chuyển tiền  
✅ **Statistics:** Thống kê thu/chi/số dư  
✅ **Data Sync:** Đồng bộ số dư trên Home/Wallet/Transaction  
✅ **Error Handling:** Xử lý lỗi toàn cục, offline support  
✅ **Performance:** Optimized loading, caching, pagination  
✅ **Security:** JWT auth, rate limiting, input validation  
✅ **API Documentation:** Swagger UI + JSDoc  
✅ **Testing:** Unit + Integration tests, E2E checklist

Dự án sẵn sàng để deploy staging/production và UAT.

---

## 9. Tài liệu tham khảo

| Tài liệu               | Link                                                       |
| ---------------------- | ---------------------------------------------------------- |
| **Swagger UI (Local)** | `http://localhost:3000/api-docs`                           |
| **Swagger UI (Prod)**  | `https://smartspender-x1fl.onrender.com/api-docs`          |
| **GitHub Repository**  | `https://github.com/Minh08012005/SmartSpender`             |
| **Backend README**     | `backend/README-DEPLOY.md`                                 |
| **Flutter Docs**       | `https://flutter.dev/docs`                                 |
| **Express.js Docs**    | `https://expressjs.com`                                    |
| **MongoDB Docs**       | `https://docs.mongodb.com`                                 |
| **Postman Collection** | `backend/postman/cud-auth-testing.postman_collection.json` |
| **Development Guide**  | `DEVELOPMENT_GUIDE.md`                                     |
| **Setup Guide**        | `SETUP_GUIDE.md`                                           |
| **E2E Checklist**      | `MOBILE_E2E_TEST_CHECKLIST.md`                             |

---

**Cập nhật lần cuối:** 31/03/2026  
**Trạng thái:** ✅ Sẵn sàng UAT  
**Phiên bản:** 1.0.0
