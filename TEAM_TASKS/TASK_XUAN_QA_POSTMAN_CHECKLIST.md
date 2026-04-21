# [QA/Support] Postman + checklist tích hợp - Task cho Xuân

## 0) Setup trước khi test (bắt buộc)

### 0.1 Cài và mở Postman

1. Cài Postman bản desktop.
2. Import collection team đang dùng.
3. Import environment team đang dùng.

### 0.2 Cấu hình environment

Tạo các biến:

- baseUrl = URL backend local/dev
- accessToken = token đăng nhập hợp lệ
- month = 4
- year = 2026
- date = 2026-04-18
- targetAmount = 6000000

### 0.2.1 Nạp dữ liệu test chuẩn cho cả team

1. Làm theo file setup dữ liệu nhanh:
   - TEAM_TASKS/TEST_DATA_SETUP_QUICKSTART.md
2. Sau khi nạp xong, xác nhận lại:
   - month=4 có dữ liệu
   - date=2026-04-17 có cả income/expense
   - date=2026-04-19 rỗng dữ liệu

### 0.3 Verify nhanh trước khi test API mới

1. Gọi 1 endpoint cũ có auth để chắc token và baseUrl đúng.
2. Nếu lỗi 401/403: lấy token mới trước khi test.

## 1) Mục tiêu

Đảm bảo 3 API mới pass theo contract và có checklist regression rõ ràng cho team trước demo.

Kết quả đầu ra bắt buộc:

- Postman test cho daily stats, budget, transactions by date.
- Checklist pass/fail theo từng case.
- Báo lỗi có dữ liệu tái hiện rõ ràng.

## 2) Phối hợp

- Nhận endpoint chính thức từ Nam, Ngọc Anh, Chúc.
- Làm việc với Minh để xác nhận dữ liệu backend trả đúng thứ Mobile cần.
- Khi fail test: ghi bug ngắn gọn, có request mẫu và response lỗi.

## 3) File/tài nguyên cần cập nhật

- backend/postman/collection.json (hoặc collection team đang dùng)
- backend/postman/env.json (nếu cần biến môi trường)
- TIMELINE_CAI_TIEN_LICH_THANG.md (cập nhật trạng thái pass/fail nếu team thống nhất)
- Có thể thêm file báo cáo: backend/postman/failures.md

## 4) Scope kiểm thử

API bắt buộc test:

- GET /api/statistics/daily
- GET /api/statistics/budget
- POST/PATCH /api/statistics/budget
- GET /api/transactions/by-date

## 5) Checklist quy trình (5 pha)

### Pha 1: Phân tích

- [ ] Đọc contract mục 14 trong TIMELINE_CAI_TIEN_LICH_THANG.md.
- [ ] Tạo bảng mapping field contract -> field response thực tế.
- [ ] Chuẩn bị test data đầu vào tối thiểu.

### Pha 2: Thiết kế test

- [ ] Viết test case happy path cho từng endpoint.
- [ ] Viết test case empty data cho daily/by-date.
- [ ] Viết test case invalid input (month/year/date/targetAmount).
- [ ] Viết expected status code + expected message.

## 5.1 Hướng dẫn tạo request cụ thể trong Postman

### A. Daily stats

1. Request name: GET Daily Stats.
2. Method: GET.
3. URL: {{baseUrl}}/api/statistics/daily?month={{month}}&year={{year}}.
4. Header: Authorization: Bearer {{accessToken}}.

Test script gợi ý:

```js
pm.test("Status 200", function () {
  pm.response.to.have.status(200);
});

const body = pm.response.json();
pm.test("success true", function () {
  pm.expect(body.success).to.eql(true);
});

pm.test("days is array", function () {
  pm.expect(Array.isArray(body.data.days)).to.eql(true);
});
```

### B. Get budget

1. Request name: GET Budget.
2. URL: {{baseUrl}}/api/statistics/budget?month={{month}}&year={{year}}.
3. Header auth như trên.

### C. Save budget

1. Request name: SAVE Budget.
2. Method: POST hoặc PATCH theo backend đã chọn.
3. URL: {{baseUrl}}/api/statistics/budget.
4. Body JSON:

```json
{
	"month": {{month}},
	"year": {{year}},
	"targetAmount": {{targetAmount}}
}
```

### D. Transactions by date

1. Request name: GET Transactions By Date.
2. URL: {{baseUrl}}/api/transactions/by-date?date={{date}}.
3. Header auth như trên.

## 5.2 Checklist pass/fail chi tiết

### Daily stats

- [ ] 200 khi query hợp lệ.
- [ ] success=true.
- [ ] Có data.month, data.year, data.days.
- [ ] days item có date, totalIncome, totalExpense, net, transactionCount.

### Budget

- [ ] GET budget trả đủ field.
- [ ] SAVE budget thành công với targetAmount hợp lệ.
- [ ] SAVE budget fail khi targetAmount <= 0.

### By-date

- [ ] 200 khi date hợp lệ.
- [ ] transactions là array.
- [ ] summary.totalIncome/totalExpense/net có mặt.
- [ ] 400 khi date sai format.

## 5.3 Mẫu bảng report cuối ngày

| API                       | Case                | Expected          | Actual | Result    | Owner    |
| ------------------------- | ------------------- | ----------------- | ------ | --------- | -------- |
| /api/statistics/daily     | month hợp lệ        | 200 + data.days   | ...    | Pass/Fail | Nam      |
| /api/statistics/budget    | save targetAmount>0 | 200 + data.status | ...    | Pass/Fail | Ngọc Anh |
| /api/transactions/by-date | date sai format     | 400               | ...    | Pass/Fail | Chúc     |

### Pha 3: Thực thi test

- [ ] Chạy test daily stats.
- [ ] Chạy test budget get/save.
- [ ] Chạy test transactions by date.
- [ ] Ghi lại request + response thực tế cho case fail.

### Pha 4: Báo cáo lỗi

- [ ] Mỗi bug ghi rõ: endpoint, input, actual, expected, mức độ.
- [ ] Gửi bug ngay cho owner endpoint tương ứng.
- [ ] Theo dõi fix và retest.

### Pha 5: Chốt regression

- [ ] Retest 3 endpoint sau khi fix.
- [ ] Chạy nhanh luồng đổi tháng/bấm ngày/lưu mục tiêu với Mobile.
- [ ] Chốt bảng pass/fail cuối ngày.
- [ ] Đính kèm evidence (ảnh/chụp output Postman).

## 6) Định nghĩa hoàn thành (DoD)

Task được coi là xong khi:

- Có checklist đầy đủ cho tất cả endpoint mới.
- Không còn bug blocker ở contract field.
- Có bằng chứng test pass cho các case chính.
- Mobile xác nhận ghép API không bị lệch field.

## 7) Mẫu bug report ngắn

- Endpoint:
- Input:
- Expected:
- Actual:
- Ảnh/JSON đính kèm:
- Owner xử lý:
- Trạng thái: Open/Fixed/Retested

## 8) Quy tắc làm việc khi có bug

1. Báo bug theo contract field, không báo mơ hồ.
2. Mỗi bug cần có request và response thật.
3. Sau khi backend báo fix, bắt buộc retest cùng case cũ.
4. Chỉ đánh dấu Done khi đã retest pass.
