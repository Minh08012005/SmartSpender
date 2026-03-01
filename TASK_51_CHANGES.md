# Summary of Changes — Task #51 (POST /transactions)

**Reviewer:** Leader (Minh)
**Date:** 01/03/2026

## Mục tiêu
- Tối ưu endpoint `POST /api/transactions` và `GET /api/transactions` theo các điểm review trước đó.
- Sửa các vấn đề bảo mật, validation, và hiệu năng nhỏ.

## Những thay đổi đã thực hiện

1. Tối ưu pipeline truy vấn (backend/services/transaction_service.js)
   - Chuyển `getFilteredTransactions` sang dùng `aggregate` với `$facet` để trả về:
     - `docs` (danh sách transactions với `$skip`/`$limit`),
     - `totalCount` (số bản ghi phù hợp),
     - `stats` (totalAmount, totalIncome, totalExpense)
   - Mục đích: giảm số lần gọi DB (từ 3 câu lệnh xuống 1 pipeline), cải thiện hiệu năng và đảm bảo atomicity cho thống kê.
   - Mở rộng search: tìm kiếm cả `title` và `note` (partial, case-insensitive).

2. Cải thiện validation & normalization (backend/services/transaction_service.js)
   - Ép kiểu `page`, `limit`, `month`, `year` về `Number` sớm.
   - Parse `date` bằng `Date.UTC` từ format `YYYY-MM-DD`, kiểm tra strict để tránh timezone bug.
   - Ép kiểu `amount` và validate là số hữu hạn >= 0.
   - Normalize `category` về `lowercase` và kiểm tra với `VALID_CATEGORIES`.

3. Auth middleware hardening (đã review trước đó)
   - Đảm bảo `process.env.JWT_SECRET` tồn tại trước khi verify.
   - Kiểm tra `payload.userId` sau khi giải mã token.

4. Cập nhật dependency (backend/package.json)
   - Thêm `escape-string-regexp` dependency để đảm bảo behaviour escape regex consistent across environments.
   - Code vẫn giữ fallback nếu package không tìm thấy (defensive).

5. File tài liệu review thay thế (đã add trước đó)
   - `TASK_51_REVIEW.md` chứa review ban đầu và checklist.

## Lý do và tác động
- Gộp các thao tác DB giúp giảm latency và giảm rủi ro khác biệt giữa các truy vấn (count, find, aggregate) do dữ liệu thay đổi giữa các lệnh.
- Normalize và validate sớm giảm lỗi runtime do dữ liệu đầu vào không hợp lệ.
- Thêm dependency chính thức giúp môi trường CI/production ổn định.

## Tests & bước kiểm tra đề nghị
- Chạy bộ test hiện tại (`npm test`) — đảm bảo unit & integration vẫn pass.
- Kiểm tra thủ công via Postman:
  - Tạo giao dịch mới (`POST /api/transactions`).
  - Lấy transactions với `?page=1&limit=10` và với `?from=...&to=...` hoặc `?month=..&year=..`.
  - Test search: `?search=lunch` — thấy kết quả từ `title` và `note`.

## Kết luận — Có thể merge vào `dev`?
- Tình trạng: Các issue chính được xử lý (escape regex, coercion, date parsing, amount guard, auth payload guard). Code đã được tối ưu cho query. Nếu CI tests pass, có thể merge vào `dev`.

---

Nếu bạn đồng ý, tôi sẽ commit & push các thay đổi này lên nhánh `feat/post-transaction` (đã thực hiện) và bạn có thể tạo PR merge sau khi CI pass.
