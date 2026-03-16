# Review follow-up cho thay đổi gần đây của Bảo

**Nhánh:** `test/CRUD_transaction`  
**Ngày review:** 16/03/2026  
**Mục tiêu:** Đánh giá các commit mới sau lần feedback trước để chốt mức sẵn sàng merge vào `dev` cho task test CRUD backend, ưu tiên tính ổn định khi mobile tích hợp với backend.

## Phạm vi đã kiểm tra

- `3d49228 feat(validator): normalize and harden update transaction schema`
- `daf0a80 fix(service): normalize filters and harden date/query validation`
- `7e7ec01 feat(error): support optional errorCode in AppError responses`
- `244524d test(service): cover filter normalization and date guard cases`
- `6fe6760 test(integration): align transaction auth contract and delete flow`
- `e811a9f docs(api): align PUT/DELETE swagger contract examples`

## Kết quả tổng quan

Các thay đổi mới đi đúng hướng ở PUT/DELETE:

- Contract 401 với `TOKEN_MISSING`, `TOKEN_INVALID`, `TOKEN_EXPIRED` đã rõ hơn và bám sát integration test.
- Update/Delete đã có guard tốt hơn cho ObjectId và payload rỗng.
- `AppError` đã hỗ trợ `errorCode`, hữu ích cho mobile xử lý lỗi theo mã máy đọc được.
- Test cho PUT/DELETE và service layer hiện đang pass ở phạm vi tôi chạy.

Tuy nhiên, hiện tại tôi **chưa đánh giá nhánh này là đủ an toàn để merge vào `dev`** vì vẫn còn 2 vấn đề ảnh hưởng trực tiếp tới luồng tích hợp GET `/api/transactions`.

## Findings

### 1. High: Normalize filter mới chỉ đúng ở service, nhưng API GET vẫn chặn từ validator

Ở service, `type` và `category` đã được normalize về lowercase trước khi build query tại [backend/services/transaction.service.js#L153](backend/services/transaction.service.js#L153) và [backend/services/transaction.service.js#L167-L170](backend/services/transaction.service.js#L167-L170). Nhưng route GET vẫn đi qua `validate(getTransactionsSchema, 'query')` trước khi vào service tại [backend/routes/transaction_routes.js#L225-L228](backend/routes/transaction_routes.js#L225-L228), trong khi query schema vẫn yêu cầu giá trị lowercase cứng ở [backend/validators/transaction.validator.js#L29](backend/validators/transaction.validator.js#L29) và category custom validator ở [backend/validators/transaction.validator.js#L30-L38](backend/validators/transaction.validator.js#L30-L38) chưa normalize về lowercase.

Hệ quả là request như `type=INCOME` hoặc `category=Food, TRAVEL` vẫn bị reject `400 Validation failed` ngay ở validator, nên phần fix “normalize filters” trong service chưa thực sự có hiệu lực ở API boundary. Đây là điểm dễ vỡ khi mobile/client tái sử dụng data nhập từ form POST/PUT hoặc gửi query không đồng nhất hoa thường.

Tôi đã kiểm chứng nhanh bằng cách validate trực tiếp schema hiện tại:

```text
TYPE "type" must be one of [income, expense]
CATEGORY category not allowed
```

Đề xuất:

- Thêm `.trim().lowercase()` cho `type` trong `getTransactionsSchema`.
- Với `category`, tách CSV, `trim().toLowerCase()` từng phần tử ngay trong validator để thống nhất với service.
- Bổ sung integration test cho GET `/api/transactions` với `type=INCOME` và `category=Food,TRAVEL` để bắt regression ở tầng route thay vì chỉ test service.

### 2. High: `to=YYYY-MM-DD` đang loại mất gần như toàn bộ giao dịch của ngày cuối cùng

Swagger hiện mô tả rõ `from` và `to` đều chấp nhận cả `YYYY-MM-DD` lẫn ISO datetime tại [backend/routes/transaction_routes.js#L55](backend/routes/transaction_routes.js#L55) và [backend/routes/transaction_routes.js#L61](backend/routes/transaction_routes.js#L61). Nhưng ở service, `to` đang được parse bằng `new Date(value)` tại [backend/services/transaction.service.js#L97-L103](backend/services/transaction.service.js#L97-L103) rồi gán trực tiếp vào `$lte` tại [backend/services/transaction.service.js#L122](backend/services/transaction.service.js#L122).

Với input bare date như `2026-03-31`, JavaScript parse thành `2026-03-31T00:00:00.000Z`. Nghĩa là filter `from=2026-03-01&to=2026-03-31` sẽ chỉ lấy transaction tới đúng đầu ngày 31/03, còn các bản ghi lúc `2026-03-31T10:00:00Z`, `2026-03-31T18:00:00Z` sẽ bị loại sai.

Điểm này ảnh hưởng trực tiếp tới màn hình lịch sử giao dịch và thống kê khi mobile dùng khoảng ngày theo UI date picker, vì người dùng thường chọn `YYYY-MM-DD` chứ không tự nhập thời điểm cuối ngày.

Đề xuất:

- Nếu client gửi `to` theo dạng `YYYY-MM-DD`, service cần nâng lên cuối ngày `23:59:59.999` trước khi query.
- Hoặc nếu muốn giữ semantics hiện tại, phải sửa Swagger và contract để chỉ chấp nhận datetime đầy đủ cho `to`. Với tình huống tích hợp mobile hiện tại, phương án đầu sẽ an toàn hơn.
- Thêm test route/service xác nhận transaction trong ngày `to` vẫn được trả về khi query dùng `YYYY-MM-DD`.

## Kiểm chứng đã chạy

Đã chạy các test mục tiêu sau và đều pass:

```bash
cd backend
npm test -- --runInBand tests/unit/validators/transaction.validator.test.js tests/unit/services/transaction.service.test.js tests/integration/transaction.put.test.js tests/integration/transaction.delete.test.js
```

Lưu ý: việc các test này pass không phủ nhận 2 issue ở trên, vì hiện chưa có test integration nào cover đúng hai scenario đó.

## Kết luận

**Kết luận hiện tại: chưa nên merge vào `dev`.**

PUT/DELETE đã tiến gần mức sẵn sàng tích hợp, nhưng GET `/api/transactions` vẫn còn 2 lỗ hổng contract quan trọng:

- Client gửi filter hoa/thường không đồng nhất vẫn bị chặn ở validator.
- Date range với `to=YYYY-MM-DD` có thể trả thiếu dữ liệu ngày cuối.

Hai điểm này đều tác động trực tiếp tới mobile integration và có thể tạo ra bug khó phát hiện vì test hiện tại vẫn xanh. Tôi khuyến nghị fix xong rồi chạy lại test integration cho GET trước khi chốt merge.
