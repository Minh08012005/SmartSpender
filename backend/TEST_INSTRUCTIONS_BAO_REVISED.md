Hướng dẫn kiểm thử cho Bảo — CRUD Transaction + Validation + Auth (Phiên bản chuẩn)

Mục tiêu

- Kiểm chứng toàn bộ flow CRUD cho `transactions` (Create, Read, Update, Delete).
- Xác nhận validation rules và authentication/authorization hoạt động đúng.
- Cung cấp artifacts để mobile team tích hợp và debug nếu cần.

Deliverables bắt buộc

- `npm test` output (console) và folder/HTML `coverage/` nếu có.
- `collection.json` (Postman collection) và `env.json` (Postman environment) chứa `baseUrl` và biến auth như `authToken`.
- `report.html` (Newman HTML report) nếu chạy bằng Newman; nếu không, gửi screenshots nhưng ưu tiên report file.
- `failures.md` liệt kê các failing cases (mỗi case gồm: request (method+URL+headers+body), response JSON, và steps để tái tạo).
- Nếu API behavior khác docs: cung cấp PR/patch cập nhật `docs/transaction.swagger.yaml` hoặc ghi chú rõ chỗ cần chỉnh.

Chuẩn bị

1. Khởi động server (local hoặc staging). Ghi lại `baseUrl` để đưa vào `env.json`.
2. Kiểm tra `docs/transaction.swagger.yaml` để biết expected contract.
3. Chuẩn bị 1 tài khoản test (hoặc tạo bằng `POST /api/auth/register`) và lưu credentials.

Chạy unit & integration tests

```
cd backend
npm install
npm test
# Nếu cần coverage
npx jest --runInBand --coverage
```

Postman collection (bắt buộc)

- Tạo requests sau và lưu vào collection:
  - `POST /api/auth/register` (nếu cần tạo test user)
  - `POST /api/auth/login` (lấy token)
  - `POST /api/transactions` (create)
  - `GET /api/transactions` (list, filters, pagination)
  - `GET /api/transactions/:id` (get single)
  - `PUT /api/transactions/:id` (update)
  - `DELETE /api/transactions/:id` (delete)
- Thiết lập header Authorization: `Bearer {{authToken}}` trên collection hoặc dùng pre-request script để set.
- Export `collection.json` và `env.json`.

Test cases chi tiết (bắt buộc có evidence)

Phase A — Create

- POST payload hợp lệ -> mong đợi 201 (hoặc 200 theo spec) và response chứa `id` mới cùng các trường dữ liệu.
- POST thiếu trường bắt buộc -> mong đợi lỗi validation 4xx kèm thông báo.
- POST với định dạng không hợp lệ (ví dụ date, number) -> mong đợi lỗi 4xx.
- POST `amount` âm (nếu business rule không cho phép) -> mong đợi lỗi 4xx.

Phase B — Read / List

- GET danh sách cho user có dữ liệu -> response chứa các transaction đã tạo.
- GET danh sách cho user không có dữ liệu -> trả 200 và danh sách rỗng.
- GET với filter (month/year, from/to, type, category, search) -> kết quả phù hợp với filter.
- Pagination: kiểm thử `page`/`limit`; Sorting: kiểm thử `sortBy`/`order`.

Phase C — Update

- PUT cập nhật hợp lệ -> mong đợi 200 và dữ liệu được cập nhật.
- PUT cập nhật một phần (partial) nếu API hỗ trợ -> chấp nhận.
- PUT với payload không hợp lệ -> lỗi validation 4xx.
- PUT với `id` không tồn tại -> trả 404.
- PUT lên item thuộc user khác -> trả 403 hoặc 404 theo spec.

Phase D — Delete

- DELETE item tồn tại -> mong đợi 200/204 và gọi GET sau đó không thấy item.
- DELETE item không tồn tại -> 404.
- DELETE item thuộc user khác -> 403/404 theo spec.

Phase E — Auth & Ownership

- Không có token -> các endpoint yêu cầu auth trả 401.
- Token không hợp lệ / hết hạn -> 401.
- Xác nhận user A không thể truy cập/sửa/xóa transaction của user B.

Verification checklist (after each mutation)

- CREATE -> GET list and GET single to verify creation.
- UPDATE -> GET single to verify updates persisted.
- DELETE -> GET list to verify removal.

Automation & reporting (khuyến nghị)

- Dùng Newman để chạy collection và xuất report HTML:

```
npm install -g newman newman-reporter-html
newman run collection.json -e env.json -r cli,html --reporter-html-export report.html
```

Ghi chép & nộp kết quả

- `npm test` output + folder `coverage/`.
- `collection.json` và `env.json`.
- `report.html` (Newman) hoặc screenshots (ít ưu tiên).
- `failures.md` (mô tả request+response+steps cho mỗi lỗi).
- Nếu cần fix docs: PR/patch cho `docs/transaction.swagger.yaml`.

Acceptance (quick leader check)

- Happy-path CRUD cases pass (evidence via Newman or screenshots).
- Validation & auth negative cases have evidence.
- Ownership enforced.
- Any failing cases documented with reproduction steps.

Ghi chú: nếu gấp, tối thiểu gửi `collection.json` + `env.json` + screenshots cho 5 case chính: create success, create validation fail, update success, delete success, auth failure.

-- End
