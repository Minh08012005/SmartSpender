# 📋 Quy Định Đóng Góp - SmartSpender

## 🚫 Quy Tắc Bắt Buộc

### 1. Git Flow

- **Đặt tên nhánh**: `feat/tên-tính-năng`, `fix/tên-lỗi`, `docs/tên-tài-liệu`
- **TUYỆT ĐỐI KHÔNG push trực tiếp vào `dev`**
- Mọi thay đổi phải qua Pull Request

### 2. Pull Request

- **Cần ít nhất 1 người approve** mới merge
- Mỗi PR chỉ làm **1 task duy nhất**
- Tối đa **300-500 dòng code**

### 3. Commit Message

Chuẩn Conventional Commits:

```bash
feat(scope): mô tả ngắn gọn
fix(scope): mô tả lỗi đã sửa
docs: cập nhật tài liệu
```

### 4. Code Quality

- Đặt tên biến/hàm: **camelCase** (tiếng Anh)
- Đặt tên class: **PascalCase**
- File không quá **250 dòng**
- Format code trước khi commit: `flutter format .`

---

## 🎯 SPRINT 2: Core Features & Integration

### 🎯 Mục Tiêu Chính

- ✅ **Integration (Kết nối):** Dummy Data → Real API
- ✅ **Core Logic:** Filter, CRUD, Statistics
- ✅ **State Management:** Provider/Riverpod hoàn chỉnh

---

## 📅 Timeline

### 🔥 Giai đoạn 1: TẬP TRUNG CAO ĐỘ (10/02 - 16/02)

**Focus:** Logic, API, Kết nối chính

#### Backend Team

**🧑‍💻 Nguyễn Văn Duy**

- [ ] API Filter Transaction nâng cao (Ngày, Loại, Category)
- [ ] API Statistics (Aggregation Framework) tính tổng thu/chi

**🧑‍💻 Vũ Nguyễn Ngọc Bảo**

- [ ] Viết API Thêm/Sửa/Xóa giao dịch (CRUD)
- [ ] Swagger API Documentation chi tiết
- [ ] Viết Unit Test cho các hàm cơ bản
- [ ] Tối ưu Middleware xử lý lỗi

#### Mobile Team

**📱 Trịnh Thái Sơn**

- [ ] Integration Màn hình Home (kết nối API thật)
- [ ] Xử lý UI states: Loading, Skeleton, Empty, Error
- [ ] Làm tính năng "Kéo để tải lại" (Pull-to-refresh)

**📱 Lê Đức Anh**

- [ ] Xử lý Form nhập liệu (Thêm/Sửa Giao dịch)
- [ ] Validation chi tiết (Số tiền, Danh mục, Ngày, Ghi chú)
- [ ] Tối ưu UX: Form blur, error handling
- [ ] Gọi API Thêm mới và Cập nhật

#### Leader

**👨‍💼 Mai Huy Minh**

- [ ] Thiết lập State Management (Provider/Riverpod)
- [ ] Setup Base Code, Folder Structure (hoàn thiện)
- [ ] Code Review 100% PR của team
- [ ] Hỗ trợ: merge code, giải quyết conflict

---

### 🧘 Giai đoạn 2: NHẸ NHÀNG (16/02 - 20/02)

**Focus:** Unit Test, Tài liệu, Chỉnh sửa UI

#### Toàn Team

- [ ] Viết Unit Test (Backend + Mobile)
- [ ] Viết Tài liệu (Docs) đầy đủ
- [ ] Chỉnh sửa UI nhỏ (nếu có feedback)
- [ ] Prepare Demo Sprint 2

---

## 👥 Phân Công Chi Tiết

### 🧑‍💻 Backend

**Nguyễn Văn Duy**

- Xử lý các Logic phức tạp của hệ thống
- API Filter Transaction nâng cao (Lọc theo nhiều điều kiện: Ngày, Loại, Category...)
- API Statistics (Aggregation Framework) để tính tổng thu/chi

**Vũ Nguyễn Ngọc Bảo**

- Xây dựng CRUD cơ bản & Tài liệu hóa hệ thống
- Viết API Thêm/Sửa/Xóa giao dịch (Create/Update/Delete)
- BẮT BUỘC: Viết Swagger API Documentation chi tiết trước khi code để Mobile bắm theo
- Viết Unit Test cho các hàm cơ bản
- Tối ưu Middleware xử lý lỗi

### 📱 Mobile

**Trịnh Thái Sơn**

- Integration Màn hình Home (Home Screen)
- Kết nối API lấy danh sách giao dịch (thay thế Dummy Data)
- Xử lý các trạng thái UI: Loading (Skeleton), Empty State, Error State
- Làm tính năng "Kéo để tải lại" (Pull-to-refresh)

**Lê Đức Anh**

- Xử lý Màn hình Thêm/Sửa Giao dịch (Form)
- Xây dựng Form nhập liệu (Số tiền, Danh mục, Ngày, Ghi chú)
- Tối ưu UX: Validation chi tiết lỗi khi Submit hoặc Blur (không báo lỗi khi đang gõ)
- Xử lý logic API: Gọi API Thêm mới và Cập nhật

### 👨‍💼 Leader

**Mai Huy Minh**

- Thiết lập kiến trúc State Management (Provider/Riverpod) và Base Code
- Sẽ hoàn thiện khung sườn (Folder structure, Base Provider, API Service) trên nhánh dev ngay trong đêm nay và sáng mai
- Cam kết: Sẽ Code Review 100% PR của team và Merge code
- Hỗ trợ: Code Review 100% PR của team và Merge code

---

## 🔄 Quy Trình Làm Việc

```bash
# 1. Lấy code mới nhất
git checkout dev && git pull

# 2. Tạo nhánh mới
git checkout -b feat/your-feature

# 3. Code & commit
git add .
git commit -m "feat(scope): description"

# 4. Push & tạo PR
git push origin feat/your-feature
```

---

## 👀 Code Review Checklist

- [ ] Code hoạt động đúng
- [ ] Không có warning/error
- [ ] Naming conventions đúng chuẩn
- [ ] File không quá 250 dòng
- [ ] Đã format code
- [ ] Comment giải thích logic phức tạp

---

_Cập nhật: 10/02/2026 - Sprint 2 Timeline_

_Cập nhật: February 2026_
