# [BE] Transactions by date - Task cho Chúc

## 0) Setup trước khi code (bắt buộc)

### 0.1 Chạy backend local

1. Mở terminal tại backend.
2. Chạy:
   - npm install
   - npm run dev
3. Verify server chạy ổn.

### 0.2 Chuẩn bị dữ liệu test

1. Có ít nhất 2 ngày dữ liệu:
   - 1 ngày có giao dịch.
   - 1 ngày không có giao dịch.
2. Trong ngày có dữ liệu, nên có cả income và expense để test summary.
3. Làm theo file setup dữ liệu nhanh:

- TEAM_TASKS/TEST_DATA_SETUP_QUICKSTART.md

4. Bộ dữ liệu Chúc cần dùng:

- date=2026-04-17 (có cả income + expense)
- date=2026-04-19 (rỗng dữ liệu)

### 0.3 Chốt input/output với Mobile

1. Input: date=YYYY-MM-DD.
2. Output: summary + transactions đúng contract, không đổi tên field.

## 1) Mục tiêu

Xây dựng API lấy giao dịch theo ngày để Mobile hiển thị bottom sheet theo ngày đã chọn.

Kết quả đầu ra bắt buộc:

- Endpoint GET /api/transactions/by-date hoạt động ổn định.
- Trả summary theo ngày và danh sách transactions đúng contract.
- Xử lý đúng ngày có dữ liệu và ngày không có dữ liệu.

## 2) Phối hợp

- Phối hợp với Minh (Mobile): xác nhận field list transaction khớp model hiện tại.
- Phối hợp với Nam: thống nhất cách tính net để nhất quán với daily stats.
- Phối hợp với Xuân: cung cấp test cases edge.

## 3) File cần sửa

- backend/services/transaction.service.js
- backend/controllers/transaction_controller.js
- backend/routes/transaction_routes.js
- backend/swagger.yaml (hoặc file swagger liên quan)

## 4) Contract cần bám

Endpoint:

- Method: GET
- URL: /api/transactions/by-date
- Query: date=YYYY-MM-DD

Response shape:

- success: boolean
- data.date: string
- data.summary.totalIncome: number
- data.summary.totalExpense: number
- data.summary.net: number
- data.transactions: array
- data.transactions[].id: string
- data.transactions[].title: string
- data.transactions[].amount: number
- data.transactions[].type: string
- data.transactions[].category: string
- data.transactions[].date: string ISO
- data.transactions[].note: string

## 5) Checklist quy trình (5 pha)

### Pha 1: Phân tích

- [ ] Đọc contract ở TIMELINE_CAI_TIEN_LICH_THANG.md mục 14.3.
- [ ] Chốt timezone parse query date.
- [ ] Chốt phạm vi lọc theo userId hiện tại.

### Pha 2: Thiết kế

- [ ] Thiết kế query from-start-of-day đến end-of-day.
- [ ] Thiết kế summary calculator: totalIncome, totalExpense, net.
- [ ] Thiết kế mapper transaction response ổn định field.

### Pha 3: Coding

- [ ] Implement service getTransactionsByDate(userId, date).
- [ ] Implement controller handler by-date.
- [ ] Add route GET /api/transactions/by-date.
- [ ] Validate date đúng format YYYY-MM-DD.
- [ ] Trả mảng rỗng khi không có transaction.

## 5.1 Hướng dẫn code chi tiết theo từng file

### A. backend/services/transaction.service.js

Việc cần làm:

1. Viết hàm parse date query thành start/end của ngày.
2. Query transactions theo userId và range thời gian trong ngày.
3. Tính summary totalIncome, totalExpense, net.
4. Trả object theo contract.

Khung code gợi ý:

```js
function toDayRange(dateStr) {
  const [y, m, d] = dateStr.split("-").map(Number);
  const start = new Date(Date.UTC(y, m - 1, d, 0, 0, 0));
  const end = new Date(Date.UTC(y, m - 1, d + 1, 0, 0, 0));
  return { start, end };
}

async function getTransactionsByDate(userId, dateStr) {
  const { start, end } = toDayRange(dateStr);

  const rows = await Transaction.find({
    userId,
    date: { $gte: start, $lt: end },
  })
    .sort({ date: -1 })
    .lean();

  let totalIncome = 0;
  let totalExpense = 0;
  for (const tx of rows) {
    if (tx.type === "income") totalIncome += tx.amount;
    if (tx.type === "expense") totalExpense += tx.amount;
  }

  return {
    date: dateStr,
    summary: {
      totalIncome,
      totalExpense,
      net: totalIncome - totalExpense,
    },
    transactions: rows,
  };
}
```

### B. backend/controllers/transaction_controller.js

Việc cần làm:

1. Validate format date.
2. Lấy userId từ req.user.
3. Gọi service và trả response success.

Khung code gợi ý:

```js
function isValidDateQuery(dateStr) {
  return /^\d{4}-\d{2}-\d{2}$/.test(dateStr);
}

async function getTransactionsByDate(req, res, next) {
  try {
    const date = req.query.date;
    if (!date || !isValidDateQuery(date)) {
      return res
        .status(400)
        .json({ success: false, message: "date không hợp lệ (YYYY-MM-DD)" });
    }

    const userId = req.user.id;
    const data = await transactionService.getTransactionsByDate(userId, date);
    return res.status(200).json({ success: true, data });
  } catch (err) {
    return next(err);
  }
}
```

### C. backend/routes/transaction_routes.js

Khung code gợi ý:

```js
router.get(
  "/by-date",
  authMiddleware,
  transactionController.getTransactionsByDate,
);
```

## 5.2 Tự test trước khi push

1. /api/transactions/by-date?date=2026-04-18 (có data).
2. /api/transactions/by-date?date=2026-04-19 (rỗng data).
3. /api/transactions/by-date?date=2026/04/18 (invalid format, phải 400).

## 5.3 Lỗi thường gặp và cách tránh

1. Sai format date parser:
   - Chỉ nhận YYYY-MM-DD.
2. Trả về transaction field không khớp model Mobile:
   - Đối chiếu lại id/title/amount/type/category/date/note.
3. Net tính sai dấu:
   - net = totalIncome - totalExpense.

### Pha 4: Testing

- [ ] Test date có dữ liệu income + expense.
- [ ] Test date chỉ có expense.
- [ ] Test date rỗng dữ liệu.
- [ ] Test date invalid format.
- [ ] Test timezone boundary (23:xx/00:xx) nếu có.

### Pha 5: Deploy/PR

- [ ] Update swagger với ví dụ response đầy đủ.
- [ ] Tạo PR kèm ảnh/chứng cứ test.
- [ ] Gắn reviewer: Minh + Xuân.
- [ ] Đính kèm cURL hoặc Postman export.

## 6) Định nghĩa hoàn thành (DoD)

Task được coi là xong khi:

- Endpoint by-date pass đúng contract.
- Summary đúng với data trả về.
- Không phá API /api/transactions hiện có.
- Mobile gọi theo ngày và hiển thị ngay được.

## 7) Bàn giao cho Mobile

Bàn giao tối thiểu:

- Query mẫu date.
- Response mẫu có data.
- Response mẫu không có data.
- Danh sách error code cho invalid date.

## 8) Tin nhắn bàn giao mẫu

"Chúc đã xong API transactions by date: GET /api/transactions/by-date?date=YYYY-MM-DD. Đã test case có dữ liệu, rỗng dữ liệu, invalid date. Contract giữ nguyên mục 14.3. Mời Minh ghép mobile và Xuân retest."
