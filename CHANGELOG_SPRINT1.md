# 📝 CHANGELOG - Sprint 1 (Dev Branch)

**Ngày cập nhật:** 06/02/2026  
**Người thực hiện:** Minh  
**Nhánh:** `dev`

---

## 🎯 Tổng quan

Sprint này tập trung **refactor auth screens** và **fix các lỗi UI** để chuẩn bị cho integration testing.

> 📋 **Xem chi tiết các lỗi từ code merge:** [TEAM_CODE_REVIEW.md](TEAM_CODE_REVIEW.md)

---

## ✨ Những thay đổi chính

### 1. 🔧 Fix UI "Nhảy" (UI Jumping Issues)

**Vấn đề:** UI bị giật/nhảy khi hiển thị error message và loading state.

**Giải pháp:**

- Thêm `AnimatedErrorMessage` - error message xuất hiện/biến mất mượt mà
- Thêm `SmoothPrimaryButton` - button loading với animation smooth
- Thêm `SmoothNavigation` - page transitions mượt mà (slide + fade)

**Files mới:**

- `lib/shared/widgets/animated_error_message.dart`
- `lib/shared/widgets/smooth_primary_button.dart`
- `lib/shared/utils/smooth_navigation.dart`

---

### 2. 🐛 Fix Validation Error Hiện Sớm

**Vấn đề:** Error message hiện ngay khi user đang gõ (chưa gõ xong đã báo lỗi).

**Giải pháp:**

- Thêm cơ chế `forceValidation`
- Validation chỉ chạy khi:
  - User blur ra ngoài field (tap outside)
  - User nhấn nút Submit
- Không validate khi đang gõ

**Files thay đổi:**

- `lib/shared/widgets/forms/custom_text_field.dart` - thêm `_hasStartedTyping`, `_showValidation`, `forceValidation`
- `lib/shared/widgets/forms/custom_password_field.dart` - tương tự
- `lib/features/auth/widgets/login_form.dart` - sử dụng `forceValidation`
- `lib/features/auth/widgets/register_form.dart` - sử dụng `forceValidation`

---

### 3. 📦 Modular Code - Tách nhỏ file

**Vấn đề:** File `login.dart` (339 dòng) và `register.dart` (384 dòng) quá dài, khó maintain.

**Giải pháp:** Tách thành các modules nhỏ theo feature-based structure.

| File gốc                | Trước     | Sau      | Giảm    |
| ----------------------- | --------- | -------- | ------- |
| `screens/login.dart`    | 339 lines | 53 lines | **84%** |
| `screens/register.dart` | 384 lines | 45 lines | **88%** |

**Cấu trúc mới:**

```
lib/
├── core/
│   └── config/
│       └── app_config.dart          ← NEW: Config API URL
│
├── features/
│   └── auth/
│       └── widgets/
│           ├── auth_header.dart     ← NEW: Header component
│           ├── auth_form_wrapper.dart  ← NEW: Form wrapper
│           ├── login_form.dart      ← NEW: Login form logic
│           └── register_form.dart   ← NEW: Register form logic
│
├── shared/
│   ├── utils/
│   │   └── smooth_navigation.dart   ← NEW: Page transitions
│   └── widgets/
│       ├── animated_error_message.dart  ← NEW
│       ├── smooth_primary_button.dart   ← NEW
│       ├── primary_button.dart          ← Giữ nguyên (legacy)
│       └── forms/
│           ├── custom_text_field.dart   ← MODIFIED
│           └── custom_password_field.dart  ← MODIFIED
│
└── screens/
    ├── login.dart       ← SIMPLIFIED (chỉ còn layout)
    └── register.dart    ← SIMPLIFIED (chỉ còn layout)
```

---

### 4. ⚙️ App Config - Auto-detect Platform

**Vấn đề:** Phải sửa URL thủ công khi test trên emulator/physical device.

**Giải pháp:** Tạo `AppConfig` tự động detect platform và chọn URL phù hợp.

**File mới:** `lib/core/config/app_config.dart`

**Cách dùng:**

```dart
// Emulator (mặc định)
static const bool usePhysicalDevice = false;

// Physical device (cùng WiFi)
static const String localNetworkIP = '192.168.x.x';  // IP máy bạn
static const bool usePhysicalDevice = true;
```

---

### 5. 📖 Documentation

**Files mới:**

- `SETUP_GUIDE.md` - Hướng dẫn setup cho team members
- `CHANGELOG_SPRINT1.md` - File này

---

## 📁 Danh sách files thay đổi

### Files MỚI (11 files):

1. `lib/core/config/app_config.dart`
2. `lib/features/auth/widgets/auth_header.dart`
3. `lib/features/auth/widgets/auth_form_wrapper.dart`
4. `lib/features/auth/widgets/login_form.dart`
5. `lib/features/auth/widgets/register_form.dart`
6. `lib/shared/utils/smooth_navigation.dart`
7. `lib/shared/widgets/animated_error_message.dart`
8. `lib/shared/widgets/smooth_primary_button.dart`
9. `lib/shared/widgets/forms/custom_text_field.dart`
10. `lib/shared/widgets/forms/custom_password_field.dart`
11. `SETUP_GUIDE.md`

### Files SỬA (3 files):

1. `lib/screens/login.dart` - Refactored (339 → 53 lines)
2. `lib/screens/register.dart` - Refactored (384 → 45 lines)
3. `lib/services/auth_service.dart` - Sử dụng AppConfig, tăng timeout

---

## 🧪 Cách Test

### Test trên Emulator:

```bash
cd backend && npm start    # Terminal 1
cd mobile && flutter run   # Terminal 2
```

### Test trên Physical Device:

1. Sửa `app_config.dart`:
   ```dart
   static const String localNetworkIP = 'YOUR_IP';
   static const bool usePhysicalDevice = true;
   ```
2. Mở firewall port 3000 (xem SETUP_GUIDE.md)
3. Hot reload và test

---

## ⚠️ Breaking Changes

**Không có breaking changes** - Code mới tương thích hoàn toàn với code cũ.

---

## 📌 Việc cần làm tiếp (Sprint 2)

- [ ] Integration testing đầy đủ
- [ ] State management (Provider/Riverpod)
- [ ] Error handling toàn cục
- [ ] Unit tests cho auth services
- [ ] UI polish cho home screen

---

## 💬 Liên hệ

Nếu có thắc mắc về code changes, liên hệ: [Minh/Leader SmartSpender]
