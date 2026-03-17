# REVIEW ROUND 3 - Leader Summary cho nhánh của Bảo

**Nhánh:** test/CRUD_transaction  
**Mốc commit đã rà soát:** 25af539, 80ca867, 36504e1  
**Ngày review:** 17/03/2026  
**Mục tiêu:** xác nhận mức độ hoàn tất các điểm tồn đọng CRUD trước khi cân nhắc merge vào dev.

## 1) Kết luận nhanh cho leader

1. **Hai rủi ro High của vòng trước đã được xử lý đúng hướng và có test đi kèm.**
2. **Các test trọng tâm liên quan thay đổi mới đều pass (74/74).**
3. **Trạng thái hiện tại đề xuất:** Có thể chuyển sang bước pre-merge check cuối (regression toàn bộ backend) trước khi merge.

## 2) Bảo đã xử lý được gì trong đợt này

### 2.1 FIX-A: Đồng bộ normalize filter GET tại API boundary (đã xử lý)

- **Vấn đề cũ:** GET filter có thể reject input hoa/thường (ví dụ `INCOME`, `Food,TRAVEL`) ngay ở validator.
- **Thay đổi chính:**

1. `type` được normalize lowercase ngay ở validator query.
2. `category` CSV được trim + lowercase từng phần tử và trả về chuỗi CSV đã normalize.
3. Middleware validation lưu dữ liệu đã validate vào `req.validated.query` và đồng bộ lại `req.query` để controller/service nhận đúng dữ liệu đã normalize.
4. Controller ưu tiên dùng nguồn `req.validated.query`.

- **File liên quan:**

1. backend/validators/transaction.validator.js
2. backend/middleware/validate.middleware.js
3. backend/controllers/transaction_controller.js

- **Bằng chứng test:**

1. backend/tests/unit/validators/transaction.validator.test.js
2. backend/tests/integration/transaction.routes.test.js

### 2.2 FIX-B: Chốt semantics `to=YYYY-MM-DD` lấy đến cuối ngày (đã xử lý)

- **Vấn đề cũ:** filter khoảng ngày có nguy cơ bỏ sót giao dịch trong chính ngày `to`.
- **Thay đổi chính:**

1. Service thêm parse logic cho date-only (`YYYY-MM-DD`) và nếu là trường `to` thì nâng lên `23:59:59.999` (UTC).
2. Điều kiện query date range dùng `$gte`/`$lte` với mốc cuối ngày cho `to` khi input là date-only.

- **File liên quan:**

1. backend/services/transaction.service.js

- **Bằng chứng test:**

1. backend/tests/unit/services/transaction.service.test.js (case kiểm tra `toISOString()` bằng `2026-03-31T23:59:59.999Z`)
2. backend/tests/integration/transaction.routes.test.js (giữ nguyên from/to dạng string đến service)

### 2.3 FIX-C: Đồng bộ docs contract GET với runtime (đã xử lý phần lớn)

- **Thay đổi chính:**

1. Tạo file contract tập trung `backend/swagger.yaml` và đưa vào app như nguồn docs chính.
2. Mô tả rõ behavior normalize `type/category` và semantics `to` date-only.

- **File liên quan:**

1. backend/swagger.yaml
2. backend/app.js

## 3) Bug map theo góc nhìn quản lý tiến độ

1. **RISK-01 vòng trước (GET normalize mismatch):** **ĐÃ ĐÓNG**.
2. **RISK-02 vòng trước (to-date mất dữ liệu cuối ngày):** **ĐÃ ĐÓNG**.
3. **PUT/DELETE bug ở vòng trước (BUG-1/2/3/10):** không bị hồi quy trong đợt này (không thấy dấu hiệu phá vỡ, test hiện tại vẫn pass).

## 4) Kết quả verify thực thi

Đã chạy test trọng tâm liên quan thay đổi mới:

1. `tests/integration/transaction.routes.test.js`
2. `tests/unit/services/transaction.service.test.js`
3. `tests/unit/validators/transaction.validator.test.js`

**Kết quả:** 3 test suites pass, 74 tests pass.

## 5) Điểm cần lưu ý thêm (mức độ thấp, không blocker merge)

1. Trong Swagger, tham số `from/to` đang để `format: date` nhưng phần mô tả nói hỗ trợ cả full ISO date-time.
2. Đây là lệch nhẹ ở tầng mô tả schema (đặc biệt nếu team dùng codegen client), không ảnh hưởng runtime hiện tại.
3. Nên cân nhắc đổi schema `from/to` thành dạng cho phép cả date và date-time để docs chặt chẽ hơn.

## 6) Khuyến nghị quyết định merge cho leader

1. **Có thể cho qua vòng review kỹ thuật chính** vì 2 rủi ro High đã được xử lý có bằng chứng test.
2. Trước merge vào `dev`, chạy thêm regression backend đầy đủ 1 lần trên CI/local để chốt độ ổn định tổng thể.
3. Nếu regression pass, có thể **approve merge** cho phần CRUD backend của nhánh này.
