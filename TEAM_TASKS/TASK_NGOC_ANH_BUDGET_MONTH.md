# [BE] Budget mục tiêu tháng - Task cho Ngọc Anh

## 0) Setup trước khi code (bắt buộc)

### 0.1 Chạy backend local

1. Mở terminal tại backend.
2. Chạy:

- npm install
- npm run dev

3. Xác nhận server chạy ổn.

### 0.2 Chuẩn bị dữ liệu test

1. Có ít nhất 1 user test.
2. Có transactions trong tháng test để actualExpense có giá trị.
3. Có tháng rỗng dữ liệu để test budget khi actualExpense = 0.
4. Làm theo file setup dữ liệu nhanh:

- TEAM_TASKS/TEST_DATA_SETUP_QUICKSTART.md

5. Bộ dữ liệu Ngọc Anh cần dùng:

- month=4, year=2026 (actualExpense > 0)
- month=5, year=2026 (actualExpense = 0)

### 0.3 Đồng bộ rule với Mobile trước khi code

1. Chốt status enum: safe, near, over.
2. Chốt trường hợp chưa có budget:

- targetAmount mặc định bao nhiêu hoặc null.

3. Chốt format response không đổi field.

## 1) Mục tiêu

Xây dựng API budget tháng để Mobile hiển thị và lưu mục tiêu chi tiêu tháng.

Kết quả đầu ra bắt buộc:

- GET /api/statistics/budget trả được budget summary theo tháng.
- POST hoặc PATCH /api/statistics/budget lưu được targetAmount.
- Trả đầy đủ targetAmount, actualExpense, remaining, status.

## 2) Phối hợp

- Phối hợp với Minh (Mobile): chốt enum status (safe/near/over).
- Phối hợp với Nam: thống nhất logic actualExpense lấy theo tháng.
- Phối hợp với Xuân: gửi request mẫu để test full case.

## 3) File cần sửa

- backend/services/statistic.service.js (hoặc service mới nếu team tách)
- backend/controllers/statistic.controller.js
- backend/routes/statistic_routes.js
- backend/models/... (nếu cần model budget riêng)
- backend/swagger.yaml (hoặc file swagger liên quan)

## 4) Contract cần bám

### 4.1 GET budget

- Method: GET
- URL: /api/statistics/budget
- Query: month, year

Response shape:

- success: boolean
- data.month: number
- data.year: number
- data.targetAmount: number
- data.actualExpense: number
- data.remaining: number
- data.status: string (safe | near | over)

### 4.2 Save budget

- Method: POST hoặc PATCH
- URL: /api/statistics/budget
- Body: month, year, targetAmount

Response tối thiểu:

- success: boolean
- data.month, data.year, data.targetAmount, data.actualExpense, data.remaining, data.status

## 5) Checklist quy trình (5 pha)

### Pha 1: Phân tích

- [ ] Đọc contract ở TIMELINE_CAI_TIEN_LICH_THANG.md mục 14.2.
- [ ] Chốt cách lưu budget (collection riêng hoặc chung).
- [ ] Chốt rule status:
  - safe: actualExpense / targetAmount < 0.8
  - near: 0.8 <= ratio <= 1.0
  - over: actualExpense > targetAmount

### Pha 2: Thiết kế

- [ ] Thiết kế schema budget tháng (nếu lưu riêng): userId, month, year, targetAmount.
- [ ] Thiết kế unique key cho 1 user + 1 month + 1 year.
- [ ] Thiết kế upsert cho save budget.

### Pha 3: Coding

- [ ] Implement getBudgetSummary(month, year, userId).
- [ ] Implement saveBudgetTarget(month, year, targetAmount, userId).
- [ ] Validate targetAmount > 0.
- [ ] Validate month/year hợp lệ.
- [ ] Trả đúng shape response contract.

## 5.1 Hướng dẫn code chi tiết theo từng file

### A. backend/services/statistic.service.js

Việc cần làm:

1. Tạo function getBudgetSummary(userId, month, year).
2. Tạo function saveBudgetTarget(userId, month, year, targetAmount).
3. Tính actualExpense từ transactions theo tháng.
4. Tính remaining và status.

Khung code gợi ý:

```js
function computeBudgetStatus(targetAmount, actualExpense) {
  if (targetAmount <= 0) return "safe";
  if (actualExpense > targetAmount) return "over";
  const ratio = actualExpense / targetAmount;
  if (ratio >= 0.8) return "near";
  return "safe";
}

async function getBudgetSummary(userId, month, year) {
  const budget = await Budget.findOne({ userId, month, year }).lean();
  const targetAmount = budget?.targetAmount ?? 0;

  const actualExpense = await statisticRepo.getMonthlyExpense(
    userId,
    month,
    year,
  );
  const remaining = targetAmount - actualExpense;
  const status = computeBudgetStatus(targetAmount, actualExpense);

  return { month, year, targetAmount, actualExpense, remaining, status };
}

async function saveBudgetTarget(userId, month, year, targetAmount) {
  await Budget.findOneAndUpdate(
    { userId, month, year },
    { $set: { targetAmount } },
    { upsert: true, new: true },
  );

  return getBudgetSummary(userId, month, year);
}
```

### B. backend/controllers/statistic.controller.js

Việc cần làm:

1. Thêm handler GET budget.
2. Thêm handler save budget (POST/PATCH).
3. Validate month/year/targetAmount.

Khung code gợi ý:

```js
async function getBudget(req, res, next) {
  try {
    const month = Number(req.query.month);
    const year = Number(req.query.year);
    const userId = req.user.id;

    if (!month || !year || month < 1 || month > 12) {
      return res
        .status(400)
        .json({ success: false, message: "month/year không hợp lệ" });
    }

    const data = await statisticService.getBudgetSummary(userId, month, year);
    return res.status(200).json({ success: true, data });
  } catch (err) {
    return next(err);
  }
}

async function saveBudget(req, res, next) {
  try {
    const { month, year, targetAmount } = req.body;
    const m = Number(month);
    const y = Number(year);
    const t = Number(targetAmount);
    const userId = req.user.id;

    if (!m || !y || m < 1 || m > 12 || !t || t <= 0) {
      return res
        .status(400)
        .json({ success: false, message: "Dữ liệu không hợp lệ" });
    }

    const data = await statisticService.saveBudgetTarget(userId, m, y, t);
    return res.status(200).json({ success: true, data });
  } catch (err) {
    return next(err);
  }
}
```

### C. backend/routes/statistic_routes.js

Khung code gợi ý:

```js
router.get("/budget", authMiddleware, statisticController.getBudget);
router.post("/budget", authMiddleware, statisticController.saveBudget);
// hoặc router.patch('/budget', ...)
```

## 5.2 Tự test trước khi push

1. GET budget khi chưa thiết lập.
2. POST/PATCH budget với targetAmount hợp lệ.
3. GET budget sau khi lưu.
4. POST/PATCH với targetAmount <= 0 phải 400.

## 5.3 Lỗi thường gặp và cách tránh

1. Không chặn targetAmount <= 0:
   - Validate ngay ở controller.
2. Tính status sai ngưỡng near:
   - Giữ đúng rule ratio >= 0.8.
3. Lưu trùng nhiều budget cùng tháng:
   - Dùng unique key userId+month+year hoặc findOneAndUpdate upsert.

### Pha 4: Testing

- [ ] Test GET khi chưa có budget (quy ước targetAmount mặc định hoặc null theo chốt team).
- [ ] Test GET khi đã có budget.
- [ ] Test save budget mới.
- [ ] Test update budget hiện có.
- [ ] Test invalid targetAmount (<= 0).

### Pha 5: Deploy/PR

- [ ] Update swagger và ví dụ request/response.
- [ ] Tạo PR rõ impact lên Mobile.
- [ ] Gắn reviewer: Minh + Xuân.
- [ ] Đính kèm bằng chứng Postman.

## 6) Định nghĩa hoàn thành (DoD)

Task được coi là xong khi:

- GET/POST(PATCH) budget pass theo contract.
- status tính đúng theo rule đã chốt.
- Không gây ảnh hưởng endpoint statistics summary hiện có.
- Mobile có thể gọi thật để thay local state.

## 7) Bàn giao cho Mobile

Bàn giao tối thiểu:

- Rule rõ cho trường hợp chưa có budget.
- Request mẫu save budget.
- Response mẫu get/save budget.
- Mã lỗi validation và message tương ứng.

## 8) Tin nhắn bàn giao mẫu

"Ngọc Anh đã xong budget API. Có GET /api/statistics/budget và POST/PATCH /api/statistics/budget. Trả đầy đủ targetAmount, actualExpense, remaining, status đúng contract. Nhờ Minh ghép mobile và Xuân retest checklist budget."
