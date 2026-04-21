# SmartSpender - Ứng dụng quản lý chi tiêu thông minh

SmartSpender là dự án quản lý tài chính cá nhân theo mô hình monorepo, gồm:

- Backend API: Node.js + Express + MongoDB.
- Mobile App: Flutter + Provider.

Tài liệu này phản ánh trạng thái thực tế của dự án tại thời điểm chuẩn bị đóng gói.

## 1. Trạng thái hiện tại

- Nhánh triển khai chính: `dev`.
- Mức sẵn sàng: có thể đóng gói bản nội bộ/UAT.
- Luồng nghiệp vụ cốt lõi đã hoàn thiện: xác thực, giao dịch, thống kê, ví, chuyển tiền giữa ví.
- Dữ liệu ví đã đồng bộ theo giao dịch (bao gồm cơ chế đối soát lại số dư từ lịch sử giao dịch).

## 2. Thành viên nhóm

- Leader: Mai Huy Minh.
- Mobile: Trịnh Thái Sơn, Lê Đức Anh.
- Backend: Nguyễn Văn Duy, Vũ Nguyễn Ngọc Bảo.

## 3. Kiến trúc và cấu trúc thư mục

```text
SmartSpender/
|- backend/                    # API server
|  |- controllers/             # Xử lý request/response
|  |- middleware/              # Auth, validate, error handler, rate limit
|  |- models/                  # Schema MongoDB
|  |- routes/                  # Khai báo endpoint
|  |- services/                # Business logic
|  |- validators/              # Joi + express-validator
|  |- tests/                   # Unit + Integration tests
|  |- config/                  # Cấu hình DB và các cấu hình khác
|  |- app.js                   # Khởi tạo app Express
|  |- server.js                # Entry point server
|  \- swagger.yaml             # API contract chính
|
|- mobile/                     # Ứng dụng Flutter
|  |- lib/
|  |  |- core/                 # Config, hằng số, service dùng chung
|  |  |- data/                 # Model + Provider
|  |  |- features/             # Module theo tính năng
|  |  |- screens/              # Màn hình chức năng
|  |  |- views/                # Các tab chính + widget theo view
|  |  \- navigation/           # Điều hướng chính
|  |- test/                    # Widget/unit test phía mobile
|  \- pubspec.yaml
|
|- tests/                      # Một số test cấp root (nếu có)
\- *.md                        # Tài liệu hướng dẫn, checklist
```

## 4. Tính năng đã có (chi tiết)

### 4.1 Xác thực và phiên đăng nhập

- Đăng ký tài khoản.
- Đăng nhập nhận JWT.
- Lưu token cục bộ trên mobile.
- Cơ chế xử lý token cũ/token khác nguồn backend để tránh lỗi phiên.

### 4.2 Quản lý giao dịch

- Tạo giao dịch thu/chi.
- Cập nhật giao dịch.
- Xóa giao dịch.
- Lọc theo tháng-năm hoặc theo khoảng ngày (`from` - `to`).
- Lọc theo loại giao dịch, danh mục; hỗ trợ tìm kiếm, sắp xếp, phân trang.
- Validate đầu vào và chuẩn hóa phản hồi lỗi từ backend.

### 4.3 Thống kê

- API tổng thu, tổng chi, số dư theo tháng.
- Mobile hiển thị thống kê theo bộ lọc thời gian.

### 4.4 Quản lý ví

- Lấy danh sách ví của người dùng.
- Lấy chi tiết ví theo ID.
- Cập nhật thông tin ví (tên/mô tả).
- Khởi tạo ví mặc định cho user khi chưa có dữ liệu ví.

### 4.5 Chuyển tiền giữa ví

- Chuyển tiền từ ví nguồn sang ví đích.
- Kiểm tra điều kiện số dư trước khi chuyển.
- Có xử lý timeout/trạng thái submit để tránh cảm giác “treo” trên mobile.

### 4.6 Đồng bộ số dư Home - Wallet - Transaction

- Tổng số dư hiển thị trên Home dựa trên dữ liệu ví.
- Khi tạo/sửa/xóa giao dịch, số dư ví tương ứng được cập nhật theo `walletType`.
- Có cơ chế reconcile số dư ví từ lịch sử giao dịch để giảm lệch dữ liệu legacy.

### 4.7 UI/UX hiện tại

- Tab Wallet đã đồng bộ theme với toàn ứng dụng.
- Trạng thái loading/empty/error rõ ràng hơn.
- Luồng modal chuyển tiền đã cải thiện validate và xử lý trạng thái.

## 5. API chính đang sử dụng

- API base URL chính thức (Render): `https://smartspender-x1fl.onrender.com/api/v1`

- Auth:
  - `POST /api/auth/register`
  - `POST /api/auth/login`
- Transactions:
  - `GET /api/transactions`
  - `POST /api/transactions`
  - `PUT /api/transactions/:id`
  - `DELETE /api/transactions/:id`
- Statistics:
  - `GET /api/statistics/summary`
- Wallets:
  - `GET /api/wallets`
  - `GET /api/wallets/:id`
  - `PATCH /api/wallets/:id`
  - `POST /api/wallets/transfer`
- API Docs (Swagger UI): `http://localhost:3000/api-docs`

## 6. Hướng dẫn chạy dự án

### 6.1 Chạy Backend

```bash
cd backend
npm install
npm start
```

Backend mặc định chạy tại: `http://localhost:3000`

Biến môi trường tối thiểu:

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/smartspender
JWT_SECRET=your_secret_key
```

### 6.2 Chạy Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Lưu ý kết nối API theo môi trường thiết bị:

- Android Emulator: dùng `10.0.2.2` cho localhost backend.
- iOS Simulator: dùng `localhost`.
- Thiết bị thật: cấu hình IP LAN trong app config.

## 7. Kiểm thử và chất lượng

### 7.1 Backend

```bash
cd backend
npm test
```

### 7.2 Mobile

```bash
cd mobile
flutter analyze
flutter test
```

Kết quả xác minh gần nhất (28/03/2026):

- Backend: `13/13` test suites pass, `149/149` tests pass.
- Mobile: `flutter analyze` không có lỗi.
- Mobile: `flutter test` pass toàn bộ.

## 8. Quy trình làm việc đề xuất

```bash
git checkout dev
git pull origin dev
git checkout -b feat/ten-tinh-nang

# code + test
git add .
git commit -m "feat(scope): mo-ta-ngan"
git push origin feat/ten-tinh-nang
```

Sau đó tạo Pull Request vào `dev` để review trước khi merge.

## 9. Tài liệu liên quan

- `CONTRIBUTING.md`
- `DEVELOPMENT_GUIDE.md`
- `SETUP_GUIDE.md`
- `MOBILE_E2E_TEST_CHECKLIST.md`
- `MOBILE_SPRINT3_UI_CHECKLIST.md`
- [docs/api-presentation/README.md](docs/api-presentation/README.md)

## 10. Ghi chú phát hành

- Bản hiện tại phù hợp để đóng gói bản nội bộ/UAT.
- Các hạng mục dự kiến nâng cấp tiếp theo:
  - Budget planning.
  - Biểu đồ/thống kê nâng cao.
  - Push notification.
  - Dark mode.

---

Cập nhật lần cuối: 28/03/2026
