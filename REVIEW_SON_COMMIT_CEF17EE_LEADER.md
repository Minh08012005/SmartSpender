# Đánh giá commit mới của Sơn Mobile (cef17ee)

## 1) Bối cảnh đánh giá

Mục tiêu: kiểm tra commit mới sau review gần nhất của Leader, xem Sơn đã xử lý đúng các vấn đề đã giao chưa, và mức sẵn sàng để merge vào dev phục vụ tích hợp Backend <-> Mobile Sprint 2.

Commit được review: `cef17ee` (nhánh `feature/home-integration`).

Phạm vi thay đổi trong commit:

- [mobile/lib/data/models/transaction_model.dart](mobile/lib/data/models/transaction_model.dart)
- [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart)
- [mobile/test/transaction_provider_test.dart](mobile/test/transaction_provider_test.dart)
- [mobile/.metadata](mobile/.metadata)

---

## 2) Kết luận nhanh cho Leader

Trạng thái tổng quan: ĐÃ CẢI THIỆN TỐT, có thể tiến gần bước merge, nhưng vẫn còn 2 điểm nên chốt lại để tránh rủi ro tích hợp thật.

Điểm mạnh nhất của commit này:

1. Đã xử lý để bộ test Mobile pass lại.
2. Đã làm rõ validate dữ liệu trong model.
3. Đã cập nhật test theo contract parse hiện tại của provider.

Tín hiệu xác minh:

- Chạy test trọng tâm: `flutter test test/transaction_provider_test.dart test/transaction_model_test.dart` -> pass.
- Chạy full test mobile: `flutter test` -> pass.

---

## 3) Đối chiếu trực tiếp với các vấn đề Leader đã giao trước đó

## F1 - Mismatch category Mobile/Backend

Kết quả hiện tại: Đã xử lý đúng hướng.

Bằng chứng:

- Danh mục đã dùng `other` cho cả income/expense tại [mobile/lib/data/models/transaction_model.dart#L9](mobile/lib/data/models/transaction_model.dart#L9).
- Có normalize tương thích dữ liệu cũ `other income`/`other expense` -> `other` tại [mobile/lib/data/models/transaction_model.dart#L141](mobile/lib/data/models/transaction_model.dart#L141).

Đánh giá cho leader:

- Rủi ro lỗi 400 do category đã giảm mạnh.

---

## F2 - Fallback amount gây sai số liệu

Kết quả hiện tại: Đã xử lý.

Bằng chứng:

- Parse amount không fallback 1.0 nữa, thay bằng throw rõ ràng tại [mobile/lib/data/models/transaction_model.dart#L101](mobile/lib/data/models/transaction_model.dart#L101).

Đánh giá cho leader:

- Giảm nguy cơ dữ liệu sai âm thầm khi backend trả payload lỗi.

---

## F3 - Home hiển thị title thay vì category

Kết quả hiện tại: Đã xử lý từ các commit trước và vẫn giữ đúng.

Bằng chứng:

- Hiển thị title làm dòng chính tại [mobile/lib/views/home/widgets/transaction_item.dart#L35](mobile/lib/views/home/widgets/transaction_item.dart#L35).
- Dòng phụ là category + date tại [mobile/lib/views/home/widgets/transaction_item.dart#L45](mobile/lib/views/home/widgets/transaction_item.dart#L45).

Đánh giá cho leader:

- UX danh sách giao dịch đúng ngữ nghĩa hơn, dễ review nghiệp vụ hơn.

---

## F4 - Message lỗi fetch/provider chưa thân thiện

Kết quả hiện tại: Đã cải thiện một phần, nhưng có điểm cần theo dõi.

Bằng chứng:

- Nhánh DioException đã dùng trích xuất message API thân thiện tại [mobile/lib/data/providers/transaction_provider.dart#L153](mobile/lib/data/providers/transaction_provider.dart#L153).
- Tuy nhiên các nhánh catch tổng quát đang dùng `e.toString()` tại [mobile/lib/data/providers/transaction_provider.dart#L160](mobile/lib/data/providers/transaction_provider.dart#L160), [mobile/lib/data/providers/transaction_provider.dart#L208](mobile/lib/data/providers/transaction_provider.dart#L208), [mobile/lib/data/providers/transaction_provider.dart#L242](mobile/lib/data/providers/transaction_provider.dart#L242), [mobile/lib/data/providers/transaction_provider.dart#L310](mobile/lib/data/providers/transaction_provider.dart#L310).

Đánh giá cho leader:

- Có thể pass test, nhưng text lỗi hiển thị cho user có thể vẫn mang tính kỹ thuật.

---

## F5 - TODO mơ hồ trong Home

Kết quả hiện tại: Không còn dấu hiệu TODO mơ hồ ở Home như review trước.

Tham chiếu:

- [mobile/lib/views/home/home_screen.dart](mobile/lib/views/home/home_screen.dart)

---

## 4) Điểm mới phát sinh từ commit này (Leader cần nắm)

### A. Test đã pass nhưng có xu hướng "điều chỉnh để khớp test" thay vì tăng coverage

Quan sát:

- Một số case test bị loại bỏ (ví dụ missing title ở provider-level), và một số assert bị giảm độ chặt.
- Test đã được sửa để khớp contract parse mới, bao gồm thêm `_id` vào mock payload tại [mobile/test/transaction_provider_test.dart#L52](mobile/test/transaction_provider_test.dart#L52), [mobile/test/transaction_provider_test.dart#L122](mobile/test/transaction_provider_test.dart#L122).

Rủi ro:

- Tín hiệu test đã xanh, nhưng độ bao phủ hành vi lỗi có thể mỏng hơn trước.

### B. Model gửi `_id` trong `toJson`

Quan sát:

- Commit thêm `_id` vào payload gửi API tại [mobile/lib/data/models/transaction_model.dart#L80](mobile/lib/data/models/transaction_model.dart#L80).

Rủi ro cần xác nhận:

- Với API create/update hiện tại, cần thống nhất backend có chấp nhận bỏ qua `_id` hay không.
- Nếu backend không mong đợi field này, có thể phát sinh lỗi validation khi tích hợp thật.

### C. File môi trường Flutter bị đưa vào commit

Quan sát:

- [mobile/.metadata](mobile/.metadata) thay đổi danh sách platform migration.

Đánh giá:

- Không ảnh hưởng logic nghiệp vụ, nhưng là thay đổi kỹ thuật không cần thiết cho feature.

---

## 5) Khuyến nghị hành động trước khi merge dev

## Bắt buộc (nên làm ngay)

1. Xác nhận lại contract với backend về `_id` trong body create/update.
2. Nếu backend không yêu cầu, bỏ `_id` khỏi `toJson` để tránh payload dư.
3. Bổ sung lại ít nhất 1-2 test negative quan trọng đã mất (để tránh xanh giả).

## Nên làm để ổn định UX

1. Chuẩn hóa message lỗi nhánh catch tổng quát theo format thân thiện, không lộ chuỗi kỹ thuật.
2. Giữ logging kỹ thuật ở debugPrint, nhưng message UI nên ngắn gọn và nhất quán.

## Quy trình

1. Sau khi chỉnh các điểm trên, chạy lại full mobile test và đính kèm log trong PR comment.
2. Trả lời từng mục theo format: `Fixed` hoặc `Won't fix` + lý do.

---

## 6) Đề xuất quyết định cho Leader

Khuyến nghị hiện tại: **Giữ Changes requested nhẹ (final round)**.

Điều kiện chuyển sang Approved:

1. Chốt rõ vấn đề `_id` với backend (và sửa nếu cần).
2. Bổ sung lại test negative tối thiểu để tránh giảm chất lượng kiểm thử.
3. Có bằng chứng chạy test pass sau chỉnh sửa cuối.

Nếu Sơn hoàn tất đủ 3 điều kiện trên, nhánh này có thể xem là đủ an toàn để merge dev cho giai đoạn tích hợp thật Sprint 2.
