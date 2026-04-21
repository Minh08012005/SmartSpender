[BE] Transactions by date - GET /api/transactions/by-date

**Người thực hiện:** Chúc  
**Ngày:** 20/04/2026

## Mô tả
1.Mục tiêu đã thực hiện

1.Hoàn chỉnh API giao dịch theo ngày cho mobile:
GET /api/transactions/by-date?date=YYYY-MM-DD

3.Trả đúng contract mục 14.3:
success + data.date + data.summary + data.transactions

4.Bổ sung test và swagger cho endpoint mới.

5.Các file đã sửa và nội dung sửa

  5.1.transaction.service.js

-- Thêm toDayRange để parse ngày chuẩn UTC.
-- Thêm mapTransactionByDate để map field id, title, amount, type, category, date,  note.
-- Thêm getTransactionsByDate(userId, dateStr):
    lọc theo userId + khoảng ngày UTC start/end
    sort theo date giảm dần
    tính totalIncome, totalExpense, net
    trả object đúng contract by-date.
  5.2.transaction_controller.js
--Thêm DATE_ONLY_REGEX.
--Thêm isValidDateQuery kiểm tra YYYY-MM-DD và ngày hợp lệ.
--Thêm handler getTransactionsByDate:
    invalid date trả 400
    valid date gọi service
    trả response dạng success + data.
  5.3.transaction_routes.js
--Import getTransactionsByDate.
--Đăng ký route:
    GET /by-date (có authenticate).
  5.4.swagger.yaml
--Thêm path /api/transactions/by-date.
--Thêm responses mẫu cho case có data, rỗng, invalid date.
--Thêm schema:
    TransactionByDate
    TransactionsByDatePayload
    TransactionsByDateSuccess.
  5.5.transaction.routes.test.js
--Mock thêm getTransactionsByDate.
--Thêm 3 test integration:
    date có dữ liệu
    date rỗng dữ liệu
    date sai format trả 400.
--Xác nhận by-date trả đúng shape success + data.
  5.6.transaction.service.test.js
--Thêm block test Transaction Service - getTransactionsByDate:
    query đúng day range UTC
    tính summary đúng
    map field đúng
    empty case
    invalid userId/date.
  5.7.collection.json
--Sửa script login:
    lấy token từ data.accessToken (fallback data.token)
    set authToken đúng để tránh TOKEN_INVALID.
  5.8.package.json
  5.9.package-lock.json
Cập nhật axios lên 1.15.1 để bỏ lỗi thiếu module khi chạy test.

## Test Cases (Postman)

### 1. Ngày có dữ liệu (2026-04-17)
![Có dữ liệu]


### 2. Ngày không có dữ liệu (2026-04-19)
![Không có dữ liệu]

### 3. Invalid date format
![Invalid date]

## Kết quả test
- Status code đúng (200 cho trường hợp hợp lệ, 400 cho invalid date)
- Contract khớp hoàn toàn với yêu cầu
- Summary tính đúng (`net = totalIncome - totalExpense`)
- Xử lý tốt trường hợp không có transaction

## Checklist
- [x] Endpoint hoạt động ổn định
- [x] Đúng contract (không đổi tên field)
- [x] Test đầy đủ các case
- [x] Update swagger

Mời **Minh** review & ghép Mobile, **Xuân** retest.

---