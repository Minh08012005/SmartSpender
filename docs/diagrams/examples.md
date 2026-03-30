## Ví dụ request / response

### 1) Tạo giao dịch (Create Transaction)

Request:

POST /api/transactions
Headers:

- Authorization: Bearer <JWT>
- Content-Type: application/json

Body:

{
"title": "Ăn trưa",
"amount": 120000,
"category": "food",
"type": "expense",
"date": "2026-03-29T12:30:00Z",
"walletType": "cash",
"note": "Cơm văn phòng"
}

Response (201 Created):

{
"success": true,
"statusCode": 201,
"message": "Transaction created successfully",
"data": {
"\_id": "65c88df8b2f8a1c21c23abcd",
"userId": "...",
"title": "Ăn trưa",
"amount": 120000,
"type": "expense",
"category": "food",
"walletType": "cash",
"date": "2026-03-29T12:30:00.000Z",
"note": "Cơm văn phòng",
"createdAt": "2026-03-29T12:30:01.000Z"
}
}

### 2) Lấy summary thống kê theo tháng

Request:

GET /api/statistics/summary?month=3&year=2026
Headers:

- Authorization: Bearer <JWT>

Response (200):

{
"success": true,
"statusCode": 200,
"message": "Get monthly statistics successfully",
"data": {
"totalIncome": 5000000,
"totalExpense": 3200000,
"balance": 1800000
}
}

---

Ghi chú:

- Khi client dùng kiểu filter `from` / `to` nếu gửi `YYYY-MM-DD` cho `to`, server sẽ nâng `to` về cuối ngày (23:59:59.999) để không bỏ sót giao dịch trong ngày đó.
- Khi nhận `401` kèm `errorCode: TOKEN_EXPIRED`, mobile nên điều hướng người dùng sang màn hình đăng nhập.
