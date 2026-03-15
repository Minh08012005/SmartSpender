# Final Review Task #35 - Đức Anh (Mobile)

## Mục tiêu của bản review này

- Tập trung vào bước chuẩn bị tích hợp API thật Sprint 2.
- Chỉ giữ các việc cần làm có tác động trực tiếp tới tích hợp, tránh mất thời gian chỉnh sửa không cần thiết.

## Phạm vi

- Nhánh: feat/edit-transaction-clean
- Commit chính: 9ab587a
- Đối chiếu với feedback review trước.

## Kết luận nhanh

- Đức Anh đã fix đúng hầu hết lỗi cốt lõi ở vòng review trước.
- Trạng thái hiện tại: có thể tiến gần merge, nhưng cần chốt 2 việc bắt buộc để tránh nghẽn lúc tích hợp API thật.

## Những gì đã đạt (không cần làm lại)

1. Đã restore đầy đủ màn hình/form add-edit:

- mobile/lib/screens/add_transaction_screen.dart
- mobile/lib/screens/edit_transaction_screen.dart
- mobile/lib/features/auth/widgets/edit_transaction_form.dart
- mobile/lib/widgets/category_dropdown.dart

2. Đã đồng bộ category theo contract backend (dùng other).

3. Đã thêm validate title trước khi gọi API trong provider.

4. Đã parse lỗi API có fallback rõ ràng bằng \_extractApiErrorMessage.

5. Đã khôi phục test cho TransactionProvider và chạy pass.

## Bắt buộc xử lý trước merge (ưu tiên cao)

### A. Nối flow Add/Edit vào luồng sử dụng thật

Vấn đề:

- Add/Edit screen đã có nhưng chưa có entry point từ Home.

Hướng làm cụ thể:

1. File mobile/lib/views/home/home_screen.dart

- Thêm nút Add (FAB hoặc AppBar action) để mở AddTransactionScreen.
- Khi thêm thành công và pop(true), gọi lại \_loadTransactions() hoặc \_refreshTransactions().

2. File mobile/lib/views/home/widgets/transaction_item.dart

- Cho phép tap vào item và callback lên Home để mở EditTransactionScreen.

3. File mobile/lib/views/home/home_screen.dart

- Khi mở EditTransactionScreen, nếu pop(true) thì refresh danh sách.

Kết quả mong đợi:

- Người dùng tạo/sửa xong thấy dữ liệu cập nhật ngay trên Home.

### B. Sửa widget_test để không làm đỏ pipeline

Vấn đề:

- mobile/test/widget_test.dart đang là counter test mẫu, không đúng app hiện tại.

Hướng làm cụ thể:

1. File mobile/test/widget_test.dart

- Thay test counter bằng smoke test theo app thật.
- Chỉ cần assert app build được và có widget gốc (MaterialApp/Home/Login) là đủ cho giai đoạn này.

Kết quả mong đợi:

- Chạy flutter test không fail vì test mẫu không liên quan.

## Nên làm ngay sau merge (không chặn tích hợp)

### C. Chốt rule amount giữa mobile và backend

Hiện trạng:

- Backend: amount >= 0
- Mobile model: amount > 0

Khuyến nghị ngắn hạn:

- Giữ mobile > 0 theo nghiệp vụ chi tiêu.
- Thống nhất lại với backend team để đổi validator backend thành > 0 khi phù hợp.

File liên quan:

- mobile/lib/data/models/transaction_model.dart
- backend/validators/transaction.validator.js

### D. Làm sạch payload gửi API

Hiện trạng:

- toJson trong model vẫn gửi id trong body.

Khuyến nghị:

- Bỏ id khỏi payload POST/PUT để đúng contract và dễ bảo trì.

File liên quan:

- mobile/lib/data/models/transaction_model.dart

### E. Clean code nhỏ, xử lý nhanh

1. Sửa typo UI: Tranction Type -> Transaction Type.
2. Tái sử dụng CategoryDropdown trong add screen để giảm duplicate.

File liên quan:

- mobile/lib/screens/add_transaction_screen.dart

## Checklist giao việc ngắn cho Đức Anh

- [ ] Nối nút mở Add từ Home và refresh sau add thành công.
- [ ] Nối mở Edit từ transaction item và refresh sau edit thành công.
- [ ] Đổi widget_test sang smoke test đúng app.
- [ ] Sửa typo Tranction Type.

## Checklist phối hợp với Sơn (Home owner)

- [ ] Chốt vị trí UI mở Add/Edit trong Home (FAB, tap item, hoặc menu).
- [ ] Xác nhận rule refresh dữ liệu sau pop(true) để tránh reload dư.
- [ ] Kiểm tra lại trạng thái loading/error/empty khi quay về từ Add/Edit.

## Đánh giá cuối

- Mức sẵn sàng tích hợp API thật: cao, sau khi hoàn thành 2 mục bắt buộc A và B.
- Không cần refactor lớn ở thời điểm này; ưu tiên hoàn tất flow thực thi và độ ổn định test trước.
