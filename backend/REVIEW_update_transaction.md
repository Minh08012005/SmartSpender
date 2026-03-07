# Review: Hoàn thiện API Update Transaction (PUT /api/transactions/:id)

**Người review:** Mai Huy Minh
**Branch kiểm tra:** `feat/API_Update` (commit gần nhất)

---

## 1) Tóm tắt những gì đã làm tốt (đã fix)

- Đã import `VALID_CATEGORIES` đúng chỗ (không còn ReferenceError).
- Đã thêm `objectIdParamSchema` và validate `params.id` trên route PUT → fail-fast cho malformed id.
- Service có nhiều defensive checks: guard kiểu trước khi dùng `.trim()`/`.toLowerCase()`, validate `amount` (>= 0), validate `date` (ISO), validate `category` và `type`.
- Đã cast `userId`/`transactionId` sang `mongoose.Types.ObjectId` trước khi query → ownership check chính xác.
- `createTransaction` đã normalize input (trim title, lowercase category, coerce amount).
- Pagination `page`/`limit` đã được cast sang `Number` trước khi tính `skip`.
- Thêm integration tests cho PUT cover các case quan trọng (update type/note, amount=0, partial update, invalid inputs, malformed id, not-owner).

---

## 2) Những điểm cần sửa / hoàn thiện (ưu tiên)

1. Sử dụng `limitNum` nhất quán trong `getFilteredTransactions`: hiện code tính `limitNum` nhưng gọi `.limit(Number(limit))`. Sửa thành `.limit(limitNum)`.
2. Đồng bộ contract `date`: trong Swagger/Docs nêu rõ API chấp nhận `ISO 8601` (ví dụ `2026-03-01T00:00:00Z`) hoặc nếu muốn chấp nhận `YYYY-MM-DD` thì service cần parse chính xác theo UTC. Chọn 1 và update cả validator, service và docs.
3. Chuẩn hoá format lỗi trả về: validator (Joi) và service (AppError) nên trả thông tin error nhất quán (vd. `{ field, message }` hoặc `errors: []`) để client/mobile dễ xử lý.
4. Thêm debug logging cho những trường hợp permission-denied / invalid-id để dễ debug (không log token/password).
5. Kiểm tra index Mongo cho trường `userId` và `date` (hoặc compound index) để tối ưu query lọc/aggregate.
6. Đảm bảo CI có MongoDB để chạy integration tests hoặc mock DB; cập nhật README test-run nếu cần.

---

## 3) Gợi ý code sửa (thực tế và ngắn) — Bảo tự thêm vào service/route

1. Fix `limitNum` nhất quán

```js
// trong getFilteredTransactions
const pageNum = Number(page) || 1;
const limitNum = Number(limit) || 20;
const skip = (pageNum - 1) * limitNum;
...
.limit(limitNum)
```

2. Đồng bộ `date` (nếu chọn ISO): update docs và đảm bảo service parse ISO

```js
// service: updateTransaction
if (payload.date !== undefined) {
  if (typeof payload.date !== "string")
    throw new AppError("Date must be a string (ISO 8601)", 400);
  const parsed = new Date(payload.date);
  if (isNaN(parsed.getTime())) throw new AppError("Invalid date format", 400);
  sanitized.date = parsed; // store Date object
}
```

3. Thêm logging debug (ví dụ dùng console hoặc logger)

```js
// khi update không tìm thấy -> permission denied
if (!updated) {
  logger && logger.debug("Update failed", { userId, transactionId });
  throw new AppError("Transaction not found or permission denied", 404);
}
```

4. Chuẩn hoá error response (gợi ý format)

```js
// utils/response.util.js -> successResponse / errorResponse
// errorResponse example:
{
  success: false,
  statusCode: 400,
  message: 'Validation failed',
  errors: [ { field: 'amount', message: 'amount must be >= 0' } ]
}
```

5. Nếu cần hỗ trợ `YYYY-MM-DD` chính xác (UTC):

```js
function parseYYYYMMDD(s) {
  const parts = s.split("-").map(Number);
  if (parts.length !== 3) return null;
  const [y, m, d] = parts;
  const dt = new Date(Date.UTC(y, m - 1, d));
  if (
    dt.getUTCFullYear() !== y ||
    dt.getUTCMonth() !== m - 1 ||
    dt.getUTCDate() !== d
  )
    return null;
  return dt;
}

// use when payload.date matches /^\d{4}-\d{2}-\d{2}$/ then parseYYYYMMDD
```

---

## 4) Tests cần đảm bảo (nên có trong PR)

- Unit tests cho `updateTransaction` cover: invalid id, empty payload, invalid amount, invalid date, invalid category, invalid type, ownership denied, successful partial updates.
- Integration tests: đã có `transaction.put.test.js` nhưng lưu ý đảm bảo môi trường CI có DB hoặc dùng test container.

---

## 5) PR checklist (copy-paste vào PR description)

- [ ] Dùng `limitNum` cho `.limit(...)` trong `getFilteredTransactions`.
- [ ] Cập nhật Swagger/Docs: nêu rõ `date` format = ISO 8601 (hoặc sửa parsing nếu muốn hỗ trợ YYYY-MM-DD).
- [ ] Chuẩn hoá error response format giữa validator và service.
- [ ] Thêm debug logs cho permission-denied cases (không log sensitive info).
- [ ] Kiểm tra/Thêm index Mongo cho `userId`, `date` nếu cần.
- [ ] Đảm bảo CI có Mongo test DB hoặc chuyển tests sang mock; đính kèm hướng dẫn chạy test.
- [ ] Chạy `npm test` + lint/format; đính kèm test output trong PR.

---

## 6) Gợi ý mô tả PR (title + body ngắn)

- Title: `feat(transaction): implement and harden update transaction (PUT /api/transactions/:id)`
- Body (ngắn):
  - Tóm tắt: implement updateTransaction service + controller + route + validator + tests
  - Changes: defensive checks, normalization, params validation, integration tests
  - Tests: đính kèm output `npm test`

---
