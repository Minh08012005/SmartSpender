# 🔗 Integration Testing Runbook - SmartSpender

**Ngày**: 22/03/2026 | **Trạng thái**: CRUD Testing (Create, Read, Update, Delete)

---

## 📋 Mục Tiêu

Thực hiện test **End-to-End Integration** toàn quy trình:

1. ✅ Test Backend APIs độc lập (Postman)
2. ✅ Lấy Authentication Token
3. ✅ Test CRUD từ Mobile App
4. ✅ Verify dữ liệu sync giữa Backend ↔ Mobile

---

## 🎯 Scope Kiểm Tra

**CRUD Operations:**

- ✅ **Create (C)**: Tạo giao dịch từ mobile
- ✅ **Read (R)**: Xem danh sách giao dịch
- ✅ **Update (U)**: Sửa giao dịch từ mobile
- ✅ **Delete (D)**: Xóa giao dịch từ mobile

**Filtering** (riêng biệt - không trong scope lần này):

- ⏳ Filter by type (income/expense)
- ⏳ Filter by date range
- ⏳ Filter by category

---

## 🚀 PHASE 1: Setup & Backend Testing

### Step 1️⃣: Chuẩn Bị Environment

#### 1.1 - Kiểm tra Database

```bash
# Mở terminal, chạy từ backend folder
cd backend

# Verify seed data có được tạo chưa
node seeds/transaction_seed.js
# Output expected:
# ✓ Connected to MongoDB
# ✓ Database seed completed successfully
```

#### 1.2 - Start Backend Server

```bash
# Từ backend folder, chạy dev server với Nodemon
npm run dev

# Expected output:
# > backend@1.0.0 dev
# > nodemon server.js
# 🚀 Server running on http://localhost:5000
# 🔌 MongoDB connected
```

**Giữ terminal này **mở**. Đừng đóng!**

---

### Step 2️⃣: Backend Testing (Postman)

#### 2.1 - Authentication: Đăng Nhập

**Endpoint**: `POST /auth/login`

```bash
POST http://localhost:5000/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

**Expected Response** (200 OK):

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "user_id_here",
      "email": "test@example.com",
      "name": "Test User"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

**💾 SAVE THIS TOKEN!**

- Copy token từ response
- Dùng cho tất cả API calls sau
- Header: `Authorization: Bearer <token>`

#### 2.2 - Read: Lấy Danh Sách Giao Dịch

**Endpoint**: `GET /transactions`

```bash
GET http://localhost:5000/transactions?month=3&year=2026
Authorization: Bearer <token_from_login>
```

**Expected Response**:

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Transactions fetched successfully",
  "data": {
    "transactions": [
      {
        "_id": "65f8d1a2b3c4d5e6f7890123",
        "userId": "user_id",
        "title": "Cơm trưa",
        "amount": 50000,
        "type": "expense",
        "category": "food",
        "date": "2026-03-22T12:00:00.000Z",
        "note": "Ăn với bạn",
        "createdAt": "2026-03-22T12:00:00.000Z"
      }
      // ... more transactions
    ],
    "totalCount": 5,
    "currentPage": 1,
    "totalPages": 1
  }
}
```

**📊 Ghi chép**:

- Số lượng transactions hiện tại: `___`
- Transaction ID mẫu: `___`

#### 2.3 - Create: Tạo Giao Dịch Mới

**Endpoint**: `POST /transactions`

```bash
POST http://localhost:5000/transactions
Authorization: Bearer <token_from_login>
Content-Type: application/json

{
  "title": "Test Postman - Ăn sáng",
  "amount": 75000,
  "type": "expense",
  "category": "food",
  "date": "2026-03-22T08:30:00.000Z",
  "note": "Test tạo giao dịch qua Postman"
}
```

**Expected Response** (201 Created):

```json
{
  "success": true,
  "statusCode": 201,
  "message": "Transaction created successfully",
  "data": {
    "_id": "newly_created_id_123",
    "userId": "user_id",
    "title": "Test Postman - Ăn sáng",
    "amount": 75000,
    "type": "expense",
    "category": "food",
    "date": "2026-03-22T08:30:00.000Z",
    "note": "Test tạo giao dịch qua Postman",
    "createdAt": "2026-03-22T15:30:00.000Z"
  }
}
```

**📊 Ghi chép**:

- Newly created Transaction ID: `___` (dùng cho Update/Delete sau)
- Status: ✅ / ❌

#### 2.4 - Verify: Xem danh sách lại (Read)

**Chạy lại GET /transactions**:

```bash
GET http://localhost:5000/transactions?month=3&year=2026
Authorization: Bearer <token_from_login>
```

**Kiểm tra**:

- ✅ Giao dịch vừa tạo có trong list không?
- ✅ Amount: 75000?
- ✅ Category: food?

---

#### 2.5 - Update: Sửa Giao Dịch

**Endpoint**: `PUT /transactions/:id`

```bash
PUT http://localhost:5000/transactions/newly_created_id_123
Authorization: Bearer <token_from_login>
Content-Type: application/json

{
  "title": "Test Postman - Ăn sáng (Sửa)",
  "amount": 85000,
  "category": "food"
}
```

**Expected Response** (200 OK):

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Transaction updated successfully",
  "data": {
    "_id": "newly_created_id_123",
    "title": "Test Postman - Ăn sáng (Sửa)",
    "amount": 85000,
    "category": "food"
    // ... other fields
  }
}
```

**📊 Ghi chép**:

- Amount sau sửa: `___` (expect 85000)
- Status: ✅ / ❌

---

#### 2.6 - Delete: Xóa Giao Dịch

**Endpoint**: `DELETE /transactions/:id`

```bash
DELETE http://localhost:5000/transactions/newly_created_id_123
Authorization: Bearer <token_from_login>
```

**Expected Response** (200 OK):

```json
{
  "success": true,
  "statusCode": 200,
  "message": "Transaction deleted successfully",
  "data": {
    "_id": "newly_created_id_123"
    // ... deleted transaction data
  }
}
```

**📊 Ghi chép**:

- Status: ✅ / ❌

---

#### 2.7 - Verify: Xem danh sách lần cuối (Read)

**Chạy lại GET /transactions**:

```bash
GET http://localhost:5000/transactions?month=3&year=2026
Authorization: Bearer <token_from_login>
```

**Kiểm tra**:

- ✅ Giao dịch vừa xóa **không** còn trong list?
- ✅ Tổng số transactions **giảm** về con số ban đầu?

---

## 🎯 PHASE 2: Mobile Integration Testing

### Step 3️⃣: Mobile Cấu Hình

#### 3.1 - Check Backend URL Config

**File**: `mobile/lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // Kiểm tra baseUrl pointing đến backend server
  static const String baseUrl = 'http://YOUR_BACKEND_IP:5000';

  // Nếu bạn chạy cùng máy, dùng:
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000'; // iOS simulator
}
```

**❓ Câu hỏi**:

- Backend chạy ở đâu? (local machine / remote server)
- Mobile chạy ở đâu? (device / emulator)

**→ Nếu cùng máy + Android emulator**: Thay bằng `http://10.0.2.2:5000`

#### 3.2 - Start Mobile App

```bash
cd mobile

# Clean build (optional nhưng recommended)
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run -v

# Expected output:
# ✓ Device connected
# ✓ Build successful
# ✓ App launched on device/emulator
```

**Giữ terminal này **mở** và canh sát logs**

---

### Step 4️⃣: Mobile Manual Testing - CRUD Flow

#### 4.1 - Login trên Mobile

1. **Mở app** → Thấy Login screen
2. **Nhập credentials**:
   - Email: `test@example.com`
   - Password: `password123`
3. **Nhấn "Đăng Nhập"**
4. **Kiểm tra**:
   - ✅ Login thành công?
   - ✅ Token được save?
   - ✅ Chuyển sang Home screen?

**📊 Ghi chép**:

- Login status: ✅ / ❌
- Logs (từ `flutter run` terminal):
  ```
  🚀 REQUEST [POST] /auth/login
  200 OK - Login successful
  ```

---

#### 4.2 - View Transactions (Read)

1. **Ở Home screen**, xem danh sách giao dịch
2. **Kiểm tra**:
   - ✅ Danh sách load thành công?
   - ✅ Thấy ít nhất 1 transaction?
   - ✅ Dữ liệu từ backend (không phải dummy)?

**Cách verify dữ liệu từ backend**:

- Xem logs mobile: `🚀 REQUEST [GET] /transactions`
- Check JSON response contains data từ Postman test trước

**📊 Ghi chép**:

- Số transactions thấy: `___`
- Transaction IDs visible: `___`

---

#### 4.3 - Create Transaction (Create)

1. **Nhấn nút "Thêm giao dịch"** (FAB hoặc button)
2. **Điền form**:
   - Title: `Mobile Test - Mua cà phê`
   - Amount: `35000`
   - Type: `Expense` (Chi)
   - Category: `Food` (hoặc food)
   - Date: Today (mặc định)
   - Note: `Test tạo giao dịch từ mobile`
3. **Nhấn "Lưu"** hoặc **"Thêm"**
4. **Kiểm tra**:
   - ✅ Giao dịch xuất hiện trong danh sách?
   - ✅ Amount hiển thị đúng 35000?
   - ✅ Không có validation errors?

**Cách verify gọi API thành công**:

- Terminal mobile logs: `🚀 REQUEST [POST] /transactions`
- Response status: `201 Created`
- Transaction ID returned không rỗng

**📊 Ghi chép**:

- Transaction created: ✅ / ❌
- Thấy transaction trong list ngay: ✅ / ❌
- Transaction ID: `___` (lấy từ logs nếu cần)

---

#### 4.4 - Update Transaction (Update)

1. **Từ danh sách, nhấn vào transaction vừa tạo** (hoặc nhấn edit icon)
2. **Chỉnh sửa**:
   - Title: `Mobile Test - Mua cà phê (Sửa)`
   - Amount: `45000` (tăng từ 35000)
3. **Nhấn "Lưu"** hoặc **"Cập nhật"**
4. **Kiểm tra**:
   - ✅ Transaction được cập nhật trong list?
   - ✅ Amount hiển thị đúng 45000?
   - ✅ Back về danh sách và thấy dữ liệu mới?

**Cách verify gọi API thành công**:

- Terminal mobile logs: `🚀 REQUEST [PUT] /transactions/:id`
- Response status: `200 OK`

**📊 Ghi chép**:

- Transaction updated: ✅ / ❌
- Amount mới = 45000: ✅ / ❌

---

#### 4.5 - Delete Transaction (Delete)

1. **Từ danh sách, tìm transaction vừa cập nhật**
2. **Nhấn "Xóa"** (trash icon hoặc swipe)
3. **Confirm dialog**: Nhấn "Xóa" để confirm
4. **Kiểm tra**:
   - ✅ Giao dịch biến mất khỏi list?
   - ✅ Không có errors?

**Cách verify gọi API thành công**:

- Terminal mobile logs: `🚀 REQUEST [DELETE] /transactions/:id`
- Response status: `200 OK`

**📊 Ghi chép**:

- Transaction deleted: ✅ / ❌
- Biến mất khỏi list: ✅ / ❌

---

### Step 5️⃣: Verification - Đối Chiếu Backend ↔ Mobile

Sau khi xong các test trên mobile, **kiểm tra Backend bằng Postman**:

#### 5.1 - GET /transactions từ Postman lần cuối

```bash
GET http://localhost:5000/transactions?month=3&year=2026
Authorization: Bearer <token>
```

**Kiểm tra**:

- ✅ Transactions được tạo từ mobile có trong backend?
- ✅ Dữ liệu khớp với mobile (amount, title, category)?
- ✅ Transactions bị xóa từ mobile không còn ở backend?

**📊 Ghi chép**:

- Backend data sync với mobile: ✅ / ❌
- Dữ liệu inconsistencies: `___`

---

## 📊 Summary: Test Results

| Feature             | Backend (Postman) | Mobile  | Status  |
| ------------------- | ----------------- | ------- | ------- |
| **Login**           | ✅ / ❌           | ✅ / ❌ | ✅ / ❌ |
| **Read (GET)**      | ✅ / ❌           | ✅ / ❌ | ✅ / ❌ |
| **Create (POST)**   | ✅ / ❌           | ✅ / ❌ | ✅ / ❌ |
| **Update (PUT)**    | ✅ / ❌           | ✅ / ❌ | ✅ / ❌ |
| **Delete (DELETE)** | ✅ / ❌           | ✅ / ❌ | ✅ / ❌ |
| **Data Sync**       | -                 | -       | ✅ / ❌ |

---

## 🐛 Troubleshooting

### Issue 1: Mobile không kết nối backend (404 / Connection refused)

**Nguyên nhân**: Backend URL sai

**Fix**:

```dart
// mobile/lib/core/constants/api_constants.dart
// Nếu Android emulator:
static const String baseUrl = 'http://10.0.2.2:5000';
// Nếu iOS simulator:
static const String baseUrl = 'http://localhost:5000';
// Nếu real device:
static const String baseUrl = 'http://<YOUR_MACHINE_IP>:5000';
```

**Test kết nối**:

```bash
# Từ mobile terminal
flutter run -v | grep "REQUEST"
```

---

### Issue 2: Authentication Error (401 Unauthorized)

**Nguyên nhân**: Token expire hoặc không được pass

**Fix**:

- Login lại để lấy token mới
- Verify token được save right vào SharedPreferences
- Check logs: `Headers: Authorization: Bearer ...`

---

### Issue 3: Validation Error (400 Bad Request)

**Nguyên nhân**: Dữ liệu input không valid

**Fix**: Check backend logs xem error message:

```bash
# Backend terminal sẽ show validation errors
❌ Validation Error: amount must be positive
```

---

### Issue 4: CORS Error

**Nguyên nhân**: Frontend (mobile) không được phép call backend API

**Fix**: Đảm bảo backend đã enable CORS:

```javascript
// backend/server.js
app.use(
  cors({
    origin: "*", // hoặc specify frontend origins
    credentials: true,
    optionsSuccessStatus: 200,
  }),
);
```

---

## ✅ Checklist Completion

- [ ] Backend server running successfully
- [ ] Postman authentication successful
- [ ] POST /transactions (Create) works
- [ ] GET /transactions (Read) returns data
- [ ] PUT /transactions (Update) modifies data
- [ ] DELETE /transactions (Delete) removes data
- [ ] Mobile app connects to backend
- [ ] Mobile CRUD operations work
- [ ] Data syncs between backend ↔ mobile
- [ ] No critical errors in logs

---

## 📝 Notes & Issues Found

```
[Backend]


[Mobile]


[General Issues]


```

---

**Cập nhật lần cuối**: 22/03/2026 - Version 1.0
