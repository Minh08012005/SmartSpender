# SmartSpender - Biểu đồ Kiến trúc Tổng thể

## Kiến trúc 3 Lớp Chi tiết (3-Tier Architecture)

```mermaid
%%{init: {
    'theme': 'base',
    'themeVariables': {
        'primaryColor': '#e8eaf6',
        'primaryTextColor': '#1a237e',
        'primaryBorderColor': '#3f51b5',
        'lineColor': '#3949ab',
        'secondaryColor': '#ffffff',
        'tertiaryColor': '#f5f5f5',
        'fontSize': '13px'
    }
}}%%

graph TD
    subgraph Clients["🖥️ LỚPSƠ KẾT - CLIENT (Người dùng)"]
        WEB["📱 Flutter Web<br/>GitHub Pages<br/>smartspender.pages.dev"]
        MOBILE["📲 Flutter Mobile<br/>APK/iOS<br/>Provider StateManagement"]
        DESKTOP["🖥️ Flutter Desktop<br/>Windows/MacOS<br/>Tùy chọn"]
    end

    subgraph CDN["📡 CDN & Lưu trữ"]
        GHPAGES["GitHub Pages<br/>Tài sản tĩnh"]
        IMG["Bộ nhớ Cache<br/>Lưu trữ cục bộ"]
    end

    subgraph Network["🌐 LỚPMẠNG"]
        REST["REST API<br/>HTTPS/TLS"]
        AUTH["JWT Bearer Token<br/>Authorization Header"]
    end

    subgraph Backend["⚙️ LỚPỨNGDỤNG - BACKEND"]
        subgraph Routes["Tuyến đường & Các điểm cuối API"]
            AUTH_ROUTE["auth/register<br/>auth/login"]
            TX_ROUTE["/api/transactions<br/>GET/POST/PUT/DELETE"]
            WALLET_ROUTE["/api/wallets<br/>GET/PATCH/POST"]
            STAT_ROUTE["/api/statistics<br/>GET"]
        end

        subgraph Middleware["🛡️ Đường ống Middleware"]
            JWT_MW["Xác thực JWT<br/>Middleware"]
            VALIDATE_MW["Xác thực Input<br/>Joi/Express-Validator"]
            RATE_MW["Giới hạn Tốc độ<br/>100 yêu cầu/15 phút"]
            ERROR_MW["Trình xử lý Lỗi<br/>Ngoại lệ Toàn cục"]
        end

        subgraph Controllers["Bộ điều khiển - Logic Kinh doanh"]
            AUTH_CTRL["AuthController<br/>đăng ký/đăng nhập"]
            TX_CTRL["TransactionController<br/>Thao tác CRUD"]
            WALLET_CTRL["WalletController<br/>Quản lý Ví"]
            STAT_CTRL["StatisticController<br/>Báo cáo Tóm tắt"]
        end

        subgraph Services["Services - Logic Miền"]
            AUTH_SVC["AuthService<br/>JWT, Hash Mật khẩu"]
            TX_SVC["TransactionService<br/>Truy vấn/Tính toán"]
            WALLET_SVC["WalletService<br/>Cập nhật Số dư"]
            STAT_SVC["StatisticService<br/>Tổng hợp Dữ liệu"]
        end

        subgraph Models["Mô hình Dữ liệu - Mongoose"]
            USER_MODEL["Mô hình User<br/>email/mật khẩu/hồ sơ"]
            TX_MODEL["Mô hình Giao dịch<br/>số tiền/danh mục/ngày"]
            WALLET_MODEL["Mô hình Ví<br/>tên/số dư/loại"]
        end

        subgraph Utils["Tiện ích"]
            LOGGER["Bộ ghi nhật ký<br/>Winston/Console"]
            RESPONSE["Định dạng Phản hồi<br/>Định dạng Thống nhất"]
            ERROR_CLASS["AppError<br/>Lớp Lỗi Tùy chỉnh"]
        end
    end

    subgraph Database["💾 LỚPDỮLIỆU - CƠSỞ DỮ LIỆU"]
        MONGODB["MongoDB Atlas<br/>Cơ sở dữ liệu Đám mây"]
        Collections["Bộ sưu tập:<br/>người dùng, giao dịch,<br/>ví, chuyển nhượng"]
    end

    subgraph Infrastructure["🚀 CƠ SỞ HẠ TẦNG & DEVOPS"]
        GIT["GitHub Repository<br/>Kiểm soát Phiên bản"]
        CI_CD["GitHub Actions<br/>Đường ống CI/CD"]
        RENDER["Render Hosting<br/>Máy chủ Node.js"]
        LOGS["Giám sát & Nhật ký<br/>Theo dõi Lỗi"]
    end

    subgraph Mobile_Internal["📱 MOBILE - Kiến trúc Nội bộ"]
        subgraph Screens["Màn hình & Chế độ xem"]
            LOGIN["LoginScreen"]
            HOME["HomeScreen"]
            TX_LIST["TransactionScreen"]
            WALLET_VIEW["WalletScreen"]
            PROFILE["ProfileScreen"]
        end

        subgraph Providers["Quản lý Trạng thái (Provider)"]
            AUTH_PROV["AuthProvider<br/>Trạng thái Đăng nhập/Đăng ký"]
            TX_PROV["TransactionProvider<br/>Trạng thái CRUD"]
            WALLET_PROV["WalletProvider<br/>Trạng thái Ví"]
            STAT_PROV["StatisticProvider<br/>Trạng thái Tóm tắt"]
        end

        subgraph Models_Mobile["Mô hình Dữ liệu"]
            USER_MOB["UserModel<br/>fromJson/toJson"]
            TX_MOB["TransactionModel<br/>Tuần tự hóa"]
            WALLET_MOB["WalletModel<br/>Phân tích JSON"]
        end

        subgraph Services_Mobile["Services"]
            API_SVC["ApiService<br/>Dio HTTP Client"]
            STORAGE["Lưu trữ Cục bộ<br/>shared_preferences"]
        end

        subgraph Widgets["Tiện ích & Giao diện"]
            FORMS["Biểu mẫu<br/>Xác thực Input"]
            LISTS["Danh sách<br/>TransactionList"]
            CARDS["Thẻ<br/>WalletCard"]
            LOADERS["Bộ tải<br/>Shimmer"]
        end
    end

    %% Kết nối - Luồng dữ liệu
    WEB -->|HTTPS REST API| REST
    MOBILE -->|HTTPS REST API| REST
    REST -->|Bearer Token| AUTH
    AUTH -->|Xác minh JWT| JWT_MW
    JWT_MW -->|Đã xác thực| VALIDATE_MW
    VALIDATE_MW -->|Kiểm tra Tốc độ| RATE_MW
    RATE_MW -->|Khớp Tuyến đường| Routes

    AUTH_ROUTE --> AUTH_CTRL
    TX_ROUTE --> TX_CTRL
    WALLET_ROUTE --> WALLET_CTRL
    STAT_ROUTE --> STAT_CTRL

    AUTH_CTRL --> AUTH_SVC
    TX_CTRL --> TX_SVC
    WALLET_CTRL --> WALLET_SVC
    STAT_CTRL --> STAT_SVC

    AUTH_SVC --> USER_MODEL
    TX_SVC --> TX_MODEL
    WALLET_SVC --> WALLET_MODEL

    USER_MODEL -->|Mongoose ODM| MONGODB
    TX_MODEL -->|Mongoose ODM| MONGODB
    WALLET_MODEL -->|Mongoose ODM| MONGODB

    MONGODB -->|Dữ liệu Đã lưu| Collections

    ERROR_MW -->|Xử lý Ngoại lệ| LOGGER
    LOGGER -->|Đầu ra Nhật ký| LOGS

    %% Luồng Dữ liệu Mobile
    LOGIN -->|Nhấn Gửi| AUTH_PROV
    HOME -->|Hiển thị Thống kê| STAT_PROV
    TX_LIST -->|Hiển thị Danh sách| TX_PROV
    WALLET_VIEW -->|Hiển thị Ví| WALLET_PROV
    PROFILE -->|Thông tin Người dùng| AUTH_PROV

    AUTH_PROV -->|Yêu cầu HTTP| API_SVC
    TX_PROV -->|Yêu cầu HTTP| API_SVC
    WALLET_PROV -->|Yêu cầu HTTP| API_SVC
    STAT_PROV -->|Yêu cầu HTTP| API_SVC

    API_SVC -->|Dio Client| REST

    AUTH_PROV -->|Lưu Token| STORAGE
    TX_PROV -->|Bộ nhớ Cache Dữ liệu| STORAGE

    TX_PROV -->|Phân tích JSON| TX_MOB
    WALLET_PROV -->|Phân tích JSON| WALLET_MOB

    %% CI/CD & Cơ sở hạ tầng
    GIT -->|Đẩy Mã| CI_CD
    CI_CD -->|Tự động Triển khai| RENDER
    CI_CD -->|Xây dựng Web| GHPAGES
    RENDER -->|Chạy Node.js| Backend
    Collections -->|Sao lưu| GIT

    %% Định dạng màu sắc
    style Clients fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    style Backend fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Database fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style Infrastructure fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style Network fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    style Mobile_Internal fill:#f0f4c3,stroke:#9ccc65,stroke-width:2px

    style Routes fill:#ffffff,stroke:#3f51b5,stroke-width:1px
    style Middleware fill:#ffffff,stroke:#3f51b5,stroke-width:1px
    style Controllers fill:#ffffff,stroke:#3f51b5,stroke-width:1px
    style Services fill:#ffffff,stroke:#3f51b5,stroke-width:1px
    style Models fill:#ffffff,stroke:#3f51b5,stroke-width:1px
```

---

## Luồng Dữ liệu Chi tiết

### 1️⃣ **Tạo Giao dịch - CREATE TRANSACTION**

```
Giao diện Mobile (TransactionForm)
  ↓ [Xác thực phía khách hàng]
Provider.submitTransaction()
  ↓ [Gọi API]
API Service (POST /api/transactions)
  ↓ [HTTPS + JWT]
Express Server
  ↓ [JWT Middleware]
Xác thực ✓
  ↓ [Validation Middleware]
Schema được xác thực ✓
  ↓ [Giới hạn Tốc độ]
Trong giới hạn ✓
  ↓ [Khớp Tuyến đường]
TransactionController.createTransaction()
  ↓ [Logic Kinh doanh]
TransactionService.create()
  ↓ [Hoạt động Cơ sở dữ liệu]
Mongoose → MongoDB.insert()
  ↓ [Cập nhật Ví]
WalletService.updateBalance()
  ↓ [Trả lời Phản hồi]
{ success: true, data: transaction }
  ↓ [Phản hồi HTTP]
API Service
  ↓ [Phân tích JSON]
TransactionModel.fromJson()
  ↓ [Cập nhật Trạng thái]
Provider.notifyListeners()
  ↓ [Xây dựng Tiện ích]
TransactionList cập nhật ✓
```

### 2️⃣ **Lấy Giao dịch - READ TRANSACTIONS (với Bộ lọc)**

```
Giao diện Mobile (Năm Biểu mẫu)
  ↓ [Người dùng thay đổi bộ lọc]
Provider.fetchTransactions(tháng, năm, loại, danh mục)
  ↓ [Xây dựng Chuỗi Truy vấn]
API Service (GET /api/transactions?month=3&year=2026&type=expense)
  ↓ [HTTPS + JWT]
Express Server
  ↓ [JWT Middleware]
Xác thực ✓
  ↓ [Validation Middleware]
Các tham số Truy vấn được xác thực ✓
  ↓ [Khớp Tuyến đường]
TransactionController.getTransactions()
  ↓ [Xây dựng Truy vấn MongoDB]
TransactionService.findByFilters()
  ↓ [Mongoose Truy vấn]
MongoDB.find({ userId, date: {...}, type: ... })
  ↓ [Tổng hợp/Sắp xếp/Phân trang]
[Mảng Giao dịch]
  ↓ [Định dạng Phản hồi]
{ success: true, data: [...], total: 50, page: 1 }
  ↓ [Phản hồi HTTP]
API Service
  ↓ [Phân tích Mảng JSON]
for each → TransactionModel.fromJson()
  ↓ [Cập nhật Trạng thái]
Provider.transactions = [...]
Provider.notifyListeners()
  ↓ [Xây dựng lại Giao diện]
ListView với Giao dịch mới ✓
```

### 3️⃣ **Xác thực - AUTHENTICATION**

```
Giao diện Mobile (LoginScreen)
  ↓ [Email + Mật khẩu]
Provider.login(email, mật khẩu)
  ↓ [Xác thực phía khách hàng]
Email & Định dạng Mật khẩu hợp lệ ✓
  ↓ [Gọi API]
API Service (POST /api/auth/login)
  ↓ [Request Body: { email, mật khẩu }]
Express Server
  ↓ [Body Parser Middleware]
  ↓ [Validation Middleware]
Schema được xác thực ✓
  ↓ [Khớp Tuyến đường]
AuthController.login()
  ↓ [Tìm Người dùng theo Email]
AuthService.findUserByEmail()
  ↓ [Truy vấn MongoDB]
Tài liệu Người dùng được Lấy
  ↓ [So sánh Hash Mật khẩu]
bcrypt.compare(mật khẩu, hash)
  ↓ [Phù hợp ✓]
Tạo Token JWT
  ↓ [jose.sign({ userId, email }, secret)]
Trả lại { token, user }
  ↓ [Phản hồi HTTP 200]
API Service
  ↓ [Trích xuất Token]
Provider.setToken()
  ↓ [Lưu vào shared_preferences]
  ↓ [Cập nhật isAuthenticated = true]
Provider.notifyListeners()
  ↓ [Xây dựng lại Navigation]
Chuyển hướng sang HomeScreen ✓
```

### 4️⃣ **Cập nhật Giao dịch - UPDATE TRANSACTION**

```
Giao diện Mobile (Chi tiết Giao dịch)
  ↓ [Nhấn Chỉnh sửa]
Form mở với Dữ liệu Cũ
  ↓ [Người dùng thay đổi Số tiền]
Provider.updateTransaction(id, updatedData)
  ↓ [Xác thực Phía khách hàng]
Dữ liệu hợp lệ ✓
  ↓ [Gọi API]
API Service (PUT /api/transactions/:id)
  ↓ [HTTPS + JWT]
Express Server
  ↓ [Middleware Pipeline]
Xác thực Thành công ✓
  ↓ [TransactionController.updateTransaction()]
  ↓ [TransactionService.update()]
Mongoose → MongoDB.updateOne()
  ↓ [Tính toán lại Số dư Ví]
WalletService.recalculateBalance()
  ↓ [{ success: true, data: updatedTransaction }]
  ↓ [Phản hồi HTTP]
API Service
  ↓ [Phân tích JSON]
Provider.updateLocalTransaction()
  ↓ [notifyListeners()]
Danh sách cập nhật ✓
```

### 5️⃣ **Xóa Giao dịch - DELETE TRANSACTION**

```
Giao diện Mobile (Danh sách Giao dịch)
  ↓ [Long-press / Swipe để xóa]
Hộp thoại Xác nhận
  ↓ [Người dùng xác nhận]
Provider.deleteTransaction(id)
  ↓ [Gọi API]
API Service (DELETE /api/transactions/:id)
  ↓ [HTTPS + JWT]
Express Server
  ↓ [Middleware & Controller]
  ↓ [TransactionService.delete()]
MongoDB.deleteOne({ _id: id })
  ↓ [Lấy Giao dịch Cũ để tính toán Số dư]
WalletService.restoreBalance()
  ↓ [{ success: true }]
  ↓ [Phản hồi HTTP]
API Service
  ↓ [Provider.removeTransaction(id)]
  ↓ [notifyListeners()]
Giao dịch biến mất ✓
Toast "Xóa thành công" ✓
```

---

## Thành phần Chính

### 📱 **Lớp Sơ kết (Presentation Layer)**

| Thành phần             | Mô tả                                 |
| ---------------------- | ------------------------------------- |
| **Flutter Web**        | Ứng dụng web trên GitHub Pages        |
| **Flutter Mobile**     | APK (Android) + IPA (iOS)             |
| **Provider**           | Quản lý Trạng thái với ChangeNotifier |
| **Dio**                | HTTP Client cho API Call              |
| **shared_preferences** | Lưu trữ Token & Dữ liệu Cục bộ        |

### ⚙️ **Lớp Ứng dụng (Application Layer)**

| Thành phần        | Mô tả                          |
| ----------------- | ------------------------------ |
| **Express.js**    | Framework Web chính            |
| **JWT Auth**      | Xác thực Stateless             |
| **Joi Validator** | Xác thực Schema Input          |
| **Middleware**    | Xử lý yêu cầu trước Controller |
| **Controllers**   | Xử lý Business Logic           |
| **Services**      | Lớp Logic Miền                 |
| **Mongoose**      | ODM cho MongoDB                |

### 💾 **Lớp Dữ liệu (Data Layer)**

| Thành phần        | Mô tả                                   |
| ----------------- | --------------------------------------- |
| **MongoDB Atlas** | Cơ sở dữ liệu Đám mây                   |
| **Collections**   | users, transactions, wallets, transfers |
| **Indexes**       | Tối ưu hóa Truy vấn                     |
| **Validation**    | Schema Validation                       |

### 🚀 **Cơ sở Hạ tầng (Infrastructure)**

| Thành phần         | Mô tả                   |
| ------------------ | ----------------------- |
| **GitHub**         | Kiểm soát Phiên bản     |
| **GitHub Actions** | CI/CD tự động           |
| **Render**         | Hosting Backend Node.js |
| **GitHub Pages**   | Hosting Web tĩnh        |
| **MongoDB Atlas**  | Hosting Cơ sở dữ liệu   |

---

## Tính năng Bảo mật

✅ **JWT Authentication** - Token không có Trạng thái (Stateless)  
✅ **Password Hashing** - bcrypt với Salt Rounds  
✅ **HTTPS/TLS** - Mã hóa tất cả Giao tiếp  
✅ **CORS** - Danh sách Trắng Origin  
✅ **Rate Limiting** - 100 yêu cầu mỗi 15 phút  
✅ **Input Validation** - Joi Schema + express-validator  
✅ **Error Handling** - Không tiếp lộ Dữ liệu Nhạy cảm  
✅ **Helmet.js** - Security Headers

---

**Cập nhật lần cuối:** 01/04/2026  
**Trạng thái:** ✅ Hoàn chỉnh & Sẵn sàng
