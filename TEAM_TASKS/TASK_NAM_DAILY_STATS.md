# [BE] Daily Stats theo ngày trong tháng - Task cho Nam

## 0) Setup trước khi code (bắt buộc)

### 0.1 Cài đặt và chạy backend local

1. Mở terminal ở thư mục backend.
2. Chạy lệnh:
   - npm install
   - npm run dev
3. Xác nhận server chạy không lỗi ở terminal.

### 0.2 Chuẩn bị env và DB

1. Đảm bảo file .env có đủ:
   - MONGODB_URI
   - JWT_SECRET
   - PORT
2. Đảm bảo DB có dữ liệu transactions để test tháng có dữ liệu và tháng rỗng dữ liệu.
3. Làm theo file setup dữ liệu nhanh:

- TEAM_TASKS/TEST_DATA_SETUP_QUICKSTART.md

1. Bộ dữ liệu Nam cần dùng:

- month=4, year=2026 (có dữ liệu)
- month=5, year=2026 (rỗng dữ liệu)

### 0.3 Verify nhanh trước khi bắt đầu task

1. Gọi thử endpoint cũ để chắc backend đang ổn:
   - GET /api/statistics/summary?month=4&year=2026
2. Nếu endpoint cũ đang lỗi, sửa lỗi môi trường trước khi làm task mới.

## 1) Mục tiêu

Xây dựng API thống kê theo ngày trong tháng để Mobile render lịch tháng trực quan, đúng contract đã chốt.

Kết quả đầu ra bắt buộc:

- Endpoint GET /api/statistics/daily hoạt động ổn định.
- Trả đúng format data.days như contract.
- Chạy đúng cả tháng có dữ liệu và tháng không có dữ liệu.

## 2) Phối hợp

- Phối hợp với Minh (Mobile): xác nhận field final trước khi merge.
- Phối hợp với Xuân (QA): cung cấp ví dụ request/response để Xuân test Postman.
- Nếu cần đổi field: báo trong nhóm trước, không tự đổi.

## 3) File cần sửa

- backend/services/statistic.service.js
- backend/controllers/statistic.controller.js
- backend/routes/statistic_routes.js
- backend/swagger.yaml (hoặc file swagger liên quan, nếu team đang dùng)

## 4) Contract cần bám

Endpoint:

- Method: GET
- URL: /api/statistics/daily
- Query: month, year

Response shape:

- success: boolean
- data.month: number
- data.year: number
- data.days: array
- data.days[].date: string (YYYY-MM-DD)
- data.days[].totalIncome: number
- data.days[].totalExpense: number
- data.days[].net: number
- data.days[].transactionCount: number

## 5) Checklist quy trình (5 pha)

### Pha 1: Phân tích

- [ ] Đọc contract ở TIMELINE_CAI_TIEN_LICH_THANG.md mục 14.1.
- [ ] Xác nhận nguồn dữ liệu lấy từ collection transaction hiện tại.
- [ ] Chốt timezone dùng để group theo ngày (khuyến nghị UTC+7 hoặc thống nhất theo server timezone).

### Pha 2: Thiết kế

- [ ] Thiết kế hàm aggregate theo ngày trong service.
- [ ] Thiết kế mapping type income/expense để cộng đúng totalIncome/totalExpense.
- [ ] Thiết kế response adapter trả đúng field contract (không dư/không thiếu).

### Pha 3: Coding

- [ ] Thêm function service: getDailyStatsByMonth(userId, month, year).
- [ ] Thêm controller handler cho route daily stats.
- [ ] Đăng ký route GET /api/statistics/daily.
- [ ] Validate query month/year (tháng 1-12, year hợp lệ).
- [ ] Trường hợp tháng không có dữ liệu vẫn trả success=true, days=[].

## 5.1 Hướng dẫn code chi tiết theo từng file

### A. backend/services/statistic.service.js

Việc cần làm:

1. Tạo function mới: getDailyStatsByMonth(userId, month, year).
2. Tính startDate và endDate của tháng.
3. Aggregate theo từng ngày.
4. Trả về mảng days đúng format contract.

Khung code gợi ý:

```js
async function getDailyStatsByMonth(userId, month, year) {
  const startDate = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0));
  const endDate = new Date(Date.UTC(year, month, 1, 0, 0, 0));

  const rows = await Transaction.aggregate([
    {
      $match: {
        userId: new mongoose.Types.ObjectId(userId),
        date: { $gte: startDate, $lt: endDate },
      },
    },
    {
      $group: {
        _id: {
          y: { $year: "$date" },
          m: { $month: "$date" },
          d: { $dayOfMonth: "$date" },
        },
        totalIncome: {
          $sum: { $cond: [{ $eq: ["$type", "income"] }, "$amount", 0] },
        },
        totalExpense: {
          $sum: { $cond: [{ $eq: ["$type", "expense"] }, "$amount", 0] },
        },
        transactionCount: { $sum: 1 },
      },
    },
    { $sort: { "_id.y": 1, "_id.m": 1, "_id.d": 1 } },
  ]);

  const days = rows.map((r) => {
    const date = `${r._id.y}-${String(r._id.m).padStart(2, "0")}-${String(
      r._id.d,
    ).padStart(2, "0")}`;
    const net = r.totalIncome - r.totalExpense;
    return {
      date,
      totalIncome: r.totalIncome,
      totalExpense: r.totalExpense,
      net,
      transactionCount: r.transactionCount,
    };
  });

  return { month, year, days };
}
```

### B. backend/controllers/statistic.controller.js

Việc cần làm:

1. Parse month/year từ query.
2. Validate month/year.
3. Lấy userId từ req.user.
4. Gọi service và trả success response.

Khung code gợi ý:

```js
async function getDailyStats(req, res, next) {
  try {
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    if (!month || !year || month < 1 || month > 12) {
      return res.status(400).json({
        success: false,
        message: "month/year không hợp lệ",
      });
    }

    const userId = req.user.id;
    const data = await statisticService.getDailyStatsByMonth(
      userId,
      month,
      year,
    );

    return res.status(200).json({ success: true, data });
  } catch (err) {
    return next(err);
  }
}
```

### C. backend/routes/statistic_routes.js

Việc cần làm:

1. Add route GET /daily.
2. Route phải đi qua middleware auth như các route statistics khác.

Khung code gợi ý:

```js
router.get("/daily", authMiddleware, statisticController.getDailyStats);
```

## 5.2 Tự test trước khi push

1. Case 1: tháng có dữ liệu
   - GET /api/statistics/daily?month=4&year=2026
   - Kỳ vọng: success=true, days có item.
2. Case 2: tháng rỗng
   - Kỳ vọng: success=true, days=[].
3. Case 3: query lỗi
   - GET thiếu month hoặc year
   - Kỳ vọng: 400.

## 5.3 Lỗi thường gặp và cách tránh

1. Group ngày sai do timezone:
   - Chốt 1 timezone thống nhất, không trộn local/UTC.
2. Trả thiếu field net:
   - Luôn map net = totalIncome - totalExpense ở response.
3. month/year parse sai kiểu string:
   - Luôn Number() và validate range.

### Pha 4: Testing

- [ ] Test case tháng có dữ liệu (đủ income + expense).
- [ ] Test case tháng rỗng dữ liệu.
- [ ] Test case query thiếu month hoặc year.
- [ ] Test case month/year invalid.
- [ ] Gửi sample JSON pass cho Xuân để import Postman test.

### Pha 5: Deploy/PR

- [ ] Cập nhật swagger/comment cho endpoint.
- [ ] Tạo PR với mô tả rõ contract.
- [ ] Gắn reviewer: Minh + Xuân.
- [ ] Đính kèm ảnh/chứng cứ test trong PR.

## 6) Định nghĩa hoàn thành (DoD)

Task được coi là xong khi:

- Endpoint chạy pass theo contract 14.1.
- Không đổi tên field so với contract.
- Postman pass các case chính.
- Được reviewer xác nhận có thể ghép Mobile ngay.

## 7) Bàn giao cho Mobile

Bàn giao tối thiểu:

- URL endpoint chính thức.
- Query mẫu.
- 2 response mẫu: có data và rỗng data.
- Danh sách lỗi có thể trả về (message, status code).

## 8) Tin nhắn bàn giao mẫu (copy gửi nhóm)

"Nam đã xong API daily stats. Endpoint: GET /api/statistics/daily?month=&year=. Contract giữ nguyên mục 14.1. Đã test case có dữ liệu, rỗng dữ liệu, query invalid. Nhờ Minh ghép mobile và Xuân retest Postman."
