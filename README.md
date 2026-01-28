# 💰 SmartSpender - Quản lý chi tiêu thông minh

Dự án phát triển ứng dụng quản lý tài chính cá nhân dành cho nhóm 2 - Sprint 1.

## 👥 Thành viên nhóm
* **Leader:** Minh
* **Backend:** Bảo, Duy
* **Mobile:** Sơn, Đức Anh

## 📂 Cấu trúc thư mục
Dự án được tổ chức theo mô hình Monorepo:
* `/backend`: Mã nguồn phía máy chủ (Node.js).
* `/mobile`: Mã nguồn ứng dụng di động (Flutter).

## 🚀 Quy trình làm việc (Git Flow)
1. Luôn bắt đầu từ nhánh `dev`.
2. Tạo nhánh tính năng mới: `git checkout -b feature/ten-tinh-nang`.
3. Sau khi hoàn thành, push nhánh lên GitHub và tạo **Pull Request** để Leader review.

## 📅 Lộ trình phát triển (Roadmap)

### 🏁 Sprint 1 (26/01 - 08/02) - Đang thực hiện 🛠️
- [x] Khởi tạo dự án & chia folder.
- [ ] Thiết kế cơ sở dữ liệu (Database Design).
- [ ] API Đăng ký/Đăng nhập.
- [ ] UI màn hình Home & Login.

### 🔜 Sprint 2 (Dự kiến)
- [ ] Chức năng quản lý ví và tài khoản.
- [ ] Biểu đồ thống kê chi tiêu hàng tuần.

## 💻 Hướng dẫn chạy code (Sẽ cập nhật chi tiết sau)

### Backend
1. `cd backend`
2. `npm install`
3. `npm start`

### Mobile
1. `cd mobile`
2. `flutter pub get`
3. `flutter run`