# TÀI LIỆU THAM KHẢO & HƯỚNG DẪN THÊM CHO CHƯƠNG 7-8

> Tài liệu này cung cấp thêm chi tiết hỗ trợ, test cases, và link tài nguyên cho báo cáo môn học công nghệ phần mềm

---

## I. CÔNG NGHỆ VÀ FRAMEWORK SỬ DỤNG

### Backend Stack

- **Runtime:** Node.js v18+
- **Framework:** Express.js v5.2.1
- **Database:** MongoDB v5+
- **Authentication:** JWT (jose/jsonwebtoken)
- **Validation:** Joi + express-validator
- **ORM:** Mongoose v9.1.5
- **API Doc:** Swagger/OpenAPI 3.0
- **Testing:** Jest v30.2.0 + Supertest
- **Security:** Helmet, CORS, Rate Limiting

### Mobile Stack

- **Framework:** Flutter v3.10.7+
- **Language:** Dart v3.10.7+
- **State Management:** Provider v6.1.1
- **HTTP Client:** Dio v5.4.0
- **Storage:** shared_preferences v2.2.2
- **Testing:** Widget tests, Mocktail

### DevOps & Deployment

- **VCS:** Git + GitHub
- **Backend Hosting:** Render (free tier)
- **Web Hosting:** GitHub Pages + Cloudflare Pages
- **Database Hosting:** MongoDB Atlas
- **CI/CD:** GitHub Actions
- **API Testing:** Postman

---

## II. KIẾN TRÚC THIẾT KẾ

### 2.1 Mô hình 3-Layer Backend

```
┌──────────────────────────────────────┐
│       REST API (Routes)              │
│  (HTTP verb + path matching)         │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│    Business Logic (Controllers)      │
│    (Xử lý yêu cầu, gọi Service)     │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│   Data Layer (Models + Services)    │
│  (Truy vấn DB, xử lý dữ liệu)       │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│   Database (MongoDB)                 │
│  (Lưu trữ persistent data)          │
└──────────────────────────────────────┘
```

### 2.2 Clean Architecture Mobile (Flutter)

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)          │
│  - Screens                           │
│  - Widgets                           │
│  - Theme & Navigation                │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│    State Management Layer            │
│  - Providers (ChangeNotifier)        │
│  - Business Logic                    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│    Data & Domain Layer               │
│  - Models (JSONable)                 │
│  - API Service                       │
│  - Repository Pattern (optional)     │
└─────────────────────────────────────┘
```

---

## III. CHI TIẾT IMPLEMENTATION (CODE EXAMPLES)

### 3.1 Backend Example: Transaction Controller

```javascript
// controllers/transaction_controller.js
const createTransaction = async (req, res, next) => {
  try {
    // 1. Extract data từ request
    const { type, category, amount, note, date, walletType } = req.body;
    const userId = req.user.id; // Từ JWT middleware

    // 2. Validate qua Joi schema (middleware đã check)

    // 3. Gọi Service để xử lý logic
    const transaction = await TransactionService.create({
      userId,
      type,
      category,
      amount,
      note,
      date,
      walletType,
    });

    // 4. Update wallet balance
    await WalletService.updateBalanceByType(userId, walletType, amount, type);

    // 5. Normalize response
    return res.status(201).json({
      success: true,
      statusCode: 201,
      data: transaction,
      message: "Tạo giao dịch thành công",
    });
  } catch (error) {
    // 6. Pass error to ErrorHandler middleware
    next(error);
  }
};
```

### 3.2 Mobile Example: Transaction Provider

```dart
// data/providers/transaction_provider.dart
class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch transactions với filter
  Future<void> fetchTransactions({
    required int month,
    required int year,
    String? type,
    String? category,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService().getTransactions(
        month: month,
        year: year,
        type: type,
        category: category,
      );

      _transactions = (response['data'] as List)
          .map((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create transaction
  Future<bool> createTransaction(Transaction transaction) async {
    try {
      final response = await ApiService().createTransaction(transaction);
      _transactions.add(Transaction.fromJson(response['data']));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

### 3.3 Middleware Example: Auth Validation

```javascript
// middleware/auth.middleware.js
const authenticate = async (req, res, next) => {
  try {
    // 1. Extract token từ header
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: "Access token required",
        errorCode: "TOKEN_MISSING",
      });
    }

    // 2. Verify JWT
    const decoded = await jwtService.verifyToken(token);

    // 3. Attach user to request
    req.user = decoded;
    next();
  } catch (error) {
    if (error.code === "ERR_JWT_EXPIRED") {
      return res.status(401).json({
        success: false,
        statusCode: 401,
        message: "Token expired",
        errorCode: "TOKEN_EXPIRED",
      });
    }

    return res.status(401).json({
      success: false,
      statusCode: 401,
      message: "Invalid token",
      errorCode: "TOKEN_INVALID",
    });
  }
};

module.exports = authenticate;
```

### 3.4 Validation Example: Transaction Validator

```javascript
// validators/transaction.validator.js
const Joi = require("joi");

const createTransactionSchema = Joi.object({
  type: Joi.string().valid("income", "expense").required().messages({
    "string.valid": "Type must be income or expense",
  }),
  category: Joi.string().required().trim().lowercase(),
  amount: Joi.number().positive().required().messages({
    "number.positive": "Amount must be greater than 0",
  }),
  note: Joi.string().max(500).optional().trim(),
  date: Joi.date().max("now").required(),
  walletType: Joi.string().required(),
});

// Export middleware
const validateCreateTransaction = (req, res, next) => {
  const { error, value } = createTransactionSchema.validate(req.body);

  if (error) {
    return res.status(400).json({
      success: false,
      statusCode: 400,
      message: "Validation failed",
      errorCode: "VALIDATION_ERROR",
      details: error.details.map((d) => ({
        field: d.path.join("."),
        message: d.message,
      })),
    });
  }

  req.body = value;
  next();
};

module.exports = { validateCreateTransaction };
```

---

## IV. TESTING STRATEGY

### 4.1 Backend Testing Pyramid

```
             △ E2E Tests (API Integration)
           /   \  - Full flow: Auth → CRUD → Response
          /     \  - Database interactions
         /       \  Count: ~20-30 tests
        /─────────\
       /           \
      /   Unit      \  - Individual functions
     /    Tests      \ - Mocked dependencies
    /               \  Count: ~100-120 tests
   /───────────────────\
  / Integration Tests   \ - Service + Model
 /                       \ - Database with test DB
/─────────────────────────\ Count: ~25-30 tests
```

### 4.2 Test Cases cho Transaction CRUD

**CREATE:**

```javascript
describe("createTransaction", () => {
  test("should create transaction with valid data", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${validToken}`)
      .send({
        type: "expense",
        category: "food",
        amount: 150000,
        note: "Lunch",
        date: new Date(),
      });

    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data._id).toBeDefined();
  });

  test("should reject with missing amount", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${validToken}`)
      .send({
        type: "expense",
        category: "food",
        note: "Lunch",
        // amount missing!
      });

    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.errorCode).toBe("VALIDATION_ERROR");
  });
});
```

**UPDATE:**

```javascript
test("should update transaction amount", async () => {
  const transaction = await Transaction.create({
    userId: testUser._id,
    type: "expense",
    amount: 150000,
    category: "food",
    date: new Date(),
  });

  const res = await request(app)
    .put(`/api/transactions/${transaction._id}`)
    .set("Authorization", `Bearer ${validToken}`)
    .send({ amount: 200000 });

  expect(res.status).toBe(200);
  expect(res.body.data.amount).toBe(200000);
});
```

**DELETE:**

```javascript
test("should delete transaction and update wallet", async () => {
  const transaction = await Transaction.create({
    userId: testUser._id,
    type: "expense",
    amount: 150000,
    category: "food",
    walletType: "CASH",
    date: new Date(),
  });

  const walletBefore = await Wallet.findById(testWallet._id);

  const res = await request(app)
    .delete(`/api/transactions/${transaction._id}`)
    .set("Authorization", `Bearer ${validToken}`);

  expect(res.status).toBe(200);

  const walletAfter = await Wallet.findById(testWallet._id);
  expect(walletAfter.balance).toBe(walletBefore.balance + 150000);
});
```

### 4.3 Mobile Widget Testing Example

```dart
// test/transaction_form_test.dart
void main() {
  testWidgets('TransactionForm validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find form fields
    final amountField = find.byType(TextFormField).first;
    final submitButton = find.byType(ElevatedButton);

    // Test: Submit with empty amount
    await tester.tap(submitButton);
    await tester.pumpWidget(const MyApp());

    expect(
      find.text('Amount phải > 0'),
      findsOneWidget
    );

    // Test: Submit with valid amount
    await tester.enterText(amountField, '150000');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## V. PERFORMANCE & OPTIMIZATION

### 5.1 Backend Optimization

**Query Optimization:**

```javascript
// ❌ Bad: N+1 query problem
const transactions = await Transaction.find({ userId });
for (let tx of transactions) {
  const wallet = await Wallet.findById(tx.walletId); // Repeated queries!
}

// ✅ Good: Use populate
const transactions = await Transaction.find({ userId })
  .populate("walletId")
  .lean(); // Return plain JSON, not Mongoose docs
```

**Pagination:**

```javascript
// API: GET /api/transactions?page=1&limit=20
const page = req.query.page || 1;
const limit = req.query.limit || 20;
const skip = (page - 1) * limit;

const transactions = await Transaction.find({ userId })
  .skip(skip)
  .limit(limit)
  .sort({ createdAt: -1 });
```

**Rate Limiting:**

```javascript
const rateLimit = require("express-rate-limit");

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // max 100 requests per window
  message: "Too many requests",
});

app.use("/api/", limiter);
```

### 5.2 Mobile Optimization

**State Management:**

```dart
// ✅ Efficient: Only rebuild affected widget
Consumer<TransactionProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }
    return ListView(
      children: provider.transactions
          .map((tx) => TransactionItem(transaction: tx))
          .toList()
    );
  }
)
```

**Image Caching:**

```dart
// ✅ Cached network image
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://...',
  placeholder: (context, url) => const ShimmerPlaceholder(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
);
```

**Lazy Loading:**

```dart
// ✅ Lazy load transactions
ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    // Load more when scrolling to bottom
    if (index == transactions.length - 5) {
      provider.loadMore();
    }
    return TransactionItem(transaction: transactions[index]);
  }
)
```

---

## VI. SECURITY BEST PRACTICES

### 6.1 Backend Security

| Aspek                   | Implementasi                         |
| ----------------------- | ------------------------------------ |
| **Password Hashing**    | bcrypt (rounds: 10)                  |
| **JWT Secret**          | Environment variable, min 32 chars   |
| **Token Expiry**        | 7 days                               |
| **CORS**                | Whitelist specific origins           |
| **Rate Limiting**       | 100 req/15min per IP                 |
| **Input Validation**    | Joi schema + express-validator       |
| **SQL/NoSQL Injection** | Mongoose ODM + parameterized queries |
| **HTTPS**               | Enforce in production                |
| **CORS Headers**        | Helmet middleware                    |
| **XSS Protection**      | Sanitize input, CSP headers          |

### 6.2 Mobile Security

```dart
// ✅ Secure token storage
import 'flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

// Save token
await storage.write(
  key: 'jwt_token',
  value: token,
  aOptions: _getAndroidOptions(),
  iOptions: _getIOSOptions(),
);

// Retrieve token
final token = await storage.read(key: 'jwt_token');

// Delete token on logout
await storage.delete(key: 'jwt_token');
```

---

## VII. DEPLOYMENT CHECKLIST

### Pre-Deployment

- [ ] Code review completed
- [ ] All tests passing (unit + integration + E2E)
- [ ] No console errors/warnings
- [ ] Environment variables configured
- [ ] Database backups created
- [ ] API documentation updated

### Deployment (Backend - Render)

```bash
# 1. Push to main branch
git add .
git commit -m "Release: v1.0.0"
git push origin main

# 2. Render auto-deploys via GitHub Actions
# 3. Monitor logs
render logs --service smartspender-backend

# 4. Test endpoints
curl https://smartspender-x1fl.onrender.com/api/auth/login
```

### Deployment (Mobile - Google Play)

```bash
# 1. Generate APK/AAB
flutter build apk --release
# or
flutter build appbundle --release

# 2. Sign APK
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore ~/my-release-key.jks \
  build/app/outputs/apk/release/app-release.apk release
```

### Post-Deployment

- [ ] Smoke test on production
- [ ] Monitor error logs
- [ ] Check performance metrics
- [ ] User acceptance testing
- [ ] Document deployment steps

---

## VIII. TROUBLESHOOTING COMMON ISSUES

### Backend Issues

| Issue                        | Cause                   | Solution                                |
| ---------------------------- | ----------------------- | --------------------------------------- |
| `MongoDB connection timeout` | DB URI wrong/Network    | Verify MONGO_URI in .env                |
| `JWT token invalid`          | Secret mismatch         | Check JWT_SECRET in .env                |
| `CORS error`                 | Origin not whitelisted  | Add origin to CORS_ALLOWED_ORIGINS      |
| `Rate limit exceeded`        | Too many requests       | Implement exponential backoff on client |
| `Memory leak`                | Not closing connections | Use connection pooling                  |

### Mobile Issues

| Issue                     | Cause                          | Solution                                 |
| ------------------------- | ------------------------------ | ---------------------------------------- |
| `Connection refused`      | API URL wrong                  | Check app_config.dart                    |
| `Token not persisted`     | shared_preferences not working | Use flutter_secure_storage               |
| `Widgets not updating`    | notifyListeners() not called   | Add notifyListeners() after state change |
| `Images not loading`      | Network issue                  | Add error widget + retry button          |
| `App crash on navigation` | Route not registered           | Check app_navigation.dart                |

---

## IX. TÀI LIỆU THAM KHẢO NGOÀI

### Official Documentation

- [Express.js Guide](https://expressjs.com)
- [MongoDB Documentation](https://docs.mongodb.com)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [JWT Guide](https://jwt.io)
- [OpenAPI/Swagger](https://swagger.io)

### Learning Resources

- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)
- [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
- [Design Patterns](https://refactoring.guru/design-patterns)

### Tools & Services

- [Postman API Testing](https://www.postman.com)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- [Render Hosting](https://render.com)
- [GitHub Actions CI/CD](https://github.com/features/actions)
- [VS Code](https://code.visualstudio.com)

---

## X. GLOSSARY (Từ ĐIỂN KỸ THUẬT)

| Thuật ngữ             | Giải thích                                                 |
| --------------------- | ---------------------------------------------------------- |
| **JWT**               | JSON Web Token - Token xác thực stateless                  |
| **API**               | Application Programming Interface - Giao diện lập trình    |
| **REST**              | Representational State Transfer - Kiến trúc API            |
| **CRUD**              | Create, Read, Update, Delete - 4 phép toán cơ bản          |
| **ORM**               | Object Relational Mapping - Ánh xạ đối tượng-cơ sở dữ liệu |
| **Middleware**        | Hàm trung gian xử lý request/response                      |
| **Provider**          | Pattern state management trong Flutter                     |
| **ChangeNotifier**    | Lớp cơ sở cho state management Provider                    |
| **Mongoose**          | MongoDB object modeling cho Node.js                        |
| **Joi**               | Schema validation library cho Node.js                      |
| **E2E**               | End-to-End testing - Test từ UI đến database               |
| **Async/Await**       | Syntax xử lý Promise trong JavaScript                      |
| **Future**            | Tương đương Promise trong Dart                             |
| **notifyListeners()** | Gọi để trigger rebuild các widgets listening               |

---

**Cập nhật lần cuối:** 31/03/2026  
**Dành cho:** Báo cáo môn Công nghệ Phần mềm  
**Phiên bản:** 1.0.0  
**Tác giả:** SmartSpender Team
