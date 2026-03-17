# Bao Follow-up Guide: Hoàn thiện task chính và bước kế tiếp cho Create

## Bối cảnh ngắn gọn

Nhánh backend hiện tại đã đi đến giai đoạn đủ mạnh để tích hợp mobile ở các luồng GET, PUT, DELETE.
Mục tiêu còn lại để chốt chất lượng CRUD trọn vẹn là bổ sung integration test cho Create (`POST /api/transactions`) theo chuẩn đang áp dụng cho PUT/DELETE.

---

## Những phần Bảo đã hoàn thiện tốt trong task chính

### Ổn định CRUD cốt lõi

Bảo đã xử lý chắc các hành vi quan trọng của CRUD ở mức backend runtime:

- Luồng Update có đầy đủ behavior cho success, partial update, validation fail và ownership.
- Luồng Delete có đầy đủ behavior cho success, not found/not owner, invalid id và auth fail.
- Các tình huống token thiếu/sai/hết hạn đã được xử lý nhất quán ở các endpoint chính.

### Đóng các rủi ro chất lượng cao ở GET

Bảo đã xử lý các điểm trước đó có nguy cơ gây mismatch integration với mobile:

- Đồng bộ normalize query filter ở boundary để tránh sai khác hoa/thường giữa client và backend.
- Chốt semantics `to=YYYY-MM-DD` theo cuối ngày để tránh hụt dữ liệu ở ngày biên.
- Đồng bộ tài liệu API với hành vi runtime ở các điểm liên quan GET contract.

### Tăng độ tin cậy của test hiện có

- Unit test validator/service đã bao phủ tốt các rule chính.
- Integration test hiện có cho GET/PUT/DELETE đã đủ để phát hiện regression quan trọng.

---

## Điểm còn cần xử lý thêm

Khoảng trống chính hiện tại không phải bug runtime, mà là khoảng trống kiểm thử tự động:

- Chưa có integration test cho `POST /api/transactions` theo cùng mức độ chặt chẽ như PUT/DELETE.

Điều này ảnh hưởng đến mức độ tự tin khi merge dài hạn, vì endpoint Create vẫn thiếu lớp xác nhận end-to-end ở HTTP layer.

---

## Cách Bảo nên tự triển khai test Create

## Mục tiêu của bộ test

Bộ test Create cần chứng minh 3 thứ cùng lúc:

- API tạo transaction đúng khi dữ liệu hợp lệ.
- API trả đúng status/message khi dữ liệu không hợp lệ.
- API giữ đúng contract auth và response shape cho mobile.

## Nên bám theo pattern nào

- Dùng cùng cấu trúc đã có ở test PUT/DELETE để đảm bảo đồng nhất style của team.
- Tái sử dụng setup token, dữ liệu test, cách assert response envelope đang dùng ở integration hiện tại.
- Giữ naming test case gần checklist issue để leader dễ đối chiếu khi review.

## Bộ case tối thiểu nên có

### Nhóm thành công

- Tạo transaction hợp lệ trả 201.
- Response có đủ envelope chuẩn (`success`, `statusCode`, `message`, `data`).
- Dữ liệu tạo ra phản ánh đúng các field quan trọng (amount, type, category, date, note).

### Nhóm validation fail

- Thiếu field bắt buộc.
- `amount` âm hoặc sai kiểu.
- `category` không thuộc allow-list.
- `type` không hợp lệ.
- `date` sai format.

### Nhóm auth fail

- Không token.
- Token sai.
- Token hết hạn.

### Nhóm dữ liệu/contract

- Kiểm tra field trả về không bị lệch so với contract đã chốt.
- Nếu có normalize ở input (type/category), xác nhận output cuối cùng nhất quán với behavior mong muốn.

---

## Cách tự kiểm tra chất lượng sau khi viết test

- Chạy riêng file test Create trước để debug nhanh.
- Chạy lại trọn bộ CRUD integration để chắc chắn không phá vỡ test cũ.
- Đối chiếu lại với Swagger và checklist issue để bảo đảm test phản ánh đúng contract.

Khi gửi PR, nên đính kèm:

- Danh sách case đã thêm.
- Kết quả chạy test (pass/fail) cho từng nhóm case.
- Ghi chú rõ endpoint Create hiện đã đạt mức coverage integration tương đương PUT/DELETE.

---

## Kỳ vọng đầu ra cho vòng kế tiếp

Sau khi bổ sung xong phần này, backend CRUD sẽ đạt trạng thái “đủ tự tin để freeze integration” vì cả 4 endpoint chính (GET, POST, PUT, DELETE) đều có lớp integration test tương ứng.
