# Setup dữ liệu test nhanh (10-15 phút)

## 1) Dữ liệu test được chuẩn bị ở đâu

Dữ liệu test của team nên nằm trong MongoDB dev (collection `transactions` và nếu có thì `budgets`).

Nguồn dữ liệu mẫu có sẵn trong repo:

- backend/postman/test-data.json

## 2) Cách nạp dữ liệu nhanh nhất cho người mới

### Bước 1: Chạy backend và đăng nhập lấy token

1. Chạy backend:
   - npm install
   - npm run dev
2. Dùng Postman gọi API login để lấy access token.
3. Lưu token vào biến Postman: `accessToken`.

### Bước 2: Nạp data mẫu giao dịch bằng Postman

1. Mở file backend/postman/test-data.json.
2. Bỏ qua các object chỉ chứa `_comment`.
3. Với mỗi object còn lại, gọi:
   - Method: POST
   - URL: {{baseUrl}}/api/transactions
   - Header: Authorization: Bearer {{accessToken}}
   - Body: raw JSON (object transaction)

Ghi chú:

- Schema hiện tại chấp nhận `walletType` optional (default sẽ tự gán), nên có thể dùng nguyên data mẫu.
- Category hợp lệ: food, travel, shopping, salary, entertainment, utility, other.
- Type hợp lệ: income, expense.

## 3) Dữ liệu bổ sung bắt buộc cho timeline tháng

Ngoài file test-data hiện có, thêm 3 giao dịch này để test daily/by-date trực quan:

```json
{
  "title": "Salary Bonus April",
  "amount": 10000000,
  "type": "income",
  "category": "salary",
  "date": "2026-04-17",
  "note": "bonus"
}
```

```json
{
  "title": "Lunch April 17",
  "amount": 50000,
  "type": "expense",
  "category": "food",
  "date": "2026-04-17",
  "note": "lunch"
}
```

```json
{
  "title": "Cosmetic April 18",
  "amount": 1000000,
  "type": "expense",
  "category": "shopping",
  "date": "2026-04-18",
  "note": "shopping"
}
```

Mục đích của 3 record này:

- 2026-04-17 có cả income + expense.
- 2026-04-18 chỉ có expense.
- Có thể dùng 2026-04-19 làm ngày rỗng dữ liệu để test empty.

## 4) Kiểm tra nhanh dữ liệu đã vào DB chưa

1. Gọi GET {{baseUrl}}/api/transactions?month=4&year=2026
2. Kỳ vọng thấy các record ngày 17, 18 tháng 4.
3. Nếu không thấy:
   - kiểm tra token còn hạn không,
   - kiểm tra date gửi đúng YYYY-MM-DD,
   - kiểm tra user đăng nhập có đúng user dùng để test không.

## 5) Mapping dữ liệu test cho từng người

- Nam (daily stats):
  - Dùng tháng 4/2026 để test có dữ liệu.
  - Dùng tháng 5/2026 để test rỗng dữ liệu.

- Ngọc Anh (budget):
  - Dùng tháng 4/2026 để test actualExpense > 0.
  - Dùng tháng 5/2026 để test actualExpense = 0.

- Chúc (by-date):
  - Dùng date=2026-04-17 (có cả thu/chi).
  - Dùng date=2026-04-19 (không có giao dịch).

- Xuân (QA/Postman):
  - Dùng đúng bộ dữ liệu trên để test regression cho cả 3 API.

## 6) Nếu muốn nạp nhanh bằng MongoDB Compass

1. Mở collection `transactions`.
2. Import JSON từ backend/postman/test-data.json (xóa object `_comment` trước).
3. Thêm 3 record tháng 4 ở trên.
4. Đảm bảo `userId` trỏ đúng user test đang đăng nhập.

Khuyến nghị:

- Người mới nên ưu tiên nạp qua POST API để tránh lỗi sai `userId` khi import trực tiếp DB.
