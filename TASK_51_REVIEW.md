# 📋 Code Review: Task #51 - POST /transactions

**Reviewer:** Leader (Minh)
**Assignee:** Backend (Duy)
**Date:** 28/02/2026
**Status:** ⚠️ Needs Changes / Improvements

---

## 📌 Tóm tắt nhanh

Duy đã implement API `POST /api/transactions` và các endpoint liên quan (cả phần lấy transactions). Code có cấu trúc rõ ràng, validation và tests cơ bản. Tuy nhiên có một số điểm cần điều chỉnh trước khi merge để đảm bảo an toàn, tính nhất quán và tránh lỗi runtime.

---

## 📋 Files đã xem

- `backend/routes/transaction_routes.js`
- `backend/controllers/transaction_controller.js`
- `backend/services/transaction_service.js`
- `backend/validators/transaction_validator.js`
- `backend/models/transaction_schema.js`
- `backend/middleware/validate_middleware.js`
- `backend/middleware/auth_middleware.js`
- `backend/utils/response_util.js`

---

## ✅ Những điểm làm tốt

- Thiết kế tách bạch (routes → middleware → controller → service → model). Dễ đọc và maintain.
- `Joi` validator được dùng cho cả query và body, có messages rõ ràng.
- Responses được chuẩn hoá bằng `successResponse` / `errorResponse`.
- `getFilteredTransactions` trả kèm stats (aggregation) – hợp lý cho UI chỉ gọi 1 API.
- Có tests unit/integration (theo attachments) và Postman evidence.

---

## ⚠️ Vấn đề cần fix (priority)

1. Kiểm tra dependency escape-regex
   - Vị trí: `backend/services/transaction_service.js` dùng `require("regex-escape")`.
   - Vấn đề: package phổ biến hơn là `escape-string-regexp`. Nếu dependency sai sẽ gây lỗi khi chạy.
   - Hành động: kiểm tra `package.json` và thay bằng `escape-string-regexp` hoặc thêm fallback function để escape regex.

2. Ép kiểu (coerce) các giá trị query trước khi dùng
   - Vị trí: `getFilteredTransactions` dùng `page`, `limit`, `month`, `year` trực tiếp.
   - Vấn đề: giá trị từ `req.query` là string. Phép tính như `(page - 1) * limit` có thể sai/nhầm.
   - Hành động: ép kiểu sớm, ví dụ:

   ```js
   const pageNum = Math.max(1, Number(page) || 1);
   const limitNum = Math.min(100, Number(limit) || 20);
   const skip = (pageNum - 1) * limitNum;
   ```

3. Parse `date` rõ ràng & timezone
   - Vị trí: `createTransaction` trong service đang dùng `new Date(`${payload.date}T00:00:00.000Z`)`.
   - Vấn đề: thêm `Z` ép UTC midnight; có thể khác timezone khi hiển thị. Cần rõ rule (lưu UTC hay local) và xử lý an toàn.
   - Hành động: parse bằng `Date.UTC` để chính xác, ví dụ:

   ```js
   const [y, m, d] = payload.date.split("-").map(Number);
   const parsedDate = new Date(Date.UTC(y, m - 1, d));
   ```

4. Defense-in-depth cho dữ liệu ở service
   - Dù validator đã kiểm tra, service vẫn nên đảm bảo `amount` là number, `userId` hợp lệ, `category` trong danh sách.
   - Hành động: ép kiểu `amount = Number(payload.amount)` và kiểm tra `Number.isNaN(amount)`; kiểm tra `mongoose.Types.ObjectId.isValid(userId)` (đã có) và category nếu cần.

5. Kiểm tra `auth_middleware` sau verify token
   - Hiện tại: gán `req.user = { _id: payload.userId }` ngay sau `jwtVerify`.
   - Hành động: nếu `payload.userId` undefined → trả 401; đảm bảo `JWT_SECRET` tồn tại khi startup.

---

## 🛠 Gợi ý sửa (copy/paste)

1. Fallback escape-regex:

```js
let escapeStringRegexp;
try {
  escapeStringRegexp = require("escape-string-regexp");
} catch (e) {
  escapeStringRegexp = (s) => s.replace(/[.*+?^${}()|[\\]\\]/g, "\\\\$&");
}
```

2. Coerce page/limit:

```js
const pageNum = Math.max(1, Number(page) || 1);
const limitNum = Math.min(100, Number(limit) || 20);
const skip = (pageNum - 1) * limitNum;
// .limit(limitNum)
```

3. Parse date an toàn (UTC):

```js
const [y, m, d] = payload.date.split("-").map(Number);
const parsedDate = new Date(Date.UTC(y, m - 1, d));
```

4. Defensive amount check:

```js
const amountNum = Number(payload.amount);
if (Number.isNaN(amountNum)) throw new AppError("Invalid amount", 400);
```

---

## ✅ Tests - đề xuất bổ sung

- Test `page`/`limit` khi gửi chuỗi (e.g. `?page=2&limit=20`).
- Test combo invalid category → trả 400.
- Test gửi đồng thời `from+to` và `month+year` để đảm bảo rule ưu tiên (nếu đã chọn). Hiện validator dùng `oxor`/`and` nhưng cần test end-to-end.
- Test parsing date để đảm bảo ngày lưu đúng (timezone).

---

## 🔒 Bảo mật

- Đảm bảo `JWT_SECRET` được set; nếu không app nên fail startup.
- Sau `jwtVerify`, confirm `payload.userId` tồn tại trước khi gán `req.user`.

---

## ✅ Acceptance checklist (ready to merge khi)

- [ ] Tất cả unit & integration tests pass trên CI.
- [ ] `package.json` xác nhận package escape-regex đúng hoặc đã thêm fallback.
- [ ] Đã xử lý ép kiểu `page`/`limit` hoặc xác nhận middleware luôn convert an toàn.
- [ ] Các thay đổi date parsing / defensive checks đã được review.
- [ ] PR description kèm evidence: Postman screenshot + test summary và link task #33.

---

## 🎯 Action Items cho Duy

1. Kiểm tra `package.json` và fix package escape-regex hoặc thêm fallback (như snippet trên).
2. Ép kiểu `page`/`limit` trong `getFilteredTransactions`.
3. Parse date bằng `Date.UTC` và comment rõ rule timezone.
4. Thêm defensive checks cho `amount` và `payload` trong service.
5. Thêm test case đề xuất và chạy CI.

---

## 💬 Ghi chú cuối

Code hiện tại đã tốt ở nhiều phần, chỉ cần vài chỉnh sửa nhỏ để tăng robustness. Sau khi Duy apply các fix nhỏ này, PR có thể merge nhanh.

**Reviewer:** Leader (Minh)
