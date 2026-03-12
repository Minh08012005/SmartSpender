Hướng dẫn kiểm thử cho Duy — Filter & Statistic

Mục tiêu
- Xác nhận các endpoint `GET /api/transactions` và `GET /api/statistics/summary` hoạt động đúng theo spec.
- Cung cấp bằng chứng (artifacts) để mobile team tích hợp an toàn.

Yêu cầu deliverables (bắt buộc gửi lại)
- `npm test` output (console) và folder/HTML `coverage/` nếu có.
- `collection.json` (Postman collection) và `env.json` (Postman environment, có `baseUrl` và biến auth như `authToken`).
- `report.html` (Newman HTML report) nếu chạy bằng Newman; nếu không có thể gửi screenshots nhưng ưu tiên file report.
- `test-data.csv` hoặc `test-data.json` nếu dùng data để chạy nhiều case.
- `failures.md` listing các failing cases: cho mỗi case ghi rõ request (method+URL+headers+body), response JSON đầy đủ và các bước tái tạo.
- Nếu cần thay đổi API hoặc docs: PR hoặc patch cho `docs/transaction.swagger.yaml`.

Các bước thực hiện (gợi ý)
1. Chuẩn bị môi trường
   - Chạy server backend trên máy local hoặc staging; xác nhận `baseUrl` (vd. `http://localhost:3000`).
   - Kiểm tra `docs/transaction.swagger.yaml` hiện tại.

2. Chạy unit + integration tests
```
cd backend
npm install
npm test
# optional: coverage
npx jest --runInBand --coverage
```

3. Tạo/chuẩn bị Postman collection
- Tạo requests cơ bản: `POST /auth/login`, `GET /api/transactions`, `GET /api/statistics/summary`.
- Ở request `POST /auth/login` thêm test script để set token (tuỳ ý) hoặc copy token thủ công vào `env.json`.
- Export ra `collection.json` và `env.json`.

4. Test thủ công / bằng Runner
- Manual: kiểm tra các case chính trong Postman (gửi và verify response).
- Automated (khuyến nghị): dùng Collection Runner hoặc Newman để chạy nhiều iteration.

Ví dụ lệnh Newman
```
npm install -g newman newman-reporter-html
newman run collection.json -e env.json -r cli,html --reporter-html-export report.html
```

Test cases tối thiểu (phải chạy & có evidence)
- `GET /api/transactions` với user mới (không có transaction) -> trả 200 + empty list.
- `GET /api/transactions?month=..&year=..` với dữ liệu có sẵn -> trả đúng items.
- `GET /api/transactions` với `month` thiếu `year` hoặc `month` invalid -> trả validation error (4xx).
- Gửi `month` cùng lúc với `from`+`to` -> validate theo spec (nếu là invalid phải trả error).
- Filter theo `type`, `category`, `search` -> kết quả phù hợp.
- Pagination + sorting (page, limit, sortBy, order) -> kiểm tra behavior.
- No token / invalid token / expired token -> trả 401 hoặc error tương ứng.
- `GET /api/statistics/summary` cho tháng có dữ liệu và tháng không có dữ liệu -> kiểm tra `totalIncome`, `totalExpense`, `balance`.

Assertions tối thiểu trong Postman Tests
- Status code đúng (200/400/401...).
- Response schema có `success`, `statusCode`, `message`, `data.transactions`, `data.stats` (nếu applicable).
- Với aggregation: các giá trị tính toán phải trùng với dataset test.

Ghi lại và nộp kết quả
- Đính kèm `npm test` output và folder `coverage/` (hoặc report HTML).
- Đính kèm `collection.json` + `env.json`.
- Đính kèm `report.html` (Newman) hoặc screenshots nếu không thể tạo report.
- Đính kèm `test-data.csv`/`test-data.json` (nếu có).
- Đính kèm `failures.md` với request+response và bước tái tạo cho mọi failing case.
- Nếu phát hiện khác biệt so với docs, đề xuất sửa `docs/transaction.swagger.yaml` hoặc mở PR.

Tiêu chí chấp nhận nhanh (cho leader)
- Có `collection.json` + `env.json`.
- Happy-path trả 200 và schema đúng (kiểm tra sample response).
- Có evidence cho mọi failing case (request + response).
- Nếu mobile phụ thuộc vào filter/statistic: ít nhất có 1 Newman report hoặc screenshots + collection.



Ghi chú
- Đây là phiên bản trung gian: nếu thời gian hạn chế, ít nhất hãy gửi `collection.json` + `env.json` + screenshots cho 3 happy-path và 2 failing cases.

— End of file
