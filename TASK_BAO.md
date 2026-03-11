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

---

## 🔧 Vừa được fix (bởi Copilot)

| #   | Vấn đề                                                                                                          | File đã sửa                            |
| --- | --------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| 🔧  | Route `DELETE /api/transactions/:id` bị thiếu hoàn toàn — controller & service đã xong nhưng chưa đăng ký route | `backend/routes/transaction_routes.js` |

---

## 🚧 CÒN PHẢI LÀM — Checklist cho Bảo

---

### Pha 3 — Hiện thực hóa (Coding)

#### 3.1 Kiểm tra lại API Delete Transaction

> Route đã được fix tự động. Bảo cần xác nhận hoạt động đúng.

- [ ] Chạy server và test thủ công `DELETE /api/transactions/:id` bằng Postman / curl
- [ ] Kiểm tra trả về `200` khi xóa thành công transaction của đúng user
- [ ] Kiểm tra trả về `404` khi xóa transaction không tồn tại hoặc không thuộc về user hiện tại
- [ ] Kiểm tra trả về `400` khi truyền `id` không đúng định dạng ObjectId (24 ký tự hex)
- [ ] Kiểm tra trả về `401` khi không có Bearer token

> 📌 **Lưu ý:** Swagger docs cho endpoint DELETE đã được thêm vào `transaction_routes.js` — vào `http://localhost:3000/api-docs` để kiểm tra tài liệu hiển thị đúng chưa.

---

#### 3.2 Kiểm tra Middleware xác thực (ownership check)

> Middleware `authenticate` đã được áp dụng cho tất cả 4 route. Cần xác nhận logic ownership.

- [ ] Xác nhận `authenticate` middleware đã bảo vệ đủ 4 route: `GET`, `POST`, `PUT`, `DELETE`
- [ ] Test: Đăng nhập user A → tạo transaction → đăng nhập user B → thử PUT/DELETE transaction của user A → kết quả phải là `404` (không phải `403`, vì không lộ thông tin transaction tồn tại)
- [ ] Đảm bảo `req.user._id` được truyền đúng vào service layer ở cả 4 endpoint

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

- [x] `POST /api/transactions` hoạt động và có Swagger docs
- [x] `PUT /api/transactions/:id` hoạt động và có Swagger docs
- [ ] `DELETE /api/transactions/:id` pass tất cả test case (manual + unit test)
- [ ] Unit tests viết đủ cho service & validator, pass `npm test`
- [ ] Swagger UI hiển thị đủ cả 4 endpoints, team Mobile xác nhận đã đọc tài liệu
- [ ] PR được tạo, code review bởi Minh, merge vào `dev`

---

_Cập nhật: 08/03/2026_
