# 💰 SmartSpender - Quản lý chi tiêu thông minh

Dự án phát triển ứng dụng quản lý tài chính cá nhân dành cho nhóm 2 - Sprint 1.

## 👥 Thành viên nhóm

- **Leader:** Minh
- **Backend:** Bảo, Duy
- **Mobile:** Sơn, Đức Anh

## 📂 Cấu trúc thư mục

Dự án được tổ chức theo mô hình Monorepo:

- `/backend`: Mã nguồn phía máy chủ (Node.js).
- `/mobile`: Mã nguồn ứng dụng di động (Flutter).



## 🛠 Quy định chung & Quy trình làm việc

Để dự án vận hành trơn tru và tránh xung đột code, toàn bộ thành viên bắt buộc tuân thủ các quy định sau:

### 1. Phân chia khu vực làm việc (Folder)

Dự án áp dụng mô hình Monorepo. Thành viên chỉ làm việc trong thư mục được phân công:

- **Team Backend (Bảo, Duy):** Thao tác hoàn toàn trong thư mục `/backend`.
- **Team Mobile (Sơn, Đức Anh):** Thao tác hoàn toàn trong thư mục `/mobile`.
- **Leader:** Quản lý cấu trúc gốc và duyệt Merge.

### 2. Quy trình Git (Git Flow)

Áp dụng "5 Tình huống Git" đã thống nhất. Mọi task đều phải thực hiện trên nhánh riêng tách từ `dev`.

- **Bắt đầu Task:** `git checkout dev` -> `git pull origin dev` -> `git checkout -b feature/ten-task`.
- **Nộp bài (PR):** Đẩy nhánh feature lên GitHub và tạo Pull Request (PR) vào nhánh `dev`.
- **Tuyệt đối:** Không code trực tiếp trên nhánh `main` hoặc `dev`.

### 3. Quy định về .gitignore & File rác

Mỗi Team phải đảm bảo file `.gitignore` hoạt động đúng trước khi push code:

- **Backend:** Chặn `node_modules/`, `.env`, các file log.
- **Mobile:** Chặn `build/`, `.dart_tool/`, `.packages`.
- **Lưu ý:** Nếu thấy PR có hàng trăm file lạ (thư viện), Leader sẽ Reject (từ chối) yêu cầu merge.

### 4. Pull Request & Review

- Mọi PR cần được ít nhất 1 thành viên khác trong cùng team (Backend/Mobile) review trước khi Leader bấm Merge.
- Nội dung PR phải ghi rõ: "Hoàn thành Task #[Số Task] - [Tên Task]".

---

_Chúc anh em có một Sprint 1 làm việc hiệu quả! 🔥_

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
