**Review cập nhật (Yêu cầu hành động cho Sơn - mobile)**

**Tóm tắt nhanh:**

- Tôi đã xem hai commit gần nhất của bạn trên nhánh `docs/diagrams`. Cảm ơn đã cập nhật — nhiều điểm chính trong review trước đã được xử lý (endpoint {id}, ownership check, wallet update, error cases, client notify).

**Yêu cầu tiếp theo (bắt buộc/ưu tiên) để biểu đồ chính thức hoàn thiện:**

1. Chuẩn hoá tên file (đã yêu cầu và tôi đã đổi):
   - `sequence_crud_transaction.png` — sequence CRUD giao dịch
   - `activity_create_transaction.png` — activity Create Transaction
   - `use_case_diagram.png` — use case (giữ nguyên)

2. Thêm file nguồn editable (bắt buộc):
   - Push file nguồn của diagram (Mermaid `.mmd`, draw.io `.drawio`/`.xml`, hoặc file gốc tool khác) vào `docs/diagrams/sources/`.
   - Lý do: PNG khó sửa nhãn; source cho phép chỉnh sửa nhanh cho báo cáo và reviewer.

3. Update Use Case label: đổi "Xem báo cáo" thành **"Xem Thống kê (Statistics)"** nếu tính năng chỉ là hiển thị thống kê từ `/api/statistics/summary`.
   - Nếu product yêu cầu export (PDF/CSV), tạo Issue mới và implement API `GET /api/reports/...` + UI action để tải.

4. Ảnh chất lượng cho báo cáo: export SVG hoặc PNG 300–600 dpi; lưu tại `docs/diagrams/hires/`.

5. Chú thích (caption) cho mỗi ảnh: thêm 1-2 dòng caption ngay trong `docs/diagrams/readme.md` ví dụ:
   - `sequence_crud_transaction.png`: "Sequence cho Create/Update/Delete. Endpoints: POST /api/transactions, PUT/DELETE /api/transactions/{id}. Errors: 400/401/404/500"

6. Kiểm tra final trên code (dev):
   - Confirm ownership check xảy ra trước DB mutation (đã thể hiện) và trả 404 khi mismatch.
   - Confirm wallet rollback khi update (đã thể hiện trong diagram) — nếu service thực sự rollback, note trong diagram.

**Checklist (hãy commit trả lời vào branch này khi hoàn tất):**

- [ ] Đã push files nguồn vào `docs/diagrams/sources/`
- [ ] Đã export SVG/hi-res PNG vào `docs/diagrams/hires/`
- [ ] Đã cập nhật Use Case label thành "Xem Thống kê (Statistics)"
- [ ] Đã cập nhật `docs/diagrams/readme.md` với caption ngắn cho mỗi ảnh
- [ ] Ghi commit message ngắn giải thích mỗi thay đổi (ví dụ: `docs/diagrams: add sources + rename files + export svg`)

**Ghi chú cho bạn (Leader):**

- Sau khi Sơn hoàn tất checklist, biểu đồ có thể merge vào branch chính để chèn vào slide/word report.

Hãy Sơn thực hiện các mục trên và thông báo lại tại đây, tôi sẽ re-check nhanh trong vòng 1 giờ.

Thân,
Reviewer
**Review Diagrams (Feedback cho Sơn - mobile)**

**Tóm tắt:**

- Người review: Backend/Integration
- Mục tiêu: Kiểm tra ba sơ đồ Sơn đã thêm (Use Case, Sequence: CRUD Transaction, Activity: Statistics) so với code hiện tại, chỉ ra điểm chưa khớp và gợi ý cách sửa để biểu đồ phản ánh đúng logic ứng dụng.

**1) Tổng quan nhanh**

- **Status:** Biểu đồ đã nắm được luồng chính (UI → Provider → Service → API) và luồng xác thực JWT.
- **Cần bổ sung:** chi tiết ownership check, cập nhật wallet balance khi tạo/sửa/xóa giao dịch, và các trường hợp lỗi (400/404) trong biểu đồ sequence và activity.

**2) Sai lệch cụ thể & Gợi ý sửa (Sequence: CRUD Transaction)**

- **Endpoint path:** Hiện biểu đồ ghi POST/PUT/DELETE /api/transactions. Trong code thực tế, PUT và DELETE đều yêu cầu id: phải là /api/transactions/{id}. Hãy sửa label action tương ứng.
  - File tham khảo: [backend/routes/transaction_routes.js](backend/routes/transaction_routes.js)

- **Ownership check thiếu trong diagram:** Service kiểm tra ownership (userId) trước khi update/delete. Nếu không khớp sẽ trả 404 (không chép trực tiếp 403 để tránh lộ existence). Thêm một bước sau Verify JWT: "Ownership check (transaction.userId === req.user.\_id) → 404 nếu không đúng".
  - File tham khảo: [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js)

- **Wallet balance update (business logic) chưa thể hiện:** Khi tạo/sửa/xóa transaction, backend cập nhật wallet balance (apply delta, reject nếu balance âm). Thêm vào diagram luồng từ Transaction Service → Wallet Service/Model: "calculateDelta -> applyWalletDelta -> save wallet" và include branch khi insufficient balance → trả 400.
  - File tham khảo: [backend/services/transaction.service.js](backend/services/transaction.service.js)

- **Các HTTP error cases:** Hiện chỉ có 200/401 trên diagram; cần thêm ít nhất:
  - 400: validation errors (invalid amount/type/category, invalid date)
  - 404: transaction not found / ownership mismatch
  - 500: internal error (tóm tắt)

- **UI/Provider reaction:** Sau Response 200 diagram nên thể hiện notifyListeners()/state update (Provider) — mobile code dùng notifyListeners() sau khi cập nhật danh sách.
  - File tham khảo: [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart)

**3) Sai lệch cụ thể & Gợi ý sửa (Activity: Statistics)**

- **Endpoint đúng:** GET /api/statistics/summary — đúng với route, nhưng kiểm tra kỹ 'statistics' (plural) trong label.
  - File tham khảo: [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js)

- **Validation input:** API yêu cầu month và year (validator). Nếu thiếu/không hợp lệ sẽ trả 400 — biểu đồ cần có branch cho validation error trước khi gọi backend hoặc hiển thị lỗi 400 khi backend trả.

- **Response structure:** Thêm mô tả ngắn về cấu trúc JSON trả về (success, statusCode, message, data:{ totalIncome, totalExpense, balance }) để người đọc báo cáo hiểu dữ liệu được dùng để render Pie/Bar charts.
  - File tham khảo: [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js)

**4) Use Case Diagram (góc độ nhỏ):**

- Use Case nhìn chung hợp lý (User: Login, Manage Transactions, View Statistics). Kiểm tra thêm include/extend chi tiết:
  - Include: Validate form trước khi submit (mobile có validate trước khi gọi API)
  - Extend: Token expired flow hướng dẫn re-login (ở sequence/auth hoặc auth shared diagram đã có) — nếu use case thiếu, gợi ý thêm vào.

**Lưu ý quan trọng:**

- Trong code hiện tại **không thấy** endpoint hoặc module riêng cho chức năng "Xem báo cáo" (report). Thay vào đó backend có endpoint thống kê là `/api/statistics/summary` dùng để lấy dữ liệu render biểu đồ (Pie/Bar). Nếu task ban đầu yêu cầu "Xem báo cáo" với nghĩa xuất file (PDF/CSV) hoặc một màn hình báo cáo chi tiết khác, cần:
  1. Cập nhật requirement/task để làm rõ tính năng (export hay chỉ hiển thị thống kê).
  2. Nếu cần export, bổ sung API ở backend (ví dụ `GET /api/reports/monthly?month=...&year=...`) và tương ứng UI/mobile để tải file.
  3. Nếu chỉ hiển thị thống kê thì chỉnh lại Use Case label thành "Xem Thống kê (Statistics)" để khớp với implementation hiện có.

**5) Gợi ý trực tiếp cho Sơn (về phần vẽ):**

- Trong Sequence: sửa label HTTP method + path chính xác (thêm {id} cho PUT/DELETE).
- Thêm bước "Ownership check" và "Wallet update" trong alt block khi JWT hợp lệ.
- Thêm các trường hợp lỗi 400 và 404, và annotate nguyên nhân (ví dụ: 400 = invalid amount / insufficient balance; 404 = not found/ownership).
- Trong Activity (Statistics): thêm node cho validation (month/year) và note cấu trúc response JSON cho chart rendering.
- Giữ nhãn rõ ràng: "Authorization: Bearer <token>" thay vì chỉ "JWT" để dễ đọc cho người chấm báo cáo.

**6) Ví dụ sửa nhỏ (text to replace trên diagram):**

- Thay PUT /api/transactions → PUT /api/transactions/{id}
- Thay DELETE /api/transactions → DELETE /api/transactions/{id}
- Thêm annotation sau Verify JWT: → Ownership check (if fail: 404)
- Thêm call: Transaction Service → Wallet Service: applyDelta (if negative balance → 400)

**7) Tài liệu tham khảo code (để Sơn kiểm tra lại):**

- [backend/middleware/auth.middleware.js](backend/middleware/auth.middleware.js)
- [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js)
- [backend/services/transaction.service.js](backend/services/transaction.service.js)
- [backend/routes/transaction_routes.js](backend/routes/transaction_routes.js)
- [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart)
- [mobile/lib/data/providers/statistic_provider.dart](mobile/lib/data/providers/statistic_provider.dart)

**Kết:**
Sơ đồ của Sơn đã đúng chiều lớn — nhất là phần xác thực JWT và luồng gọi API — nhưng để chính xác hoàn toàn với implementation cần bổ sung ownership check, wallet balance update, và các trường hợp lỗi (400/404). Nếu Sơn cập nhật theo các gợi ý trên, biểu đồ sẽ phản ánh chính xác behavior của backend và giúp reviewer dễ hiểu logic business hơn.

