# 📋 Hướng Dẫn Đóng Góp (Contributing Guide)

Chào mừng bạn đến với dự án **SmartSpender**! 🎉

Tài liệu này quy định cách thức làm việc với code, Git, và review để đảm bảo chất lượng code đồng nhất và quy trình phát triển trơn tru.

---

## 📚 Mục Lục

1. [Git Flow & Branching Strategy](#1-git-flow--branching-strategy)
2. [Pull Request Guidelines](#2-pull-request-guidelines)
3. [Commit Message Standards](#3-commit-message-standards)
4. [Code Quality Standards](#4-code-quality-standards)
5. [Code Review Process](#5-code-review-process)

---

## 1. Git Flow & Branching Strategy

### 🌳 Cấu Trúc Nhánh

```
main (production)
  └── dev (development)
       ├── feat/login-screen
       ├── feat/transaction-list
       ├── fix/validation-bug
       └── docs/api-documentation
```

### 📝 Quy Tắc Đặt Tên Nhánh

| Loại Nhánh | Prefix      | Ví Dụ                     | Mục Đích                       |
| ---------- | ----------- | ------------------------- | ------------------------------ |
| Feature    | `feat/`     | `feat/transaction-filter` | Phát triển tính năng mới       |
| Bug Fix    | `fix/`      | `fix/login-validation`    | Sửa lỗi                        |
| Hotfix     | `hotfix/`   | `hotfix/critical-crash`   | Sửa lỗi nghiêm trọng trên main |
| Docs       | `docs/`     | `docs/setup-guide`        | Cập nhật tài liệu              |
| Refactor   | `refactor/` | `refactor/api-service`    | Tái cấu trúc code              |

### 🚫 Quy Tắc VÀNG

> **TUYỆT ĐỐI KHÔNG push trực tiếp vào nhánh `dev` hoặc `main`!**

Mọi thay đổi phải qua Pull Request và được review.

### 🔄 Quy Trình Làm Việc

```bash
# 1. Checkout nhánh dev mới nhất
git checkout dev
git pull origin dev

# 2. Tạo nhánh feature mới
git checkout -b feat/your-feature-name

# 3. Làm việc và commit
git add .
git commit -m "feat(scope): your changes"

# 4. Push lên remote
git push origin feat/your-feature-name

# 5. Tạo Pull Request trên GitHub
# Đợi review và merge
```

---

## 2. Pull Request Guidelines

### ✅ Yêu Cầu Bắt Buộc

- **Ít nhất 1 thành viên khác approve** mới được merge
- **Tất cả conflicts phải được resolve** trước khi merge
- **CI/CD checks phải pass** (nếu có)
- **Mô tả rõ ràng** những gì đã thay đổi

### 📄 Template Pull Request

```markdown
## 🎯 Mục Đích

<!-- Mô tả ngắn gọn task này làm gì -->

## 🔧 Thay Đổi

- [ ] Thêm màn hình Login
- [ ] Tích hợp API authentication
- [ ] Viết unit tests

## 📸 Screenshots (nếu có UI changes)

<!-- Đính kèm ảnh màn hình -->

## ✅ Checklist

- [ ] Code đã test thủ công
- [ ] Không có warning/error
- [ ] Code đã format (flutter format / dart format)
- [ ] Comment đã cập nhật

## 🔗 Related Issues

Closes #123
```

### 💡 Best Practices

- **Một PR = Một Task**: Tránh gộp nhiều tính năng vào một PR
- **Giữ PR nhỏ gọn**: Tối đa 300-500 dòng code để dễ review
- **Self-review trước**: Đọc lại diff của mình trước khi gửi PR
- **Trả lời comments nhanh**: Resolve discussions ngay khi có thể

---

## 3. Commit Message Standards

### 📐 Chuẩn Conventional Commits

**Format:**

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### 🏷️ Types

| Type       | Ý Nghĩa                             | Ví Dụ                                    |
| ---------- | ----------------------------------- | ---------------------------------------- |
| `feat`     | Tính năng mới                       | `feat(auth): add login screen`           |
| `fix`      | Sửa lỗi                             | `fix(ui): fix button alignment`          |
| `docs`     | Cập nhật tài liệu                   | `docs(readme): add setup instructions`   |
| `style`    | Format code (không ảnh hưởng logic) | `style(home): format with dart format`   |
| `refactor` | Tái cấu trúc code                   | `refactor(api): simplify error handling` |
| `test`     | Thêm/sửa tests                      | `test(auth): add login validation tests` |
| `chore`    | Công việc maintain                  | `chore(deps): update dependencies`       |

### 🎯 Ví Dụ Commit Tốt

```bash
# ✅ TỐT
git commit -m "feat(auth): implement token refresh logic"
git commit -m "fix(transaction): handle null date in parser"
git commit -m "docs(contributing): add PR template"

# ❌ KHÔNG TỐT
git commit -m "update"
git commit -m "fix bug"
git commit -m "changes"
```

### 📜 Quy Tắc Subject Line

- Sử dụng **imperative mood**: "add", "fix", "update" (không dùng "added", "fixed")
- **Chữ thường** sau dấu `:`
- **Không kết thúc bằng dấu chấm** (`.`)
- **Tối đa 72 ký tự**

---

## 4. Code Quality Standards

### 🎨 Naming Conventions

#### Dart/Flutter

```dart
// ✅ Classes: PascalCase
class UserProfile {}
class TransactionModel {}

// ✅ Variables & Functions: camelCase
String userName = 'John';
void fetchTransactions() {}

// ✅ Constants: lowerCamelCase (hoặc SCREAMING_SNAKE_CASE cho compile-time constants)
const apiBaseUrl = 'https://api.example.com';
const int MAX_RETRY_COUNT = 3;

// ✅ Private members: _leadingUnderscore
class MyWidget {
  String _privateField;
  void _privateMethod() {}
}

// ✅ Files: snake_case
// user_profile_screen.dart
// transaction_model.dart
```

#### JavaScript/Node.js (Backend)

```javascript
// ✅ Variables & Functions: camelCase
const userName = "John";
function getUserProfile() {}

// ✅ Classes: PascalCase
class UserController {}

// ✅ Constants: SCREAMING_SNAKE_CASE
const API_BASE_URL = "http://localhost:3000";
const MAX_FILE_SIZE = 5242880;

// ✅ Files: kebab-case hoặc camelCase
// user-controller.js
// transaction.model.js
```

### 📏 File Structure Rules

- **Tối đa 250 dòng**: Nếu file vượt quá, hãy tách thành nhiều file nhỏ
- **Single Responsibility**: Mỗi file chỉ làm một việc
- **Organize imports**: Sắp xếp imports theo thứ tự:

  ```dart
  // 1. Dart/Flutter core
  import 'dart:io';
  import 'package:flutter/material.dart';

  // 2. Third-party packages
  import 'package:provider/provider.dart';
  import 'package:dio/dio.dart';

  // 3. Project imports
  import '../models/user.dart';
  import '../services/api_service.dart';
  ```

### 🧹 Code Formatting

#### Flutter

```bash
# Format toàn bộ project
flutter format .

# Format một file cụ thể
flutter format lib/main.dart
```

#### Backend (Node.js)

```bash
# Sử dụng Prettier
npm run format

# Hoặc ESLint
npm run lint
```

### ✍️ Comment Guidelines

```dart
// ✅ TỐT: Comment giải thích WHY, không phải WHAT
// Use 10.0.2.2 for Android emulator to access host machine
final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';

// ✅ TỐT: Doc comment cho public APIs
/// Fetches transactions from the API.
///
/// Returns a list of [TransactionModel] or throws [DioException] if failed.
Future<List<TransactionModel>> fetchTransactions() async {}

// ❌ KHÔNG TỐT: Comment thừa
// Get the user name
String name = user.getName(); // This gets the name
```

### 🚫 Avoid Common Mistakes

```dart
// ❌ Magic numbers
if (status == 200) { }

// ✅ Named constants
const HTTP_OK = 200;
if (status == HTTP_OK) { }

// ❌ Deep nesting
if (a) {
  if (b) {
    if (c) {
      // ...
    }
  }
}

// ✅ Early returns
if (!a) return;
if (!b) return;
if (!c) return;
// ...

// ❌ Mutable state in models
class User {
  String name; // Có thể thay đổi sau khi tạo
}

// ✅ Immutable models
class User {
  final String name; // Không thể thay đổi
  const User({required this.name});
}
```

---

## 5. Code Review Process

### 👀 Reviewer Checklist

Khi review code, hãy kiểm tra:

#### Functionality

- [ ] Code hoạt động đúng như mô tả
- [ ] Edge cases đã được xử lý
- [ ] Error handling đầy đủ

#### Code Quality

- [ ] Naming conventions đúng chuẩn
- [ ] Không có code trùng lặp
- [ ] Functions không quá dài (< 50 dòng)
- [ ] Comments hợp lý

#### Architecture

- [ ] Tuân thủ Clean Architecture (nếu đã setup)
- [ ] Separation of concerns rõ ràng
- [ ] No hardcoded values

#### Security

- [ ] Không commit secrets (API keys, passwords)
- [ ] Input validation đầy đủ
- [ ] SQL injection/XSS đã được prevent

#### Performance

- [ ] Không có memory leaks
- [ ] Network calls hiệu quả
- [ ] UI không bị lag

### 💬 Review Comments Guidelines

```dart
// ✅ Constructive feedback
"Có thể extract function này để dễ test hơn không?"
"Nên thêm null check ở đây để tránh crash."

// ❌ Not helpful
"Code này xấu quá."
"Sai rồi, làm lại đi."
```

### ⚡ Response Time

- **Initial review**: Trong vòng 24 giờ
- **Re-review sau changes**: Trong vòng 12 giờ
- **Urgent PRs**: Tag người review với @mention

---

## 🎓 Resources

### 📖 Đọc Thêm

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Clean Code JavaScript](https://github.com/ryanmcdermott/clean-code-javascript)

### 🛠️ Tools

- **Flutter Analyzer**: `flutter analyze`
- **Dart Format**: `flutter format .`
- **Git Hooks**: Husky (cho pre-commit checks)

---

## ❓ Questions?

Nếu có thắc mắc về quy trình, hãy:

- Hỏi trong group chat của team
- Tạo issue với label `question`
- Liên hệ  Leader

---
