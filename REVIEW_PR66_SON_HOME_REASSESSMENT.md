# Re-review PR #66 - Sơn Mobile Home Integration

## 1) Mục tiêu và phạm vi

Tài liệu này đánh giá lại PR #66 sau khi Sơn đã resolve conflict và cập nhật theo review cũ (commit 7f2ac5b), với mục tiêu:

- Kiểm tra độ sẵn sàng cho bước tích hợp API thật Mobile <-> Backend.
- Đưa ra kết luận rõ ràng để Leader quản lý tiến độ và quy trình merge.
- Liệt kê yêu cầu fix bắt buộc trước khi approve.

Phạm vi file đã review:

- [mobile/lib/views/home/home_screen.dart](mobile/lib/views/home/home_screen.dart)
- [mobile/lib/views/home/widgets/balance_card.dart](mobile/lib/views/home/widgets/balance_card.dart)
- [mobile/lib/views/home/states/home_loading.dart](mobile/lib/views/home/states/home_loading.dart)
- [mobile/lib/views/home/states/home_error.dart](mobile/lib/views/home/states/home_error.dart)
- [mobile/lib/views/home/states/home_empty.dart](mobile/lib/views/home/states/home_empty.dart)
- [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart)
- [mobile/lib/data/models/transaction_model.dart](mobile/lib/data/models/transaction_model.dart)
- [mobile/lib/screens/add_transaction_screen.dart](mobile/lib/screens/add_transaction_screen.dart)
- [mobile/lib/views/home/widgets/transaction_item.dart](mobile/lib/views/home/widgets/transaction_item.dart)
- [backend/validators/constants.js](backend/validators/constants.js)
- [backend/validators/transaction.validator.js](backend/validators/transaction.validator.js)
- [backend/models/transaction_schema.js](backend/models/transaction_schema.js)

---

## 2) Kết luận nhanh cho Leader

Trạng thái tổng quan: Đã có tiến bộ tốt, NHƯNG CHƯA SẴN SÀNG merge vào dev để tích hợp API thật.

Lý do chính:

1. Đã resolve conflict sạch (không còn conflict marker).
2. Đã tách state UI Home (Loading/Error/Empty/Data) rõ hơn.
3. Vẫn còn 2 lỗi nghiêm trọng liên quan đến contract và toàn vẹn dữ liệu, có thể gây lỗi 400 hoặc sai dữ liệu hiển thị.

Khuyến nghị gate merge:

- Đặt trạng thái: Changes requested.
- Chỉ approve khi đã fix xong toàn bộ mục P0/P1 bên dưới và pass test checklist.

---

## 3) Tiến độ xử lý so với review cũ (7f2ac5b)

| Hạng mục review cũ                                 | Trạng thái hiện tại | Ghi chú                                                |
| -------------------------------------------------- | ------------------- | ------------------------------------------------------ |
| Resolve conflict với dev                           | Đã đạt              | PR đã merge-base mới, không còn marker conflict        |
| Tách state flow Home Loading/Error/Empty/Data      | Đã đạt              | Đã tách thành các state widget riêng                   |
| Bổ sung title trong TransactionModel               | Đã đạt một phần     | Đã có field title trong model và toJson/fromJson       |
| Xử lý stale tổng thu/chi                           | Đã cải thiện        | Đã reset remote stats khi CRUD/fetch lỗi               |
| Mức sẵn sàng contract và tính ổn định cho API thật | Chưa đạt            | Vẫn còn mismatch category và fallback amount nguy hiểm |

---

## 4) Findings ưu tiên (theo mức độ ảnh hưởng)

## P0 - Bắt buộc fix trước khi review tiếp

### F1. Mismatch category giữa Mobile và Backend sẽ gây lỗi 400 khi tạo/sửa giao dịch

Mô tả:

- Mobile đang dùng category income/expense không trùng contract backend:
  - Mobile có other income, other expense.
  - Backend chỉ cho phép other.
- Nghĩa là user chọn category hợp lệ trên app nhưng backend có thể từ chối request.

Bằng chứng:

- Mobile categories: [mobile/lib/data/models/transaction_model.dart#L9](mobile/lib/data/models/transaction_model.dart#L9), [mobile/lib/data/models/transaction_model.dart#L10](mobile/lib/data/models/transaction_model.dart#L10), [mobile/lib/data/models/transaction_model.dart#L17](mobile/lib/data/models/transaction_model.dart#L17)
- Backend allowed categories: [backend/validators/constants.js#L1](backend/validators/constants.js#L1), [backend/validators/constants.js#L8](backend/validators/constants.js#L8)
- Add form lấy options trực tiếp từ model: [mobile/lib/screens/add_transaction_screen.dart#L42](mobile/lib/screens/add_transaction_screen.dart#L42), [mobile/lib/screens/add_transaction_screen.dart#L245](mobile/lib/screens/add_transaction_screen.dart#L245)

Tác động quy trình:

- Team sẽ gặp lỗi API 400 ngắt quãng trong giai đoạn UAT tích hợp.
- Leader khó phân tách lỗi do backend hay mobile vì UI validate pass nhưng backend reject.

Yêu cầu sửa:

1. Chuẩn hóa category enum mobile khớp 100% với backend constants.
2. Quy ước 1 giá trị other dùng cho cả income và expense (nếu backend giữ contract hiện tại).
3. Rà lại Add/Edit form để dropdown không đưa ra giá trị ngoài contract.
4. Bổ sung test parse/submit category theo contract backend.

---

### F2. Fallback amount = 1.0 trong fromJson có nguy cơ che lỗi dữ liệu và tạo số liệu sai

Mô tả:

- Khi amount null/invalid, model đang fallback thành 1.0.
- Đây là default nguy hiểm vì biến lỗi contract thành dữ liệu hợp lệ giả, làm sai thống kê.

Bằng chứng:

- [mobile/lib/data/models/transaction_model.dart#L73](mobile/lib/data/models/transaction_model.dart#L73)

Tác động quy trình:

- Có thể không fail ngay, nhưng phát sinh data sai âm thầm (hard-to-debug).
- Ảnh hưởng trực tiếp tổng thu/chi và báo cáo.

Yêu cầu sửa:

1. Không fallback 1.0.
2. Chọn 1 trong 2 hướng:
   - Ném exception để provider bắt lỗi và hiển thị state error đúng.
   - Hoặc fallback 0.0 + đánh dấu invalid transaction và loại bỏ khỏi list hiển thị.
3. Bổ sung test cho case amount null/string invalid.

---

## P1 - Nên fix trước khi merge để giảm debt tích hợp

### F3. Home list đang hiển thị category thay vì title, giảm giá trị UX và khó trace giao dịch

Mô tả:

- Item list đang hiển thị transaction.category ở dòng chính.
- Backend contract và luồng tạo/sửa đều tập trung vào title là thông tin chính.

Bằng chứng:

- [mobile/lib/views/home/widgets/transaction_item.dart#L34](mobile/lib/views/home/widgets/transaction_item.dart#L34)
- Backend title required: [backend/models/transaction_schema.js#L48](backend/models/transaction_schema.js#L48), [backend/models/transaction_schema.js#L50](backend/models/transaction_schema.js#L50), [backend/validators/transaction.validator.js#L61](backend/validators/transaction.validator.js#L61)

Yêu cầu sửa:

1. Hiển thị title là text chính trên TransactionItem.
2. Category + date + note đưa xuống text phụ.

---

### F4. Message lỗi fetchTransactions chưa ổn định và chưa thân thiện cho user

Mô tả:

- Trong nhánh DioException đang ưu tiên e.error.toString() thay vì payload message từ backend.
- Dễ tạo message kỹ thuật khó hiểu trên UI.

Bằng chứng:

- [mobile/lib/data/providers/transaction_provider.dart#L152](mobile/lib/data/providers/transaction_provider.dart#L152)

Yêu cầu sửa:

1. Dùng lại \_extractApiErrorMessage(e, fallback) để lấy message chuẩn API.
2. Chuẩn hóa ngôn ngữ message (tránh vừa Anh vừa Việt).

---

## P2 - Cải tiến quy trình/maintainability

### F5. Còn TODO mơ hồ trong HomeScreen để lại rủi ro hiểu nhầm tiến độ

Mô tả:

- Comment TODO nói cho backend task khác đã xong/chưa xong nhưng code đã gọi fetchTransactions thật.
- Dễ làm leader khó đọc trạng thái thực tế của task.

Bằng chứng:

- [mobile/lib/views/home/home_screen.dart#L23](mobile/lib/views/home/home_screen.dart#L23)

Yêu cầu sửa:

1. Xóa TODO nếu không còn đúng.
2. Nếu còn dependency, đổi thành comment rõ dependency gate + issue link.

---

## 5) Điểm tốt cần ghi nhận

1. Resolve conflict đã sạch, không còn marker xung đột trong module Home.
2. Tách state UI thành widget riêng giúp dễ test và dễ maintain:
   - [mobile/lib/views/home/states/home_loading.dart](mobile/lib/views/home/states/home_loading.dart)
   - [mobile/lib/views/home/states/home_error.dart](mobile/lib/views/home/states/home_error.dart)
   - [mobile/lib/views/home/states/home_empty.dart](mobile/lib/views/home/states/home_empty.dart)
3. Đã bổ sung reset remote totals sau CRUD/fetch lỗi trong provider, giảm stale summary.

---

## 6) Checklist bắt buộc Sơn hoàn thành trước khi xin review lại

## A. Code fixes

- [ ] Đồng bộ category mobile với backend constants.
- [ ] Sửa parse amount fallback để không tạo dữ liệu giả 1.0.
- [ ] Chuyển TransactionItem sang hiển thị title là chính.
- [ ] Chuẩn hóa message lỗi fetch bằng \_extractApiErrorMessage.
- [ ] Dọn TODO/ghi chú để trạng thái task rõ ràng.

## B. Verification

- [ ] Thử công Add/Edit với mọi category, đảm bảo backend không trả 400 do category.
- [ ] Thử case backend trả amount lỗi (hoặc mock) để xác nhận UI xử lý đúng.
- [ ] Thử loading/error/empty/data trên Home sau khi fix.
- [ ] Chụp bằng chứng (log/request-response/ảnh màn hình) trong PR comment.

## C. Quy trình PR

- [ ] Rebase hoặc merge mới nhất từ dev trước khi push.
- [ ] Đảm bảo PR không còn conflict, không còn TODO mơ hồ, không còn commit debug.
- [ ] Trả lời từng finding trong review comment theo format: Fixed / Won't fix + lý do.

---

## 7) Đề xuất quản lý tiến độ cho Leader

Trạng thái khuyến nghị hiện tại: Changes requested

Điều kiện chuyển sang Approved:

1. Hoàn thành hết mục P0.
2. Hoàn thành ít nhất F3 và F4 trong P1.
3. Có bằng chứng test nhanh cho luồng Add/Edit/Home state.

Nếu Sơn cần tách nhỏ để dễ merge:

1. PR nhỏ 1: Contract alignment (category + parse amount).
2. PR nhỏ 2: UI data clarity (TransactionItem + error message cleanup + TODO cleanup).

---

## 8) Chốt

PR #66 đã tiến bộ rõ về cấu trúc Home và xử lý conflict. Tuy nhiên, với mục tiêu tích hợp API thật an toàn, cần fix tiếp các điểm contract/data integrity bên trên trước khi có thể xem là sẵn sàng merge.
