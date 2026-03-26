# 🧪 HƯỚNG DẪN TEST API STATISTICS - SmartSpender

## 📌 TÓNG TẮT CÁC BỨC

### **Bước 1: Khởi động Backend**

```bash
# Terminal 1
cd F:/BTL_CNPM/smartspender/SmartSpender/backend
npm install
npm run dev

# Output mong đợi:
# Server running on port 3000 in development mode
```

**Xác thực:** Truy cập `http://localhost:3000` - nếu không lỗi là OK

---

### **Bước 2: Test Backend API (Tự động hoá - Khuyến nghị)**

```bash
# Terminal 2
cd F:/BTL_CNPM/smartspender/SmartSpender

# Chạy script PowerShell (Windows)
.\TEST_API_STATISTICS.ps1

# Hoặc Bash (Mac/Linux)
sh QUICK_START_TEST.sh
```

**Script sẽ tự động:**

- ✅ Kiểm tra backend connection
- ✅ Đăng ký/Login test user
- ✅ Test statistics API (/api/statistics/summary)
- ✅ Test transactions API
- ✅ Test negative cases (401, 400)

**Output mong đợi:**

```
📊 Statistics API Tests:   3 PASSED, 0 FAILED
   ✅ Month 3/2026: Income ₫XXX, Expense ₫XXX
   ✅ Month 2/2026: Income ₫XXX, Expense ₫XXX
   ✅ Month 1/2026: Income ₫XXX, Expense ₫XXX
```

---

### **Bước 3: Khởi động Mobile**

```bash
# Terminal 3
cd F:/BTL_CNPM/smartspender/SmartSpender/mobile

# Chạy app
flutter run

# Hoặc specify device
flutter devices  # Xem danh sách
flutter run -d emulator-5554  # Chỉ định device
```

**Output mong đợi:**

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
✓ Installing and launching...
```

---

### **Bước 4: Test Trên Mobile**

#### 👤 Login

- Email: `test@smartspender.com`
- Password: `Test@123456`

#### 📊 Chuyển tới Statistics Screen

- Tap tab "Thống kê" / "Statistics"

#### ✅ Xác Thực KPI Cards

**Đối chiếu Backend API response vs Mobile UI:**

| KPI           | Backend `GET /api/statistics/summary?month=3&year=2026` | Mobile UI  | ✅ Match? |
| ------------- | ------------------------------------------------------- | ---------- | --------- |
| Total Income  | API response `data.totalIncome`                         | KPI Card 1 | ?         |
| Total Expense | API response `data.totalExpense`                        | KPI Card 2 | ?         |
| Balance       | API response `data.balance`                             | KPI Card 3 | ?         |

**Ví dụ:**

```
Backend API Response:
{
  "data": {
    "totalIncome": 50000.00,
    "totalExpense": 25000.00,
    "balance": 25000.00
  }
}

Mobile UI phải hiển thị:
├─ Total Expense: ₫25,000
├─ Total Income: ₫50,000
└─ Balance: ₫25,000
```

#### 🔄 Test Period Picker

1. Nhấn vào period selector (month/year)
2. Chọn tháng khác (e.g., Tháng 2)
3. Chờ data reload

**✅ Xác thực:**

- Values cập nhật đúng
- Không có error
- Pull-to-refresh hoạt động

#### 📋 Scroll Xuống Kiểm Tra

- **Category Breakdown:** Hiển thị % chi tiêu per category
- **Recent Transactions:** Hiển thị 5 giao dịch gần nhất

---

## 🔍 KIỂM CHỨNG DỮ LIỆU CHI TIẾT

### Cách 1: Dùng Postman (GUI - Dễ nhất)

**Import Collection:**

```
File → Import → Postman Collection
```

**Test Case 1: Login**

```
POST http://localhost:3000/login
Body:
{
  "email": "test@smartspender.com",
  "password": "Test@123456"
}

Expected: 200 + accessToken
```

**Test Case 2: Get Statistics**

```
GET http://localhost:3000/api/statistics/summary?month=3&year=2026

Authorization: Bearer <TOKEN_FROM_LOGIN>

Expected:
{
  "success": true,
  "data": {
    "totalIncome": XXX,
    "totalExpense": XXX,
    "balance": XXX
  }
}
```

### Cách 2: Dùng VS Code REST Client (Nhẹ nhất)

**File:** `test-statistics.http`

```http
### Login
POST http://localhost:3000/login
Content-Type: application/json

{
  "email": "test@smartspender.com",
  "password": "Test@123456"
}

### Extract token from above response, then:

### Get Statistics Summary
GET http://localhost:3000/api/statistics/summary?month=3&year=2026
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

### Get Transactions (for category breakdown)
GET http://localhost:3000/api/transactions?month=3&year=2026
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...
```

### Cách 3: Dùng Curl (Terminal)

```bash
# Login & lấy token
TOKEN=$(curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@smartspender.com","password":"Test@123456"}' \
  | jq -r '.data.accessToken')

# Get Statistics
curl -X GET "http://localhost:3000/api/statistics/summary?month=3&year=2026" \
  -H "Authorization: Bearer $TOKEN"
```

---

## ✅ FULL TEST CHECKLIST

### Backend

- [ ] Server chạy port 3000
- [ ] MongoDB connected ✅
- [ ] Test script chạy không lỗi
- [ ] Statistics API returns 200
- [ ] Data có 3 field: totalIncome, totalExpense, balance

### Mobile

- [ ] App build successful (flutter analyze: 0 errors)
- [ ] Login flows through ✅
- [ ] Statistics screen loads ✅
- [ ] KPI cards visible ✅
- [ ] Values match backend API ✅
- [ ] Period picker works ✅
- [ ] Category breakdown visible ✅
- [ ] Recent transactions visible ✅

### Data Consistency

- [ ] Mobile Income value = Backend API totalIncome
- [ ] Mobile Expense value = Backend API totalExpense
- [ ] Mobile Balance = Backend API balance

### Performance

- [ ] API response time < 500ms
- [ ] No lag on UI
- [ ] No memory leaks

---

## 🐛 TROUBLESHOOTING

### ❌ "Cannot connect to localhost:3000"

**Giải pháp:**

1. Backend có running không? `npm run dev`
2. Port 3000 có bị chiếm không?

   ```bash
   # Windows
   netstat -ano | findstr :3000

   # Mac/Linux
   lsof -i :3000
   ```

### ❌ "401 Unauthorized"

**Giải pháp:**

```
1. Đăng ký/login lại để get token mới
2. Copy chính xác header: Authorization: Bearer <TOKEN>
3. Check token không hết hạn (JWT_SECRET đúng?)
```

### ❌ Statistics API returns 0 values

**Giải pháp:**

```bash
# Kiểm tra có transaction cho month/year này không
# MongoDB Compass:
# db.transactions.find({ year: 2026, month: 3 })

# Hoặc import seed data:
# node backend/seeds/transaction_seed.js
```

### ❌ Mobile shows error "Cannot connect to server"

**Giải pháp (tùy device):**

- **Android Emulator:** Backend URL phải là `http://10.0.2.2:3000`
- **iOS Simulator:** Backend URL phải là `http://localhost:3000`
- **Physical Device:** Backend URL phải là machine IP (e.g., `http://192.168.x.x:3000`)

**Edit:** `mobile/lib/core/config/app_config.dart`

---

## 📊 SAMPLE TEST DATA

Nếu không có transaction hoặc result=0, import seed data:

```bash
cd F:/BTL_CNPM/smartspender/SmartSpender/backend

# Run seed script
node seeds/transaction_seed.js

# Kết quả: Tạo ~20 transactions với tháng/năm khác nhau
```

---

## 🎯 EXPECTED RESULTS

### ✅ Thành Công

```
TERMINAL 2 Output:
───────────────────────────────────────────
✅ Backend Connection: SUCCESS
✅ Authentication: SUCCESS
📊 Statistics API Tests: 3 PASSED

TERMINAL 3 (Mobile):
───────────────────────────────────────────
Login: OK
Statistics Screen: LOADED
KPI Cards: Income ₫50,000 | Expense ₫25,000 | Balance ₫25,000
Category Breakdown: OK
Recent Transactions: OK
```

---

## 📞 SUPPORT

Sau khi test xong, gather:

1. **Backend logs** (Terminal 1)
2. **Test output** (Terminal 2)
3. **Mobile debug logs** (Terminal 3)
4. **Screenshots** (Mobile UI)

Lưu lại trong email/ticket cho team review.

---

## ⏱️ ESTIMATED TIME

- Backend setup: **5 min**
- API test: **2 min** (auto script)
- Mobile test: **10 min**
- **Total: ~20 min ✅**

---

**Status: 🟢 Ready to Test**  
**Date: March 26, 2026**  
**App Version: 1.0.0**
