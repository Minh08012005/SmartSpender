# Backend Deep Dive

Tài liệu này mô tả luồng xử lý backend hiện tại theo cách có thể dùng để trả lời câu hỏi sâu trong buổi demo API.

## 1. Luồng xử lý chung

Toàn bộ backend được khởi tạo trong [backend/app.js](../../backend/app.js). File này:

- Gắn middleware bảo mật và logging.
- Cấu hình CORS.
- Gắn rate limit.
- Mount route cho auth, transactions, statistics, wallets, notifications.
- Expose Swagger UI tại `/api-docs`.
- Đưa lỗi qua global error handler.

Luồng chuẩn của một request là:

1. Client gửi request kèm Bearer token nếu cần.
2. Route nhận request.
3. Middleware validate kiểm tra dữ liệu đầu vào.
4. Middleware auth giải mã token và gắn `req.user`.
5. Controller lấy dữ liệu từ request và gọi service.
6. Service xử lý business logic và làm việc với MongoDB models.
7. Response được trả về bằng format thống nhất.
8. Nếu có lỗi, global error handler chuẩn hóa response lỗi.

## 2. Auth

### Files chính

- [backend/routes/auth/register.route.js](../../backend/routes/auth/register.route.js)
- [backend/routes/auth/login.route.js](../../backend/routes/auth/login.route.js)
- [backend/routes/auth/change_password.route.js](../../backend/routes/auth/change_password.route.js)
- [backend/controllers/auth/register.controller.js](../../backend/controllers/auth/register.controller.js)
- [backend/controllers/auth/login.controller.js](../../backend/controllers/auth/login.controller.js)
- [backend/controllers/auth/change_password.controller.js](../../backend/controllers/auth/change_password.controller.js)
- [backend/services/auth.service.js](../../backend/services/auth.service.js)
- [backend/validators/auth.validator.js](../../backend/validators/auth.validator.js)
- [backend/models/users.model.js](../../backend/models/users.model.js)

### Endpoint hiện có

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/change-password`

### Luồng nghiệp vụ

`register`:

- Route validate `email`, `password`, `fullName` bằng Joi.
- Controller gọi `registerUser`.
- Service kiểm tra user đã tồn tại chưa.
- Password được hash bằng `bcrypt`.
- User mới được lưu vào MongoDB.
- Hệ thống khởi tạo ví mặc định cho user mới bằng `initializeWalletsForUser`.
- Service tạo JWT bằng `jose` và trả về `accessToken` cùng thông tin user.

`login`:

- Route validate `email`, `password`.
- Controller gọi `loginUser`.
- Service tìm user, so sánh password hash bằng `bcrypt.compare`.
- Nếu đúng, service tạo JWT và trả về token.

`change-password`:

- Route bắt buộc auth.
- Controller lấy `req.user._id` từ token.
- Service kiểm tra mật khẩu hiện tại, hash mật khẩu mới, lưu lại và trả về token mới.

### Điểm dễ bị hỏi sâu

- Token được tạo ở `auth.service.js` bằng `SignJWT` với hạn `1d`.
- Mobile lưu token bằng `SharedPreferences` qua [mobile/lib/services/auth_service.dart](../../mobile/lib/services/auth_service.dart).
- `register` tạo wallet mặc định gián tiếp, nên sau đăng ký mới vào Wallet tab sẽ có dữ liệu.
- Nếu cô hỏi vì sao mật khẩu không lưu plain text, câu trả lời là vì đã hash bằng `bcrypt` trước khi lưu.

## 3. Transactions

### Files chính

- [backend/routes/transaction_routes.js](../../backend/routes/transaction_routes.js)
- [backend/controllers/transaction_controller.js](../../backend/controllers/transaction_controller.js)
- [backend/services/transaction.service.js](../../backend/services/transaction.service.js)
- [backend/validators/transaction.validator.js](../../backend/validators/transaction.validator.js)
- [backend/models/transaction_schema.js](../../backend/models/transaction_schema.js)
- [backend/models/wallet.model.js](../../backend/models/wallet.model.js)
- [backend/services/wallet.service.js](../../backend/services/wallet.service.js)

### Endpoint hiện có

- `GET /api/transactions`
- `POST /api/transactions`
- `PUT /api/transactions/:id`
- `DELETE /api/transactions/:id`

### Luồng `GET /transactions`

- Bắt buộc auth.
- Validate query bằng Joi.
- Controller chuẩn hóa query số sang number.
- Service `getFilteredTransactions` tạo query Mongo theo user.
- Hỗ trợ 2 mode lọc:
  - `from` + `to`
  - `month` + `year`
- Ngoài ra còn lọc theo:
  - `type`
  - `category` dạng CSV
  - `search` trong `note`
  - `page`, `limit`, `sortBy`, `order`
- Service trả về:
  - danh sách transaction
  - `totalCount`
  - `page`
  - `limit`
  - `stats` gồm `totalIncome`, `totalExpense`, `balance`

### Luồng `POST /transactions`

- Validator kiểm tra `title`, `amount`, `type`, `category`, `walletType`, `date`, `note`.
- Service tự bảo vệ thêm ở level business logic.
- `ensureWalletsAndGetMap` đảm bảo user có đủ ví chuẩn.
- Transaction mới được normalize:
  - title trim
  - category lowercase
  - type lowercase
  - walletType lowercase và hợp lệ
- Số dư ví được cập nhật ngay khi tạo transaction:
  - income thì cộng
  - expense thì trừ
- Nếu số dư không đủ, service ném lỗi.
- Transaction được lưu vào MongoDB cùng với update ví tương ứng.

### Luồng `PUT /transactions/:id`

Đây là chỗ cô giáo rất hay hỏi.

- Service kiểm tra `userId`, `id`, body hợp lệ.
- Lấy transaction cũ theo user và id.
- Tính delta cũ và rollback số dư ví cũ.
- Tính delta mới và apply vào ví mới.
- Nếu đổi luôn `walletType`, service sẽ cập nhật đúng ví nguồn và ví đích.
- Sau đó transaction được cập nhật và lưu lại.

### Luồng `DELETE /transactions/:id`

- Tìm transaction theo user và id.
- Xác định ví liên quan.
- Rollback số dư ví theo giao dịch sắp bị xóa.
- Xóa transaction trong MongoDB.

### Ý nghĩa nghiệp vụ

Transaction không chỉ là một bản ghi tiền, mà còn là nguồn dữ liệu trực tiếp để:

- Tính số dư ví.
- Tính tổng thu/chi trong Statistic.
- Hiển thị recent transactions ở Home.

### Điểm dễ bị hỏi sâu

- Vì sao transaction tạo/sửa/xóa lại tác động đến wallet? Vì số dư ví được xem là kết quả suy ra từ lịch sử giao dịch và transfer.
- Vì sao phải có validate ở cả route và service? Vì service vẫn phải tự bảo vệ nếu validator bị bỏ qua.
- Vì sao `month/year` và `from/to` không dùng chung? Vì contract muốn rõ mode lọc và tránh query mơ hồ.
- Vì sao `search` chỉ search `note`? Vì đây là quyết định scope hiện tại để giữ logic đơn giản.

## 4. Statistics

### Files chính

- [backend/routes/statistic_routes.js](../../backend/routes/statistic_routes.js)
- [backend/controllers/statistic.controller.js](../../backend/controllers/statistic.controller.js)
- [backend/services/statistic.service.js](../../backend/services/statistic.service.js)
- [backend/validators/statistic.validator.js](../../backend/validators/statistic.validator.js)
- [backend/models/transaction_schema.js](../../backend/models/transaction_schema.js)

### Endpoint hiện có

- `GET /api/statistics/summary`

### Luồng nghiệp vụ

- Route bắt buộc auth.
- Validator bắt buộc `month` và `year`.
- Controller gọi `getMonthlyStatistics(userId, month, year)`.
- Service gọi xuống `getStatistics`.
- Mongo aggregate tính:
  - totalIncome
  - totalExpense
  - balance
- Nếu không có giao dịch thì trả về 0 cho cả ba giá trị.

### Điểm cần nhớ khi trình bày

- Thống kê hiện tại là thống kê tháng, không phải chart phức tạp.
- Logic được tính ở backend để mobile chỉ render, không tự cộng tay.
- `transaction_provider.dart` dùng response này để cache tổng thu/chi/số dư trên UI.

## 5. Wallets

### Files chính

- [backend/routes/wallet_routes.js](../../backend/routes/wallet_routes.js)
- [backend/controllers/wallet.controller.js](../../backend/controllers/wallet.controller.js)
- [backend/services/wallet.service.js](../../backend/services/wallet.service.js)
- [backend/models/wallet.model.js](../../backend/models/wallet.model.js)
- [backend/models/wallet_transfer.model.js](../../backend/models/wallet_transfer.model.js)
- [backend/validators/wallet.validator.js](../../backend/validators/wallet.validator.js)

### Endpoint hiện có

- `GET /api/wallets`
- `GET /api/wallets/:id`
- `PATCH /api/wallets/:id`
- `POST /api/wallets/transfer`

### Luồng `GET /wallets`

- Controller lấy ví theo `userId`.
- Nếu user chưa có ví, service khởi tạo 3 ví mặc định:
  - cash
  - bank
  - ewallet
- Sau đó hệ thống reconcile lại số dư ví dựa trên toàn bộ transaction và wallet transfer hiện có.
- Response trả về list ví và `totalBalance`.

### Luồng `PATCH /wallets/:id`

- Chỉ cập nhật tên và mô tả.
- Không cho sửa `balance` trực tiếp.
- Đây là quyết định nghiệp vụ quan trọng để số dư chỉ đổi qua transaction hoặc transfer.

### Luồng `POST /wallets/transfer`

- Validate `fromWalletId`, `toWalletId`, `amount`, `note`.
- Kiểm tra ví nguồn và ví đích có tồn tại không.
- Kiểm tra ví nguồn khác ví đích.
- Kiểm tra số dư đủ trước khi chuyển.
- Trừ tiền ví nguồn, cộng tiền ví đích.
- Lưu một record `WalletTransfer` để có lịch sử chuyển tiền.

### Điểm dễ bị hỏi sâu

- Vì sao `GET /wallets` lại reconcile số dư mỗi lần gọi? Để giảm lệch dữ liệu legacy hoặc lệch giữa lịch sử và số dư hiện tại.
- Vì sao transfer phải có record riêng? Để phân biệt với transaction bình thường và có audit trail rõ hơn.
- Vì sao không cho sửa balance trực tiếp? Vì balance là dữ liệu kết quả, không nên sửa tay làm sai lịch sử.

## 6. Notifications

### Files chính

- [backend/routes/notification.routes.js](../../backend/routes/notification.routes.js)
- [backend/controllers/notification.controller.js](../../backend/controllers/notification.controller.js)
- [backend/services/notification.service.js](../../backend/services/notification.service.js)
- [backend/models/notification.model.js](../../backend/models/notification.model.js)

### Endpoint hiện có

- `GET /api/notifications`
- `POST /api/notifications`
- `PATCH /api/notifications/:id/read`
- `PATCH /api/notifications/read-all`
- `DELETE /api/notifications/:id`

### Luồng nghiệp vụ

- `listNotifications`: lấy danh sách theo user, sort mới nhất trước.
- `create`: tạo notification mới.
- `read`: đánh dấu một thông báo là đã đọc.
- `readAll`: đánh dấu toàn bộ là đã đọc.
- `remove`: xóa một thông báo.

### Điểm cần nhớ

- Backend notification là CRUD tương đối đơn giản.
- Mobile có thể lưu đồng bộ cục bộ để UI vẫn hoạt động tốt khi backend chưa có dữ liệu.
- Phần này thường được dùng làm điểm cộng khi demo vì cho thấy có đủ luồng thông báo và trạng thái đọc/chưa đọc.

## 7. Shared infrastructure

### Middleware đáng nhớ

- `auth.middleware.js`: giải mã JWT và gắn `req.user`.
- `validate.middleware.js`: chặn dữ liệu sai trước controller.
- `rateLimit.middleware.js`: giảm spam request.
- `errorHandler.middleware.js`: chuẩn hóa lỗi cuối cùng.

### Utility đáng nhớ

- `response.util.js`: chuẩn hóa format response success/error.
- `appError.js`: ném lỗi có status code rõ ràng.
- `date_util.js`: hỗ trợ xử lý ngày tháng nếu cần.

## 8. Cách trả lời khi bị hỏi "backend làm gì ở đây?"

Khi cô giáo chọn một tính năng bất kỳ, hãy trả lời theo mẫu này:

1. Màn nào trên mobile gọi tính năng đó.
2. Provider/service nào gửi request.
3. Route nào nhận request.
4. Middleware nào kiểm tra trước.
5. Controller nào xử lý đầu vào.
6. Service nào chứa business logic.
7. Model nào bị đọc hoặc ghi.
8. Response trả về gì cho UI.

Nếu giữ đúng thứ tự này, nhóm sẽ ít bị lạc khi bị hỏi xoáy vào code.
