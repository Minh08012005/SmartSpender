# 📋 CODE REVIEW - Sprint 1 Team Meeting

**Ngày merge:** 06/02/2026  
**Nhánh đích:** `dev`  
**Reviewer:** Minh

---

## 🎯 Mục đích

File này ghi lại **các vấn đề phát sinh** sau khi merge code từ các nhánh của thành viên vào `dev`, giúp:
1. Mỗi thành viên hiểu rõ lỗi trong code của mình
2. Học hỏi lẫn nhau từ các best practices
3. Cải thiện chất lượng code trong Sprint tiếp theo

---

## 📊 Tổng quan các nhánh đã merge
 
| # |      Nhánh      |             Thành viên      |      Nội dung               |     Status             |
|---|-------|----------- |----------|--------|
| 1 | `feature/login-api`          | Đúc Anh |       Login/Register API integration|     ⚠️ Cần fix           |
| 2 | `feature/home-ui`            | Sơn |           Home UI screen             |      ✅ OK              |
| 3 | `feature/transaction-schema` | Bảo |        Transaction mongoose schema   |     ✅ OK               |
| 4 | `feature/transaction-seed`   | Bảo  |        Seed script for transactions  |   ✅ OK                 |
| 5 | `feature/transaction-api`    | Bảo |         Transaction API routes          ⚠️ Cần fix             |
| 6 | `fix/login`                  | Đức Anh |           Fix route ordering              ✅ OK                |

--- 

## 🔴 Vấn đề #1: UI "Nhảy" khi hiển thị Error

**Nhánh liên quan:** `feature/login-api`  
**File:** `mobile/lib/screens/login.dart` (lines 200-210)

### ❌ Code gốc (có vấn đề):
```dart
// Error message xuất hiện đột ngột, làm UI nhảy
if (_errorMessage != null) ...[
  Text(
    _errorMessage!,
    style: AppTextStyle.subtitle.copyWith(
      color: AppColors.textLink,
    ),
  ),
  const SizedBox(height: 16),
],
```

### 🔍 Vấn đề:
- Khi `_errorMessage` thay đổi từ `null` → có giá trị, UI rebuild đột ngột
- `SizedBox(height: 16)` xuất hiện/biến mất gây "nhảy" layout
- Trải nghiệm người dùng không mượt

### ✅ Cách fix (đã áp dụng):
```dart
// File: lib/shared/widgets/animated_error_message.dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  height: errorMessage != null ? null : 0,
  curve: Curves.easeInOut,
  child: AnimatedOpacity(
    duration: Duration(milliseconds: 300),
    opacity: errorMessage != null ? 1.0 : 0.0,
    child: errorMessage != null
        ? Container(
            margin: EdgeInsets.only(bottom: 16),
            child: Text(errorMessage!, style: errorStyle),
          )
        : SizedBox.shrink(),
  ),
);
```

### 📚 Bài học:
> Luôn dùng `AnimatedContainer`, `AnimatedOpacity` hoặc `AnimatedSwitcher` khi element có thể xuất hiện/biến mất để tạo transition mượt.

---

## 🔴 Vấn đề #2: Validation chạy quá sớm

**Nhánh liên quan:** `feature/login-api`  
**File:** `mobile/lib/screens/login.dart` (lines 120-140)

### ❌ Code gốc (có vấn đề):
```dart
TextFormField(
  controller: _emailController,
  autovalidateMode: AutovalidateMode.onUserInteraction, // ← Vấn đề!
  validator: (value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Vui lòng nhập email';
    }
    if (!_emailRegex.hasMatch(value!.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  },
)
```

### 🔍 Vấn đề:
- `AutovalidateMode.onUserInteraction` validate ngay khi user gõ ký tự đầu tiên
- User chưa gõ xong email đã thấy lỗi "Email không đúng định dạng"
- Gây frustration, UX kém

### ✅ Cách fix (đã áp dụng):
```dart
// File: lib/shared/widgets/forms/custom_text_field.dart
class _CustomTextFieldState extends State<CustomTextField> {
  bool _hasStartedTyping = false;
  bool _showValidation = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // Chỉ validate khi _showValidation = true
      autovalidateMode: _showValidation
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
          
      onChanged: (value) {
        if (!_hasStartedTyping) {
          setState(() => _hasStartedTyping = true);
        }
      },
      
      // Chỉ bật validation khi user blur (tap outside)
      onTapOutside: (_) {
        if (_hasStartedTyping) {
          setState(() => _showValidation = true);
        }
      },
    );
  }
}
```

### 📚 Bài học:
> Validate field chỉ khi user:
> 1. Đã rời khỏi field (blur/tap outside)
> 2. Nhấn nút Submit
> 
> KHÔNG validate khi user đang gõ!

---

## 🔴 Vấn đề #3: Button không có Loading Animation

**Nhánh liên quan:** `feature/login-api`  
**File:** `mobile/lib/screens/login.dart` (lines 250-280)

### ❌ Code gốc (có vấn đề):
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleLogin,
  child: _isLoading
      ? CircularProgressIndicator(color: Colors.white)  // ← Nhảy!
      : Text('Sign in'),
)
```

### 🔍 Vấn đề:
- Khi switch giữa Text và CircularProgressIndicator, UI giật
- Không có animation transition

### ✅ Cách fix (đã áp dụng):
```dart
// File: lib/shared/widgets/smooth_primary_button.dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  child: ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    child: AnimatedSwitcher(  // ← Smooth transition!
      duration: Duration(milliseconds: 200),
      child: isLoading
          ? SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text),
    ),
  ),
);
```

### 📚 Bài học:
> Dùng `AnimatedSwitcher` khi cần switch giữa 2 widget khác nhau.

---

## 🔴 Vấn đề #4: File quá dài, khó maintain

**Nhánh liên quan:** `feature/login-api`  
**Files:** 
- `mobile/lib/screens/login.dart` - **339 dòng**
- `mobile/lib/screens/register.dart` - **384 dòng**

### 🔍 Vấn đề:
- Một file chứa quá nhiều logic: UI + validation + API call + navigation
- Khó debug khi có lỗi
- Khó reuse components
- Conflict khi nhiều người cùng sửa

### ✅ Cách fix (đã áp dụng):

**Tách theo feature-based structure:**

```
lib/
├── screens/
│   ├── login.dart          # 53 lines (chỉ layout)
│   └── register.dart       # 45 lines (chỉ layout)
│
├── features/auth/widgets/
│   ├── auth_header.dart    # Header component
│   ├── auth_form_wrapper.dart  # Form container
│   ├── login_form.dart     # Login logic (185 lines)
│   └── register_form.dart  # Register logic (221 lines)
│
└── shared/widgets/
    ├── forms/
    │   ├── custom_text_field.dart    # Reusable
    │   └── custom_password_field.dart
    ├── animated_error_message.dart
    └── smooth_primary_button.dart
```

### 📚 Bài học:
> **Single Responsibility Principle:**
> - Mỗi file chỉ làm 1 việc
> - Screen chỉ lo layout, gọi components
> - Components chỉ lo logic của mình
> - Shared widgets có thể reuse nhiều nơi

---

## 🟡 Vấn đề #5: Route ordering sai

**Nhánh liên quan:** `feature/transaction-api`  
**File:** `backend/server.js`

### ❌ Code gốc (có vấn đề):
```javascript
// Transaction routes được định nghĩa SAU app.listen()
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Routes này không hoạt động!
app.use('/api/transactions', transactionRoutes);
```

### ✅ Cách fix (nhánh fix/login):
```javascript
// Routes phải định nghĩa TRƯỚC app.listen()
app.use('/api/auth', authRoutes);
app.use('/api/transactions', transactionRoutes);

// Cuối cùng mới listen
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 📚 Bài học:
> Trong Express.js, thứ tự rất quan trọng:
> 1. Middleware trước
> 2. Routes
> 3. Error handlers
> 4. `app.listen()` cuối cùng

---

## ✅ Code tốt - Đáng khen

### 1. Transaction Schema (feature/transaction-schema)
```javascript
// Clean schema với proper validation
const transactionSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  type: { type: String, enum: ['income', 'expense'], required: true },
  category: { type: String, required: true },
  // ... well-structured
});
```

### 2. Seed Script (feature/transaction-seed)
- Có comments giải thích rõ ràng
- Tách category theo type (income/expense)
- Date range hợp lý

### 3. Home UI (feature/home-ui)
- Currency format VND đúng
- Layout responsive
- Code structure ok

---

## 📝 Action Items cho Sprint 2

| Thành viên        |      Việc cần làm                               |
|                   ------------|--------------                       |
| [Đức Anh, Sơn]    | Học cách dùng Animation widgets trong Flutter   |
| [Đức Anh, Sơn]    | Review lại validation UX best practices         |
| [Đức Anh, Sơn]    | Áp dụng Single Responsibility khi code          |
| [Bảo]             | Kiểm tra route ordering trong Express           |
| **Team**          |          Code review trước khi merge PR         |

---

## 📌 Git Commands hữu ích

```bash
# Xem code gốc trước refactor
git show 56d9371:mobile/lib/screens/login.dart

# So sánh 2 version
git diff 56d9371 HEAD -- mobile/lib/screens/login.dart

# Xem history của 1 file
git log --oneline -- mobile/lib/screens/login.dart

# Xem ai sửa dòng nào
git blame mobile/lib/screens/login.dart
```

---

## 🔗 References

- [Flutter Animation Best Practices](https://docs.flutter.dev/development/ui/animations)
- [Form Validation UX](https://uxdesign.cc/form-validation-best-practices)
- [Clean Architecture Flutter](https://resocoder.com/flutter-clean-architecture)
