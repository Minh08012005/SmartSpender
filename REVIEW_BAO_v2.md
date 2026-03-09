# 📋 Review lần 2: Task của Vũ Nguyễn Ngọc Bảo — [BE] Basic CRUD Transaction & Documentation #33

> **Sprint 2** · 10/02 – 20/02/2026  
> **Trạng thái hiện tại:** 🔄 In Progress

---

## ✅ Đánh giá các thay đổi trong PR #56

### 1. **Thay đổi đã thực hiện**

| #   | Hạng mục                                                                      | Trạng thái    |
| --- | ----------------------------------------------------------------------------- | ------------- |
| ✅  | Thêm route `DELETE /api/transactions/:id` với middleware `authenticate`       | Đã hoàn thành |
| ✅  | Import controller `deleteTransaction` vào `transaction_routes.js`             | Đã hoàn thành |
| ✅  | Thêm Swagger docs cho endpoint DELETE với response examples (200/400/401/404) | Đã hoàn thành |
| ✅  | Thêm file `TASK_BAO.md` với checklist chi tiết cho các pha còn lại            | Đã hoàn thành |

### 2. **Nhận xét chi tiết**

#### 2.1 Route `DELETE /api/transactions/:id`

- **Ưu điểm:**
  - Route đã được đăng ký đầy đủ với middleware `authenticate` và validation `objectIdParamSchema`.
  - Controller `deleteTransaction` được import và sử dụng đúng cách.
  - Service `deleteTransaction()` đã xử lý logic xóa giao dịch, bao gồm kiểm tra quyền sở hữu và xóa giao dịch.
  - Swagger documentation đã được cập nhật đầy đủ với các response examples (200/400/401/404).

- **Cần cải thiện:**
  - **Test thủ công:**
    - Chưa có thông tin xác nhận rằng các test thủ công đã được thực hiện. Bảo cần thực hiện các bước test sau:
      1. Gửi request với ID hợp lệ và token hợp lệ → Kỳ vọng trả về `200`.
      2. Gửi request với ID không hợp lệ → Kỳ vọng trả về `400`.
      3. Gửi request với ID hợp lệ nhưng không tồn tại → Kỳ vọng trả về `404`.
      4. Gửi request không có Bearer token → Kỳ vọng trả về `401`.
  - **Test ownership:**
    - Đăng nhập user A, tạo transaction.
    - Đăng xuất, đăng nhập user B.
    - Cố gắng DELETE transaction của user A bằng user B token → Kỳ vọng trả về `404` (không `403`, vì lý do bảo mật).

#### 2.2 Middleware `authenticate`

- **Ưu điểm:**
  - Middleware `authenticate` đã được áp dụng cho tất cả các route (`GET`, `POST`, `PUT`, `DELETE`).

- **Cần cải thiện:**
  - Xác nhận rằng middleware `authenticate` hoạt động đúng cách:
    - Đảm bảo `req.user._id` được truyền đúng vào service layer ở tất cả các endpoint (`getTransactions`, `createTransaction`, `updateTransaction`, `deleteTransaction`).
    - Kiểm tra logic ownership: User A không thể truy cập hoặc chỉnh sửa giao dịch của User B.

#### 2.3 Swagger Documentation

- **Ưu điểm:**
  - Swagger documentation đã được cập nhật đầy đủ cho endpoint `DELETE /api/transactions/:id`.

- **Cần cải thiện:**
  - Kiểm tra lại Swagger UI để đảm bảo các thông tin (summary, parameters, responses) hiển thị chính xác.

#### 2.4 Unit Test

- **Cần thực hiện:**
  - Viết unit test cho các hàm trong service layer (`createTransaction`, `updateTransaction`, `deleteTransaction`).
  - Viết unit test cho các schema validator (`createTransactionSchema`, `updateTransactionSchema`, `objectIdParamSchema`).

---

## 🚧 Các vấn đề cần xử lý tiếp

### 1. **Kiểm tra và xác nhận hoạt động của endpoint DELETE**

- **Hướng dẫn xử lý:**
  - Sử dụng Postman để thực hiện các test thủ công như đã liệt kê ở phần trên.
  - Đảm bảo tất cả các trường hợp đều trả về response đúng như kỳ vọng.

### 2. **Kiểm tra middleware `authenticate`**

- **Hướng dẫn xử lý:**
  - Đọc lại code trong `auth.middleware.js` để đảm bảo middleware kiểm tra đúng quyền sở hữu.
  - Thực hiện test thủ công với các trường hợp:
    - User A tạo transaction → User B cố gắng truy cập hoặc chỉnh sửa transaction đó.
    - Đảm bảo trả về `404` thay vì `403`.

### 3. **Viết Unit Test**

- **Hướng dẫn xử lý:**
  - Tạo file test cho service layer (`transaction.service.test.js`) và validator (`transaction.validator.test.js`).
  - Sử dụng thư viện `jest` để viết các test case.
  - Các test case cần bao gồm:
    - **Service layer:**
      - `createTransaction()`: Test các trường hợp thành công và thất bại (ví dụ: thiếu trường bắt buộc, giá trị không hợp lệ).
      - `updateTransaction()`: Test cập nhật thành công và các lỗi (transaction không tồn tại, không thuộc user).
      - `deleteTransaction()`: Test xóa thành công và các lỗi (transaction không tồn tại, không thuộc user).
    - **Validator:**
      - `createTransactionSchema`: Test validation pass/fail với các trường hợp hợp lệ và không hợp lệ.
      - `updateTransactionSchema`: Test validation khi chỉ gửi một số trường (ví dụ: chỉ gửi `note`).
      - `objectIdParamSchema`: Test pass/fail với ObjectId hợp lệ và không hợp lệ.

### 4. **Xuất bản tài liệu API**

- **Hướng dẫn xử lý:**
  - Chạy server local (`npm run dev`) và kiểm tra Swagger UI tại `http://localhost:5000/api-docs`.
  - Xuất file `swagger.json` hoặc `swagger.yaml` và chia sẻ với team Mobile.
  - Thông báo cho Sơn và Đức Anh về cấu trúc response của endpoint `DELETE` để họ tích hợp API.

---

## 📌 Kết luận

- Bảo đã hoàn thành phần lớn công việc coding cho endpoint `DELETE /api/transactions/:id`.
- Tuy nhiên, cần thực hiện thêm các bước kiểm tra và viết unit test để đảm bảo chất lượng code.
- Hãy thực hiện các bước hướng dẫn trên để hoàn thiện task và sẵn sàng merge vào nhánh `dev`. Nếu có bất kỳ thắc mắc nào, hãy liên hệ để được hỗ trợ thêm.
