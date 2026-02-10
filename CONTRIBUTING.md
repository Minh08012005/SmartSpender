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

**Ví dụ:**
```bash
✅ feat(auth): add login screen
✅ fix(ui): fix button alignment
❌ update
❌ fix bug
```

### 4. Code Quality
- Đặt tên biến/hàm: **camelCase** (tiếng Anh)
- Đặt tên class: **PascalCase**
- File không quá **250 dòng**
- Format code trước khi commit: `flutter format .`

---

## 📅 Sprint 2 Checklist

### Tuần 1 (Done ✅)
- [x] Setup Clean Architecture boilerplate
- [x] Tạo ApiService với Dio + Interceptors
- [x] Implement TransactionProvider
- [x] Persistent Login logic
- [x] Tài liệu CONTRIBUTING.md

### Tuần 2 (In Progress 🔄)
- [ ] Tích hợp API thật vào TransactionProvider
- [ ] Implement Add/Edit/Delete Transaction
- [ ] Transaction filtering (by month/category)
- [ ] Error handling UI

### Tuần 3-4 (Planned 📝)
- [ ] Budget management features
- [ ] Chart/Statistics screen
- [ ] Notifications
- [ ] Unit tests

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

*Cập nhật: February 2026*
