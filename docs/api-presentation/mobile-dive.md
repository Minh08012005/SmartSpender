# Mobile Deep Dive

Tài liệu này giải thích luồng UI -> provider -> API service -> backend để khi demo không bị chỉ biết bấm app mà không hiểu code.

## 1. Cấu trúc mobile cần nhớ

### Shell chính

- [mobile/lib/navigation/main_navigation.dart](../../mobile/lib/navigation/main_navigation.dart)
- Tabs hiện tại:
  - Home
  - Statistic
  - Wallet
  - Profile

`MainNavigation` là khung điều hướng chính sau khi login thành công.

### Điều hướng mở đầu

- [mobile/lib/screens/login.dart](../../mobile/lib/screens/login.dart)
- [mobile/lib/screens/register.dart](../../mobile/lib/screens/register.dart)
- [mobile/lib/services/auth_service.dart](../../mobile/lib/services/auth_service.dart)

Luồng mở đầu là:

1. Người dùng vào Login hoặc Register.
2. Form gọi `AuthService.login` hoặc `AuthService.register`.
3. Nếu thành công, app chuyển sang `MainNavigation`.
4. Token được lưu vào `SharedPreferences`.

## 2. API service chung

### Files chính

- [mobile/lib/core/services/api_service.dart](../../mobile/lib/core/services/api_service.dart)
- [mobile/lib/core/constants/api_constants.dart](../../mobile/lib/core/constants/api_constants.dart)
- [mobile/lib/core/config/app_config.dart](../../mobile/lib/core/config/app_config.dart)

### Vai trò

`ApiService` là lớp trung tâm cho các request Dio:

- Tự động gắn Authorization header.
- Log request/response để debug.
- Xử lý lỗi 401, 403, 404, 500 ở một nơi.
- Nếu token lỗi hoặc hết hạn, app clear session và quay về Login.

### Ý nghĩa khi trình bày

Nếu cô hỏi "vì sao app tự về login khi token hỏng?", câu trả lời nằm ở interceptor của `ApiService`.

## 3. Home / Dashboard

### Files chính

- [mobile/lib/views/home/home_screen.dart](../../mobile/lib/views/home/home_screen.dart)
- [mobile/lib/views/home/widgets/balance_card.dart](../../mobile/lib/views/home/widgets/balance_card.dart)
- [mobile/lib/views/home/widgets/transaction_item.dart](../../mobile/lib/views/home/widgets/transaction_item.dart)
- [mobile/lib/data/providers/transaction_provider.dart](../../mobile/lib/data/providers/transaction_provider.dart)
- [mobile/lib/data/providers/wallet_provider.dart](../../mobile/lib/data/providers/wallet_provider.dart)

### Luồng nghiệp vụ

- Khi Home mở, app tự gọi:
  - `TransactionProvider.fetchTransactions(month: now.month, year: now.year)`
  - `WalletProvider.fetchWallets(forceRefresh: true)`
- `BalanceCard` hiển thị tổng số dư ví, tổng thu và tổng chi.
- Danh sách bên dưới hiển thị giao dịch gần nhất.
- Người dùng có thể bấm giao dịch để vào màn sửa.
- Nút dấu cộng mở màn thêm giao dịch.

### Điểm cần nhớ

- Home không tự tính số dư bằng tay; nó lấy từ provider.
- Nếu thêm/sửa/xóa giao dịch xong, Home reload lại để đồng bộ.

## 4. Transactions UI

### Files chính

- [mobile/lib/data/providers/transaction_provider.dart](../../mobile/lib/data/providers/transaction_provider.dart)
- [mobile/lib/screens/add_transaction_screen.dart](../../mobile/lib/screens/add_transaction_screen.dart)
- [mobile/lib/screens/edit_transaction_screen.dart](../../mobile/lib/screens/edit_transaction_screen.dart)
- [mobile/lib/screens/all_transactions_screen.dart](../../mobile/lib/screens/all_transactions_screen.dart)

### Provider xử lý gì

`TransactionProvider` là lớp state cho transaction:

- `fetchTransactions` lấy danh sách theo tháng/năm.
- `addTransaction` gửi request tạo giao dịch.
- `updateTransaction` gửi request sửa giao dịch.
- `deleteTransaction` gửi request xóa giao dịch.
- Provider còn giữ `totalIncome`, `totalExpense`, `balance` để UI dùng nhanh.

### Phần cần nói rõ khi demo

Khi tạo một giao dịch mới:

1. Mobile validate đầu vào lần nữa.
2. Provider gọi backend `POST /api/transactions`.
3. Backend cập nhật transaction và số dư ví.
4. Provider cập nhật state local.
5. Home và Statistic rebuild.

## 5. Statistic screen

### Files chính

- [mobile/lib/views/statistic/statistic_screen.dart](../../mobile/lib/views/statistic/statistic_screen.dart)
- [mobile/lib/views/statistic/widgets/period_picker_widget.dart](../../mobile/lib/views/statistic/widgets/period_picker_widget.dart)
- [mobile/lib/views/statistic/widgets/month_calendar_widget.dart](../../mobile/lib/views/statistic/widgets/month_calendar_widget.dart)
- [mobile/lib/views/statistic/widgets/day_transactions_sheet.dart](../../mobile/lib/views/statistic/widgets/day_transactions_sheet.dart)
- [mobile/lib/views/statistic/widgets/month_budget_card_widget.dart](../../mobile/lib/views/statistic/widgets/month_budget_card_widget.dart)
- [mobile/lib/views/statistic/widgets/category_row_widget.dart](../../mobile/lib/views/statistic/widgets/category_row_widget.dart)
- [mobile/lib/views/statistic/widgets/transaction_tile_widget.dart](../../mobile/lib/views/statistic/widgets/transaction_tile_widget.dart)
- [mobile/lib/data/providers/statistic_provider.dart](../../mobile/lib/data/providers/statistic_provider.dart)

### Hiện trạng thực tế

Statistic hiện tại đã có các phần sau:

- Bộ chọn tháng.
- Tổng thu, tổng chi, số dư tháng.
- Phân bổ theo danh mục.
- Danh sách giao dịch gần đây.
- Khối lịch tháng và budget card đang theo hướng UI-first, nên khi demo phải nói rõ phần backend tương ứng còn đang hoàn thiện.

### Luồng dữ liệu

- Khi vào màn, `StatisticScreen` gọi:
  - `TransactionProvider.fetchTransactions(month, year)`
  - `StatisticProvider.fetchStatistics(month, year)`
- `StatisticProvider` gọi backend `GET /api/statistics/summary`.
- `TransactionProvider` lấy danh sách transaction để dựng breakdown và recent list.
- Khi đổi tháng, screen reload lại toàn bộ dữ liệu liên quan.

### Điểm cần nhớ

Nếu bị hỏi "month target card lấy từ đâu?", hiện tại phải nói rõ đây là UI-first placeholder, chưa nên trình bày như API hoàn chỉnh nếu backend chưa xong.

## 6. Wallet UI

### Files chính

- [mobile/lib/views/wallet/wallet_screen.dart](../../mobile/lib/views/wallet/wallet_screen.dart)
- [mobile/lib/views/wallet/widgets/total_balance_card.dart](../../mobile/lib/views/wallet/widgets/total_balance_card.dart)
- [mobile/lib/views/wallet/widgets/transfer_modal_widget.dart](../../mobile/lib/views/wallet/widgets/transfer_modal_widget.dart)
- [mobile/lib/views/wallet/widgets/wallet_card.dart](../../mobile/lib/views/wallet/widgets/wallet_card.dart)
- [mobile/lib/data/providers/wallet_provider.dart](../../mobile/lib/data/providers/wallet_provider.dart)
- [mobile/lib/core/services/wallet_api_service.dart](../../mobile/lib/core/services/wallet_api_service.dart)

### Luồng nghiệp vụ

- Mở Wallet tab thì provider gọi backend lấy danh sách ví.
- Nếu backend trả rỗng, provider tự dựng ví mặc định tạm thời.
- Người dùng bấm chuyển tiền để mở modal transfer.
- Khi transfer thành công, provider cập nhật lại số dư 2 ví liên quan và lưu cache.

### Điểm cần nhớ

- `WalletProvider` có cache bằng `SharedPreferences` để app mở lên nhanh hơn.
- `WalletProvider` còn có timeout riêng cho transfer để tránh cảm giác treo.
- Câu hỏi quan trọng: balance không được sửa trực tiếp từ UI mà phải qua backend transfer hoặc transaction.

## 7. Profile và Logout

### Files chính

- [mobile/lib/views/profile/profile_screen.dart](../../mobile/lib/views/profile/profile_screen.dart)
- [mobile/lib/views/profile/notifications_screen.dart](../../mobile/lib/views/profile/notifications_screen.dart)
- [mobile/lib/views/profile/personal_info_screen.dart](../../mobile/lib/views/profile/personal_info_screen.dart)
- [mobile/lib/views/profile/login_security_screen.dart](../../mobile/lib/views/profile/login_security_screen.dart)
- [mobile/lib/services/auth_service.dart](../../mobile/lib/services/auth_service.dart)

### Luồng nghiệp vụ

- Profile đọc thông tin user từ `SharedPreferences`.
- Nút logout gọi `AuthService.clearSession()`.
- Sau logout, `TransactionProvider.reset()` được gọi để xóa state cũ.
- App quay về `LoginScreen`.

### Notifications trong Profile

Màn notifications hiện tại có hai lớp:

- Backend notification thông qua `NotificationsProvider`.
- Một phần lưu local bằng `SharedPreferences` để UI vẫn hoạt động nếu backend chưa có dữ liệu.

## 8. Notifications provider

### Files chính

- [mobile/lib/data/providers/notifications_provider.dart](../../mobile/lib/data/providers/notifications_provider.dart)
- [mobile/lib/views/profile/widgets/notification_widgets.dart](../../mobile/lib/views/profile/widgets/notification_widgets.dart)

### Luồng nghiệp vụ

- Provider thử gọi backend `/api/notifications` trước.
- Nếu backend có dữ liệu, provider dùng dữ liệu backend và lưu lại local.
- Nếu backend rỗng hoặc lỗi, provider dùng dữ liệu local đã lưu.
- `markAsRead`, `markAllAsRead`, `deleteNotification` vừa cập nhật UI vừa gọi API tương ứng.

### Ý nghĩa khi trình bày

Đây là ví dụ tốt để nói về chiến lược fallback. App không phụ thuộc hoàn toàn vào backend để render UI ngay lập tức.

## 9. Cách trình bày với cô giáo

Khi cô hỏi một màn bất kỳ, nói theo cấu trúc này:

1. Màn nào trên app.
2. Provider nào giữ state.
3. API service nào gọi backend.
4. Backend route/controller/service nào xử lý.
5. Dữ liệu nào thay đổi trên UI sau khi response về.

Nếu trả lời theo mẫu này, nhóm sẽ không bị đứng khi bị hỏi xoáy vào code.

## 10. Điều cần tránh khi demo

- Không trình bày lịch tháng/budget UI-first như một tính năng backend đã hoàn chỉnh.
- Không nói Wallet chỉ là màn hiển thị, vì nó có transfer và reconciliation phía backend.
- Không nói Statistic chỉ là giao diện, vì phần aggregate đang nằm ở backend.
