![alt text](image.png)# 📋 Mẫu Slide ISA Chi Tiết - SmartSpender

> **Hướng dẫn viết nội dung slide + Biểu đồ tương ứng**  
> **Base:** CNPM slides của nhóm (chỉ cần sửa nội dung khoảng)

---

## 📊 CẤU TRÚC SLIDE (13 slides tổng cộng)

| #   | Tên Slide                      | Nội dung                                     | Biểu đồ              |
| --- | ------------------------------ | -------------------------------------------- | -------------------- |
| 1   | Giới thiệu                     | Team, dự án, mục tiêu                        | Logo + Table         |
| 2   | Tổng quan Kiến trúc            | 3 lớp chính                                  | 3-Layer diagram      |
| 3   | Lớp Presentation               | Flutter Web/Mobile, UI                       | Layer detail         |
| 4   | Lớp Application                | Express, Controllers, Services               | Layer detail         |
| 5   | Lớp Data                       | MongoDB, Collections                         | Layer detail         |
| 6   | Luồng API & REST               | HTTP methods, Status codes, Request-Response | Card/Table           |
| 7   | Xác thực JWT                   | Token flow, Stateless                        | JWT flow diagram     |
| 8   | Middleware Pipeline            | Tuần tự xử lý request                        | Pipeline diagram     |
| 9   | MVC Pattern                    | Controller-Service-Model                     | Layer diagram        |
| 10  | Deployment                     | Triển khai thực tế                           | Architecture diagram |
| 11  | Ví dụ Flow: User Login         | Step by step từ UI → DB                      | Sequence diagram     |
| 12  | Ví dụ Flow: Create Transaction | CRUD transaction                             | Sequence diagram     |
| 13  | Hướng mở rộng                  | 3-Tier → Microservices                       | Evolution diagram    |

---

## 📝 CHI TIẾT TỪNG SLIDE

### **SLIDE 1: Giới Thiệu SmartSpender**

**Tiêu đề:**

```
SmartSpender - Ứng dụng Quản lý Chi Tiêu Cá Nhân
```

**Nội dung slide:**

**Mục tiêu dự án:**

- Quản lý chi tiêu cá nhân trên nền tảng di động
- Ghi nhận các giao dịch (chi, thu) theo thời gian thực
- Phân loại chi tiêu & xem báo cáo thống kê

**Team phát triển (5 thành viên):**
| Tên | Vai trò | Trách nhiệm |
|-----|---------|-----------|
| Mai Huy Minh | Leader | Tổng hợp + Review kiến trúc |
| Nguyễn Văn Duy | Backend Dev | API Authentication, Transaction |
| Vũ Nguyễn Ngọc Bảo | Backend Dev | Wallet, Statistic API |
| Trịnh Thái Sơn | Mobile Dev | Flutter UI/UX, State Management |
| Lê Đức Anh | Mobile Dev | Flutter UI/UX, Provider Integration |

**Tech Stack:**

- **Frontend:** Flutter (Android, iOS, Web), Provider (State), Dio (HTTP)
- **Backend:** Node.js, Express.js, Mongoose (ODM)
- **Database:** MongoDB Atlas (Cloud)
- **Authentication:** JWT + bcrypt password hashing
- **Deployment:** GitHub Actions (CI/CD), Render (Node.js), GitHub Pages (Web)

---

---

### **SLIDE 2: Tổng Quan Kiến Trúc 3-Tier**

**Tiêu đề:**

```
Kiến Trúc N-Tier: Client - Server - Database
```

**Nội dung slide:**

**3 Lớp chính của SmartSpender:**

```
┌──────────────────────────────────┐
│  🎨 PRESENTATION LAYER           │
│  (Flutter Mobile, Web, Desktop)  │
│  - UI Components                 │
│  - State Management (Provider)   │
│  - HTTP Client (Dio)             │
└──────────────── ↓ ────────────────┘
         (REST API via HTTPS)
┌──────────────────────────────────┐
│  🌐 APPLICATION LAYER            │
│  (Node.js + Express.js)          │
│  - Routes & Controllers          │
│  - Business Logic (Services)     │
│  - Auth Middleware & Validation  │
│  - Model Definition (Mongoose)   │
└──────────────── ↓ ────────────────┘
┌──────────────────────────────────┐
│  💾 DATA LAYER                   │
│  (MongoDB Atlas)                 │
│  - Users, Transactions, Wallets  │
│  - Persistent Storage            │
└──────────────────────────────────┘
```

**Tại sao 3-Tier:**

- ✅ **Separation of Concerns:** Mỗi lớp có nhiệm vụ riêng
- ✅ **Scalability:** Dễ mở rộng từng lớp độc lập
- ✅ **Maintainability:** Code tổ chức rõ ràng, dễ bảo trì
- ✅ **Testability:** Kiểm thử từng lớp riêng biệt
- ✅ **Security:** Xác thực & kiểm tra tập trung tại middleware

---

### **SLIDE 3: Lớp Presentation (Client - Flutter)**

**Tiêu đề:**

```
Lớp Presentation: Giao Diện & Quản Lý Trạng Thái
```

**Nội dung slide:**

**Trách nhiệm:**

- Hiển thị dữ liệu cho người dùng
- Nhận input từ người dùng & validate
- Quản lý trạng thái ứng dụng (State Management)
- Gọi API Backend thông qua HTTP

**Công nghệ chính:**

- **Flutter Framework:** Cross-platform (Android, iOS, Web)
- **Provider:** Quản lý state với ChangeNotifier
- **Dio:** HTTP client với request/response interceptors

**Cấu trúc Presentation Layer:**

```
📱 Flutter App
├── Screens/Pages
│   ├── LoginScreen (đăng nhập/đăng ký)
│   ├── HomeScreen (tổng quan chi tiêu)
│   ├── TransactionScreen (CRUD giao dịch)
│   ├── WalletScreen (quản lý ví)
│   └── ProfileScreen (thông tin user)
├── Providers (State Management)
│   ├── AuthProvider (user, token, login/logout)
│   ├── TransactionProvider (danh sách, filter, CRUD)
│   ├── WalletProvider (ví, chuyển tiền, số dư)
│   └── StatisticProvider (báo cáo tháng/năm)
├── Services
│   └── ApiService (Dio HTTP client)
└── Models
    ├── UserModel (parsing JSON từ API)
    ├── TransactionModel
    └── WalletModel
```

**Luồng tương tác:**
User nhấn → UI call Provider → Provider call Service → Service call API → Parse JSON → UI re-render

---

### **SLIDE 4: Lớp Application (Backend - Node.js)**

**Tiêu đề:**

```
Lớp Application: Xử Lý Logic Kinh Doanh
```

**Nội dung slide:**

**Trách nhiệm:**

- Nhận HTTP request từ client
- Xác thực JWT & kiểm tra quyền hạn
- Validate dữ liệu input
- Xử lý business logic
- Gọi database & trả response

**Công nghệ chính:**

- **Express.js:** Web framework, routing
- **Mongoose:** ODM (Object-Document Mapping)
- **Middleware Pipeline:** Xử lý request tuần tự

**Cấu trúc Application Layer (MVC):**

```
HTTP Request
    ↓
┌─────────────────────────────────┐
│ Routes (express.Router)          │  ← Định tuyến
│ POST /api/auth/login             │
│ POST /api/transactions           │
│ GET /api/wallets                 │
└──────────────┬────────────────────┘
               ↓
┌─────────────────────────────────┐
│ Middleware Pipeline              │  ← Xử lý tuần tự
│ 1. JWT Verification              │
│ 2. Input Validation (Joi)        │
│ 3. Rate Limiting                 │
│ 4. Error Handling                │
└──────────────┬────────────────────┘
               ↓
┌─────────────────────────────────┐
│ Controllers                      │  ← Nhận request
│ AuthController.login()           │
│ TransactionController.create()   │
│ WalletController.transfer()      │
└──────────────┬────────────────────┘
               ↓
┌─────────────────────────────────┐
│ Services (Business Logic)        │  ← Xử lý logic
│ AuthService: hash password       │
│ TransactionService: validate     │
│ WalletService: update balance    │
└──────────────┬────────────────────┘
               ↓
        Database Query
        (Mongoose Models)
```

---

### **SLIDE 5: Lớp Data (MongoDB)**

**Tiêu đề:**

```
Lớp Data: Lưu Trữ & Quản Lý Dữ Liệu
```

**Nội dung slide:**

**Công nghệ:**

- **MongoDB Atlas:** Cloud database (NoSQL, document-based)
- **Mongoose:** ODM + schema validation

**Collections (Bảng dữ liệu):**

1. **Users** - Quản lý người dùng
   - `_id`: MongoDB ObjectId (primary key)
   - `email`: Unique, for login
   - `password`: Hash (bcrypt)
   - `fullName`: User's name
   - `avatar`: User's avatar URL
   - `createdAt`, `updatedAt`: Timestamps

2. **Transactions** - Ghi nhận giao dịch
   - `_id`: ObjectId
   - `userId`: Foreign key → Users
   - `type`: "income" | "expense"
   - `category`: "food", "transport", "salary"...
   - `amount`: Số tiền (VND)
   - `note`: Mô tả giao dịch
   - `date`: Ngày giao dịch
   - `createdAt`, `updatedAt`: Timestamps

3. **Wallets** - Quản lý ví tiền
   - `_id`: ObjectId
   - `userId`: Foreign key → Users
   - `name`: "Tiền mặt", "Ngân hàng", "VCB Tiết Kiệm"...
   - `type`: "cash" | "bank" | "savings"
   - `balance`: Số dư hiện tại
   - `currency`: "VND"
   - `createdAt`, `updatedAt`: Timestamps

4. **WalletTransfers** - Lịch sử chuyển tiền
   - `_id`: ObjectId
   - `fromWalletId`: Foreign key → Wallets
   - `toWalletId`: Foreign key → Wallets
   - `amount`: Số tiền chuyển
   - `status`: "completed" | "failed"
   - `createdAt`: Timestamp

**Tính năng:**

- ✅ Atlas tự động backup
- ✅ Mongoose validation (schema enforcement)
- ✅ Indexing (tìm kiếm nhanh)
- ✅ Aggregation (báo cáo thống kê)

---

### **SLIDE 6: REST API & HTTP Methods**

**Tiêu đề:**

```
Luồng API: Client ↔ Server (REST + HTTP)
```

**Nội dung slide:**

**RESTful Design Principles:**

- **Resource-based URLs:** `/api/transactions`, `/api/wallets`
- **HTTP Methods có ý nghĩa:**
  - `GET` → Lấy dữ liệu (Read)
  - `POST` → Tạo mới (Create)
  - `PUT` → Cập nhật toàn bộ document (Update ALL)
  - `PATCH` → Cập nhật một phần (Update PARTIAL)
  - `DELETE` → Xóa (Delete)

**Ví dụ API Endpoints:**

| Method | Endpoint                  | Mô tả               | Auth |
| ------ | ------------------------- | ------------------- | ---- |
| POST   | `/api/auth/register`      | Tạo tài khoản mới   | No   |
| POST   | `/api/auth/login`         | Đăng nhập, nhận JWT | No   |
| GET    | `/api/transactions`       | Danh sách giao dịch | JWT  |
| POST   | `/api/transactions`       | Tạo giao dịch mới   | JWT  |
| PUT    | `/api/transactions/:id`   | Cập nhật giao dịch  | JWT  |
| DELETE | `/api/transactions/:id`   | Xóa giao dịch       | JWT  |
| GET    | `/api/wallets`            | Danh sách ví        | JWT  |
| POST   | `/api/wallets/transfer`   | Chuyển tiền         | JWT  |
| GET    | `/api/statistics/summary` | Báo cáo tháng/năm   | JWT  |

**Request-Response Format (JSON):**

```
Request Header:
POST /api/transactions
Authorization: Bearer eyJhbGc...
Content-Type: application/json

Request Body:
{
  "type": "expense",
  "category": "food",
  "amount": 50000,
  "note": "Ăn trưa",
  "date": "2025-01-15"
}

Response (200 OK):
{
  "success": true,
  "message": "Tạo giao dịch thành công",
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": "507f1f77bcf86cd799439012",
    "type": "expense",
    "category": "food",
    "amount": 50000,
    "date": "2025-01-15",
    "createdAt": "2025-01-15T10:30:00Z"
  }
}
```

---

### **SLIDE 7: Xác Thực JWT (Authentication & Authorization)**

**Tiêu đề:**

```
JWT Authentication: Token-Based Stateless Auth
```

**Nội dung slide:**

**Luồng Authentication:**

1. **Login:** User gửi email + password → Backend verify → Tạo JWT
2. **Each Request:** JWT được gửi trong Authorization header
3. **Verification:** Middleware verify JWT signature trước khi xử lý request
4. **Logout:** Delete token ở client (không có logout server-side)

**JWT Token Structure:**

```
Header: {"alg": "HS256", "typ": "JWT"}
Payload: {"userId": "507f...", "email": "user@gmail.com", "iat": 1234..., "exp": 1234...}
Signature: HMACSHA256(header.payload + secret_key)

Complete JWT:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQi.Qh4j...
```

**Quy trình chi tiết:**

```
User Input (Email, Password)
    ↓
POST /api/auth/login
    ↓
AuthController.login()
    ↓
AuthService.verifyPassword(inputPwd, hashedPwd)  ← bcrypt compare
    ↓
Nếu đúng:
  - Tạo JWT token (chứa userId, email, expiration)
  - Trả JWT về client
  Nếu sai:
  - Trả error 401 Unauthorized
    ↓
Client lưu JWT vào localStorage/secureStorage
    ↓
Mỗi request sau đó:
  Authorization: Bearer {JWT}
    ↓
JWT Middleware verify signature & check expiration
    ↓
Nếu hợp lệ → Cho phép access
Nếu hết hạn → Trả 401, yêu cầu login lại
```

**Security:**

- ✅ **Stateless:** Server không lưu session
- ✅ **Tamper-proof:** JWT signature
- ✅ **Expiration:** Token hết hạn sau N phút
- ✅ **HTTPS:** Mã hóa transmission

---

### **SLIDE 8: Middleware Pipeline**

**Tiêu đề:**

```
Middleware: Xử Lý Request Tuần Tự
```

**Nội dung slide:**

**Middleware là gì:**
Middleware là function xử lý request tuần tự, có thể:

- Kiểm tra điều kiện (JWT, input)
- Chuyển đổi dữ liệu
- Ghi log request
- Xử lý lỗi toàn cục

**Middleware Pipeline của SmartSpender:**

```
Incoming Request
    ↓
[1] CORS Middleware
    - Cho phép cross-origin requests
    ↓
[2] Body Parser Middleware
    - Parse request body (JSON, form-data)
    ↓
[3] JWT Verification Middleware
    - Verify Authorization header
    - Extract userId từ token
    - req.user = decoded JWT payload
    - Nếu lỗi → return 401
    ↓
[4] Input Validation Middleware (Joi/Express-Validator)
    - Validate schema request body
    - Kiểm tra required fields, types, formats
    - Nếu invalid → return 400 Bad Request
    ↓
[5] Rate Limiting Middleware
    - Giới hạn số requests từ 1 IP
    - Ví: 100 requests/15 phút
    - Nếu vượt → return 429 Too Many Requests
    ↓
[6] Route Handler (Controller)
    - Xử lý business logic
    ↓
[7] Error Handling Middleware (catch-all)
    - Bắt tất cả lỗi từ trên
    - Log error, gửi response 500
    - Prevent server crash
```

**Ví dụ code (Express.js):**

```javascript
// Middleware stack (order matters!)
app.use(cors());
app.use(express.json());
app.use(jwtVerify); // Verify JWT
app.use(validateInput); // Validate body
app.use(rateLimit); // Rate limit
app.use(errorHandler); // Top-level error handler
```

---

### **SLIDE 9: MVC Pattern**

**Tiêu đề:**

```
MVC Pattern: Tách biệt Model - View - Controller
```

**Nội dung slide:**

**MVC (Model-View-Controller):**

| Thành phần     | Vai trò                                       | Ví dụ SmartSpender                          |
| -------------- | --------------------------------------------- | ------------------------------------------- |
| **Model**      | Định nghĩa schema, validate, query DB         | User, Transaction, Wallet (Mongoose Models) |
| **View**       | Trình bày dữ liệu cho user                    | Flutter UI (HomeScreen, TransactionScreen)  |
| **Controller** | Nhận request, gọi Model/Service, trả response | AuthController, TransactionController       |

**Cấu trúc MVC trong SmartSpender:**

```
Browser/Fleet App (CLIENT)
    ↓ HTTP Request
    ↓
Router: /api/transactions (Express Route)
    ↓
TransactionController.getAll()
    ├→ Kiểm tra quyền (JWT)
    ├→ Gọi TransactionService.findUserTransactions(userId)
    │   └→ TransactionService.findUserTransactions()
    │       └→ Transaction.find({userId}) [Mongoose Model]
    │           └→ MongoDB: db.transactions.find()
    ├→ Format response data
    └→ res.json({success, data, message})
    ↓ HTTP Response (JSON)
    ↓
Browser/Flutter App (CLIENT)
    ↓ Render UI với dữ liệu
```

**Lợi ích MVC:**

- ✅ **Separation:** Dễ phân công việc team
- ✅ **Reusability:** Service dùng lại cho nhiều Controller
- ✅ **Testability:** Unit test từng phần
- ✅ **Maintainability:** Thay đổi 1 phần không ảnh hưởng toàn bộ

---

### **SLIDE 10: Deployment & Infrastructure**

**Tiêu đề:**

```
Triển Khai: Đưa Ứng Dụng Lên Production
```

**Nội dung slide:**

**Infrastructure Architecture:**

```
┌─────────────────────────────────┐
│    Client Layer (Frontend)       │
├─────────────────────────────────┤
│ ✅ GitHub Pages                  │
│    - Tài sản tĩnh (HTML, JS, CSS)
│    - Smart Spender.pages.dev    │
│ ✅ APK/iOS App Store            │
│    - Flutter compiled app        │
└─────────────────────────────────┘
         ↓ HTTPS REST API
┌─────────────────────────────────┐
│    Server Layer (Backend)        │
├─────────────────────────────────┤
│ ✅ Render (render.com)           │
│    - Node.js + Express.js        │
│    - Auto-deploy from GitHub     │
│    - Environment variables       │
│    - Always-on dyno              │
└─────────────────────────────────┘
         ↓ Database Connection
┌─────────────────────────────────┐
│    Database Layer                │
├─────────────────────────────────┤
│ ✅ MongoDB Atlas (Cloud)         │
│    - NoSQL database              │
│    - Auto-backup & replication   │
│    - Connection pooling          │
│    - Activity monitoring         │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│    Version Control & CI/CD       │
├─────────────────────────────────┤
│ ✅ GitHub Repository             │
│    - Source code management     │
│ ✅ GitHub Actions (CI/CD)        │
│    - Auto-test on push          │
│    - Auto-build & deploy        │
│    - Run backend tests          │
└─────────────────────────────────┘
```

**Deployment Flow:**

```
Developer commit & push code
    ↓
GitHub Actions trigger
    ↓
[1] Run tests (Jest/Mocha)
[2] Build Node.js app
[3] Check environment
    ↓
Render auto-deploy
    ↓
Server restart với code mới
    ↓
✅ Live trên production
```

**Environment Variables:**

```
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/db
JWT_SECRET=secret_key_123
```

---

### **SLIDE 11: Ví Dụ Flow - User Login**

**Tiêu đề:**

```
Sequence Diagram: Step-by-Step User Login
```

**Nội dung slide:**

**Luồng Login từ UI → DB:**

```
Từng bước chi tiết:

1️⃣  User → UI: Nhập email & password → Nhấn Login

2️⃣  UI → Validate:
    - Email có format đúng?
    - Password có ≥ 6 ký tự?
    - Nếu lỗi → hiển thị error message

3️⃣  UI → POST /api/auth/login
    Headers: {"Content-Type": "application/json"}
    Body: {"email": "user@gmail.com", "password": "abc123"}

4️⃣  Backend: AuthController.login()
    - Nhận email, password từ request
    - Lấy user từ DB: User.findOne({email})
    - Nếu user không tìm thấy → return 401 "Wrong email"

5️⃣  Backend: AuthService.verifyPassword()
    - Hashing password từ request với bcrypt
    - So sánh với password hash trong DB
    - Nếu không match → return 401 "Wrong password"

6️⃣  JWT Generation:
    - Tạo JWT token chứa userId, email, exp
    - JWT = sign({userId, email}, secret_key, {expiresIn: '7d'})

7️⃣  Return Response:
    {
      "success": true,
      "message": "Đăng nhập thành công",
      "token": "eyJhbGc...",
      "user": {"id": "...", "email": "user@gmail.com", "fullName": "..."}
    }

8️⃣  UI: Lưu JWT
    - localStorage.setItem('token', response.token)
    - AuthProvider.setUserData(response.user)
    - Redirect → HomeScreen

9️⃣  UI: Subsequent Requests:
    - GET /api/transactions
    - Headers: {"Authorization": "Bearer eyJhbGc..."}

🔟 Backend Middleware:
    - JWT Middleware verify token
    - Extract userId từ payload
    - req.user = decoded data
    - Cho phép access protected routes
```

**Error Cases:**

```
❌ Email not found
    ← 401 Unauthorized: "Email hoặc mật khẩu sai"

❌ Password incorrect
    ← 401 Unauthorized: "Email hoặc mật khẩu sai"

❌ Database error
    ← 500 Internal Server Error: "Lỗi server, thử lại sau"
```

---

### **SLIDE 12: Ví Dụ Flow - Create Transaction (CRUD)**

**Tiêu đề:**

```
Sequence Diagram: Create Transaction (Chi tiêu)
```

**Nội dung slide:**

**Luồng CRUD Giao Dịch (Create, Read, Update, Delete):**

**[CREATE] Thêm giao dịch mới:**

```
1️⃣  User → UI: Nhập chi tiêu
    - Type: "expense"
    - Category: "food"
    - Amount: "50000" VND
    - Note: "Ăn trưa"
    - Date: "2025-01-15"

2️⃣  UI → Validate:
    - Amount > 0?
    - Category valid?
    - Date không trong tương lai?
    → TransactionProvider.createTransaction()

3️⃣  Provider → POST /api/transactions
    Authorization: Bearer JWT
    Body: {
      "type": "expense",
      "category": "food",
      "amount": 50000,
      "note": "Ăn trưa",
      "date": "2025-01-15"
    }

4️⃣  Middleware Pipeline:
    [JWT Verify] ✓ Valid
    [Input Validate] ✓ Valid
    [Rate Limit] ✓ OK
    → TransactionController.create()

5️⃣  Backend Logic:
    - TransactionService.create()
    - Validate amount > 0
    - Nếu "expense" → cập nhật wallet balance
      Wallet.balance -= amount
      Wallet.save()
    - Tạo transaction record:
      Transaction.create({
        userId, type, category, amount, note, date
      })

6️⃣  Database Insert:
    DB.transactions.insertOne({
      userId: ObjectId("..."),
      type: "expense",
      category: "food",
      amount: 50000,
      date: ISODate("2025-01-15"),
      createdAt: ISODate("2025-01-15T10:30:00Z")
    })

7️⃣  Response ← Backend:
    {
      "success": true,
      "message": "Tạo giao dịch thành công",
      "data": {
        "_id": "507f1f77bcf86cd799439011",
        "amount": 50000,
        "createdAt": "2025-01-15T10:30:00Z"
      }
    }

8️⃣  UI Update:
    - TransactionProvider refresh danh sách
    - Hiển thị success toast
    - Cập nhật wallet balance trên UI
    - Quay lại TransactionScreen
```

**[READ] Lấy danh sách giao dịch:**

```
GET /api/transactions?month=1&year=2025
    ↓
Service query: Transaction.find({
      userId,
      date: {$gte: "2025-01-01", $lt: "2025-02-01"}
    })
    ↓
Return sorted by date DESC
    ↓
UI: Hiển thị list
```

**[UPDATE] Sửa giao dịch:**

```
PUT /api/transactions/:id
Body: {amount: 60000, category: "transport"}
    ↓
Check authorization (userId match)
    ↓
Update DB: Transaction.findByIdAndUpdate()
    ↓
Nếu amount thay đổi → cập nhật wallet balance
    ↓
Return updated transaction
```

**[DELETE] Xóa giao dịch:**

```
DELETE /api/transactions/:id
    ↓
Find transaction
    ↓
Check authorization
    ↓
Delete: Transaction.findByIdAndDelete()
    ↓
Hoàn lại wallet balance (nếu expense)
    ↓
Return 200 OK
```

---

### **SLIDE 13: Hướng Mở Rộng - 3-Tier → Microservices**

**Tiêu đề:**

```
Evolutionary Architecture: 3-Tier → Microservices → Event-Driven
```

**Nội dung slide:**

**Tại sao cần mở rộng:**

Hiện tại SmartSpender dùng **Monolithic 3-Tier Architecture:**

- ✅ Phù hợp quy mô hiện tại (5 người)
- ✅ Deploy đơn giản
- ⚠️ Khi tăng user: performance xuống, khó maintain, deploy toàn bộ

**Giai đoạn tiến hóa:**

```
Giai Đoạn 1: Monolithic (Hiện tại)
┌──────────────────────────────┐
│ Express.js (All Logic)       │
│ - Auth routes                │
│ - Transaction routes         │
│ - Wallet routes              │
│ - Statistic routes           │
│ - Notification logic         │
└──────────────────────────────┘
Deployed: Single instance (Render)

↓ Khi app phát triển...

Giai Đoạn 2: Microservices Architecture
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Auth Service │  │ Wallet       │  │ Transaction  │
│ (Port 3001)  │  │ Service      │  │ Service      │
│              │  │ (Port 3002)  │  │ (Port 3003)  │
└──────────────┘  └──────────────┘  └──────────────┘
         │                │                 │
         └────────────────┴─────────────────┘
                    ↓
        API Gateway / Load Balancer
                    ↓
              MongoDB Atlas
              (Shared DB)

Mỗi service có:
- Riêng logic, routes, models
- Riêng instance, port
- Dễ scale từng service
- Deploy riêng lẻ


↓ Tiếp tục phát triển...

Giai Đoạn 3: Event-Driven Architecture (Future)
Service communicate qua Message Broker:

┌──────────────┐         ┌──────────────┐
│ Transaction  │ ─emit─→ │ Message      │ ─subscribe→ Wallet Service
│ Service      │ "tx"    │ Broker       │
└──────────────┘         │ (RabbitMQ/   │ ─subscribe→ Notification
                         │  Kafka)      │ Service
                         └──────────────┘ ─subscribe→
                                          Statistic Service

Lợi ích:
- Loose coupling (services độc lập)
- Async processing (không block)
- Easy to scale individual services
- Complex orchestration khả thi
```

**6 Khía cạnh kiến trúc ISA áp dụng:**

| #   | Khía cạnh              | SmartSpender Hiện Tại      | Tương Lai                       |
| --- | ---------------------- | -------------------------- | ------------------------------- |
| 1   | **Tính liên kết**      | Lỏng (loose coupling)      | Rất lỏng (event-driven)         |
| 2   | **Khả năng mô rộng**   | Vertical (tăng tài nguyên) | Horizontal (thêm instances)     |
| 3   | **Tính độc lập**       | Phần nào (separate layers) | Hoàn toàn (autonomous services) |
| 4   | **Cloud-native**       | Đạt được (render + atlas)  | Tối ưu (containers + k8s)       |
| 5   | **Khả năng thích ứng** | Ba lớp cố định             | Linh hoạt + event-driven        |
| 6   | **Độ phức tạp**        | Vừa phải                   | Cao hơn (tradeoff)              |

**Kế hoạch tiến hóa:**

```
📅 Phase 1 (Hiện tại): 3-Tier Monolithic
   - Authentication + Authorization (JWT)
   - Transaction CRUD + Statistic
   - Wallet Management + Transfer
   - Status: Production-ready

📅 Phase 2 (6 tháng): Microservices
   - Tách Auth → separate service
   - Tách Transactions → separate service
   - API Gateway quản lý routing
   - Shared MongoDB (database per service pattern)

📅 Phase 3 (1 năm): Event-Driven + Real-time
   - Message broker (RabbitMQ/Kafka)
   - Notifications real-time
   - Statistic aggregation async
   - Advanced orchestration
```

---

**Biểu đồ:**

```
Login Flow:
┌──────────┐         ┌──────────┐
│  Client  │         │  Server  │
└────┬─────┘         └────┬─────┘
     │ POST /login        │
     ├───────────────────>│
     │                    │ verify password
     │                    │ create JWT
     │<───────────────────┤ {token: "..."}
     │                    │
     │ GET /transactions  │
     │ +Bearer token      │
     ├───────────────────>│
     │                    │ verify token
     │<───────────────────┤ [data]
```

---

### **SLIDE 8: Middleware Pipeline**

**Tiêu đề slide:**

```
Middleware: Xử Lý Request Tuần Tự
```

**Nội dung viết:**

```
Middleware: Hàm xử lý request theo từng bước

Luồng Pipeline:

1. JWT Middleware
   • Kiểm tra Authorization header
   • Verify token signature & expiry
   • Extract user info từ token
   ❌ Nếu invalid → 401 Unauthorized

2. Validation Middleware
   • Kiểm tra request body schema (Joi)
   • Validate data types, required fields
   ❌ Nếu invalid → 400 Bad Request

3. Rate Limit Middleware
   • Giới hạn 100 requests per 15 minutes
   • Bảo vệ server từ abuse
   ❌ Nếu vượt → 429 Too Many Requests

4. Route Handler (Controller)
   • Gọi service, truy vấn database

5. Error Handler Middleware
   • Bắt tất cả exception
   • Return consistent error response
   • Ghi log error

Ưu điểm:
• Tách biệt: Mỗi middleware có 1 trách nhiệm
• Tái sử dụng: Middleware dùng cho nhiều routes
• Dễ test: Test từng middleware riêng lẻ
```

**Biểu đồ:**

```
┌─────────────────────────┐
│  Incoming Request       │
└────────┬────────────────┘
         │
    [1] ▼
┌─────────────────────────┐
│ JWT Verification        │
│ ✓ Valid → Continue      │
│ ✗ Invalid → 401         │
└────────┬────────────────┘
         │
    [2] ▼
┌─────────────────────────┐
│ Schema Validation       │
│ ✓ Valid → Continue      │
│ ✗ Invalid → 400         │
└────────┬────────────────┘
         │
    [3] ▼
┌─────────────────────────┐
│ Rate Limiting           │
│ ✓ OK → Continue         │
│ ✗ Exceeded → 429        │
└────────┬────────────────┘
         │
    [4] ▼
┌─────────────────────────┐
│ Route Handler           │
│ Controllers & Services  │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ Response                │
└─────────────────────────┘
```

---

### **SLIDE 9: MVC Pattern**

**Tiêu đề slide:**

```
MVC: Tách Model-View-Controller
```

**Nội dung viết:**

```
MVC Pattern: Kiến trúc phổ biến tách 3 thành phần

1. MODEL
   • Đại diện cho dữ liệu
   • Mongoose Schema (Transaction, User, Wallet)
   • Validate data trước khi lưu
   • Không biết về HTTP requests

2. VIEW
   • Giao diện người dùng
   • Flutter Screens & Widgets
   • Hiển thị dữ liệu từ Provider
   • Gửi user input đến Provider

3. CONTROLLER
   • Điểm vào cho HTTP requests
   • Nhận request, gọi Service
   • Format & trả HTTP response
   • Ví dụ: TransactionController.create()

Luồng:
1. User nhập form (View)
2. Provider gọi API (Controller endpoint)
3. Controller gọi Service
4. Service gọi Model/Database
5. Model trả data
6. Service trả kết quả
7. Controller format response
8. Provider update View

Lợi ích:
• Giáo dục: Dễ hiểu & học tập
• Tổ chức: Code có cấu trúc rõ ràng
• Bảo trì: Dễ thay đổi module riêng lẻ
```

**Biểu đồ:**

```
┌────────────────────────────────────┐
│  VIEW (Flutter UI)                 │
│  TransactionScreen                 │
│  ↓ (user input) ↑ (display)        │
├────────────────────────────────────┤
│  CONTROLLER (API Endpoint)         │
│  POST /api/transactions            │
│  ↓ (forward request)  ↑ (format)   │
├────────────────────────────────────┤
│  SERVICE (Business Logic)          │
│  TransactionService.create()       │
│  ↓ (query) ↑ (data)                │
├────────────────────────────────────┤
│  MODEL (Data & Database)           │
│  Mongoose + MongoDB                │
└────────────────────────────────────┘
```

---

### **SLIDE 10: Deployment Architecture**

**Tiêu đề slide:**

```
Kiến Trúc Triển Khai (Deployment)
```

**Nội dung viết:**

```
Cách hệ thống SmartSpender được triển khai:

CLIENT DEPLOYMENT:
• Flutter Web: Deployed on GitHub Pages
  - Static files (HTML, CSS, JS)
  - CDN (Cloudflare Pages)
  - URL: smartspender.pages.dev

• Flutter Mobile: Built as APK/IPA
  - Distributed via App Store / Play Store
  - Users install on điện thoại

SERVER DEPLOYMENT:
• Node.js Express Server: Hosted on Render
  - Runs on cloud server (always available)
  - Environment variables (API keys)
  - Port 3000 (exposed as HTTPS)

DATABASE DEPLOYMENT:
• MongoDB Atlas: Cloud database
  - Hosted by MongoDB team
  - Automatic backup & failover
  - Connection string: mongodb+srv://...

CI/CD PIPELINE:
• Source: GitHub Repository
• Build: GitHub Actions (tự động)
• Deploy: Automatic → Render (backend)
             → GitHub Pages (frontend)

Network:
• HTTPS/TLS: Encrypted communication
• CORS: Cross-Origin Resource Sharing allowed
• JWT Header: Authorization: Bearer {token}
```

**Biểu đồ:**

```
┌──────────────────────┐
│    CLIENTS           │
│  ├─ Web Browser      │
│  └─ Mobile App       │
└──────────┬───────────┘
           │ HTTPS
           ▼
┌──────────────────────┐
│   RENDER HOSTING     │
│   Node.js Express    │
│   Port 3000          │
└──────────┬───────────┘
           │ Mongoose
           │ ODM
           ▼
┌──────────────────────┐
│ MongoDB Atlas        │
│ users, transactions  │
│ wallets, ...         │
└──────────────────────┘

GitHub (VCS)
   ↓ Push
GitHub Actions (CI/CD)
   ├─ Build & Test
   └─ Deploy to Render + Pages
```

---

### **SLIDE 11: Domain Flow - User Login**

**Tiêu đề slide:**

```
Ví Dụ: Luồng Đăng Nhập (Login)
```

**Nội dung viết:**

```
Bước 1: INPUT (Client)
  Người dùng mở app → LoginScreen
  Nhập email & password → Tap "Login"

Bước 2: VALIDATION (Client)
  AuthProvider.login(email, password)
  Kiểm tra: Email format? Password length?

Bước 3: HTTP REQUEST
  ApiService.post('/api/auth/login',
    {email, password})
  Header: Content-Type: application/json
  Gửi qua HTTPS

Bước 4: SERVER MIDDLEWARE
  [JWT skip - chưa login]
  [Validation] → Email & password valid?
  [Rate Limit] → Dưới 100 req/15min?

Bước 5: CONTROLLER LOGIC
  AuthController.login()
  Gọi AuthService.verifyPassword()

Bước 6: SERVICE LOGIC
  AuthService.verifyPassword()
  • Tìm user: User.findOne({email})
  • So sánh: bcrypt.compare(password, hash)
  • Tạo token: JWT.sign({userId, email})

Bước 7: RESPONSE
  {success: true, token: "...", user: {...}}
  Status: 200 OK

Bước 8: UPDATE UI
  AuthProvider.setToken(token)
  Provider.notifyListeners()
  Navigate to HomeScreen ✓

Thành công!
```

**Biểu đồ:**

```
[Mobile App]
   LoginScreen
     │ Tap Login
     ▼
AuthProvider.login()
     │ Validate
     ▼
ApiService.post('/api/auth/login')
     │ HTTPS
     ▼
  [Express Server]
   Middleware Pipeline
     │ ✓ Validation
     ▼
   AuthController.login()
     │ Call
     ▼
   AuthService.verifyPassword()
     │ Query
     ▼
   User.findOne() → MongoDB
     │ Found
     ▼
   bcrypt.compare()
     │ ✓ Match
     ▼
   JWT.sign()
     │ Create token
     ▼
   Response {token, user}
     │ HTTPS
     ▼
AuthProvider.setToken()
     │
     ▼
   [Mobile App]
   Navigate to HomeScreen ✓
```

---

### **SLIDE 12: Domain Flow - Create Transaction**

**Tiêu đề slide:**

```
Ví Dụ: Luồng Tạo Giao Dịch (Create)
```

**Nội dụng viết:**

```
Bước 1: INPUT
  TransactionScreen → Form: loại, danh mục, số tiền
  Nhập dữ liệu → Tap "Create"

Bước 2: VALIDATION (Client)
  TransactionProvider.submitTransaction()
  Kiểm tra: amount > 0? category exists?

Bước 3: HTTP REQUEST
  ApiService.post('/api/transactions', data)
  Header: Authorization: Bearer {JWT_token}

Bước 4-5: MIDDLEWARE PIPELINE
  [JWT] → Token valid? Extract userId ✓
  [Validation] → amount number? category string? ✓
  [Rate Limit] → Check quota ✓

Bước 6-7: BUSINESS LOGIC
  TransactionController.create()
    → TransactionService.create()

Bước 8: DATABASE OPERATIONS
  • Tạo transaction: Transaction.create()
  • Update ví: Wallet.updateOne()
  • MongoDB lưu trữ ✓

Bước 9: RESPONSE
  {success: true, data: transaction, code: 201}

Bước 10: UI UPDATE
  TransactionProvider.transactions.add(new)
  notifyListeners()
  TransactionList rebuild + show giao dịch mới ✓

Nhân vật:
• Service xử lý quyền & logic
• Model đảm bảo data consistent
• Controller là HTTP interface
```

**Biểu đồ:**

```
[Mobile UI]
TransactionForm
   │ Tap Submit
   ▼
Validate (amount > 0)
   │
   ▼
POST /api/transactions
Authorization: Bearer {JWT}
   │ HTTPS
   ▼
[Middleware Pipeline]
JWT verify → Extract userId ✓
Schema validate → amount, category ✓
Rate limit check → OK ✓
   │
   ▼
TransactionController.create()
   │
   ▼
TransactionService.create()
   ├─ Check user permission
   └─ Update wallet balance
   │
   ▼
[Database]
Transaction.create()
   │
   ▼
MongoDB insert + Wallet update ✓
   │
   ▼
Response 201 {data}
   │ HTTPS
   ▼
TransactionProvider.add()
   │
   ▼
[Mobile UI]
ListView rebuild + show giao dịch mới ✓
```

---

### **SLIDE 13: Hướng Mở Rộng & Tiến Hóa**

**Tiêu đề slide:**

```
Hướng Phát Triển: Từ Monolith Sang Microservices
```

**Nội dung viết:**

```
SmartSpender hiện tại: 3-Tier Monolithic
✓ Đơn giản, dễ quản lý
✗ Khi scale lớn sẽ bị bottleneck

PHASE 1: Hiện tại (Monolithic)
├─ 1 Express app (tất cả features)
├─ 1 MongoDB (chung dữ liệu)
└─ Phù hợp: < 10k users

PHASE 2: Thêm Infrastructure (Nếu cần)
├─ API Gateway (rate limit, auth centralized)
├─ Redis Cache (reduce DB queries)
└─ Load Balancer (scale horizontally)
└─ Phù hợp: 10k - 100k users

PHASE 3: Strangler Pattern (Tách dần services)
├─ Auth Service → Tách riêng
├─ Transaction Service → Giữ monolith
├─ Message Queue → Async notifications
└─ Phù hợp: 100k+ users, khó quản lý

PHASE 4: Microservices + Event-Driven
├─ Auth μS: PostgreSQL
├─ Transaction μS: MongoDB
├─ Wallet μS: PostgreSQL
├─ Notification μS: Redis + MQ
└─ Kafka Event Bus
└─ Phù hợp: Very large scale, multiple teams

Hiện tại:
→ Giữ 3-Tier, tập trung vào features
→ Khi users > 10k, evaluate cần cache/gateway hay không
→ Nếu team > 8, consider tách Auth service
```

**Biểu đồ (Evolution):**

```
MONOLITH              STRANGLER          MICROSERVICES
(Now)                                    (Future)

┌───────┐             ┌──┐┌──┐           ┌──┐┌──┐┌──┐
│ 1 App │             │GW││μS│           │M1││M2││M3│
│ 1 DB  │    →        ├──┤└──┘    →      ├──┤├──┤├──┤
│       │             │μS│               │DB││DB││DB│
└───────┘             ├──┤               └──┘└──┘└──┘
                      │MQ│
                      └──┘

Complexity:    Low    Medium    High
Team Size:     1-3    3-5       5+
Users:         <10k   10k-100k  100k+
Scalability:   Poor   Good      Excellent
```

---

## 📐 HƯỚNG DẪN VIẾT NỘI DUNG CHUNG

### **Quy tắc:**

1. **Độ dài câu:**
   - Mỗi slide: 80-120 từ (vừa đọc trong 1 phút)
   - Bullet point: < 15 từ mỗi dòng
   - Câu dài → chỉ xảy ra ở ví dụ code/output

2. **Cấu trúc slide:**

   ```
   [Tiêu đề - 5-8 từ]

   [Nội dung - 3-5 bullets hoặc 1-2 paragraphs]

   [Biểu đồ hoặc bảng]
   ```

3. **Tránh:**
   - ❌ Sao chép từ CNPM (nội dung khác nhau!)
   - ❌ Quá nhiều giải thích (trình bày bằng miệng)
   - ❌ Code snippet dài (screenshot thôi)
   - ❌ Diagram quá phức tạp (tối ưu cho slide 1m)

4. **Dùng:**
   - ✅ Từ khóa ISA (Layer, Architecture, Pattern, Design)
   - ✅ Biểu tượng (🎨, 🌐, 💾, ▶️, ❌, ✓)
   - ✅ Ví dụ từ SmartSpender code thực tế
   - ✅ Diagram đơn giản (Mermaid style)

---

## 🎯 CÁCH SỬ DỤNG FILE NÀY

1. **Copy nội dung viết** từ từng slide trên
2. **Thay vào CNPM slide template** của bạn
3. **Tạo Mermaid diagram** tương ứng (hoặc dùng cái có sẵn)
4. **Kiểm tra:** Nội dung phù hợp ISA chưa?
5. **Demo:** Present with team → Feedback → Adjust

---

## 📋 CHECKLIST TRƯỚC KHI HOÀN THÀNH

- [ ] Tất cả 13 slides đã copy nội dung
- [ ] Biểu đồ match với nội dung
- [ ] Không có câu dài (< 15 từ/bullet)
- [ ] Dùng từ khóa ISA (Architecture, Layer, Pattern...)
- [ ] Ví dụ từ SmartSpender thực tế
- [ ] Format thống nhất (font, màu, layout)
- [ ] Kiểm tra spelling (tiếng Việt)
- [ ] Các biểu đồ rõ ràng (không quá chi tiết)

---

**Bắt đầu từ Slide 1 áp dụng hướng dẫn trên!** 🚀
