# SmartSpender API Presentation Guide

Tài liệu này dành cho buổi demo và phần hỏi sâu về code của môn API. Mục tiêu là giúp cả nhóm hiểu được:

- Ứng dụng đang có những luồng nghiệp vụ nào.
- Mỗi luồng đi qua những file nào.
- Backend xử lý dữ liệu ra sao.
- Mobile gọi API bằng cách nào.
- Những phần nào đang hoàn thiện, chưa nên trình bày như tính năng đã xong.

## Phạm vi hiện tại

Đây là bộ tài liệu cho các tính năng đã có trong hệ thống hiện tại:

- Đăng ký, đăng nhập, đổi mật khẩu.
- Giao dịch: xem, thêm, sửa, xóa, lọc theo tháng hoặc khoảng ngày.
- Thống kê tháng: tổng thu, tổng chi, số dư.
- Ví: danh sách ví, xem chi tiết ví, chuyển tiền giữa ví, cập nhật thông tin ví.
- Thông báo: danh sách, đánh dấu đã đọc, xóa.
- Mobile shell: Home, Statistic, Wallet, Profile.

Các hạng mục đang làm dở như lịch tháng và cảnh báo chi tiêu nên xem là phần đang phát triển, không đưa vào phần demo chính nếu backend chưa xong.

## Cách dùng bộ tài liệu

- Nếu cần phần mở màn demo, đọc mục "Luồng demo đề xuất" trước.
- Nếu bị cô hỏi sâu về backend, mở [backend-dive.md](./backend-dive.md).
- Nếu cần giải thích mobile gọi API thế nào, mở [mobile-dive.md](./mobile-dive.md).

## Luồng demo đề xuất

1. Đăng nhập hoặc đăng ký tài khoản.
2. Vào Home để thấy số dư ví và danh sách giao dịch gần nhất.
3. Thêm một giao dịch mới để thấy dữ liệu đổi ngay trên Home và Wallet.
4. Sang Statistic để xem tổng thu, tổng chi, số dư theo tháng.
5. Vào Wallet để xem danh sách ví và thử chuyển tiền giữa ví.
6. Mở Profile để xem luồng logout và khu vực thông báo.
7. Nếu được hỏi sâu, đi từ UI sang provider, rồi sang route/controller/service/backend model.

## Bản đồ kỹ thuật một request

Luồng chuẩn của backend hiện tại là:

UI hoặc provider -> API service -> route -> validate middleware -> auth middleware -> controller -> service -> model -> response util -> error handler.

Trong code, các điểm đáng nhớ là:

- `backend/app.js` gắn toàn bộ route và middleware chung.
- `backend/middleware/auth.middleware.js` bảo vệ endpoint cần token.
- `backend/middleware/validate.middleware.js` chặn input sai trước khi vào controller.
- `backend/utils/response.util.js` chuẩn hóa format trả về.
- `backend/middleware/errorHandler.middleware.js` gom lỗi thành response thống nhất.

## Bản đồ file theo tính năng

| Tính năng         | Mobile chính                                                                                                                                               | Backend chính                                                                                                                         | Ghi chú khi trình bày                                                                   |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Đăng nhập/đăng ký | `mobile/lib/screens/login.dart`, `mobile/lib/screens/register.dart`, `mobile/lib/services/auth_service.dart`                                               | `backend/routes/auth/*.route.js`, `backend/controllers/auth/*.controller.js`, `backend/services/auth.service.js`                      | Đây là luồng mở đầu demo, thường được hỏi token lưu ở đâu và backend tạo token thế nào. |
| Home/Dashboard    | `mobile/lib/views/home/home_screen.dart`, `mobile/lib/views/home/widgets/balance_card.dart`, `mobile/lib/views/home/widgets/transaction_item.dart`         | `backend/routes/transaction_routes.js`, `backend/services/transaction.service.js`, `backend/routes/wallet_routes.js`                  | Home lấy dữ liệu từ transaction + wallet provider.                                      |
| Giao dịch         | `mobile/lib/data/providers/transaction_provider.dart`, `mobile/lib/screens/add_transaction_screen.dart`, `mobile/lib/screens/edit_transaction_screen.dart` | `backend/routes/transaction_routes.js`, `backend/controllers/transaction_controller.js`, `backend/services/transaction.service.js`    | Đây là luồng rất dễ bị hỏi sâu vì liên quan cả số dư ví.                                |
| Thống kê          | `mobile/lib/views/statistic/statistic_screen.dart`, `mobile/lib/data/providers/statistic_provider.dart`                                                    | `backend/routes/statistic_routes.js`, `backend/controllers/statistic.controller.js`, `backend/services/statistic.service.js`          | Hiện tại là thống kê tháng, chưa phải lịch tháng/budget mới.                            |
| Ví                | `mobile/lib/views/wallet/wallet_screen.dart`, `mobile/lib/data/providers/wallet_provider.dart`, `mobile/lib/core/services/wallet_api_service.dart`         | `backend/routes/wallet_routes.js`, `backend/controllers/wallet.controller.js`, `backend/services/wallet.service.js`                   | Có phần tự khởi tạo ví mặc định và đối soát số dư.                                      |
| Thông báo         | `mobile/lib/data/providers/notifications_provider.dart`, `mobile/lib/views/profile/notifications_screen.dart`                                              | `backend/routes/notification.routes.js`, `backend/controllers/notification.controller.js`, `backend/services/notification.service.js` | Mobile có fallback local nếu backend rỗng hoặc chưa đồng bộ.                            |
| Profile/Logout    | `mobile/lib/views/profile/profile_screen.dart`                                                                                                             | `mobile/lib/services/auth_service.dart`                                                                                               | Logout chủ yếu là xóa session và quay về login.                                         |

## Nhóm trình bày nên đọc gì

- Minh: đọc toàn bộ tài liệu này và [mobile-dive.md](./mobile-dive.md), đặc biệt là Home và Statistic.
- Nam: đọc [backend-dive.md](./backend-dive.md) phần Statistics và phần validate/input.
- Chúc: đọc [backend-dive.md](./backend-dive.md) phần Transactions.
- Ngọc Anh: đọc [backend-dive.md](./backend-dive.md) phần Wallets.
- Xuân: đọc [backend-dive.md](./backend-dive.md) phần Auth, Notifications và mục lỗi/kiểm thử.

## Các câu cô giáo có thể hỏi

- Token được tạo ở đâu và lưu ở đâu?
- Vì sao thêm giao dịch thì số dư ví đổi ngay?
- Khi sửa/xóa giao dịch thì hệ thống làm gì với số dư cũ?
- Route nào đang bảo vệ bằng JWT?
- Tại sao thống kê tháng lấy từ aggregate thay vì cộng tay ở mobile?
- Wallet có được sửa trực tiếp số dư không?
- Notification backend và mobile local đang phối hợp thế nào?

## Ghi chú khi demo

- Nếu cô hỏi phần lịch tháng/cảnh báo chi tiêu, nói rõ đây là phần đang làm tiếp, chưa đưa vào demo chính.
- Không trình bày quá sâu phần UI-first của lịch tháng như một tính năng hoàn chỉnh nếu backend chưa xong.
- Khi cần trả lời nhanh, luôn đi theo thứ tự: màn nào -> provider nào -> API nào -> controller nào -> service nào -> model nào.

## Tài liệu cá nhân cho team API

Mỗi thành viên API có một cheat-sheet ngắn nằm dưới đây:

- [Tài liệu cho Minh (API Lead)](./for-minh.md)
- [Tài liệu cho Nam (Daily Stats)](./for-nam.md)
- [Tài liệu cho Ngọc Anh (Budget)](./for-ngoc-anh.md)
- [Tài liệu cho Chúc (Transactions-by-Date)](./for-chuc.md)
- [Tài liệu cho Xuân (Test & Integration)](./for-xuan.md)
