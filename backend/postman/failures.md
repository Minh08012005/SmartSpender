# failures.md – Failing Test Cases Report

> **Hướng dẫn điền**: Với mỗi case thất bại, sao chép template bên dưới và điền đầy đủ thông tin.  
> Mỗi entry phải có: request đầy đủ (method + URL + headers + body), response JSON đầy đủ, và các bước tái tạo.

---

## Tổng quan

Trạng thái hiện tại: **chưa ghi nhận failing case thực tế** trong đợt chạy gần nhất.
Các case bên dưới là **pass evidence** cho nhóm validation/auth.

| #   | Test Case ID | Endpoint                                              | Kỳ vọng | Thực tế | Trạng thái |
| --- | ------------ | ----------------------------------------------------- | ------- | ------- | ---------- |
| 1   | TC-V01       | GET /api/transactions?month=3                         | 400     | 400     | ✅ PASS    |
| 2   | TC-V02       | GET /api/transactions?month=13&year=2026              | 400     | 400     | ✅ PASS    |
| 3   | TC-V03       | GET /api/transactions?month=3&year=2026&from=..&to=.. | 400     | 400     | ✅ PASS    |
| 4   | TC-A01       | GET /api/transactions (no token)                      | 401     | 401     | ✅ PASS    |
| 5   | TC-A02       | GET /api/transactions (invalid token)                 | 401     | 401     | ✅ PASS    |
| 6   | TC-S03       | GET /api/statistics/summary?month=3                   | 400     | 400     | ✅ PASS    |

> Nếu phát hiện case thất bại mới khi chạy Postman/Newman, thêm vào mục **Fail Evidence** bên dưới và điền template.

---

## Fail Evidence

Chưa phát hiện failing case trong lần cập nhật hiện tại.

---

## Template cho failing case

Sao chép và điền vào phần này cho mỗi case fail:

---

### [ID] – Mô tả ngắn

#### Request

```http
METHOD  /path?query
Host: localhost:3000
Authorization: Bearer <token>
Content-Type: application/json

{request body nếu có}
```

#### Response nhận được

```json
{
  "success": false,
  "statusCode": ...,
  "message": "...",
  "errors": [...]
}
```

#### Response kỳ vọng

```json
{
  "success": ...,
  "statusCode": ...,
  "message": "..."
}
```

#### Bước tái tạo

1. Đảm bảo server đang chạy (`npm run dev` hoặc `npm start`).
2. Đăng nhập: `POST /api/auth/login` với `{"email":"...", "password":"..."}`.
3. Copy token từ response.
4. Gửi request trên với token vừa lấy.
5. Quan sát response.

#### Root cause (điền sau khi điều tra)

> _Chưa rõ / đang điều tra_

#### Proposed fix

> _Chưa có_

---

## Các case đã được fix trước khi phát hành

### BUG-001 – `app.js` require paths sai tên file → Integration tests không chạy được

**Phát hiện**: `npm test` cho kết quả `Cannot find module './middleware/rate_limit_middleware'`.

**Root cause**: `app.js` dùng sai tên file:

- `./middleware/rate_limit_middleware` → đúng là `./middleware/rateLimit.middleware`
- `./middleware/error_handler_middleware` → đúng là `./middleware/errorHandler.middleware`
- `./routes/auth/register_route` → đúng là `./routes/auth/register.route`
- `./routes/auth/login_route` → đúng là `./routes/auth/login.route`

**Fix**: Sửa 4 require paths trong [app.js](../app.js).

**Evidence**: Sau fix, `Tests: 81 passed, 81 total`.

---

### BUG-002 – `transactionService.updateTransaction` không tồn tại → PUT tests trả 500

**Phát hiện**: `transaction.put.test.js` báo `TypeError: transactionService.updateTransaction is not a function`.

**Root cause**: `transaction.service.js` chỉ export `getFilteredTransactions`, không có `updateTransaction`.  
Controller gọi `transactionService.updateTransaction(...)` nhưng hàm chưa được implement.

**Fix**:

1. Thêm `exports.updateTransaction` vào [transaction.service.js](../services/transaction.service.js): dùng `findOneAndUpdate` với ownership check (`userId` match), trả 404 nếu không tìm thấy.
2. Thêm guard `if (!body || Object.keys(body).length === 0)` trong service để trả 400 khi body rỗng (theo yêu cầu của integration test, trong khi unit validator test để pass empty payload lên service layer).

**Evidence**: Sau fix, tất cả 9 case trong `transaction.put.test.js` đều PASS.
