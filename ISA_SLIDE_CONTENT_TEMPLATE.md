# 📋 Mẫu Slide ISA Chi Tiết - SmartSpender

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

**Tiêu đề slide:**

```
SmartSpender - Ứng dụng Quản lý Chi tiêu
```

**Nội dung viết:**

```
• Mục tiêu: Giúp người dùng quản lý chi tiêu cá nhân
  - Ghi lại các giao dịch (chi, thu)
  - Phân loại theo danh mục
  - Xem thống kê chi tiêu

• Team phát triển: 5 thành viên
  - Leader: Mai Huy Minh
  - Backend: Nguyễn Văn Duy, Vũ Nguyễn Ngọc Bảo
  - Mobile: Trịnh Thái Sơn, Lê Đức Anh

• Công nghệ chính:
  - Frontend: Flutter (Web + Mobile)
  - Backend: Node.js + Express
  - Database: MongoDB Atlas
```

**Biểu đồ:**

- Logo SmartSpender
- Team table (tên, vai trò)

---

### **SLIDE 2: Tổng Quan Kiến Trúc Hệ Thống**

**Tiêu đề slide:**

```
Kiến Trúc 3-Tier Architecture
```

**Nội dung viết:**

```
Kiến trúc SmartSpender gồm 3 lớp:

🎨 PRESENTATION LAYER
   Người dùng tương tác qua giao diện di động

🌐 APPLICATION LAYER
   Xử lý logic kinh doanh, bảo mật, validation

💾 DATA LAYER
   Lưu trữ & quản lý dữ liệu

Lợi ích:
• Tách biệt trách nhiệm (Separation of Concerns)
• Dễ bảo trì & phát triển (Maintainability)
• Dễ kiểm thử từng lớp (Testability)
• Phù hợp với quy mô hiện tại
```

**Biểu đồ:**

```
┌─────────────────────────┐
│  PRESENTATION LAYER     │
│  (Flutter Web/Mobile)   │
├─────────────────────────┤
│  APPLICATION LAYER      │
│  (Express.js Server)    │
├─────────────────────────┤
│  DATA LAYER             │
│  (MongoDB)              │
└─────────────────────────┘
```

---

### **SLIDE 3: Lớp Presentation (Client)**

**Tiêu đề slide:**

```
Lớp Presentation: Giao Diện Người Dùng
```

**Nội dung viết:**

```
Trách nhiệm:
• Hiển thị dữ liệu cho người dùng
• Nhận input từ người dùng
• Quản lý trạng thái ứng dụng

Công nghệ:
• Flutter Framework: Cross-platform (Web, Android, iOS)
• Provider: Quản lý state (ChangeNotifier)
• Dio: HTTP client để gọi API

Các màn hình chính:
• LoginScreen: Đăng nhập / Đăng ký
• HomeScreen: Hiển thị tổng quan chi tiêu
• TransactionScreen: Danh sách giao dịch
• WalletScreen: Quản lý ví tiền
• ProfileScreen: Thông tin người dùng
```

**Biểu đồ:**

```
┌─ Screens ─────────────┐
│  ├─ LoginScreen       │
│  ├─ HomeScreen        │
│  ├─ TransactionScreen │
│  ├─ WalletScreen      │
│  └─ ProfileScreen     │
│                       │
├─ Providers ──────────┤  ← Quản lý State
│  ├─ AuthProvider     │
│  ├─ TransactionProv  │
│  ├─ WalletProvider   │
│  └─ StatisticProv    │
│                       │
├─ API Service ────────┤  ← Gọi Server
│  Dio HTTP Client      │
└───────────────────────┘
```

---

### **SLIDE 4: Lớp Application (Backend Logic)**

**Tiêu đề slide:**

```
Lớp Application: Xử Lý Logic Kinh Doanh
```

**Nội dung viết:**

```
Trách nhiệm:
• Xử lý yêu cầu từ client
• Xác thực & kiểm tra dữ liệu
• Gọi database & trả kết quả

Thành phần chính:

1. ROUTES (Định tuyến API)
   POST /api/auth/login
   POST /api/transactions
   GET /api/wallets
   ...

2. CONTROLLERS (Nhận request, gọi Service)
   AuthController.login()
   TransactionController.createTransaction()
   WalletController.updateBalance()

3. SERVICES (Chứa business logic)
   AuthService: verify password, create JWT
   TransactionService: validate, update wallet
   WalletService: tính toán số dư
```

**Biểu đồ:**

```
Request từ Client
       ↓
┌──────────────────┐
│  Routes          │
└────────┬─────────┘
         ↓
┌──────────────────┐
│  Controllers     │  ← Nhận HTTP request
└────────┬─────────┘
         ↓
┌──────────────────┐
│  Services        │  ← Xử lý logic
└────────┬─────────┘
         ↓
┌──────────────────┐
│  Models          │  ← Truy vấn DB
└──────────────────┘
```

---

### **SLIDE 5: Lớp Data (Database)**

**Tiêu đề slide:**

```
Lớp Data: Lưu Trữ & Quản Lý Dữ Liệu
```

**Nội dung viết:**

```
Công nghệ:
• MongoDB Atlas (Cloud database)
• Mongoose: Object Data Modeling (ODM)

Collections (Bảng dữ liệu):

1. USERS
   ├─ email: người dùng email
   ├─ password: hash (bcrypt)
   └─ profile: tên, avatar

2. TRANSACTIONS
   ├─ userId: liên kết user
   ├─ type: "income" | "expense"
   ├─ category: "food", "transport"...
   ├─ amount: số tiền
   └─ date: ngày giao dịch

3. WALLETS
   ├─ userId: liên kết user
   ├─ name: "Tiền mặt", "Ngân hàng"
   └─ balance: số dư hiện tại

Tính năng:
• Automatic backup (Atlas tự backup)
• Mongoose validation (kiểm tra schema)
```

**Biểu đồ:**

```
MongoDB Collections:

┌─ Users ──────────────┐
│  _id, email, pwd... │
├─ Transactions ──────┐
│  userId, type, cost │
├─ Wallets ────────────┐
│  userId, name, bal  │
└─────────────────────┘
```

---

### **SLIDE 6: Luồng API & REST**

**Tiêu đề slide:**

```
REST API: Giao Tiếp Client-Server
```

**Nội dung viết:**

```
RESTful Design:
• Resource-based URLs: /api/transactions
• HTTP Methods có ý nghĩa:
  - GET    : Lấy dữ liệu
  - POST   : Tạo mới
  - PUT    : Cập nhật toàn bộ
  - PATCH  : Cập nhật một phần
  - DELETE : Xóa

Request-Response Format (JSON):

POST /api/transactions
Authorization: Bearer {JWT}
{
  "type": "expense",
  "category": "food",
  "amount": 100000,
  "date": "2026-04-15"
}

Response 201 Created:
{
  "success": true,
  "data": {
    "id": "abc123",
    "userId": "user123",
    ...
  }
}

HTTP Status Codes:
• 200 OK: Thành công
• 201 Created: Tạo mới thành công
• 400 Bad Request: Dữ liệu sai
• 401 Unauthorized: Cần authentication
• 404 Not Found: Resource không tồn tại
• 500 Server Error: Lỗi server
```

**Biểu đồ:**

```
┌─ API Endpoints ──────────────────┐
│ POST   /api/auth/login           │
│ GET    /api/transactions         │
│ POST   /api/transactions         │
│ PUT    /api/transactions/:id     │
│ DELETE /api/transactions/:id     │
│ GET    /api/wallets              │
│ PATCH  /api/wallets/:id          │
└──────────────────────────────────┘

Request → HTTPS → Server → Response
          (JSON)        (JSON)
```

---

### **SLIDE 7: Xác Thực JWT (Authentication)**

**Tiêu đề slide:**

```
JWT: Xác Thực Stateless
```

**Nội dung viết:**

```
JWT (JSON Web Token):
• Hình thức: Token text (không lưu session ở server)
• Độc lập: Mỗi request không phụ thuộc state server

Luồng ngang hoạt động:

1. LOGIN
   Client POST /api/auth/login {email, password}
   Server verify password → Tạo JWT
   Response: {token: "eyJhbGc..."}

2. AUTHENTICATED REQUESTS
   Client gửi: Authorization: Bearer {jwt}
   GET /api/transactions
   Server kiểm tra token → Nếu valid → Xử lý

3. TOKEN STRUCTURE
   Header.Payload.Signature
   - Header: {typ: "JWT", alg: "HS256"}
   - Payload: {userId: "123", email: "user@..."}
   - Signature: HMAC(header.payload, secret_key)

Lợi ích:
• Stateless: Server không lưu session
• Scalable: Nhiều server có thể xử lý cùng lúc
• Mobile-friendly: Dễ lưu trong app
```

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
