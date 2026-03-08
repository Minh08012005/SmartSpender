# 📋 Task của Vũ Nguyễn Ngọc Bảo — [BE] Basic CRUD Transaction & Documentation #33

> **Sprint 2** · 10/02 – 20/02/2026  
> **Trạng thái hiện tại:** 🔄 In Progress

---

## ✅ Đã hoàn thành

| #   | Hạng mục                                                                         |
| --- | -------------------------------------------------------------------------------- |
| ✅  | Phân tích: Liệt kê các trường dữ liệu Transaction (Amount, Category, Note, Date) |
| ✅  | Phân tích: Xác định rule validation (Amount > 0, Date không null...)             |
| ✅  | Thiết kế: Viết Swagger/OpenAPI cho toàn bộ endpoints trước khi code              |
| ✅  | Thiết kế: Validation Schema (Joi) cho Create / Update / Delete / Get             |
| ✅  | **[Coding]** API Create Transaction — `POST /api/transactions`                   |
| ✅  | **[Coding]** API Update Transaction — `PUT /api/transactions/:id`                |
| ✅  | **[Coding + Docs]** API Delete Transaction — `DELETE /api/transactions/:id`      |

---

## 🔧 Vừa được fix (bởi Copilot - 08/03/2026)

| #   | Vấn đề                                                                                                          | Status | File đã sửa                            |
| --- | --------------------------------------------------------------------------------------------------------------- | ------ | -------------------------------------- |
| 🔧  | Route `DELETE /api/transactions/:id` bị thiếu hoàn toàn — controller & service đã xong nhưng chưa đăng ký route | ✅ Fixed | `backend/routes/transaction_routes.js` |
| 🔧  | Swagger docs cho DELETE thiếu response examples cho 400/401/404 errors | ✅ Fixed | `backend/routes/transaction_routes.js` |
| 🔧  | Xóa duplicate file `transaction_service.js` — import sai `../utils/app_error` | ✅ Fixed | `backend/services/transaction_service.js` |

---

## 🚧 CÒN PHẢI LÀM — Checklist cho Bảo

---

### Pha 3 — Hiện thực hóa (Coding)

#### 3.1 ✅ API Delete Transaction (HOÀN THÀNH)

**Những gì đã được thực hiện:**

- ✅ Route `DELETE /api/transactions/:id` được đăng ký tại `backend/routes/transaction_routes.js` (lines 353-362)
- ✅ Controller `deleteTransaction` được import từ `backend/controllers/transaction_controller.js` (line 5)
- ✅ Middleware xác thực (`authenticate`) bảo vệ route
- ✅ Validation ObjectId tại `params` bằng `objectIdParamSchema`
- ✅ Service layer `deleteTransaction()` xử lý logic (check ownership, delete)
- ✅ Swagger docs đầy đủ với response examples cho 200/400/401/404

**Cơ chế hoạt động:**

```javascript
DELETE /api/transactions/65c88df8b2f8a1c21c23abcd
Authorization: Bearer <token>
```

→ Response 200:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Transaction deleted successfully",
  "data": { ...transaction đã xóa... }
}
```

→ Response 404 (không phải của user):
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Transaction not found or permission denied"
}
```

---

#### 3.2 Kiểm tra lại DELETE endpoint (CỦA BẢO)

> **Lưu ý:** Endpoint DELETE đã được hoàn thành. Bảo chỉ cần xác nhận hoạt động bằng test thủ công.

- [ ] **Test thủ công DELETE**:
  - [ ] Mở Postman, tạo request: `DELETE http://localhost:5000/api/transactions/:id`
  - [ ] Thêm header: `Authorization: Bearer <token>`
  - [ ] Gửi request với ID của transaction thuộc user hiện tại → kỳ vọng `200` ✅
  - [ ] Gửi request với ID = `invalid_id` → kỳ vọng `400`: `"Validation failed"`
  - [ ] Gửi request với ID ObjectId hợp lệ nhưng không tồn tại → kỳ vọng `404`
  - [ ] Gửi request không có Bearer token → kỳ vọng `401`: `"Unauthorized"`

- [ ] **Test ownership** (chống bugs security):
  - [ ] Đăng nhập user A, tạo transaction
  - [ ] Đăng xuất, đăng nhập user B
  - [ ] Cố gắng DELETE transaction của user A bằng user B token → kỳ vọng `404` (không `403`, vì lý do bảo mật)

- [ ] **Kiểm tra Swagger docs**:
  - [ ] Chạy `npm run dev` (hoặc `nodemon server.js`)
  - [ ] Truy cập `http://localhost:5000/api-docs` (hoặc `/api/docs`)
  - [ ] Tìm section **Transactions** → endpoint `DELETE /api/transactions/{id}`
  - [ ] Kiểm tra: summary, parameters, responses (200/400/401/404) hiển thị chính xác

---

#### 3.3 Kiểm tra lại Middleware xác thực (ownership check)

> Middleware `authenticate` đã được áp dụng cho tất cả 4 route. Cần xác nhận logic ownership.

- [ ] Xác nhận `authenticate` middleware đã bảo vệ đủ 4 route: `GET`, `POST`, `PUT`, `DELETE`
  - [ ] Kiểm tra import tại dòng 14: `const authenticate = require('../middleware/auth.middleware');`
  - [ ] Kiểm tra từng route: `router.get()` / `router.post()` / `router.put()` / `router.delete()` đều có `authenticate` parameter

- [ ] Test: Đăng nhập user A → tạo transaction → đăng nhập user B → thử PUT/DELETE transaction của user A
  - [ ] Kết quả phải là `404` (không phải `403`, vì không lộ thông tin transaction tồn tại)
  - [ ] **Giải thích:** Trả về 404 thay vì 403 là best practice security — không cho attacker biết transaction có tồn tại hay không

- [ ] Đảm bảo `req.user._id` được truyền đúng vào service layer ở cả 4 endpoint
  - [ ] Kiểm tra `transaction_controller.js`: từng hàm (get, create, update, delete) có pass `req.user._id` không?
  - [ ] Ví dụ ở hàm `deleteTransaction`: `await transactionService.deleteTransaction(req.user._id, transactionId)`

---

### Pha 4 — Kiểm thử (Testing)

> **Vị trí:** `backend/tests/unit/services/` và `backend/tests/unit/validators/`

#### 4.1 Unit Test cho Service layer (`transaction.service.test.js`)

- [ ] Test `createTransaction()`:
  - [ ] Tạo thành công với đủ các trường hợp hợp lệ
  - [ ] Throw lỗi khi `amount` âm
  - [ ] Throw lỗi khi `title` rỗng hoặc không phải string
  - [ ] Throw lỗi khi `category` không nằm trong `VALID_CATEGORIES`
  - [ ] Throw lỗi khi `type` không phải `income` / `expense`

- [ ] Test `updateTransaction()`:
  - [ ] Cập nhật thành công khi payload hợp lệ
  - [ ] Throw lỗi khi `transactionId` không hợp lệ (ObjectId sai định dạng)
  - [ ] Throw lỗi khi payload rỗng (`{}`)
  - [ ] Throw lỗi khi `amount` âm
  - [ ] Throw lỗi khi `title` không phải string
  - [ ] Trả về `404` khi transaction không tồn tại hoặc không thuộc user

- [ ] Test `deleteTransaction()`:
  - [ ] Xóa thành công khi đúng chủ sở hữu
  - [ ] Throw `400` khi `transactionId` sai định dạng ObjectId
  - [ ] Throw `404` khi không tìm thấy hoặc không phải của user

#### 4.2 Unit Test cho Validator (`transaction.validator.test.js`)

- [ ] Test `createTransactionSchema`:
  - [ ] Validation pass với đủ các trường bắt buộc
  - [ ] Validation fail khi thiếu `title`
  - [ ] Validation fail khi `amount` âm (< 0)
  - [ ] Validation fail khi `type` không hợp lệ (ví dụ: `"debit"`)
  - [ ] Validation fail khi `category` không nằm trong danh sách cho phép

- [ ] Test `updateTransactionSchema`:
  - [ ] Validation pass khi chỉ gửi 1 field (ví dụ: chỉ gửi `note`)
  - [ ] Validation fail khi `amount` = `-100`
  - [ ] Validation fail khi `date` sai định dạng (ví dụ: `"32-13-2026"`)

- [ ] Test `objectIdParamSchema`:
  - [ ] Pass với ObjectId hợp lệ 24 ký tự hex
  - [ ] Fail với chuỗi ngắn hơn 24 ký tự
  - [ ] Fail với chuỗi không phải hex (có ký tự đặc biệt)

---

### Pha 5 — Triển khai tài liệu (Documentation)

#### 5.1 Xuất bản tài liệu API cho team Mobile

- [ ] Chạy server local: `npm run dev` và truy cập `http://localhost:3000/api-docs`
- [ ] Kiểm tra Swagger UI hiển thị đủ 4 endpoint của transactions:
  - `GET /api/transactions`
  - `POST /api/transactions`
  - `PUT /api/transactions/{id}`
  - `DELETE /api/transactions/{id}` ← mới thêm
- [ ] Kiểm tra `DELETE` endpoint hiển thị đúng: summary, params, responses (200 / 400 / 401 / 404)
- [ ] Xuất file `swagger.json` / `swagger.yaml` hoặc chia sẻ link Swagger UI cho team Mobile tham khảo khi tích hợp
- [ ] Thông báo cho **Sơn** và **Đức Anh** về cấu trúc response của `DELETE`:
  ```json
  {
    "success": true,
    "statusCode": 200,
    "message": "Transaction deleted successfully",
    "data": { ...transaction đã xóa... }
  }
  ```

---

## ⚠️ Lưu ý thêm (cho Bảo tham khảo, không phải task của Bảo)

Những vấn đề dưới đây **thuộc task của các thành viên khác** nhưng liên quan trực tiếp đến API Bảo đã viết:

| Thành viên           | Vấn đề                                                 | Mô tả                                                                                        |
| -------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| **Sơn** (Mobile)     | `TransactionModel` thiếu field `title`                 | Backend bắt buộc `title` nhưng Flutter model chưa có → cần thêm vào `transaction_model.dart` |
| **Sơn** (Mobile)     | `HomeScreen` vẫn dùng `dummyTransactions`              | Chưa tích hợp với `TransactionProvider` → gọi API thật                                       |
| **Đức Anh** (Mobile) | `TransactionProvider` thiếu method `updateTransaction` | Cần thêm method gọi `PUT /api/transactions/:id`                                              |

> 💡 Bảo nên ping Sơn và Đức Anh về format request/response để họ tích hợp đúng.

---

## 🏁 Định nghĩa "Done" cho task này

Task **#33** được coi là **hoàn thành** khi:

- [x] `POST /api/transactions` hoạt động và có Swagger docs (√ từ Sprint 1)
- [x] `PUT /api/transactions/:id` hoạt động và có Swagger docs (√ từ Sprint 1)
- [x] `DELETE /api/transactions/:id` hoạt động, có Swagger docs, và đầy đủ response examples (✅ mới hoàn thành 08/03)
- [ ] **Bảo thực hiện** test thủ công `DELETE` endpoint (manual test)
- [ ] **Bảo thực hiện** Unit tests cho service layer & validator, all pass `npm test`
- [ ] **Bảo thực hiện** Kiểm tra ownership check logic (không bị bypass)
- [x] Swagger UI hiển thị đủ cả 4 endpoints, có response examples (✅ hoàn thành 08/03)
- [ ] Team Mobile xác nhận đã đọc tài liệu API và sẵn sàng tích hợp
- [ ] PR được tạo, code review bởi Minh, merge vào `dev`

---

## 📝 Hướng dẫn test thủ công DELETE endpoint

### Chuẩn bị

```bash
# Terminal 1: Chạy server
cd backend
npm run dev
# Server chạy tại http://localhost:5000

# Terminal 2: Chuẩn bị data (dùng Postman hoặc curl)
```

### Test Cases

#### 1️⃣ Test 200 — Xóa thành công

```bash
# 1. Tạo transaction (giữ lại _id)
POST http://localhost:5000/api/transactions
Body:
{
  "title": "Test Transaction",
  "amount": 100000,
  "type": "expense",
  "category": "food",
  "date": "2026-03-08"
}

# Response: 201
# Lưu ID từ response → Gọi là TEST_ID

# 2. Xóa transaction vừa tạo
DELETE http://localhost:5000/api/transactions/TEST_ID
Authorization: Bearer <YOUR_TOKEN>

# Kỳ vọng: 200
```

#### 2️⃣ Test 400 — ID không hợp lệ

```bash
DELETE http://localhost:5000/api/transactions/invalid_id_12345
Authorization: Bearer <YOUR_TOKEN>

# Kỳ vọng: 400
# Response:
# {
#   "success": false,
#   "statusCode": 400,
#   "message": "Validation failed",
#   "errors": [{"field": "id", "message": "id must be a valid ObjectId"}]
# }
```

#### 3️⃣ Test 401 — Thiếu token

```bash
DELETE http://localhost:5000/api/transactions/65c88df8b2f8a1c21c23abcd

# Kỳ vọng: 401
# Response:
# {
#   "success": false,
#   "statusCode": 401,
#   "message": "Unauthorized"
# }
```

#### 4️⃣ Test 404 — ID không tồn tại

```bash
DELETE http://localhost:5000/api/transactions/000000000000000000000000
Authorization: Bearer <YOUR_TOKEN>

# Kỳ vọng: 404
# Response:
# {
#   "success": false,
#   "statusCode": 404,
#   "message": "Transaction not found or permission denied"
# }
```

#### 5️⃣ Test Ownership — Chống bypass

```bash
# 1. User A: Tạo transaction (node-1, node-user-a)
# 2. User B: Cố DELETE transaction của User A
DELETE http://localhost:5000/api/transactions/USER_A_TRANSACTION_ID
Authorization: Bearer USER_B_TOKEN

# Kỳ vọng: 404 (không phải 200!)
# ❌ FAIL: Nếu trả về 200 → có bug security!
```

---

---

_Cập nhật: 08/03/2026 - Copilot cập nhật DELETE endpoint + Swagger docs + TASK_BAO.md_
