# Review Chi Tiết Task Test Filter + Statistic (Duy Backend)

Ngày review: 13/03/2026  
Nhánh được review: test/transaction  
Task liên quan: [BE] Postman/test Filter + Statistics + contract GET transaction (#59)

## 1. Mục tiêu review

Đánh giá mức độ hoàn thành task kiểm thử của Duy cho 2 endpoint:

- GET /api/transactions
- GET /api/statistics/summary

Đối chiếu theo 4 nhóm tiêu chí:

- Chất lượng thay đổi code backend
- Độ đầy đủ deliverables kiểm thử
- Kết quả test thực thi
- Rủi ro tích hợp với mobile team

## 2. Tóm tắt thay đổi trên nhánh test/transaction

### 2.1 Commit mới so với dev

1. f9f27b1 - Add integration tests for transactions and statistics APIs; include seed data for testing
2. 5ba808c - chore: remove VSCode settings file
3. 4ac84a3 - feat: enhance transaction service with create and delete functionality; update transaction filtering and stats normalization

### 2.2 Thống kê thay đổi

- 17 files changed
- 4227 insertions, 649 deletions
- Nhóm file chính:
  - Tests: integration + unit
  - Postman artifacts: collection, env, report, test-data, failures
  - Service/controller/middleware: transaction, auth
  - Docs: swagger + review note

## 3. Kiểm tra deliverables theo yêu cầu task

### 3.1 Đã có đầy đủ

- backend/postman/collection.json
- backend/postman/env.json
- backend/postman/report.html
- backend/postman/test-data.json
- backend/postman/failures.md
- backend/tests/integration/api.contract.readiness.test.js
- backend/REVIEW_api_contract_readiness.md

### 3.2 Nhận xét

- Bộ deliverables có tính thực thi, có thể handoff cho mobile team.
- failures.md có bảng tổng hợp và template tái tạo lỗi; tuy nhiên hiện chủ yếu đang ghi case PASS.

## 4. Kết quả test đã xác minh

### 4.1 Test mới theo contract

- Lệnh chạy: npm test -- tests/integration/api.contract.readiness.test.js
- Kết quả: PASS (20/20)
- Bao phủ đầy đủ các nhóm:
  - Happy path
  - Validation input month/year/from/to
  - Filter type/category/search
  - Pagination + sorting
  - Missing token / invalid token / expired token
  - Summary tháng có dữ liệu và không có dữ liệu

### 4.2 Test hiện có trong nhánh

- Lệnh chạy: npm test -- tests/integration/transaction.routes.test.js
- Kết quả: FAIL 1 case, PASS 6 cases
- Case fail duy nhất:
  - GET /api/transactions - should call service with correct parameters
  - Nguyên nhân: expectation trong test vẫn so sánh query params dạng string, trong khi controller đã normalize sang number.

### 4.3 Tổng test backend tại thời điểm review

- Kết quả: 1 test fail, 81 tests pass
- Chưa có dấu hiệu regression nghiệp vụ chính, nhưng CI sẽ chưa xanh hoàn toàn do 1 false-negative test.

## 5. Findings theo mức độ nghiêm trọng

## High

1. Một test integration đang fail do expectation cũ

- Vị trí: backend/tests/integration/transaction.routes.test.js
- Tác động:
  - Có thể chặn merge nếu yêu cầu all-green CI
  - Gây nhiễu review vì đây là lỗi kiểm thử, không phải lỗi runtime
- Đề xuất fix:
  - Đổi expected args page/limit/month/year từ string sang number trong case tương ứng.

2. Cần xác nhận lại cấu hình Swagger server base URL

- Vị trí: backend/app.js và backend/docs/transaction.swagger.yaml
- Mô tả:
  - Server URL đang theo hướng localhost:3000/api
  - Cần bảo đảm không phát sinh double prefix kiểu /api/api khi render docs hoặc test theo swagger
- Đề xuất:
  - Chốt quy ước đường dẫn server + paths trong swagger, đồng bộ 1 lần.

## Medium

1. failures.md chưa tách rõ bằng chứng PASS và FAIL

- Vị trí: backend/postman/failures.md
- Mô tả:
  - Tên file là failures nhưng nội dung hiện có nhiều case PASS
- Đề xuất:
  - Tách 2 phần rõ: Pass Evidence và Fail Evidence
  - Nếu không có fail thực tế, ghi rõ "Không phát hiện failing case"

2. Report HTML có dung lượng lớn

- Vị trí: backend/postman/report.html
- Mô tả:
  - Hữu ích cho handoff, nhưng khá nặng nếu commit trực tiếp lâu dài
- Đề xuất:
  - Cân nhắc lưu artifact qua CI thay vì lưu file report lớn trong nhánh chính

## Low

1. Cải thiện thông điệp auth theo hướng thân thiện client

- Vị trí: backend/middleware/auth.middleware.js
- Giá trị:
  - Tách rõ token hết hạn và token không hợp lệ, hỗ trợ mobile xử lý UX/refresh tốt hơn

2. Stats transactions đã được normalize tốt hơn

- Vị trí: backend/services/transaction.service.js
- Giá trị:
  - Ổn định hơn cho parse phía mobile khi stats rỗng

## 6. Đối chiếu với yêu cầu task #59

### Đạt

- Có Postman collection + environment
- Có bộ test case đúng trọng tâm filter + statistic
- Có evidence qua test mới và report
- Có tài liệu review contract readiness

### Chưa đạt 100%

- Chưa all-green test suite do 1 test expectation cũ
- Cần chốt dứt điểm cấu hình swagger base URL để tránh lệch docs/runtime

## 7. Đánh giá chất lượng tổng thể

Điểm mạnh:

- Thực hiện đúng scope, đủ artifacts, test matrix rõ ràng
- Chủ động bổ sung test contract readiness phục vụ mobile integration
- Có tư duy review implementation và phát hiện rủi ro contract/docs

Điểm cần cải thiện:

- Đồng bộ expectation của test cũ ngay khi thay đổi kiểu dữ liệu query
- Làm rõ nội dung failures.md để leader đọc nhanh không bị hiểu nhầm

## 8. Kết luận merge và đề xuất hành động

Kết luận hiện tại:

- Trạng thái: Approve có điều kiện
- Lý do:
  - Chất lượng thay đổi tốt và đúng hướng
  - Còn 1 blocking item nhỏ ở test expectation

Điều kiện để merge:

1. Fix case fail trong backend/tests/integration/transaction.routes.test.js (đổi expected string -> number)
2. Verify lại swagger server URL để tránh prefix /api bị lặp

Khi hoàn thành 2 điều kiện trên:

- Có thể merge nhanh test/transaction vào dev

## 9. Ghi chú cho leader

Nếu cần cho mobile team tích hợp ngay:

- Có thể dùng bộ artifact Postman hiện tại để tích hợp sớm
- Đồng thời yêu cầu Duy push thêm 1 commit nhỏ fix test fail + chốt swagger config trước khi merge chính thức
