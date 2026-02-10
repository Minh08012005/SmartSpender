# 💰 SmartSpender - Quản lý chi tiêu thông minh

Dự án phát triển ứng dụng quản lý tài chính cá nhân dành cho nhóm 2 - **Sprint 2: Core Features & Integration**

> 🚀 **Trạng thái:** Sprint 2 đang triển khai (10/02 - 20/02/2026)

---

## 👥 Thành viên nhóm

| Vai trò | Thành viên | Nhiệm vụ Sprint 2 |
|---------|------------|-------------------|
| **👨‍💼 Leader** | Mai Huy Minh | State Management, Base Code, Code Review 100% |
| **🧑‍💻 Backend** | Nguyễn Văn Duy | API Filter & Statistics |
| **🧑‍💻 Backend** | Vũ Nguyễn Ngọc Bảo | CRUD APIs, Swagger Docs, Unit Tests |
| **📱 Mobile** | Trịnh Thái Sơn | Home Screen Integration, API Connection |
| **📱 Mobile** | Lê Đức Anh | Form Add/Edit Transaction, Validation |

---

## 📂 Cấu trúc thư mục

Dự án được tổ chức theo mô hình **Monorepo + Clean Architecture**:

```
SmartSpender/
├── backend/              # Node.js API Server
│   ├── controllers/      # Request handlers
│   ├── models/          # MongoDB schemas
│   ├── routes/          # API endpoints
│   ├── middleware/      # Auth, validation, error handling
│   └── services/        # Business logic
│
├── mobile/              # Flutter App
│   ├── lib/
│   │   ├── core/        # Config, constants, services (API, storage)
│   │   ├── data/        # Models, providers (state management)
│   │   ├── features/    # Feature modules (auth, transaction)
│   │   └── views/       # UI screens & widgets
│   └── test/            # Unit tests
│
└── docs/                # Documentation
```

---

## 📅 Lộ trình phát triển (Roadmap)

### ✅ Sprint 1 (26/01 - 08/02) - Hoàn thành

- [x] Khởi tạo dự án & chia folder
- [x] Thiết kế cơ sở dữ liệu (MongoDB)
- [x] API Đăng ký/Đăng nhập (JWT Authentication)
- [x] UI màn hình Login/Register (Flutter)
- [x] Setup Git Flow & Code Review process

**Thành tựu:**
- ✅ Backend API hoạt động ổn định
- ✅ Mobile UI/UX đẹp, smooth animations
- ✅ Authentication flow hoàn chỉnh

---

### 🔥 Sprint 2 (10/02 - 20/02) - Đang thực hiện

**🎯 Mục tiêu:** Integration (Kết nối) + Core Logic + State Management

#### Giai đoạn 1: TẬP TRUNG CAO ĐỘ (10/02 - 16/02)

**Backend:**
- [ ] 🔍 API Filter Transaction nâng cao (Ngày, Loại, Category)
- [ ] 📊 API Statistics (Aggregation) tính tổng thu/chi
- [ ] ✏️ API CRUD Transaction (Create/Update/Delete)
- [ ] 📚 Swagger API Documentation
- [ ] ✅ Unit Tests cho các API

**Mobile:**
- [ ] 🏠 Integration Home Screen với API thật (thay Dummy Data)
- [ ] 🔄 UI States: Loading, Empty, Error
- [ ] ↻ Pull-to-refresh transactions
- [ ] 📝 Form Thêm/Sửa Transaction
- [ ] ✔️ Validation chi tiết (số tiền, ngày, category)
- [ ] 🎨 State Management (Provider/Riverpod)

#### Giai đoạn 2: NHẸ NHÀNG (16/02 - 20/02)
- [ ] 🧪 Unit Tests (Backend + Mobile)
- [ ] 📖 Viết Documentation
- [ ] 🎨 Polish UI/UX
- [ ] 🎬 Prepare Demo

---

### 🔜 Sprint 3 (Dự kiến: 21/02+)

- [ ] 💼 Budget management features
- [ ] 📈 Chart/Statistics screen với biểu đồ
- [ ] 🔔 Push Notifications
- [ ] 🌙 Dark mode

---

## 🛠 Quy định chung & Quy trình làm việc

### 1. Phân chia khu vực làm việc

- **Team Backend:** Thao tác trong `/backend` only
- **Team Mobile:** Thao tác trong `/mobile` only
- **Leader:** Quản lý root, review & merge PR

### 2. Quy trình Git (Git Flow)

```bash
# Bắt đầu task mới
git checkout dev
git pull origin dev
git checkout -b feat/your-feature-name

# Code xong, commit & push
git add .
git commit -m "feat(scope): description"
git push origin feat/your-feature-name

# Tạo Pull Request trên GitHub vào nhánh dev
```

**⚠️ QUY TẮC VÀNG:**
- ❌ KHÔNG code trực tiếp trên `main` hoặc `dev`
- ✅ MỌI task phải qua Pull Request
- ✅ Cần ít nhất 1 người review & approve

### 3. Commit Message Standard

```bash
# ✅ ĐÚNG
feat(auth): add persistent login
fix(ui): fix button alignment  
docs: update README for Sprint 2

# ❌ SAI
update
fix bug
changes
```

### 4. Pull Request & Code Review

- Mọi PR cần **ít nhất 1 approval** trước khi merge
- Title PR: `[Sprint 2] feat(scope): Description`
- Nội dung: Mô tả rõ thay đổi + checklist

---

## 💻 Hướng dẫn chạy code

### Backend

```bash
cd backend
npm install
npm start        # Development mode
# Server chạy tại http://localhost:3000
```

**Environment Variables:**
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/smartspender
JWT_SECRET=your_secret_key
```

### Mobile

```bash
cd mobile
flutter pub get
flutter run      # Chọn device (Android/iOS)
```

**Lưu ý:**
- Android Emulator: API tự động dùng `10.0.2.2:3000`
- iOS Simulator: API tự động dùng `localhost:3000`
- Physical Device: Đổi `localNetworkIP` trong `app_config.dart`

---

## 📚 Tài liệu tham khảo

- **[CONTRIBUTING.md](CONTRIBUTING.md):** Quy định code, commit, PR chi tiết
- **[SETUP_GUIDE.md](SETUP_GUIDE.md):** Hướng dẫn setup môi trường dev
- **API Docs:** `http://localhost:3000/api-docs` (Swagger)

---

## 🎯 Sprint 2 Progress

| Task | Assigned | Status | Note |
|------|----------|--------|------|
| Persistent Login | Leader | ✅ Done | Đã merge vào dev |
| Clean Architecture Setup | Leader | ✅ Done | ApiService, Providers ready |
| API Filter | Backend (Duy) | 🔄 In Progress | - |
| API CRUD | Backend (Bảo) | 🔄 In Progress | - |
| Home Integration | Mobile (Sơn) | 🔄 In Progress | - |
| Form Transaction | Mobile (Anh) | 🔄 In Progress | - |

---

**📞 Liên hệ & Hỗ trợ:**
- Có vấn đề? Hỏi trong group chat team
- Cần review? Tag @MaiHuyMinh trong PR
- Gặp lỗi? Tạo Issue trên GitHub với label `bug`

---

_Sprint 2 - Let's build something awesome! 🚀🔥_

**Cập nhật lần cuối:** 10/02/2026
