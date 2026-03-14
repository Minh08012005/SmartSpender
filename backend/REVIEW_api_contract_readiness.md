# Báo cáo cho issue [#59](https://github.com/Minh08012005/SmartSpender/issues/59)

**Người viết:** @Dyu20705

## Phạm vi

- Endpoint 1: `GET /api/transactions`
- Endpoint 2: `GET /api/statistics/summary`
- Trọng tâm contract:

```json
{
  "success": true,
  "statusCode": 200,
  "message": "string",
  "data": {
    "transactions": [],
    "stats": {
      "totalIncome": 0,
      "totalExpense": 0,
      "balance": 0
    }
  }
}
```

- Các business rule đã kiểm tra:
  - Bắt buộc truyền một trong hai cặp: `(month + year)` HOẶC `(from + to)`
  - `month` phải nằm trong `1..12`
  - `year` phải hợp lệ
  - Phân trang và sắp xếp phải hoạt động
  - Bắt buộc xác thực token

---

## PHASE 1 — Phân tích (Review implementation)

### Hành vi route và validation đã xác định

- `GET /api/transactions` dùng `authenticate` + `validate(getTransactionsSchema, 'query')`.
- `GET /api/statistics/summary` dùng `authenticate` + `validate(getSummarySchema, 'query')`.
- Schema query của transactions đang enforce:
  - `.xor('from', 'month')`
  - `.with('from', 'to')`
  - `.with('month', 'year')`
- Schema summary đang enforce bắt buộc `month`, `year`.

### Hành vi response envelope đã xác định

- Cả hai controller đều trả envelope chuẩn hóa qua `successResponse(statusCode, message, data)`.
- `GET /api/transactions` trả kết quả service trực tiếp vào `data`.
- `GET /api/statistics/summary` trả `data = { totalIncome, totalExpense, balance }`.

### Rủi ro sớm phát hiện trong quá trình review code

1. Service `GET /api/transactions` trả `stats` có `totalAmount`, `totalIncome`, `totalExpense` nhưng **không đảm bảo luôn có `balance`**.
2. Khi có giao dịch, kết quả aggregation có thể chứa `_id: null` bên trong `data.stats`.
3. `error message` cho token không hợp lệ và token hết hạn đang gộp chung: `Invalid or expired token`.
4. `transaction.swagger.yaml` chưa khớp với envelope hiện tại ở một số endpoint.

---

## PHASE 2 — Thiết kế (Ma trận test case)

| ID | Endpoint | Kịch bản | Lý do quan trọng | Kỳ vọng |
| TX-01 | `/api/transactions` | User mới, chưa có giao dịch | Mobile phải render trạng thái rỗng an toàn | `200`, `data.transactions=[]`, envelope ổn định |
| TX-02 | `/api/transactions` | `month/year` hợp lệ | Luồng happy path cốt lõi | `200`, dữ liệu đã lọc |
| TX-03 | `/api/transactions` | Thiếu `year` khi có `month` | Enforce business rule | `400 Validation failed` |
| TX-04 | `/api/transactions` | `month=13` không hợp lệ | Chặn input lọc sai định dạng | `400 Validation failed` |
| TX-05 | `/api/transactions` | Truyền đồng thời `month/year` và `from/to` | Ngăn mode lọc mơ hồ | `400 Validation failed` |
| TX-06 | `/api/transactions` | `type=expense` | Đảm bảo filter được chuyển đúng | `200`, service được gọi với `type` |
| TX-07 | `/api/transactions` | `category=food` | Filter category cần cho UI mobile | `200`, service được gọi với `category` |
| TX-08 | `/api/transactions` | `search=salary` | Tìm kiếm là tính năng client cần | `200`, service được gọi với `search` |
| TX-09 | `/api/transactions` | `page/limit` | Đảm bảo ổn định danh sách phân trang | `200`, params phân trang được propagate |
| TX-10 | `/api/transactions` | `sortBy/order` | Tương thích sắp xếp phía client | `200`, params sort được propagate |
| TX-11 | `/api/transactions` | Thiếu token | Kiểm soát truy cập | `401 Access token required` |
| TX-12 | `/api/transactions` | Token không hợp lệ | Hành vi bảo mật | `401 Invalid or expired token` |
| TX-13 | `/api/transactions` | Token hết hạn | Xử lý phiên hết hạn | `401 Invalid or expired token` |
| ST-01 | `/api/statistics/summary` | Tháng có dữ liệu | Luồng KPI chính của dashboard | `200`, tổng thu + chi + số dư |
| ST-02 | `/api/statistics/summary` | Tháng không có dữ liệu | Trạng thái KPI rỗng | `200`, các giá trị bằng 0 |
| ST-03 | `/api/statistics/summary` | Thiếu token | Kiểm soát truy cập | `401 Access token required` |
| ST-04 | `/api/statistics/summary` | Token không hợp lệ | Hành vi bảo mật | `401 Invalid or expired token` |
| ST-05 | `/api/statistics/summary` | Token hết hạn | Xử lý phiên hết hạn | `401 Invalid or expired token` |
| ST-06 | `/api/statistics/summary` | `month=13` không hợp lệ | Tăng độ chắc chắn của validation | `400 Validation failed` |
| ST-07 | `/api/statistics/summary` | Thiếu `year` | Validation tham số bắt buộc | `400 Validation failed` |

### Example API call (Postman/curl)

```bash
# Transactions - month/year hợp lệ
curl -X GET "http://localhost:3000/api/transactions?month=3&year=2026&page=1&limit=20&sortBy=date&order=desc" \
  -H "Authorization: Bearer <TOKEN>"

# Transactions - month không hợp lệ
curl -X GET "http://localhost:3000/api/transactions?month=13&year=2026" \
  -H "Authorization: Bearer <TOKEN>"

# Transactions - truyền đồng thời 2 mode filter (kỳ vọng 400)
curl -X GET "http://localhost:3000/api/transactions?month=3&year=2026&from=2026-03-01&to=2026-03-31" \
  -H "Authorization: Bearer <TOKEN>"

# Statistics - tháng có dữ liệu
curl -X GET "http://localhost:3000/api/statistics/summary?month=3&year=2026" \
  -H "Authorization: Bearer <TOKEN>"

# Statistics - thiếu token (kỳ vọng 401)
curl -X GET "http://localhost:3000/api/statistics/summary?month=3&year=2026"
```

---

## PHASE 3 — Testing

### Tạo bộ test tự động cho các kịch bản

- File: `backend/tests/integration/api.contract.readiness.test.js`
- Kết quả: **20 passed / 0 failed**
- Lệnh đã dùng:

```bash
npm test -- tests/integration/api.contract.readiness.test.js
```

### Đã chạy thêm các bộ integration test hiện có

```bash
npm test -- tests/integration/transaction.routes.test.js tests/integration/statistic.routes.test.js
```

- Kết quả: **10 passed / 0 failed**

---

## PHASE 4 — Verification

### Đối chiếu contract với implementation

#### 1) Độ ổn định cấu trúc response

- Envelope top-level hiện tại ổn định: `success`, `statusCode`, `message`, `data`.
- `GET /api/statistics/summary` khớp shape stats kỳ vọng.

#### 2) Lệch contract ở phần stats của transactions

- Contract yêu cầu:
  - `data.stats.totalIncome`
  - `data.stats.totalExpense`
  - `data.stats.balance`
- Service transactions hiện có thể trả:
  - `totalAmount`
  - `totalIncome`
  - `totalExpense`
  - `_id` (tùy trường hợp)
  - **thiếu `balance` trong đường trả về thực tế của aggregation**

#### 3) Lệch Swagger

- `backend/docs/transaction.swagger.yaml` chưa đồng bộ với envelope chuẩn hiện tại ở endpoint list và một số payload.
- Rủi ro: team mobile và QA có thể test theo tài liệu cũ.

#### 4) Tính đúng đắn status code

- Lỗi validation: `400`
- Thiếu/token sai/token hết hạn: `401`
- Trường hợp thành công: `200`

#### 5) Khả năng parse cho mobile client

- Ở cấp envelope, response dễ parse.
- Có nguy cơ lỗi nếu mobile kỳ vọng luôn có `data.stats.balance` từ `/api/transactions` nhưng backend không trả.

---

## PHASE 5 — Bàn giao (Pass/Fail + Rủi ro)

## Tổng kết Pass / Fail

- ✅ PASS: Yêu cầu auth được enforce ở cả hai endpoint.
- ✅ PASS: Validation cho `month/year`, `month` không hợp lệ, và thiếu `year`.
- ✅ PASS: Tham số phân trang/sắp xếp/filter được chấp nhận và forward.
- ✅ PASS: Summary statistics trả đúng shape khi có dữ liệu và không có dữ liệu.
- ⚠️ PARTIAL: Contract list transactions cho `data.stats.balance` chưa được đảm bảo bởi service hiện tại.
- ⚠️ FAIL (chất lượng tài liệu): Swagger contract chưa đồng bộ với implementation.

## Các vấn đề backend tiềm ẩn

1. `GET /api/transactions` nên normalize stats để luôn có `balance`.
2. Loại bỏ `_id` nội bộ của aggregation khỏi `data.stats` trước khi response.
3. Đồng bộ tài liệu (`transaction.swagger.yaml`) với envelope và field thực tế.
4. Cân nhắc tách riêng message token hết hạn để UX client tốt hơn.

## Rủi ro tích hợp mobile

1. App có thể lỗi/crash UI nếu client giả định `data.stats.balance` luôn tồn tại.
2. API client được generate từ Swagger cũ có thể sinh model sai.
3. Ngữ nghĩa lỗi chưa nhất quán có thể làm logic refresh token phức tạp hơn.

---
