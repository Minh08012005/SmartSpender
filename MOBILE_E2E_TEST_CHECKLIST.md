# HƯỚNG DẪN TEST MOBILE API CHO ĐỨC ANH

Ngày cập nhật: 23/03/2026
Mục tiêu: Đức Anh test toàn bộ luồng mobile gọi API thật, ghi kết quả rõ ràng để Leader chốt sprint.

---

## 1. PHÂN VAI

- Đức Anh: test mobile app theo từng bước bên dưới, ghi PASS/FAIL.
- Sơn: sửa lỗi mobile nếu Đức Anh báo FAIL (UI, state, parse, flow).
- Leader: đối soát API/DB và chốt kết quả cuối buổi.

---

## 2. ĐẦU VÀO BẮT BUỘC (LEADER GỬI CHO ĐỨC ANH)

Đức Anh chỉ bắt đầu test khi đã có đủ 4 thông tin sau:

1. Base URL đang dùng

- Ví dụ: ngrok hoặc localhost.

2. Tài khoản test

- email:
- password:

3. Backend status

- Backend đang chạy ổn định, không lỗi server.

4. Scope test hôm nay

- Login -> Create -> Read -> Update -> Delete -> Error cơ bản.

---

## 3. CHUẨN BỊ MÔI TRƯỜNG MOBILE

### Bước M0 - Setup app

- [ ] Cập nhật đúng base URL trong app config.
- [ ] Chạy `flutter clean`.
- [ ] Chạy `flutter pub get`.
- [ ] Chạy `flutter run`.
- [ ] App mở được màn hình Login.

Mẫu ghi kết quả:

```text
[M0] PASS/FAIL:
- Mô tả ngắn: ...
- Screenshot (nếu FAIL): ...
```

Nếu FAIL:

- Gửi log flutter run + screenshot cho Sơn và Leader.
- Không qua bước tiếp theo khi app chưa mở được.

---

## 4. TEST FLOW CHI TIẾT CHO ĐỨC ANH

## Bước M1 - Login

Thao tác:

1. Nhập email/password test.
2. Bấm Login.

Kỳ vọng:

- [ ] Đăng nhập thành công.
- [ ] Không crash.
- [ ] Chuyển vào HomeScreen.

Mẫu ghi kết quả:

```text
[M1-LOGIN] PASS/FAIL:
- Thực tế: ...
- Lỗi (nếu có): ...
- Screenshot/Video: ...
```

---

## Bước M2 - Create transaction

Thao tác:

1. Bấm nút thêm transaction.
2. Nhập dữ liệu mẫu:

- title: Lunch Test
- amount: 50000
- type: expense
- category: food
- note: smoke test

3. Bấm Save.

Kỳ vọng:

- [ ] Hiện thông báo thành công.
- [ ] Quay lại danh sách.
- [ ] Không crash.

Mẫu ghi kết quả:

```text
[M2-CREATE] PASS/FAIL:
- Dữ liệu đã nhập: Lunch Test, 50000, expense, food
- Kết quả thực tế: ...
- Screenshot (nếu FAIL): ...
```

---

## Bước M3 - Read transaction

Thao tác:

1. Kiểm tra trên HomeScreen có item vừa tạo.
2. Kéo để refresh (pull-to-refresh).

Kỳ vọng:

- [ ] Item Lunch Test hiển thị đúng.
- [ ] Refresh hoạt động.

Mẫu ghi kết quả:

```text
[M3-READ] PASS/FAIL:
- Có thấy item hay không: ...
- Refresh: ...
- Screenshot (nếu FAIL): ...
```

---

## Bước M4 - Update transaction

Thao tác:

1. Mở màn hình sửa của item vừa tạo.
2. Sửa:

- title -> Lunch Test Updated
- amount -> 70000

3. Bấm Update.

Kỳ vọng:

- [ ] Cập nhật thành công.
- [ ] Danh sách hiện title/amount mới.

Mẫu ghi kết quả:

```text
[M4-UPDATE] PASS/FAIL:
- Dữ liệu mới: Lunch Test Updated, 70000
- Kết quả thực tế: ...
- Screenshot (nếu FAIL): ...
```

---

## Bước M5 - Delete transaction

Thao tác:

1. Xóa item vừa sửa (swipe, long-press, hoặc nút xóa).
2. Xác nhận xóa nếu có dialog.

Kỳ vọng:

- [ ] Xóa thành công.
- [ ] Item biến mất khỏi danh sách.

Mẫu ghi kết quả:

```text
[M5-DELETE] PASS/FAIL:
- Cách xóa đã dùng: ...
- Kết quả thực tế: ...
- Screenshot (nếu FAIL): ...
```

---

## Bước M6 - Error handling cơ bản

Thao tác:

1. Leader tạm dừng backend.
2. Đức Anh thử tạo transaction.

Kỳ vọng:

- [ ] App hiện lỗi dễ hiểu.
- [ ] Không crash.

Mẫu ghi kết quả:

```text
[M6-ERROR] PASS/FAIL:
- Nội dung thông báo lỗi: ...
- Có dễ hiểu không: CÓ/KHÔNG
- Screenshot: ...
```

---

## 5. MẪU BÁO LỖI CHUẨN (BẮT BUỘC KHI FAIL)

Khi có FAIL, Đức Anh gửi đúng mẫu này để Sơn sửa nhanh:

```text
[CASE ID]: Mx-...
[Bước lỗi]: M1/M2/M3/M4/M5/M6
[Môi trường]: localhost/ngrok
[Bước tái hiện]:
1) ...
2) ...
3) ...

[Kỳ vọng]:
- ...

[Thực tế]:
- ...

[Bằng chứng]:
- screenshot: ...
- video (nếu có): ...
- log flutter run: ...

[Mức độ]: Critical/Major/Minor
[Owner sửa]: Sơn (mobile) hoặc Leader/Backend (nếu nghi API)
[Trạng thái]: Open/Fixed/Retest Pass/Retest Fail
```

---

## 6. LUỒNG PHỐI HỢP KHI PHÁT SINH LỖI

1. Đức Anh báo lỗi theo mẫu ở mục 5.
2. Sơn nhận lỗi và sửa phần mobile.
3. Đức Anh re-test đúng case đó.
4. Nếu pass, đánh dấu "Retest Pass".
5. Nếu fail tiếp, gửi lại log mới và Sơn sửa tiếp.
6. Leader cập nhật bảng tổng hợp và chốt cuối buổi.

---

## 7. BẢNG TỔNG HỢP ĐỂ CHỐT

```text
M0-SETUP:   PASS/FAIL
M1-LOGIN:   PASS/FAIL
M2-CREATE:  PASS/FAIL
M3-READ:    PASS/FAIL
M4-UPDATE:  PASS/FAIL
M5-DELETE:  PASS/FAIL
M6-ERROR:   PASS/FAIL

OVERALL: DEMO READY / NEED FIX / NOT READY
```

Điều kiện chốt "Demo Ready":

- Tất cả M1-M5 PASS.
- Không còn lỗi Critical.
- Các lỗi còn lại (nếu có) chỉ ở mức Minor.

---

## 8. BIÊN BẢN CUỐI BUỔI

Leader: ********\_\_\_\_********
Đức Anh (mobile test): ********\_\_\_\_********
Sơn (mobile fix): ********\_\_\_\_********
Ngày: \_**\_ / \_\_** / **\_\_**
Tổng thời gian test: **\_\_** giờ
Kết luận: [Demo Ready / Need Fix / Not Ready]
