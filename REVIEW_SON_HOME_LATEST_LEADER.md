# Review cập nhật mới nhất - Sơn Mobile (Home Integration)

## 1) Mục tiêu tài liệu

Tài liệu này giúp Leader theo dõi nhanh:
- Sơn đã xử lý đến đâu sau các commit mới nhất.
- Mức sẵn sàng hiện tại cho giai đoạn test độc lập Mobile trước tích hợp API thật.
- Các bước bắt buộc Sơn cần hoàn thành để có thể merge vào dev an toàn.

Phạm vi đánh giá: các thay đổi trên nhánh `feature/home-integration` so với `dev`.

---

## 2) Kết luận nhanh cho Leader

Trạng thái hiện tại: **Đã có tiến bộ rõ**, nhưng **chưa đủ điều kiện merge vào dev**.

Lý do chính:
1. Sơn đã sửa đúng nhiều điểm trọng yếu về contract và UI hiển thị.
2. Tuy nhiên, bộ test độc lập Mobile (Provider) đang fail nhiều case, nên chưa đạt tiêu chí ổn định trước tích hợp API thật.

Khuyến nghị điều phối: giữ PR ở trạng thái **Changes requested** cho đến khi test pass đầy đủ.

---

## 3) Sơn đã xử lý tốt những gì

### A. Chuẩn hóa contract category gần backend hơn
- Đã dùng `other` thay vì tách `other income` / `other expense` trong enum category chính.
- Có normalize tương thích dữ liệu cũ.

Tham chiếu:
- [mobile/lib/data/models/transaction_model.dart#L9](mobile/lib/data/models/transaction_model.dart#L9)
- [mobile/lib/data/models/transaction_model.dart#L127](mobile/lib/data/models/transaction_model.dart#L127)

### B. Bỏ fallback amount gây sai số liệu âm thầm
- `fromJson` đã chuyển sang fail-fast khi amount null/invalid.

Tham chiếu:
- [mobile/lib/data/models/transaction_model.dart#L78](mobile/lib/data/models/transaction_model.dart#L78)

### C. UI Home rõ nghĩa dữ liệu hơn
- `TransactionItem` đã hiển thị `title` làm dòng chính.
- Dòng phụ có category + date + note (nếu có).

Tham chiếu:
- [mobile/lib/views/home/widgets/transaction_item.dart#L35](mobile/lib/views/home/widgets/transaction_item.dart#L35)
- [mobile/lib/views/home/widgets/transaction_item.dart#L45](mobile/lib/views/home/widgets/transaction_item.dart#L45)

### D. Đã thêm test model độc lập
- Có file test mới cho parse amount/category.

Tham chiếu:
- [mobile/test/transaction_model_test.dart](mobile/test/transaction_model_test.dart)

---

## 4) Các vấn đề còn tồn tại (cần xử lý trước merge)

## P0 - Bắt buộc xử lý

### 1) Bộ test provider đang fail, chưa đạt chuẩn "test độc lập"

Hiện trạng:
- Chạy test trọng tâm: `flutter test test/transaction_model_test.dart test/transaction_provider_test.dart`
- Kết quả: nhiều case fail trong `transaction_provider_test.dart`.

Nguyên nhân chính (dễ hiểu cho quản lý):
1. Dữ liệu mock trong test chưa khớp contract parse mới.
2. Một số test case đang kiểm tra logic cũ, không còn phù hợp sau khi model siết validate.

Ví dụ điểm lệch:
- Test success đang mock payload chưa đúng shape parse tạo/update hiện tại.
  - [mobile/test/transaction_provider_test.dart#L51](mobile/test/transaction_provider_test.dart#L51)
  - [mobile/lib/data/providers/transaction_provider.dart#L326](mobile/lib/data/providers/transaction_provider.dart#L326)
- Test tạo title rỗng fail ngay ở model constructor, nên không còn là test provider-level.
  - [mobile/test/transaction_provider_test.dart#L76](mobile/test/transaction_provider_test.dart#L76)
  - [mobile/lib/data/models/transaction_model.dart#L40](mobile/lib/data/models/transaction_model.dart#L40)
- Test dùng category `transport` không hợp lệ với danh mục hiện tại.
  - [mobile/test/transaction_provider_test.dart#L234](mobile/test/transaction_provider_test.dart#L234)

Tác động nếu merge ngay:
- Rủi ro hồi quy cao khi bước vào tích hợp thật vì không có “lưới an toàn” test đáng tin cậy.

---

## P1 - Nên xử lý để giảm debt kỹ thuật

### 2) Validate amount đang bị lặp trong model

Hiện trạng:
- Vừa `assert(amount > 0)` vừa `throw Exception` cho cùng điều kiện.

Tham chiếu:
- [mobile/lib/data/models/transaction_model.dart#L40](mobile/lib/data/models/transaction_model.dart#L40)
- [mobile/lib/data/models/transaction_model.dart#L46](mobile/lib/data/models/transaction_model.dart#L46)

Khuyến nghị:
- Chọn 1 cơ chế thống nhất để hành vi rõ ràng và dễ test.

### 3) Message lỗi tổng quát chưa thống nhất hoàn toàn

Hiện trạng:
- Nhánh Dio đã dùng message thân thiện hơn.
- Nhưng nhánh catch tổng quát vẫn có message kỹ thuật.

Tham chiếu:
- [mobile/lib/data/providers/transaction_provider.dart#L162](mobile/lib/data/providers/transaction_provider.dart#L162)
- [mobile/lib/data/providers/transaction_provider.dart#L168](mobile/lib/data/providers/transaction_provider.dart#L168)

---

## 5) Yêu cầu Sơn thực hiện các bước tiếp theo (đến khi đủ merge)

## Bước 1 - Sửa test để khớp contract mới (BẮT BUỘC)

1. Cập nhật fixture response trong `transaction_provider_test.dart` theo shape backend/provider hiện tại.
2. Loại bỏ hoặc viết lại các case kiểm tra title rỗng ở provider-level nếu đã bị chặn từ model constructor.
3. Sửa toàn bộ test data category về danh mục hợp lệ hiện tại.

## Bước 2 - Ổn định logic model/provider

1. Thống nhất một cơ chế validate amount (assert hoặc throw).
2. Chuẩn hóa message lỗi để dễ đọc với người dùng cuối và dễ trace log với team.

## Bước 3 - Chạy và chứng minh test độc lập

1. Chạy lại:
   - `flutter test test/transaction_model_test.dart test/transaction_provider_test.dart`
   - `flutter test`
2. Đính kèm bằng chứng pass test trong PR comment (log ngắn + ảnh).

## Bước 4 - Xin review lại

1. Trả lời từng finding theo format: `Fixed` hoặc `Won't fix` + lý do.
2. Chỉ xin approve sau khi toàn bộ mục P0 hoàn tất.

---

## 6) Cổng quyết định merge cho Leader

Cho phép chuyển từ **Changes requested** sang **Approved** khi đồng thời đạt:
1. Không còn test fail trong `mobile/test`.
2. Case test provider đã khớp contract mới (không còn fail do fixture cũ).
3. Có bằng chứng test pass được đính kèm trong PR.
4. Không còn lỗi P0.

---

## 7) Chốt điều phối

Sơn đang đi đúng hướng về logic tích hợp Home và chuẩn hóa dữ liệu. Điểm nghẽn còn lại chủ yếu nằm ở **độ tin cậy của test độc lập**. Ưu tiên cao nhất hiện tại là khóa lại bộ test provider/model để tạo nền an toàn trước khi team bước sang tích hợp API thật trên dev.
