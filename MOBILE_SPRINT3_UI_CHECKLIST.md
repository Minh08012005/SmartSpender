# Sprint 3 - Checklist Công Việc UI Mobile (Thống Kê + Ví + Hồ Sơ)

Mục tiêu: Tạo bộ khung task rõ ràng để team mobile copy vào GitHub Issue và sử dụng AI để triển khai nhanh.

## 1) Epic Tổng Quan

- [ ] Tab Thống Kê không còn Placeholder, hiển thị dữ liệu theo tháng.
- [ ] Tab Ví không còn Placeholder, có bộ khung quản lý ví cơ bản.
- [ ] Màn Hồ Sơ được chỉnh trang và có luồng đăng xuất.
- [ ] Toàn bộ UI được thống nhất 1 ngôn ngữ (ưu tiên tiếng Việt).
- [ ] Hoàn tất test giao diện và bàn giao cho QA.

---

## 2) Mẫu Issue #1 - [Mobile] Tích Hợp Màn Hình Thống Kê MVP

Người phụ trách: Minh(leader)
Độ ưu tiên: P0  
Ước lượng: 1.5 - 2 ngày

### Mục tiêu

Xây dựng màn hình Thống Kê MVP, hiển thị KPI, tỷ lệ danh mục chi tiêu, giao dịch gần đây và bộ lọc theo tháng.

### Checklist quy trình (5 pha)

#### Pha 1: Phân tích

- [ ] Xem lại cấu trúc TransactionProvider và các model giao dịch.
- [ ] Xác định nguồn dữ liệu theo tháng/năm.
- [ ] Chốt map dữ liệu: thu nhập, chi tiêu, số dư, tỷ lệ theo danh mục.

#### Pha 2: Thiết kế

- [ ] Chốt layout Thống Kê: Chọn thời gian -> 3 KPI -> Danh mục -> Giao dịch gần đây.
- [ ] Chốt màu sắc và kiểu chữ theo theme hiện tại.
- [ ] Chốt trạng thái loading/empty/error cho từng section.

#### Pha 3: Hiện thực hóa

- [ ] Hoàn thiện file statistic_screen.dart.
- [ ] Tải dữ liệu theo tháng hiện tại, refresh khi đổi tháng.
- [ ] Hiển thị top danh mục theo phần trăm chi tiêu.
- [ ] Hiển thị 5 giao dịch gần đây.
- [ ] Gắn màn hình vào BottomNavigation (tab Thống Kê).

#### Pha 4: Kiểm thử

- [ ] Test với dữ liệu rỗng (empty state).
- [ ] Test với dữ liệu có cả thu nhập và chi tiêu.
- [ ] Test đổi tháng và pull-to-refresh.
- [ ] Test tràn chữ trên màn hình nhỏ.

#### Pha 5: Triển khai

- [ ] Format code và dọn warning.
- [ ] Tạo PR theo đúng convention.
- [ ] Đính kèm screenshot màn hình Thống Kê trong PR.

### Prompt AI gợi ý (copy để dùng)

"Tôi cần hoàn thiện màn hình StatisticScreen Flutter theo MVP: period picker, 3 KPI (thu nhập, chi tiêu, số dư), category breakdown bằng linear progress, 5 giao dịch gần đây, và trạng thái loading/empty/error. Dữ liệu lấy từ TransactionProvider, có refresh theo month/year, UI thống nhất với theme hiện tại. Hãy trả về code sẵn sàng production và các điểm cần test."

---

## 3) Mẫu Issue #2 - [Mobile] Màn Hình Ví MVP + Điều Chuyển Nội Bộ

Người phụ trách: Lê Đức Anh  
Độ ưu tiên: P0  
Ước lượng: 1.5 - 2 ngày

### Mục tiêu

Xây dựng Ví MVP cho quản lý nội bộ: tổng số dư, danh sách ví, điều chuyển nội bộ (không phải chuyển tiền ngân hàng).

### Checklist quy trình (5 pha)

#### Pha 1: Phân tích

- [ ] Xác định phạm vi MVP: 3 ví mặc định (Tiền mặt, Ngân hàng, Ví điện tử).
- [ ] Xác định logic điều chuyển nội bộ: trừ ví A, cộng ví B.
- [ ] Xác định validation: số tiền > 0, ví nguồn khác ví đích, đủ số dư.

#### Pha 2: Thiết kế

- [ ] Chốt layout Ví: Tổng số dư -> Danh sách ví -> Nhóm nút hành động.
- [ ] Chốt modal điều chuyển: từ ví, đến ví, số tiền, ghi chú.
- [ ] Chốt thông điệp mô tả: đây là điều chuyển phục vụ quản lý nội bộ.

#### Pha 3: Hiện thực hóa

- [ ] Tạo file wallet_screen.dart.
- [ ] Hiển thị tổng số dư và 3 ví mặc định.
- [ ] Tạo modal điều chuyển và cập nhật số dư local state.
- [ ] Hiện snackbar kết quả thành công/thất bại.
- [ ] Gắn màn hình vào BottomNavigation (tab Ví).

#### Pha 4: Kiểm thử

- [ ] Test điều chuyển hợp lệ.
- [ ] Test điều chuyển sai validation.
- [ ] Test số dư cập nhật đúng sau nhiều lần điều chuyển.
- [ ] Test UI trên màn hình nhỏ.

#### Pha 5: Triển khai

- [ ] Format code và dọn warning.
- [ ] Tạo PR theo đúng convention.
- [ ] Đính kèm screenshot màn hình Ví + modal điều chuyển trong PR.

### Prompt AI gợi ý (copy để dùng)

"Tôi cần tạo WalletScreen MVP trong Flutter: tổng số dư, 3 wallet cards (Tiền mặt, Ngân hàng, Ví điện tử), modal điều chuyển nội bộ (không liên quan ngân hàng thật). Cần validation số tiền, cập nhật số dư local state, thông báo snackbar và UI responsive. Hãy trả về code sẵn sàng production và checklist test."

---

## 4) Mẫu Issue #3 - [Mobile] Điều Hướng + Đồng Bộ Ngôn Ngữ UI

Người phụ trách: Trịnh Thái Sơn + Lê Đức Anh  
Độ ưu tiên: P0  
Ước lượng: 0.5 - 1 ngày

### Mục tiêu

Nối hoàn chỉnh tab Thống Kê/Ví vào app và đồng bộ toàn bộ text UI theo 1 ngôn ngữ.

### Checklist quy trình (5 pha)

#### Pha 1: Phân tích

- [ ] Audit toàn bộ text đang trộn Anh - Việt.
- [ ] Chốt 1 ngôn ngữ duy nhất cho bản demo.

#### Pha 2: Thiết kế

- [ ] Chốt tên cho các label BottomNavigation.
- [ ] Chốt text cho các CTA chính (Lưu, Xóa, Đăng xuất, Điều chuyển...).

#### Pha 3: Hiện thực hóa

- [ ] Cập nhật MainNavigation để dùng màn hình Thống Kê và Ví thật.
- [ ] Chuyển text chính sang 1 ngôn ngữ thống nhất.
- [ ] Đưa text dùng lại thường xuyên về constants để dễ bảo trì.

#### Pha 4: Kiểm thử

- [ ] Kiểm tra lại tất cả label trên tab.
- [ ] Kiểm tra text trong dialog, snackbar, button.
- [ ] Kiểm tra tràn chữ khi text dài.

#### Pha 5: Triển khai

- [ ] Tạo PR riêng cho text + navigation.
- [ ] Đính kèm danh sách text đã thay đổi trong PR description.

### Prompt AI gợi ý (copy để dùng)

"Tôi cần refactor mobile navigation Flutter: thay Placeholder bằng StatisticScreen và WalletScreen thật, đồng thời chuẩn hóa toàn bộ text UI về 1 ngôn ngữ duy nhất. Hãy đề xuất bảng mapping text, cập nhật constants và checklist test nhanh."

---

## 5) Mẫu Issue #4 - [Mobile] Chỉnh Trang Hồ Sơ + Luồng Đăng Xuất

Người phụ trách: Trịnh Thái Sơn  
Độ ưu tiên: P1  
Ước lượng: 0.5 - 1 ngày

### Mục tiêu

Hoàn thiện màn Hồ Sơ cho demo: bố cục gọn, item action rõ ràng, luồng đăng xuất hoạt động.

### Checklist quy trình (5 pha)

#### Pha 1: Phân tích

- [ ] Xem lại màn Hồ Sơ hiện tại và xác định item cần giữ.
- [ ] Xác định luồng đăng xuất hiện có (lưu token, điều hướng).

#### Pha 2: Thiết kế

- [ ] Chốt bố cục Hồ Sơ gọn: header + menu cards.
- [ ] Chốt thứ bậc visual cho nút Đăng xuất.

#### Pha 3: Hiện thực hóa

- [ ] Thêm hành động cho item Đăng xuất.
- [ ] Xóa token/auth state đúng luồng.
- [ ] Điều hướng về màn hình đăng nhập sau khi đăng xuất.

#### Pha 4: Kiểm thử

- [ ] Test đăng xuất thành công.
- [ ] Test app state sau khi mở lại app.
- [ ] Test khi token hết hạn.

#### Pha 5: Triển khai

- [ ] Tạo PR riêng cho Hồ Sơ.
- [ ] Đính kèm gif/screenshot luồng đăng xuất.

### Prompt AI gợi ý (copy để dùng)

"Tôi cần hoàn thiện ProfileScreen Flutter theo hướng demo-ready: bố cục gọn, menu actions rõ ràng, và luồng đăng xuất xóa token + điều hướng về login. Hãy trả về code sẵn sàng production, edge-case cần test và acceptance criteria."

---

## 6) Mục Bàn Giao cho QA (Bạn + Leader)

- [ ] Xác minh luồng điều hướng Home -> Thống Kê -> Ví -> Hồ Sơ.
- [ ] Xác minh tab 2 và tab 3 không còn Placeholder.
- [ ] Xác minh UI text đã thống nhất 1 ngôn ngữ.
- [ ] Xác minh logic điều chuyển Ví đúng (nội bộ, không banking).
- [ ] Xác minh đăng xuất không giữ lại session cũ.
- [ ] Thu thập screenshot làm minh chứng cho báo cáo sprint.

---

## 7) Bản Nhanh để Copy vào GitHub Issue

Tiêu đề issue mẫu:

- [Mobile] Tích hợp màn hình Thống Kê MVP
- [Mobile] Màn hình Ví MVP + điều chuyển nội bộ
- [Mobile] Điều hướng + đồng bộ ngôn ngữ UI
- [Mobile] Chỉnh trang Hồ Sơ + luồng đăng xuất

Nhãn gợi ý:

- mobile
- sprint-3
- ui
- integration
- priority-p0 / priority-p1

---

## 8) Checklist Trước Khi Bắt Đầu Code

- [ ] Pull nhánh `dev` mới nhất.
- [ ] Tạo nhánh tính năng theo chuẩn `feat/<ten-task>`.
- [ ] Chạy `flutter pub get`.
- [ ] Chạy `flutter analyze` và đảm bảo không có lỗi chặn.
- [ ] Xác nhận tab Thống Kê/Ví hiện đang là Placeholder để tránh nhầm trạng thái.

Lệnh mẫu:

```bash
git checkout dev && git pull
git checkout -b feat/statistic-mvp
cd mobile
flutter pub get
flutter analyze
```

---

## 9) Danh Sách File Cần Tạo/Sửa (Bắt Buộc)

### Task Thống Kê

- [ ] Tạo/Sửa: `mobile/lib/views/statistic/statistic_screen.dart`
- [ ] Sửa: `mobile/lib/navigation/main_navigation.dart` (gắn tab Thống Kê)

### Task Ví

- [ ] Tạo mới: `mobile/lib/views/wallet/wallet_screen.dart`
- [ ] Sửa: `mobile/lib/navigation/main_navigation.dart` (gắn tab Ví)

### Task Đồng bộ ngôn ngữ

- [ ] Sửa: `mobile/lib/core/strings.dart`
- [ ] Sửa: `mobile/lib/navigation/main_navigation.dart`
- [ ] Rà soát text ở `home`, `profile`, `add/edit transaction`, `statistic`, `wallet`

### Task Hồ sơ

- [ ] Sửa: `mobile/lib/views/profile/profile_screen.dart`
- [ ] Sửa nơi xử lý auth token (nếu cần) để logout đúng luồng

---

## 10) Hợp Đồng Dữ Liệu Mock Cho Mobile (Làm Độc Lập Trước Integration)

### Dữ liệu Thống Kê (tham chiếu)

```json
{
  "month": 3,
  "year": 2026,
  "totalIncome": 5000000,
  "totalExpense": 2450000,
  "balance": 2550000,
  "categories": [
    { "name": "Ăn uống", "amount": 1029000, "percentage": 0.42 },
    { "name": "Giao thông", "amount": 441000, "percentage": 0.18 }
  ]
}
```

### Dữ liệu Ví (tham chiếu)

```json
[
  { "id": "cash", "name": "Tiền mặt", "balance": 1200000 },
  { "id": "bank", "name": "Ngân hàng", "balance": 850000 },
  { "id": "ewallet", "name": "Ví điện tử", "balance": 320000 }
]
```

### Luật điều chuyển nội bộ

- [ ] `fromWallet != toWallet`
- [ ] `amount > 0`
- [ ] `amount <= fromWallet.balance`
- [ ] Cập nhật số dư tức thời trên UI sau khi xác nhận

---

## 11) Definition of Done (DoD) Theo Từng Task

### DoD - Thống Kê

- [ ] Mở được từ tab Thống Kê, không còn Placeholder.
- [ ] Hiển thị đúng 3 KPI: Thu nhập, Chi tiêu, Số dư.
- [ ] Hiển thị danh mục theo phần trăm + giao dịch gần đây.
- [ ] Có đủ loading/empty/error state.

### DoD - Ví

- [ ] Mở được từ tab Ví, không còn Placeholder.
- [ ] Hiển thị tổng số dư và danh sách ví.
- [ ] Điều chuyển nội bộ thành công + validation đầy đủ.
- [ ] Snackbar phản hồi rõ ràng cho thành công/thất bại.

### DoD - Đồng bộ ngôn ngữ

- [ ] Không còn trộn Anh - Việt ở các màn chính.
- [ ] Text lặp lại được gom về constants.

### DoD - Hồ sơ

- [ ] Nút Đăng xuất hoạt động đúng luồng.
- [ ] Sau logout quay về màn đăng nhập.
- [ ] Không giữ lại phiên cũ khi mở lại app.

---

## 12) Checklist PR Bắt Buộc Trước Khi Merge

- [ ] PR chỉ chứa 1 task chính.
- [ ] Kích thước PR không vượt ngưỡng quy định của team.
- [ ] Đã chạy `flutter analyze` không lỗi.
- [ ] Đã format code bằng `flutter format .`.
- [ ] Đính kèm ảnh trước/sau hoặc ảnh màn hình kết quả.
- [ ] Ghi rõ mục test đã chạy trong PR description.
- [ ] Có ít nhất 1 người approve trước merge.

Mẫu PR description ngắn:

```md
## Mục tiêu

- Hoàn thiện <task>

## Thay đổi chính

- ...

## Kết quả test

- [x] Analyze pass
- [x] Manual test case 1
- [x] Manual test case 2

## Ảnh minh chứng

- <đính kèm ảnh>
```

---

## 13) Lịch Thực Thi Gợi Ý (2 Ngày)

### Ngày 1

- [ ] Sơn: hoàn thiện Thống Kê + gắn tab Thống Kê
- [ ] Đức Anh: tạo màn Ví + điều chuyển nội bộ cơ bản

### Ngày 2

- [ ] Sơn + Đức Anh: đồng bộ ngôn ngữ UI + gắn tab Ví
- [ ] Sơn: hoàn thiện Hồ sơ + logout
- [ ] Leader/QA: test luồng tổng và chốt lỗi ưu tiên cao
