# 📋 Review lần 3: Góp ý hoàn thiện task của Vũ Nguyễn Ngọc Bảo — [BE] Basic CRUD Transaction & Documentation #33

> **Sprint 2** ·
> **Trạng thái hiện tại:** 🔄 In Progress

---

## ✅ Đánh giá kết quả kiểm tra Postman

### 1. **Kết quả kiểm tra Postman**

#### 1.1 Test thủ công DELETE endpoint

- **Đã thực hiện:**
  - Gửi request với ID hợp lệ và token hợp lệ → Trả về `200` (✅ Đúng như kỳ vọng).
  - Gửi request với ID không hợp lệ → Trả về `400` với thông báo lỗi `Validation failed` (✅ Đúng như kỳ vọng).
  - Gửi request với ID hợp lệ nhưng không tồn tại → Trả về `404` với thông báo `Transaction not found or permission denied` (✅ Đúng như kỳ vọng).
  - Gửi request không có Bearer token → Trả về `401` với thông báo `Access token required` (✅ Đúng như kỳ vọng).

- **Nhận xét:**
  - Các test thủ công đã được thực hiện đầy đủ và đạt yêu cầu.

#### 1.2 Test ownership (kiểm tra quyền sở hữu)

- **Đã thực hiện:**
  - User A tạo transaction.
  - User B cố gắng xóa transaction của User A bằng token của mình → Trả về `404` (✅ Đúng như kỳ vọng, đảm bảo bảo mật).

- **Nhận xét:**
  - Logic kiểm tra quyền sở hữu đã được kiểm tra và hoạt động đúng.

---

## 🚧 Các vấn đề cần xử lý tiếp

### 1. **Viết Unit Test**

- **Cần thực hiện:**
  - Viết unit test cho các hàm trong service layer (`createTransaction`, `updateTransaction`, `deleteTransaction`).
  - Viết unit test cho các schema validator (`createTransactionSchema`, `updateTransactionSchema`, `objectIdParamSchema`).

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

### 2. **Kiểm tra Swagger Documentation**

- **Cần thực hiện:**
  - Kiểm tra lại Swagger UI để đảm bảo các thông tin (summary, parameters, responses) hiển thị chính xác.
  - Bổ sung query parameters cho `GET /transactions`:
    ```yaml
    parameters:
      - in: query
        name: page
        schema:
          type: integer
          minimum: 1
          default: 1
        description: "Số trang"
      - in: query
        name: limit
        schema:
          type: integer
          minimum: 1
          maximum: 100
          default: 20
        description: "Số lượng bản ghi mỗi trang"
      - in: query
        name: sortBy
        schema:
          type: string
          enum: [date, amount, category, createdAt]
          default: date
        description: "Trường sắp xếp"
      - in: query
        name: filter
        schema:
          type: string
        description: "Bộ lọc (ví dụ: category=food)"
    ```
  - Thêm ví dụ cho response `404` trong `GET /transactions/{id}`:
    ```yaml
    "404":
      description: Not found
      content:
        application/json:
          schema:
            type: object
            properties:
              success:
                type: boolean
                example: false
              statusCode:
                type: integer
                example: 404
              message:
                type: string
                example: "Transaction not found"
          example:
            success: false
            statusCode: 404
            message: "Transaction not found"
    ```

### 3. **Xuất bản tài liệu API**

- **Cần thực hiện:**
  - Chạy server local (`npm run dev`) và kiểm tra Swagger UI tại `http://localhost:5000/api-docs`.
  - Xuất file `swagger.json` hoặc `swagger.yaml` và chia sẻ với team Mobile.
  - Thông báo cho Sơn và Đức Anh về cấu trúc response của endpoint `DELETE` để họ tích hợp API.

---

## 📌 Kết luận

- Bảo đã hoàn thành phần lớn công việc coding và kiểm tra thủ công cho endpoint `DELETE /api/transactions/:id`.
- Tuy nhiên, cần thực hiện thêm các bước kiểm tra unit test và hoàn thiện tài liệu Swagger để đảm bảo chất lượng code và tài liệu API.
- Hãy thực hiện các bước hướng dẫn trên để hoàn thiện task và sẵn sàng merge vào nhánh `dev`. Nếu có bất kỳ thắc mắc nào, hãy liên hệ để được hỗ trợ thêm.
