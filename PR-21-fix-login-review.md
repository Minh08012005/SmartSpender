# 📋 REVIEW PR #21 (fix/login) - DỰA TRÊN FEEDBACK PR #17

**Date:** February 4, 2026  
**Reviewer:** Minh08012005  
**Author:** duckhna (Đức Anh)  
**Branch:** `fix/login`  
**Base:** `dev`

---

## 📊 **TÓM TẮT**

PR này là bản cải thiện từ PR #17 dựa trên feedback đã đưa ra trước đó. Đã có **tiến bộ đáng kể** về UI design và structure, nhưng vẫn còn một số vấn đề cần fix trước khi merge.

---

## ✅ **NHỮNG ĐIỂM ĐÃ ĐƯỢC CẢI THIỆN**

### 1. **Figma Design - Confirm Password** ✅ 
- **Trước (PR #17):** Register screen thiếu ô Confirm Password
- **Hiện tại:** Đã bổ sung đầy đủ 4 trường input:
  1. Full Name (`_nameController`)
  2. Email (`_emailController`)  
  3. Password (`_passwordController`)
  4. Confirm Password (`_confirmPasswordController`) ✅

### 2. **Toggle Password Visibility** ✅
- **Login:** `_obscurePassword` với toggle button
- **Register:** `_obscurePassword` và `_obscureConfirmPassword` với toggle buttons riêng biệt
- Hoạt động tốt với icon `visibility/visibility_off`

### 3. **Form Validation Cơ Bản** ✅
- **Register:** 
  - ✅ Password validator: Kiểm tra không được trống
  - ✅ Confirm Password validator: Kiểm tra khớp với password
- **Login:** Đã có `_formKey` setup

### 4. **Auth Service Infrastructure** ✅
- Đã setup `auth_service.dart` với:
  - `AuthService.login()` method
  - `AuthService.register()` method
  - Token storage với SharedPreferences
  - Error handling cơ bản

---

## ❌ **CÁC VẤN ĐỀ CẦN FIX**

### **1. CẤU TRÚC THƯ MỤC (CRITICAL)** ⚠️

**Vấn đề:** Tồn tại cả 2 folders:
- `mobile/lib/screens/` (đúng)
- `mobile/lib/sreens/` (sai chính tả - typo)

**Files dư thừa cần xóa:**
- `mobile/lib/sreens/login.dart`
- `mobile/lib/sreens/register.dart`

**Hành động cần thiết:**
```bash
cd mobile/lib
rm -rf sreens/
```

**Tác động:** Gây nhầm lẫn, vi phạm best practice về naming convention.

### **2. VALIDATION CHƯA ĐẦY ĐỦ** ⚠️

#### **Login Screen (`mobile/lib/screens/login.dart`):**
- ❌ **Email field:** KHÔNG CÓ validator
- ❌ **Password field:** KHÔNG CÓ validator
- Button chỉ gọi `_formKey.currentState?.validate()` nhưng không có logic validation

#### **Register Screen (`mobile/lib/screens/register.dart`):**
- ❌ **Name field:** KHÔNG CÓ validator
- ❌ **Email field:** KHÔNG CÓ validator (không validate format email)
- ✅ **Password:** Có validator
- ✅ **Confirm Password:** Có validator

**Cần bổ sung:**
```dart
// Email validator
String? _validateEmail(String? value) {
  if (value?.trim().isEmpty ?? true) {
    return 'Vui lòng nhập email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
    return 'Email không hợp lệ';
  }
  return null;
}

// Name validator
String? _validateName(String? value) {
  if (value?.trim().isEmpty ?? true) {
    return 'Vui lòng nhập họ tên';
  }
  if (value!.trim().length < 2) {
    return 'Họ tên phải có ít nhất 2 ký tự';
  }
  return null;
}
```

### **3. API INTEGRATION CHƯA HOÀN THIỆN** ⚠️

**Vấn đề:**
- ❌ Button "Sign In" và "Sign Up" chỉ gọi `validate()` mà **KHÔNG GỌI API**
- ❌ Không có loading state khi đang call API
- ❌ Không có error handling hiển thị cho user
- ❌ Không có navigation sau khi login/register thành công
- `AuthService` đã có sẵn nhưng **CHƯA ĐƯỢC SỬ DỤNG**

**Logic cần implement:**
```dart
// Trong Login Screen
bool _isLoading = false;

// Button onPressed:
onPressed: () async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    setState(() => _isLoading = false);
    
    if (result.success) {
      // Navigate to home screen
      Navigator.pushReplacement(context, 
        MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message))
      );
    }
  }
}
```

### **4. BACKEND URL CONFIGURATION**

**File:** `mobile/lib/services/auth_service.dart` (Line 6)
```dart
static const String _baseUrl = 'https://YOUR_BACKEND_URL/api/auth';
```

**Cần thay bằng:** URL backend thực tế của project.

---

## 📝 **YÊU CẦU TRƯỚC KHI APPROVE**

### **CRITICAL - Phải fix ngay:**
1. ❌ **Xóa folder `sreens/` (typo)**
2. ❌ **Bổ sung validator đầy đủ** cho TẤT CẢ fields:
   - Email format validation (regex)
   - Name validation (không trống, độ dài tối thiểu)
   - Password validation cho Login screen

### **HIGH PRIORITY:**
3. ❌ **Kết nối API vào UI:**
   - Gọi `AuthService.login()` và `AuthService.register()` trong button onPressed
   - Thêm loading indicator khi call API
   - Xử lý error messages hiển thị cho user
   - Navigation sau khi login thành công

### **MEDIUM PRIORITY:**
4. Cập nhật backend URL trong `auth_service.dart`
5. Test toàn bộ flow login/register với backend thật

---

## 🔍 **FILES ĐƯỢC REVIEW**

| File | Status | Issues |
|------|--------|--------|
| `mobile/lib/screens/login.dart` | ⚠️ | Missing validators, API integration |
| `mobile/lib/screens/register.dart` | ⚠️ | Missing name/email validators |
| `mobile/lib/sreens/login.dart` | ❌ | **XÓA - typo folder** |
| `mobile/lib/sreens/register.dart` | ❌ | **XÓA - typo folder** |
| `mobile/lib/services/auth_service.dart` | ✅ | Good structure, needs URL config |
| `mobile/lib/main.dart` | ✅ | Correct imports |

---

## 📈 **COMMIT HISTORY**

```
f051861 (HEAD -> fix/login) add toggle/add validate/fix typo
4222b97 login register chua goi api  
42b1338 Init: set up auth-services
```

---

## 💡 **GỢI Ý CHO DUCKHNA**

1. **Làm từng bước:** Fix CRITICAL issues trước, sau đó HIGH PRIORITY
2. **Testing:** Test validation thoroughly với các edge cases
3. **Error Handling:** Đảm bảo user experience tốt khi có lỗi network
4. **Code Quality:** Remove commented code, consistent naming

**Đánh giá chung:** Code đã tốt hơn nhiều so với PR #17. Cố gắng thêm chút nữa là có thể merge! 💪

---

## 📞 **NEXT STEPS**

1. Duckhna fix các issues CRITICAL và HIGH PRIORITY
2. Push code mới lên branch `fix/login`
3. Request review lại từ Minh08012005
4. Sau khi approve → merge vào `dev`

---

**Reviewer:** Minh08012005  
**Last Updated:** February 4, 2026