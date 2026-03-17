# Sprint 2 Integration Brief (Leader + Mobile Friendly)

## Bức tranh chung hiện tại

Backend đã đi được phần khó nhất để chuẩn bị tích hợp thật với mobile:

- Luồng GET transactions và GET statistics đã có contract rõ, có test contract readiness, có xác nhận auth/validation.
- Luồng PUT và DELETE đã có integration test đầy đủ cho success, validation fail, auth fail, ownership.
- Luồng CREATE đã có unit test ở validator/service, nhưng chưa có integration test POST endpoint ở mức end-to-end.

Nhìn theo quản lý tiến độ, trạng thái hiện tại là: backend CRUD gần hoàn thiện cho tích hợp, còn thiếu một mảnh tự động hóa test ở POST.

---

## Phân vai đã thể hiện đúng năng lực team

### Duy (phần nâng cao)

Duy tập trung đúng vào phần logic nâng cao và contract cho integration:

- Filter nâng cao cho GET transactions (month/year, from/to, type, category, search, pagination, sorting).
- Statistics summary và đối chiếu logic tổng hợp.
- Contract readiness để bảo đảm mobile parse ổn định theo format response đã chốt.
- Bộ Postman theo checklist để kiểm thử theo kịch bản thực tế.

Kết quả quản lý nhìn thấy: phần nền tảng tích hợp mobile của GET + statistics đã rõ ràng và có tính hệ thống.

### Bảo (phần core CRUD + hardening)

Bảo xử lý tốt phần CRUD vừa sức nhưng quan trọng cho độ ổn định:

- PUT transaction: hoàn thiện validation, auth behavior, ownership behavior, partial update, amount = 0.
- DELETE transaction: hoàn thiện behavior xóa, id validation, ownership, second delete trả 404.
- Củng cố boundary normalize cho query GET và đồng bộ từ validator -> middleware -> controller -> service.
- Chốt semantics date `to=YYYY-MM-DD` lấy đến cuối ngày để không hụt dữ liệu.

Kết quả quản lý nhìn thấy: phần CRUD cốt lõi chạy ổn định, rủi ro high ở GET đã được đóng.

---

## Ma trận test case theo góc nhìn nghiệp vụ

### Transactions - Read API (GET)

Đã có các nhóm case:

- Happy path: user mới chưa có dữ liệu, có dữ liệu đúng tháng/năm, mode from/to.
- Filter behavior: type, category, search.
- Pagination + sorting.
- Validation fail: thiếu year, month sai, dùng đồng thời month/year và from/to, thiếu toàn bộ params.
- Auth fail: missing token, invalid token, expired token.
- Contract check: response envelope, field ổn định để mobile parse.

Nguồn bằng chứng:

- [backend/tests/integration/api.contract.readiness.test.js](backend/tests/integration/api.contract.readiness.test.js)
- [backend/tests/integration/transaction.routes.test.js](backend/tests/integration/transaction.routes.test.js)
- [backend/postman/collection.json](backend/postman/collection.json)
- [backend/postman/report.html](backend/postman/report.html)

### Transactions - Update API (PUT)

Đã có các nhóm case:

- Success update.
- Partial update.
- Amount bằng 0.
- Validation fail: amount sai, payload rỗng, date sai, category sai, id sai.
- Auth fail: missing/invalid/expired token.
- Ownership fail: không phải owner trả 404.

Nguồn bằng chứng:

- [backend/tests/integration/transaction.put.test.js](backend/tests/integration/transaction.put.test.js)

### Transactions - Delete API (DELETE)

Đã có các nhóm case:

- Xóa thành công và trả document đã xóa.
- Verify dữ liệu thực sự bị xóa khỏi DB.
- Not found / not owner trả 404.
- Invalid id trả 400.
- Auth fail: missing/invalid token.
- Xóa lần 2 trả 404 (idempotency behavior).

Nguồn bằng chứng:

- [backend/tests/integration/transaction.delete.test.js](backend/tests/integration/transaction.delete.test.js)

### Transactions - Create API (POST)

Hiện trạng test:

- Đã có unit test cho logic tạo transaction ở service.
- Đã có unit test cho validate create payload.
- Chưa có integration test POST /api/transactions trong Jest để xác nhận behavior end-to-end giống cách đã làm với PUT/DELETE.

Nguồn bằng chứng:

- [backend/tests/unit/services/transaction.service.test.js](backend/tests/unit/services/transaction.service.test.js)
- [backend/tests/unit/validators/transaction.validator.test.js](backend/tests/unit/validators/transaction.validator.test.js)

### Statistics API (GET /summary)

Đã có các nhóm case:

- Tháng có dữ liệu.
- Tháng không dữ liệu (0).
- Validation fail (missing year, invalid month).
- Auth fail (missing/invalid/expired token).

Nguồn bằng chứng:

- [backend/tests/integration/api.contract.readiness.test.js](backend/tests/integration/api.contract.readiness.test.js)
- [backend/tests/integration/statistic.routes.test.js](backend/tests/integration/statistic.routes.test.js)

---

## Điều mobile team có thể tin cậy ngay

- Cấu trúc response GET transactions đã ổn định cho parse: có transactions, totalCount, page, limit, stats.
- Rule filter chính đã rõ và nhất quán.
- Auth behavior cho các case token thiếu/sai/hết hạn đã có kiểm thử.
- PUT/DELETE behavior đã rõ về status code và ownership.

---

## Khoảng trống còn lại trước khi chốt “backend fully ready”

Khoảng trống chính hiện tại:

- Thiếu integration test cho POST /api/transactions.

Việc nên giao thêm cho Bảo ngay:

- Bổ sung integration test cho Create theo cùng pattern của PUT/DELETE.
- Bao phủ các case: create thành công, amount âm, thiếu field bắt buộc, category sai, date sai format, không token, token sai/hết hạn.

---

## Kết luận quyết định merge trước mắt

Với phạm vi thay đổi mà Bảo vừa xử lý và đã review/test:

- Có thể cho phép merge vào dev ở trạng thái hiện tại, vì các bug/risk chính đã được đóng và các suite liên quan đều pass.
- Nên merge kèm ghi chú follow-up bắt buộc: bổ sung integration test cho Create ở nhánh kế tiếp hoặc PR kế tiếp trước mốc freeze demo.

Cách nói ngắn gọn khi họp team:

"Phần Bảo đã đạt mức mergeable cho sprint integration hiện tại. Điểm còn thiếu không phải bug blocker runtime, mà là khoảng trống kiểm thử tự động ở Create integration, cần chốt ngay vòng sau."
