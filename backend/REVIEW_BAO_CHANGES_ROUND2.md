# REVIEW ROUND 2 - Leader Summary cho nhánh của Bảo

**Nhánh:** test/CRUD_transaction  
**Ngày review:** 16/03/2026  
**Mục tiêu:** chốt mức sẵn sàng merge vào dev cho backend CRUD trước khi mobile/backend tích hợp chung.

## 1) Tóm tắt quyết định

**Trạng thái hiện tại: CHƯA NÊN MERGE**

Lý do:

1. Nhiều bug trong luồng PUT/DELETE đã được xử lý tốt và có test chứng minh.
2. Nhưng GET /api/transactions vẫn còn 2 rủi ro High ảnh hưởng trực tiếp đến contract tích hợp với mobile.

## 2) Những gì Bảo đã xử lý được (theo BUG có đánh số)

### BUG-1 - Normalize lowercase cho update payload

- **Mô tả bug:** type/category gửi hoa-thường không đồng nhất ở payload update.
- **Bảo đã xử lý:** Có normalize lowercase ở validator update.
- **Bằng chứng test:** tests/unit/validators/transaction.validator.test.js (case BUG-1).
- **Kết luận:** ✅ ĐÃ FIX cho luồng PUT body.

### BUG-2 - Date format phải strict ISO ở update

- **Mô tả bug:** chấp nhận date format lỏng, dễ lệch contract.
- **Bảo đã xử lý:** update validator dùng strict ISO, từ chối MM/DD/YYYY.
- **Bằng chứng test:** tests/unit/validators/transaction.validator.test.js (case BUG-2).
- **Kết luận:** ✅ ĐÃ FIX cho luồng PUT body.

### BUG-3 - Empty payload update phải fail fast ở validator

- **Mô tả bug:** body rỗng có thể lọt xuống service mới fail.
- **Bảo đã xử lý:** validator update bắt empty object sớm với message rõ ràng.
- **Bằng chứng test:** tests/unit/validators/transaction.validator.test.js (case BUG-3).
- **Kết luận:** ✅ ĐÃ FIX.

### BUG-10 - DELETE phải trả về document đã xóa (không phải null)

- **Mô tả bug:** contract DELETE trước đây chưa rõ phần data trả về.
- **Bảo đã xử lý:** service/controller trả deleted document; test contract đã check cụ thể.
- **Bằng chứng test:** tests/integration/transaction.delete.test.js (comment BUG-10 fix).
- **Kết luận:** ✅ ĐÃ FIX.

## 3) Các phần Bảo cải thiện thêm (không gắn số bug nhưng đúng hướng)

1. Bổ sung errorCode tùy chọn trong AppError để client/mobile xử lý lỗi machine-readable.
2. Củng cố guard ObjectId ở service update/delete để tránh rơi về 500 khi id lỗi.
3. Căn chỉnh test auth contract PUT/DELETE cho TOKEN_MISSING, TOKEN_INVALID, TOKEN_EXPIRED.
4. Có sửa lỗi ở error handler (return sớm ở nhánh CastError) để không bị rơi xuống 500.

## 4) Điểm còn thiếu/chưa tối ưu (cần xử lý trước merge)

### RISK-01 (High): Filter normalize chưa đồng bộ ở API boundary của GET

- **Hiện trạng:** service có normalize `type/category`, nhưng query validator GET vẫn chặn input hoa-thường ngay từ đầu.
- **Ảnh hưởng tích hợp:** mobile gửi `type=INCOME` hoặc `category=Food,TRAVEL` sẽ dính 400 dù service đã support normalize.
- **Mức độ:** High (ảnh hưởng trực tiếp màn hình list/filter).

### RISK-02 (High): `to=YYYY-MM-DD` có thể bỏ sót giao dịch ngày cuối

- **Hiện trạng:** service parse `to` bằng new Date rồi dùng `$lte` trực tiếp.
- **Ảnh hưởng tích hợp:** query `from=2026-03-01&to=2026-03-31` có nguy cơ chỉ lấy tới đầu ngày 31, bỏ sót giao dịch còn lại trong ngày.
- **Mức độ:** High (ảnh hưởng đúng/sai dữ liệu lịch sử và thống kê).

## 5) Hướng xử lý tiếp cho Bảo

### Nhóm A - Đồng bộ contract GET filter

**File nên sửa:**

1. backend/validators/transaction.validator.js
2. backend/tests/integration/transaction.routes.test.js (hoặc file integration GET tương đương)

**Hướng xử lý:**

1. Ở getTransactionsSchema, chuẩn hóa lowercase cho query type trước khi validate valid set.
2. Với category dạng CSV, normalize từng phần tử (trim + lowercase) ngay tại validator rồi mới check allow-list.
3. Giữ behavior nhất quán giữa GET filter và POST/PUT payload để mobile không cần xử lý khác nhau.
4. Thêm integration test cho case chữ hoa/thường ở query (type/category) để khóa regression ở tầng route.

### Nhóm B - Chốt semantics date range

**File nên sửa:**

1. backend/services/transaction.service.js
2. backend/routes/transaction_routes.js (swagger docs)
3. backend/tests/unit/services/transaction.service.test.js
4. backend/tests/integration/transaction.routes.test.js (hoặc file GET tương đương)

**Hướng xử lý:**

1. Quy định rõ semantics cho `to` khi client gửi `YYYY-MM-DD`.
2. Nếu muốn đúng nhu cầu mobile date-picker: xử lý `to` theo end-of-day trước khi đưa vào `$lte`.
3. Đồng bộ lại swagger examples/mô tả để đúng behavior runtime (tránh docs một kiểu, code một kiểu).
4. Bổ sung test chứng minh giao dịch trong chính ngày `to` vẫn được trả về.

## 6) Gợi ý checklist xác nhận trước khi leader duyệt merge

1. GET filter với hoa/thường (`INCOME`, `Food,TRAVEL`) trả đúng kết quả, không còn 400 sai.
2. Date range có `to=YYYY-MM-DD` không làm mất dữ liệu ngày cuối.
3. Test integration cho GET bổ sung đầy đủ và pass ổn định.
4. Swagger GET khớp đúng hành vi runtime.
5. Re-run regression cho CRUD chính: create/update/delete/get list.

## 7) Kết luận

1. Bảo đã xử lý tốt phần lớn bug ở PUT/DELETE (đặc biệt BUG-1/2/3/10).
2. Hai điểm High còn lại tập trung ở GET contract và date semantics.
3. Sau khi xử lý xong 2 nhóm RISK ở trên và test pass đầy đủ, nhánh này có thể xem xét merge vào dev.
