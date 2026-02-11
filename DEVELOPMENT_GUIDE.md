# 🛠️ Hướng dẫn phát triển SmartSpender

> **Mục đích:** Hướng dẫn team code đúng cấu trúc và quy trình, KHÔNG phải template code

---

## 📁 Backend Development (Node.js + Express + MongoDB)

### Cấu trúc MVC

```
backend/
├── validators/          # Validation rules (Joi schema)
├── controllers/         # Business logic + gọi Model
├── routes/              # Định nghĩa endpoints
├── models/              # MongoDB Schema + Query methods
└── server.js            # Đăng ký routes
```

### Quy trình làm Backend task

**Bước 1: Tạo Validator** (nếu có input từ client)

- File: `backend/validators/[feature].validator.js`
- Mục đích: Validate `req.body`, `req.query`, `req.params`
- Export: `validateFunction` middleware

**Bước 2: Tạo Controller**

- File: `backend/controllers/[feature]_controller.js`
- Tên hàm: `verb + noun` (vd: `getTransactions`, `createTransaction`)
- Logic: Nhận validated data → gọi Model → trả response
- Error: Dùng `next(error)` để ErrorHandler middleware xử lý

**Bước 3: Tạo Route**

- File: `backend/routes/[feature]_routes.js`
- Pattern: `router.httpMethod(path, [validator], controller)`
- Export: Express Router instance

**Bước 4: Đăng ký Route vào `server.js`**

```javascript
app.use('/api/[resource]', [resource]Routes);
```

### Quy tắc đặt tên Backend

- **File validator:** `[feature].validator.js` (singular)
- **File controller:** `[feature]_controller.js` (singular)
- **File route:** `[feature]_routes.js` (plural)
- **Endpoint:** `/api/[resource]` (plural, vd: `/api/transactions`)
- **Hàm controller:** camelCase bắt đầu bằng HTTP verb

---

## 📱 Mobile Development (Flutter + Clean Architecture)

### Cấu trúc Clean Architecture

```
mobile/lib/
├── data/
│   ├── models/          # Data models (JSON ↔ Dart class)
│   └── providers/       # State management (ChangeNotifier)
├── screens/             # UI screens (StatelessWidget)
├── widgets/             # Reusable components
└── core/
    ├── services/        # API calls (ApiService)
    └── constants/       # URLs, keys, configs
```

### Quy trình làm Mobile task

**Bước 1: Tạo Model** (nếu có data mới)

- File: `mobile/lib/data/models/[entity]_model.dart`
- Nội dung: Class + `fromJson()` + `toJson()`
- Mục đích: Parse JSON từ API

**Bước 2: Tạo/Cập nhật Provider**

- File: `mobile/lib/data/providers/[entity]_provider.dart`
- Extends: `ChangeNotifier`
- Chứa: List data + loading state + error state
- Methods: fetch/add/update/delete + `notifyListeners()`

**Bước 3: Tạo Screen**

- File: `mobile/lib/screens/[feature]_screen.dart`
- StatelessWidget với `Consumer<Provider>`
- UI phản ánh state: loading → data → error
- Actions: Gọi Provider methods

**Bước 4: Tạo Form Widget** (nếu có input)

- File: `mobile/lib/widgets/[feature]_form.dart`
- Dùng `Form` + `TextFormField` với `validator`
- Submit: `_formKey.currentState!.validate()` → gọi Provider

**Bước 5: Đăng ký Provider trong `main.dart`**

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NewProvider()),
  ],
)
```

### Quy tắc đặt tên Mobile

- **File model:** `[entity]_model.dart` (singular)
- **File provider:** `[entity]_provider.dart` (singular)
- **File screen:** `[feature]_screen.dart` (singular)
- **Class screen:** `[Feature]Screen` (PascalCase kết thúc bằng Screen)
- **File widget:** `[feature]_[type].dart` (vd: `transaction_form.dart`)

---

## 🎯 Task-Specific Guidelines

### Task #32: [BE] Filter & Statistics API (Duy)

**Files cần tạo:**

1. `backend/validators/transaction.validator.js`
   - Validate query params: `type`, `startDate`, `endDate`, `category`
2. `backend/controllers/transaction_controller.js`
   - Thêm 2 hàm: `filterTransactions()`, `getStatistics()`
   - Dùng Model method để query + aggregate

3. `backend/models/transaction.js`
   - Thêm static methods: `findByFilters(filters)`, `getStats(filters)`
   - Dùng MongoDB aggregation pipeline

4. `backend/routes/transaction_routes.js`
   - `GET /api/transactions/filter?type=income&startDate=...`
   - `GET /api/transactions/stats?startDate=...&endDate=...`

**Lưu ý:** Aggregation pipeline thay vì for-loop

---

### Task #33: [BE] CRUD APIs (Bảo)

**Files cần tạo:**

1. `backend/validators/transaction.validator.js`
   - Validate body: `title`, `amount`, `type`, `category`, `date`

2. `backend/controllers/transaction_controller.js`
   - 4 hàm: `createTransaction()`, `updateTransaction()`, `deleteTransaction()`, `getTransactionById()`

3. `backend/routes/transaction_routes.js`
   - `POST /api/transactions` (create)
   - `PUT /api/transactions/:id` (update)
   - `DELETE /api/transactions/:id` (delete)
   - `GET /api/transactions/:id` (get one)

**Lưu ý:** Kiểm tra `userId` match với JWT token

---

### Task #34: [Mobile] Home Integration (Sơn)

**Files cần tạo/sửa:**

1. `mobile/lib/screens/home_screen.dart`
   - Dùng `Consumer<TransactionProvider>`
   - Show: Balance card + Recent list
   - UI states: loading (spinner), empty (placeholder), data (list), error (snackbar)

2. `mobile/lib/widgets/balance_card.dart`
   - Hiển thị: Total income, Total expense, Balance
   - Computed từ Provider getters

3. `mobile/lib/widgets/transaction_list_item.dart`
   - 1 row trong list: Icon + Title + Amount + Date

**Lưu ý:** `Consumer` bọc widget tree ở level cần re-render, không bọc toàn screen

---

### Task #35: [Mobile] Form Add/Edit (Anh)

**Files cần tạo:**

1. `mobile/lib/screens/add_transaction_screen.dart`
   - StatefulWidget với `_formKey = GlobalKey<FormState>()`
   - Form fields: Title, Amount, Type (dropdown), Category (dropdown), Date (picker)

2. `mobile/lib/screens/edit_transaction_screen.dart`
   - Tương tự Add nhưng pre-fill data từ `transaction` parameter
   - Submit gọi `provider.updateTransaction()`

3. `mobile/lib/widgets/category_dropdown.dart`
   - `DropdownButtonFormField<String>` với list categories
   - Validator: `!= null`

**Lưu ý:**

- Dùng `TextFormField.validator` để validate trước khi submit
- Khi submit thành công: `Navigator.pop(context)` + refresh list

---

## ✅ Best Practices

### Backend

- **Validation:** Luôn validate input trước khi vào controller
- **Error handling:** Luôn dùng try-catch + `next(error)`
- **Response format:** Thống nhất `{ success, message, data }`
- **Status codes:** 200 (OK), 201 (Created), 400 (Bad Request), 401 (Unauthorized), 404 (Not Found), 500 (Server Error)

### Mobile

- **State management:** Provider methods phải async + try-catch + `notifyListeners()`
- **UI feedback:** Loading spinner + Error snackbar + Empty state
- **Navigation:** Dùng `Navigator.pushNamed()` với named routes
- **Form validation:** Validate UI + Validate tại API (double validation)

---

## 🔗 Tài liệu liên quan

- **[CONTRIBUTING.md](CONTRIBUTING.md):** Quy tắc Git workflow, commit convention
- **[README.md](README.md):** Roadmap Sprint 2, team assignments
