# 📚 SmartSpender - Hướng Dẫn Chi Tiết Báo Cáo API Cho 5 Thành Viên

**Phiên bản:** 1.0  
**Ngày tạo:** 21/04/2026  
**Cập nhật lần cuối:** 21/04/2026  
**Tác giả:** Minh (Team Lead)

---

## 📋 Mục Lục

1. [Tổng Quan Hệ Thống](#tổng-quan-hệ-thống)
2. [Phân Công 5 Thành Viên](#phân-công-5-thành-viên)
3. [Tính Năng 1: Authentication](#tính-năng-1-authentication) → **Minh**
4. [Tính Năng 2: Wallet Management](#tính-năng-2-wallet-management) → **Ngọc Anh + Chúc**
5. [Tính Năng 3: Transaction Management](#tính-năng-3-transaction-management) → **Xuân**
6. [Tính Năng 4: Statistics](#tính-năng-4-statistics) → **Nam**
7. [Tính Năng 5: Notifications](#tính-năng-5-notifications) → **Minh/Ngọc Anh**
8. [Cheat Sheet - Câu Hỏi Thường Gặp](#cheat-sheet--câu-hỏi-thường-gặp)
9. [Ghi Chú Cập Nhật](#ghi-chú-cập-nhật)

---

## 🏗️ Tổng Quan Hệ Thống

### Kiến Trúc 3 Lớp

```
┌──────────────────────────────────────┐
│    MOBILE (Flutter)                  │
│  - Screens, Providers, Services      │
└──────────┬───────────────────────────┘
           │ HTTP/REST API (Dio)
           │ Headers: Authorization: Bearer <JWT>
           │
┌──────────▼───────────────────────────┐
│    BACKEND (Node.js + Express)       │
│  - Routes → Controllers → Services   │
│  - MongoDB Models & Database         │
└──────────────────────────────────────┘
```

### Dòng Dữ Liệu Điển Hình

```
1. User tương tác với UI (ví dụ: bấm "Tạo giao dịch")
2. UI gọi Provider method (TransactionProvider.addTransaction())
3. Provider gọi API Service (ApiService.post())
4. Mobile gửi HTTP Request → Backend
5. Backend Routes nhận request → Controllers xử lý → Services làm logic
6. Services gọi Models để lưu vào Database
7. Backend trả Response JSON về Mobile
8. Provider cập nhật Local State
9. UI rebuild với dữ liệu mới
```

---

## 👥 Phân Công 5 Thành Viên

### 1. **Minh (Team Lead)**

- **Giải thích chính**: Tổng quan hệ thống, Authentication, Wallet Overview
- **File cần hiểu**:
  - Backend: `app.js`, `auth/login.controller.js`, `auth/register.controller.js`, `auth.service.js`
  - Mobile: `auth_service.dart`, `login.dart`, `register.dart`

### 2. **Ngọc Anh**

- **Giải thích chính**: Wallet Transfer Logic, Balance Reconciliation
- **File cần hiểu**:
  - Backend: `wallet.controller.js`, `wallet.service.js`, `wallet.model.js`, `wallet_transfer.model.js`
  - Mobile: `wallet_provider.dart`, `wallet_api_service.dart`

### 3. **Chúc**

- **Giải thích chính**: Wallet APIs (GET, PATCH), Wallet Initialization
- **File cần hiểu**:
  - Backend: `wallet_routes.js`, `wallet.controller.js` (GET endpoints)
  - Mobile: `wallet_provider.dart`, `wallet_screen.dart`

### 4. **Nam**

- **Giải thích chính**: Statistics Summary, Monthly Aggregation
- **File cần hiểu**:
  - Backend: `statistic_routes.js`, `statistic.controller.js`, `statistic.service.js`
  - Mobile: `statistic_provider.dart`, `statistic_screen.dart`

### 5. **Xuân**

- **Giải thích chính**: Transaction CRUD (Create, Read, Update, Delete), Filtering
- **File cần hiểu**:
  - Backend: `transaction_routes.js`, `transaction_controller.js`, `transaction.service.js`, `transaction_schema.js`
  - Mobile: `transaction_provider.dart`, `add_transaction_screen.dart`, `edit_transaction_screen.dart`

---

## 🔐 Tính Năng 1: Authentication

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ REGISTER / LOGIN FLOW                                    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ Mobile:                                                  │
│  User nhập email + password                             │
│   ↓                                                      │
│  Register/Login Screen gọi AuthService.register/login()  │
│   ↓                                                      │
│  AuthService gọi ApiService.post() → Backend           │
│                                                          │
│ Backend:                                                 │
│  POST /api/auth/register hoặc /api/auth/login          │
│   ↓                                                      │
│  Routes: register.route.js hoặc login.route.js         │
│   ↓                                                      │
│  Controllers: register() hoặc login()                   │
│   ↓                                                      │
│  Services: registerUser() hoặc loginUser()             │
│   │                                                     │
│   ├─ Hash password (bcrypt)                             │
│   ├─ Check email exists                                 │
│   ├─ Create JWT token                                   │
│   └─ Return {token, user}                               │
│   ↓                                                      │
│  Response 201/200 → {success: true, token, user}       │
│                                                          │
│ Mobile:                                                  │
│  Lưu token vào SharedPreferences                        │
│   ↓                                                      │
│  Navigate to MainNavigation (Home screen)              │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/auth/register.route.js`)

```javascript
router.post("/", validateRegisterInput, register);
// Input: { email, password, fullName }
// Output: 201 Created {token, user}
```

#### 2. Controller (`backend/controllers/auth/register.controller.js`)

```javascript
exports.register = async (req, res) => {
  const { email, password, fullName } = req.body;
  const result = await registerUser({ email, password, fullName });
  res
    .status(201)
    .json(successResponse(201, "User registered successfully", result));
};
```

#### 3. Service (`backend/services/auth.service.js`)

```javascript
exports.registerUser = async ({ email, password, fullName }) => {
  // 1. Check if user exists
  let user = await User.findOne({ email });
  if (user) throw new AppError("User with this email already exists", 409);

  // 2. Hash password
  const hashedPassword = await bcrypt.hash(password, 10);

  // 3. Create user
  user = await User.create({
    email,
    password: hashedPassword,
    fullName,
  });

  // 4. Generate JWT token
  const token = await generateToken(user._id);

  // 5. Initialize wallets for new user
  await initializeWalletsForUser(user._id);

  return { token, user: { _id: user._id, email, fullName } };
};
```

#### 4. Model (`backend/models/users.model.js`)

```javascript
// Schema gồm: email, password (hashed), fullName, createdAt
```

### Mobile Files

#### 1. AuthService (`mobile/lib/services/auth_service.dart`)

```dart
class AuthService {
  static Future<bool> register(String email, String password, String fullName) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'fullName': fullName
    });

    if (response.statusCode == 201) {
      final token = response.data['data']['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      return true;
    }
    return false;
  }
}
```

#### 2. Register Screen (`mobile/lib/screens/register.dart`)

```dart
onPressed: () async {
  final success = await AuthService.register(
    emailController.text,
    passwordController.text,
    fullNameController.text
  );
  if (success) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### Khi Cô Hỏi Sâu Về Auth

**Q: Tại sao app tự về login khi token hỏng?**
A: Vì trong `ApiService`, mỗi request đều có interceptor check response. Nếu trả 401 (Unauthorized), interceptor sẽ xóa token cũ và điều hướng về login.

**Q: Password được lưu như thế nào trong database?**
A: Password không được lưu dạng text. Nó được hash bằng bcrypt trước khi lưu. Khi login, hệ thống compare hash của password nhập với hash trong DB.

**Q: JWT token là gì?**
A: JWT là một chuỗi mã hóa chứa thông tin user (userId). Mỗi lần gọi API, mobile gửi token trong header Authorization. Backend verify token để xác nhận user hợp lệ.

---

## 💰 Tính Năng 2: Wallet Management

### 🎯 Ngọc Anh - Tập Trung Vào Transfer & Balance Reconciliation

### 🎯 Chúc - Tập Trung Vào Wallet APIs

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ WALLET MANAGEMENT FLOW                                   │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. FETCH WALLETS:                                        │
│    Mobile: WalletProvider.fetchWallets()                │
│      ↓                                                   │
│    GET /api/wallets → Backend                          │
│      ↓                                                   │
│    Controller getAllWallets():                          │
│      - Check wallets exist                              │
│      - If not, call initializeWalletsForUser()         │
│      - Call reconcileWalletBalancesForUser()           │
│      - Return wallets with totalBalance                │
│                                                          │
│ 2. TRANSFER BETWEEN WALLETS:                             │
│    Mobile: WalletProvider.transferBetweenWallets()      │
│      ↓                                                   │
│    POST /api/wallets/transfer                          │
│      Body: {fromWalletId, toWalletId, amount, note}    │
│      ↓                                                   │
│    Controller transferBetweenWallets():                │
│      - Validate: amount > 0, different wallets         │
│      - Check balance: fromWallet.balance >= amount     │
│      - Update balance: fromWallet -= amount            │
│      - Update balance: toWallet += amount              │
│      - Save both wallets                                │
│      - Create WalletTransfer record (history)          │
│      - Return updated wallets                           │
│                                                          │
│ 3. BALANCE RECONCILIATION (Nền tảng):                   │
│    Mỗi khi fetch, backend tính lại balance từ:         │
│      - Tất cả transactions (income/expense)             │
│      - Tất cả transfers (history)                       │
│    Công thức:                                           │
│      balance = Σ(income) - Σ(expense) +transfers       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/wallet_routes.js`)

```javascript
// Chúc - Tập trung vào:
router.get("/", authenticate, getAllWallets); // Lấy tất cả ví
router.get("/:id", authenticate, validateGetWalletById, getWalletById); // Lấy 1 ví
router.patch("/:id", authenticate, validateUpdateWallet, updateWallet); // Update tên/mô tả

// Ngọc Anh - Tập trung vào:
router.post(
  "/transfer",
  authenticate,
  validateTransfer,
  transferBetweenWallets,
);
```

#### 2. Controller (`backend/controllers/wallet.controller.js`)

```javascript
// Chúc học:
exports.getAllWallets = async (req, res, next) => {
  const userId = req.user._id;

  // 1. Lấy ví từ DB
  let wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();

  // 2. Nếu chưa có, tạo ví mặc định
  if (!wallets || wallets.length === 0) {
    await initializeWalletsForUser(userId);
    wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();
  }

  // 3. Đồng bộ số dư từ transactions + transfers
  await reconcileWalletBalancesForUser(userId);
  wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();

  res.status(200).json({
    success: true,
    data: wallets,
    totalBalance: wallets.reduce((sum, w) => sum + w.balance, 0),
  });
};

// Ngọc Anh học:
exports.transferBetweenWallets = async (req, res, next) => {
  const userId = req.user._id;
  const { fromWalletId, toWalletId, amount, note } = req.body;

  // 1. Validate
  if (!fromWalletId || !toWalletId || !amount) {
    return next(new AppError("Thiếu thông tin", 400));
  }
  if (amount <= 0) return next(new AppError("Số tiền phải > 0", 400));
  if (fromWalletId === toWalletId)
    return next(new AppError("Ví khác nhau", 400));

  // 2. Fetch wallets
  const [fromWallet, toWallet] = await Promise.all([
    Wallet.findOne({ _id: fromWalletId, userId }),
    Wallet.findOne({ _id: toWalletId, userId }),
  ]);

  if (!fromWallet || !toWallet) {
    return next(new AppError("Ví không tìm thấy", 404));
  }

  // 3. Check balance
  if (fromWallet.balance < amount) {
    return next(
      new AppError(`Số dư không đủ. Hiện có: ${fromWallet.balance}`, 400),
    );
  }

  // 4. Update balance
  fromWallet.balance -= amount;
  toWallet.balance += amount;
  fromWallet.lastUpdated = new Date();
  toWallet.lastUpdated = new Date();

  await Promise.all([fromWallet.save(), toWallet.save()]);

  // 5. Create transfer record
  const transferRecord = await WalletTransfer.create({
    userId,
    fromWalletType: fromWallet.walletType,
    toWalletType: toWallet.walletType,
    amount,
    note: (note || "").trim(),
    date: new Date(),
  });

  res.status(200).json({
    success: true,
    message: "Transfer success",
    data: { fromWallet, toWallet, amount, transferId: transferRecord._id },
  });
};
```

#### 3. Service (`backend/services/wallet.service.js`)

**Chúc - Hiểu Initialize:**

```javascript
const initializeWalletsForUser = async (userId) => {
  // Check if already exist
  const existingWallets = await Wallet.countDocuments({ userId });
  if (existingWallets > 0) return; // Already initialized

  // Create 3 default wallets
  const defaultWallets = [
    { userId, walletType: "cash", name: "Tiền mặt", balance: 0 },
    { userId, walletType: "bank", name: "Ngân hàng", balance: 0 },
    { userId, walletType: "ewallet", name: "Ví điện tử", balance: 0 },
  ];

  await Wallet.insertMany(defaultWallets);
};
```

**Ngọc Anh - Hiểu Reconciliation (Đồng Bộ):**

```javascript
const reconcileWalletBalancesForUser = async (userId) => {
  // 1. Khởi tạo wallets nếu chưa có
  await initializeWalletsForUser(userId);

  // 2. Fetch tất cả wallets, transactions, transfers của user
  const [wallets, transactions, transfers] = await Promise.all([
    Wallet.find({ userId }),
    Transaction.find({ userId }).select("amount type walletType").lean(),
    WalletTransfer.find({ userId })
      .select("amount fromWalletType toWalletType")
      .lean(),
  ]);

  // 3. Tính toán số dư từ đầu
  const nextBalances = { cash: 0, bank: 0, ewallet: 0 };

  for (const tx of transactions) {
    const walletType = tx.walletType || "cash";
    const delta = tx.type === "income" ? tx.amount : -tx.amount;
    nextBalances[walletType] += delta;
  }

  for (const transfer of transfers) {
    const fromType = transfer.fromWalletType || "cash";
    const toType = transfer.toWalletType || "cash";
    nextBalances[fromType] -= transfer.amount;
    nextBalances[toType] += transfer.amount;
  }

  // 4. Update wallets
  for (const wallet of wallets) {
    wallet.balance = Math.max(0, nextBalances[wallet.walletType]);
    wallet.lastUpdated = new Date();
    await wallet.save();
  }
};
```

#### 4. Models

```javascript
// Wallet Model (wallet.model.js)
{
  userId: ObjectId,
  walletType: 'cash' | 'bank' | 'ewallet',
  balance: Number (VND),
  name: String,
  description: String,
  lastUpdated: Date,
  timestamps: { createdAt, updatedAt }
}

// WalletTransfer Model (wallet_transfer.model.js)
{
  userId: ObjectId,
  fromWalletType: String,
  toWalletType: String,
  amount: Number,
  note: String,
  date: Date
}
```

### Mobile Files

#### 1. WalletProvider (`mobile/lib/data/providers/wallet_provider.dart`)

```dart
class WalletProvider extends ChangeNotifier {
  List<WalletModel> _wallets = [];
  int get totalBalance => _wallets.fold(0, (sum, w) => sum + w.balance);

  Future<void> fetchWallets({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      await _loadFromCache(); // Load từ SharedPreferences nếu có
    }
    await _fetchFromApi(); // Fetch mới từ API
  }

  Future<bool> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required String note
  }) async {
    // 1. Validate client-side
    if (amount <= 0) { _errorMessage = 'Amount must be positive'; return false; }
    if (fromWalletId == toWalletId) { _errorMessage = 'Source and dest different'; return false; }

    // 2. Call API
    final response = await _apiService.transferBetweenWallets(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      note: note
    );

    // 3. Update local state
    if (response.success) {
      _updateWalletFromApi(response.data.fromWallet);
      _updateWalletFromApi(response.data.toWallet);
      await _saveToCache();
      return true;
    }
    return false;
  }
}
```

#### 2. Wallet Screen (`mobile/lib/views/wallet/wallet_screen.dart`)

```dart
onPressed: () {
  // Transfer từ wallet1 tới wallet2
  walletProvider.transferBetweenWallets(
    fromWalletId: wallet1.id,
    toWalletId: wallet2.id,
    amount: 100000,
    note: 'Chuyển tiền để chi tiêu'
  );
}
```

### Khi Cô Hỏi Sâu Về Wallet

**Q: Số dư ví được cập nhật như thế nào?**
A: Số dư ở backend là **tính toán lại mỗi lần** từ:

- Tất cả transactions (income/expense) của user
- Tất cả wallet transfers (history)
  Công thức: balance = (tổng income) - (tổng expense) + (transfers in) - (transfers out)

**Q: Nếu mạng bị disconnect khi transfer, sao vậy?**
A: Mobile có timeout 15 giây. Nếu backend trả response thành công (200), thì transfer đã được lưu vào DB. Nếu timeout, mobile sẽ thông báo lỗi cho user.

**Q: Tại sao mỗi user có 3 ví cố định?**
A: Vì ứng dụng này mô phỏng quản lý tiền tệ thực tế: tiền mặt (dùng hàng ngày), ngân hàng (tiền để dự trữ), ví điện tử (Momo, ZaloPay).

---

## 💳 Tính Năng 3: Transaction Management

### 🎯 Xuân - Tập Trung Vào CRUD + Filtering

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ TRANSACTION CRUD FLOW                                    │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. FETCH TRANSACTIONS:                                   │
│    Mobile: TransactionProvider.fetchTransactions(month, year)
│      ↓                                                   │
│    GET /api/transactions?month=1&year=2026 → Backend   │
│      ↓                                                   │
│    Controller getTransactions():                        │
│      - Extract filters (month/year, category, type...)  │
│      - Call transactionService.getFilteredTransactions()│
│      - Return {transactions, pagination}                │
│                                                          │
│ 2. CREATE TRANSACTION:                                   │
│    Mobile: TransactionProvider.addTransaction()          │
│      ↓                                                   │
│    POST /api/transactions                               │
│      Body: {title, amount, type, category, walletType}  │
│      ↓                                                   │
│    Controller createTransaction():                      │
│      - Pass to transactionService.createTransaction()   │
│      - Service: Validate → Update wallet → Create tx   │
│      - Return created transaction (201)                 │
│                                                          │
│ 3. UPDATE TRANSACTION:                                   │
│    Mobile: TransactionProvider.updateTransaction()       │
│      ↓                                                   │
│    PUT /api/transactions/:id                            │
│      Body: {updated fields}                             │
│      ↓                                                   │
│    Controller updateTransaction():                      │
│      - Check ownership (userId match)                   │
│      - Update old wallet (reverse old delta)           │
│      - Update new wallet (apply new delta)             │
│      - Save transaction                                 │
│      - Return updated (200)                             │
│                                                          │
│ 4. DELETE TRANSACTION:                                   │
│    Mobile: TransactionProvider.deleteTransaction()       │
│      ↓                                                   │
│    DELETE /api/transactions/:id                         │
│      ↓                                                   │
│    Controller deleteTransaction():                      │
│      - Check ownership                                  │
│      - Reverse delta from wallet                        │
│      - Delete transaction                               │
│      - Return deleted (200)                             │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/transaction_routes.js`)

```javascript
router.get(
  "/",
  authenticate,
  validate(getTransactionsSchema, "query"),
  getTransactions,
);
router.post(
  "/",
  authenticate,
  validate(createTransactionSchema, "body"),
  createTransaction,
);
router.put(
  "/:id",
  authenticate,
  validate(updateTransactionSchema, "body"),
  updateTransaction,
);
router.delete(
  "/:id",
  authenticate,
  validate(objectIdParamSchema, "params"),
  deleteTransaction,
);
```

**Query Parameters cho GET:**

- `month` + `year`: Lọc theo tháng/năm
- `from` + `to`: Lọc theo khoảng ngày
- `type`: 'income' | 'expense'
- `category`: 'food', 'transport', 'salary', etc.
- `search`: Tìm kiếm trong title/note
- `page`, `limit`: Pagination
- `sortBy`: 'date', 'amount', 'category', 'createdAt'

#### 2. Controller (`backend/controllers/transaction_controller.js`)

```javascript
exports.getTransactions = async (req, res, next) => {
  const userId = req.user._id;
  const filter = req.query; // đã được validate

  // Call service
  const result = await transactionService.getFilteredTransactions(
    userId,
    filter,
  );

  res.status(200).json(successResponse(200, "Fetched successfully", result));
};

exports.createTransaction = async (req, res, next) => {
  const transaction = await transactionService.createTransaction(
    req.user._id,
    req.body,
  );
  res
    .status(201)
    .json(successResponse(201, "Created successfully", transaction));
};

exports.updateTransaction = async (req, res, next) => {
  const userId = req.user._id;
  const { id } = req.params;

  const updated = await transactionService.updateTransaction(
    userId,
    id,
    req.body,
  );
  res.status(200).json(successResponse(200, "Updated successfully", updated));
};

exports.deleteTransaction = async (req, res, next) => {
  const deleted = await transactionService.deleteTransaction(
    req.user._id,
    req.params.id,
  );
  res.status(200).json(successResponse(200, "Deleted successfully", deleted));
};
```

#### 3. Service (`backend/services/transaction.service.js`)

**CREATE:**

```javascript
exports.createTransaction = async (userId, body) => {
  // 1. Validate & normalize input
  if (!body.title || !body.title.trim())
    throw new AppError("Title required", 400);
  if (!Number.isFinite(body.amount) || body.amount < 0)
    throw new AppError("Invalid amount", 400);
  if (!["income", "expense"].includes(body.type))
    throw new AppError("Invalid type", 400);
  if (!VALID_CATEGORIES.includes(body.category))
    throw new AppError("Invalid category", 400);

  // 2. Ensure wallets exist
  const wallets = await ensureWalletsAndGetMap(userId);
  const wallet = wallets.get(body.walletType || "cash");

  // 3. Calculate delta (amount change)
  const delta = body.type === "income" ? body.amount : -body.amount;

  // 4. Apply to wallet
  const nextBalance = wallet.balance + delta;
  if (nextBalance < 0) throw new AppError("Insufficient balance", 400);
  wallet.balance = nextBalance;
  wallet.lastUpdated = new Date();

  // 5. Create transaction
  const created = await Transaction.create({
    ...body,
    userId: new ObjectId(userId),
  });

  // 6. Save wallet
  await wallet.save();

  return created;
};
```

**UPDATE:**

```javascript
exports.updateTransaction = async (userId, id, updateData) => {
  // 1. Find transaction
  const tx = await Transaction.findById(id);
  if (!tx || tx.userId.toString() !== userId.toString()) {
    throw new AppError("Transaction not found or not yours", 404);
  }

  // 2. Get wallets map
  const wallets = await ensureWalletsAndGetMap(userId);

  // 3. Reverse old delta
  const oldDelta = calculateDelta(tx.type, tx.amount);
  const oldWallet = wallets.get(tx.walletType || "cash");
  oldWallet.balance -= oldDelta; // Reverse

  // 4. Apply new delta
  const newDelta = calculateDelta(updateData.type, updateData.amount);
  const newWallet = wallets.get(updateData.walletType || "cash");
  newWallet.balance += newDelta; // Apply

  // 5. Update transaction & save wallets
  Object.assign(tx, updateData);
  await Promise.all([tx.save(), oldWallet.save(), newWallet.save()]);

  return tx;
};
```

**DELETE:**

```javascript
exports.deleteTransaction = async (userId, id) => {
  const tx = await Transaction.findById(id);
  if (!tx || tx.userId.toString() !== userId.toString()) {
    throw new AppError("Not found", 404);
  }

  // Reverse delta
  const wallets = await ensureWalletsAndGetMap(userId);
  const wallet = wallets.get(tx.walletType || "cash");
  const delta = calculateDelta(tx.type, tx.amount);
  wallet.balance -= delta;

  await Promise.all([tx.deleteOne(), wallet.save()]);
  return tx;
};
```

**FETCH with FILTERING:**

```javascript
exports.getFilteredTransactions = async (userId, filters) => {
  const {
    from,
    to,
    month,
    year,
    type,
    category,
    search,
    page = 1,
    limit = 20,
    sortBy = "date",
    order = "desc",
  } = filters;

  // 1. Build query
  let query = { userId };

  // Date range
  if (from && to) {
    query.date = { $gte: new Date(from), $lte: new Date(to) };
  } else if (month && year) {
    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 1);
    query.date = { $gte: start, $lt: end };
  }

  // Type filter
  if (type && ["income", "expense"].includes(type)) {
    query.type = type;
  }

  // Category filter
  if (category) {
    const categories = category.split(",").map((c) => c.trim().toLowerCase());
    query.category = { $in: categories };
  }

  // Search
  if (search) {
    const escaped = escapeStringRegexp(search);
    query.$or = [
      { title: new RegExp(escaped, "i") },
      { note: new RegExp(escaped, "i") },
    ];
  }

  // 2. Execute query
  const transactions = await Transaction.find(query)
    .sort({ [sortBy]: order === "asc" ? 1 : -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .lean();

  // 3. Calculate stats
  const allTx = await Transaction.find({ userId });
  const totalIncome = allTx
    .filter((t) => t.type === "income")
    .reduce((sum, t) => sum + t.amount, 0);
  const totalExpense = allTx
    .filter((t) => t.type === "expense")
    .reduce((sum, t) => sum + t.amount, 0);

  return {
    transactions,
    pagination: { page, limit, total: transactions.length },
    stats: { totalIncome, totalExpense, balance: totalIncome - totalExpense },
  };
};
```

#### 4. Model (`backend/models/transaction_schema.js`)

```javascript
{
  userId: ObjectId (indexed),
  title: String (required),
  amount: Number (required, >= 0),
  type: 'income' | 'expense',
  walletType: 'cash' | 'bank' | 'ewallet',
  category: String (from VALID_CATEGORIES),
  date: Date,
  note: String,
  timestamps: { createdAt, updatedAt }
}

// Indexes:
// - { userId: 1, date: -1 }
// - { userId: 1, type: 1, category: 1 }
// - Text index on title, note
```

### Mobile Files

#### 1. TransactionProvider (`mobile/lib/data/providers/transaction_provider.dart`)

```dart
class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  Future<void> fetchTransactions({int? month, int? year}) async {
    _setLoading(true);
    _clearError();

    try {
      final now = DateTime.now();
      final int useMonth = month ?? now.month;
      final int useYear = year ?? now.year;

      final response = await _apiService.get(
        ApiConstants.transactions,
        queryParameters: {'month': useMonth, 'year': useYear}
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _transactions = (data['transactions'] as List)
            .map((tx) => TransactionModel.fromJson(tx))
            .toList();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      final response = await _apiService.post(
        ApiConstants.transactions,
        data: transaction.toJson()
      );

      if (response.statusCode == 201) {
        _transactions.add(TransactionModel.fromJson(response.data['data']));
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // updateTransaction, deleteTransaction tương tự
}
```

#### 2. Add Transaction Screen (`mobile/lib/screens/add_transaction_screen.dart`)

```dart
onPressed: () async {
  final tx = TransactionModel(
    title: titleController.text,
    amount: double.parse(amountController.text),
    type: selectedType, // 'income' or 'expense'
    category: selectedCategory,
    walletType: selectedWallet,
    date: selectedDate,
    note: noteController.text
  );

  final success = await provider.addTransaction(tx);
  if (success) {
    Navigator.pop(context);
  }
}
```

### Khi Cô Hỏi Sâu Về Transaction

**Q: Nếu tạo giao dịch "chi tiêu" 50000, số dư ví giảm đúng không?**
A: Đúng. Ở service, khi tạo transaction với type='expense', delta = -50000. Nó được cộng trực tiếp vào wallet.balance.

**Q: Nếu sửa giao dịch từ 'expense' thành 'income', sao vậy?**
A: Ở updateTransaction service, nó sẽ:

1. Reverse delta cũ: balance += 50000 (ngược lại)
2. Apply delta mới: balance -= 50000 (income không được trừ)
   Kết quả: balance += 100000

**Q: Search function hoạt động như thế nào?**
A: Backend dùng regex case-insensitive để tìm kiếm trong fields title và note. Nếu search="cơm", sẽ trả về giao dịch có title hoặc note chứa "cơm".

**Q: Pagination là gì?**
A: Vì có thể người dùng có hàng trăm giao dịch, backend không trả tất cả. Nó trả từng page (trang). Mobile hỏi page=1 limit=20, backend trả 20 giao dịch đầu tiên, v.v.

---

## 📊 Tính Năng 4: Statistics

### 🎯 Nam - Tập Trung Vào Monthly Summary & Aggregation

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ STATISTICS SUMMARY FLOW                                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ Mobile: StatisticProvider.fetchStatistics(month, year)   │
│   ↓                                                      │
│ GET /api/statistics/summary?month=1&year=2026           │
│   ↓                                                      │
│ Backend Controller getSummary():                         │
│   - Extract month, year from query                       │
│   - Pass to statisticService.getMonthlyStatistics()      │
│   ↓                                                      │
│ Service:                                                 │
│   1. Build date range:                                   │
│      start = 2026-01-01                                  │
│      end = 2026-02-01                                    │
│                                                          │
│   2. Query all transactions for month:                   │
│      Transaction.find({                                  │
│        userId,                                           │
│        date: { $gte: start, $lt: end }                  │
│      })                                                  │
│                                                          │
│   3. Calculate:                                          │
│      totalIncome = SUM(tx.amount where type='income')   │
│      totalExpense = SUM(tx.amount where type='expense') │
│      balance = totalIncome - totalExpense                │
│                                                          │
│   4. Return { totalIncome, totalExpense, balance }      │
│   ↓                                                      │
│ Response 200:                                            │
│ {                                                        │
│   "success": true,                                       │
│   "data": {                                              │
│     "totalIncome": 5000000,                             │
│     "totalExpense": 2000000,                            │
│     "balance": 3000000                                  │
│   }                                                      │
│ }                                                        │
│   ↓                                                      │
│ Mobile Provider:                                         │
│   - Extract data                                        │
│   - Update _totalIncome, _totalExpense, _balance        │
│   - notifyListeners()                                   │
│   ↓                                                      │
│ UI rebuilds with new statistics                         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/statistic_routes.js`)

```javascript
router.get(
  "/summary",
  authenticate,
  validate(getSummarySchema, "query"),
  statisticController.getSummary,
);

// Query parameters:
// - month: 1-12 (required)
// - year: 2000+ (required)
```

#### 2. Controller (`backend/controllers/statistic.controller.js`)

```javascript
exports.getSummary = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { month, year } = req.query;

    // Call service to get statistics
    const data = await statisticService.getMonthlyStatistics(
      userId,
      month,
      year,
    );

    return res
      .status(200)
      .json(successResponse(200, "Get monthly statistics successfully", data));
  } catch (error) {
    next(error);
  }
};
```

#### 3. Service (`backend/services/statistic.service.js`)

```javascript
exports.getMonthlyStatistics = async (userId, month, year) => {
  // 1. Validate input
  if (!month || !year) {
    throw new AppError("Month and year required", 400);
  }

  const monthNum = parseInt(month);
  const yearNum = parseInt(year);

  if (monthNum < 1 || monthNum > 12) {
    throw new AppError("Month must be 1-12", 400);
  }
  if (yearNum < 2000) {
    throw new AppError("Year must be 2000+", 400);
  }

  // 2. Build date range
  const startDate = new Date(yearNum, monthNum - 1, 1);
  const endDate = new Date(yearNum, monthNum, 1);

  // 3. Query transactions for the month
  const transactions = await Transaction.find({
    userId: new ObjectId(userId),
    date: { $gte: startDate, $lt: endDate },
  }).lean();

  // 4. Calculate totals
  let totalIncome = 0;
  let totalExpense = 0;

  for (const tx of transactions) {
    if (tx.type === "income") {
      totalIncome += tx.amount;
    } else if (tx.type === "expense") {
      totalExpense += tx.amount;
    }
  }

  const balance = totalIncome - totalExpense;

  return {
    month: monthNum,
    year: yearNum,
    totalIncome,
    totalExpense,
    balance,
    transactionCount: transactions.length,
  };
};
```

### Mobile Files

#### 1. StatisticProvider (`mobile/lib/data/providers/statistic_provider.dart`)

```dart
class StatisticProvider extends ChangeNotifier {
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  double _balance = 0.0;
  bool _isLoading = false;

  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _balance;

  Future<void> fetchStatistics({required int month, required int year}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        ApiConstants.statisticsSummary,
        queryParameters: {'month': month, 'year': year}
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['success'] == true) {
          final stats = data['data'] as Map<String, dynamic>;

          _totalIncome = (stats['totalIncome'] as num?)?.toDouble() ?? 0.0;
          _totalExpense = (stats['totalExpense'] as num?)?.toDouble() ?? 0.0;
          _balance = (stats['balance'] as num?)?.toDouble() ?? 0.0;

          debugPrint('✅ Statistics fetched: Income=$_totalIncome, Expense=$_totalExpense');
        }
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Failed to fetch statistics');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### 2. Statistic Screen (`mobile/lib/views/statistic/statistic_screen.dart`)

```dart
void initState() {
  super.initState();

  // Fetch statistics khi mở màn
  final now = DateTime.now();
  Provider.of<StatisticProvider>(context, listen: false)
    .fetchStatistics(month: now.month, year: now.year);

  // Fetch transactions cho danh sách
  Provider.of<TransactionProvider>(context, listen: false)
    .fetchTransactions(month: now.month, year: now.year);
}

// Build UI với statistics
Consumer<StatisticProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        Text('Tổng Thu: ${provider.totalIncome}'),
        Text('Tổng Chi: ${provider.totalExpense}'),
        Text('Số Dư: ${provider.balance}'),
      ],
    );
  }
)
```

### Khi Cô Hỏi Sâu Về Statistics

**Q: Thống kê tháng 1 năm 2026 được tính từ đâu?**
A: Backend sẽ query tất cả transactions có date >= 2026-01-01 AND date < 2026-02-01. Rồi sum tất cả transactions có type='income' và type='expense'.

**Q: Nếu người dùng tạo giao dịch ngày 31/1 nhưng lần hôm sau vào ngày 2/2, số dư có đúng không?**
A: Đúng. Vì statistics không lưu trữ dữ liệu. Nó tính toán mỗi lần request dựa trên transactions thực tế trong DB.

**Q: Nếu xóa một giao dịch, statistics có tự cập nhật không?**
A: Không tự cập nhật. Mobile phải gọi lại fetchStatistics() sau khi xóa. Thường là mobile gọi lại sau mỗi tác vụ.

---

## 🔔 Tính Năng 5: Notifications

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ NOTIFICATIONS FLOW                                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. LIST NOTIFICATIONS:                                   │
│    GET /api/notifications → Returns [{id, message, read}]
│                                                          │
│ 2. CREATE NOTIFICATION:                                  │
│    POST /api/notifications                              │
│    Body: {title, message, type}                         │
│    - Tạo notification cho user                          │
│                                                          │
│ 3. MARK AS READ:                                         │
│    PATCH /api/notifications/:id/read                    │
│    - Set read: true                                     │
│                                                          │
│ 4. MARK ALL AS READ:                                     │
│    PATCH /api/notifications/read-all                    │
│    - Set read: true for all                             │
│                                                          │
│ 5. DELETE NOTIFICATION:                                  │
│    DELETE /api/notifications/:id                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/notification.routes.js`)

```javascript
router.get("/", authenticate, listNotifications);
router.post("/", authenticate, create);
router.patch("/:id/read", authenticate, read);
router.patch("/read-all", authenticate, readAll);
router.delete("/:id", authenticate, remove);
```

#### 2. Controller (`backend/controllers/notification.controller.js`)

```javascript
exports.listNotifications = async (req, res, next) => {
  // GET tất cả notifications của user
  const notifications = await Notification.find({ userId: req.user._id });
  res.status(200).json({ success: true, data: notifications });
};

exports.create = async (req, res, next) => {
  const { title, message, type } = req.body;
  const notification = await Notification.create({
    userId: req.user._id,
    title,
    message,
    type,
    read: false,
    createdAt: new Date(),
  });
  res.status(201).json({ success: true, data: notification });
};

exports.read = async (req, res, next) => {
  const { id } = req.params;
  const notification = await Notification.findByIdAndUpdate(
    id,
    { read: true },
    { new: true },
  );
  res.status(200).json({ success: true, data: notification });
};

exports.readAll = async (req, res, next) => {
  await Notification.updateMany({ userId: req.user._id }, { read: true });
  res.status(200).json({ success: true, message: "All marked as read" });
};

exports.remove = async (req, res, next) => {
  await Notification.findByIdAndDelete(req.params.id);
  res.status(200).json({ success: true, message: "Deleted" });
};
```

### Khi Cô Hỏi Sâu Về Notifications

**Q: Notifications có real-time không?**
A: Hiện tại không. Nó chỉ là list lưu trữ trong DB. Mobile phải pull (gọi) lại danh sách mỗi lần vào màn notifications. Để real-time cần dùng WebSocket hoặc Firebase Cloud Messaging.

---

## 📊 Tính Năng 6: Transactions by Date

### 🎯 Chúc - Tập Trung Vào Lấy Giao Dịch Theo Ngày

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ TRANSACTIONS BY DATE FLOW                                │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ Mobile:                                                  │
│  User chọn ngày trên lịch tháng                        │
│   ↓                                                      │
│  StatisticProvider.fetchTransactionsByDate(date)        │
│   ↓                                                      │
│  GET /api/transactions/by-date?date=YYYY-MM-DD         │
│                                                          │
│ Backend:                                                 │
│  Routes: transaction_routes.js (by-date endpoint)      │
│   ↓                                                      │
│  Controller: getTransactionsByDate()                   │
│   ↓                                                      │
│  Service: getTransactionsByDate(userId, dateStr)       │
│   │                                                     │
│   ├─ Parse date thành start/end của ngày               │
│   ├─ Query transactions trong khoảng thời gian         │
│   ├─ Tính summary: totalIncome, totalExpense, net       │
│   └─ Trả {date, summary, transactions}                 │
│                                                          │
│ Mobile:                                                  │
│  Hiển thị bottom sheet với summary và danh sách giao dịch│
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/transaction_routes.js`)

```javascript
router.get(
  "/by-date",
  authenticate,
  validate(getTransactionsByDateSchema, "query"),
  getTransactionsByDate,
);
```

#### 2. Controller (`backend/controllers/transaction_controller.js`)

```javascript
exports.getTransactionsByDate = async (req, res, next) => {
  const userId = req.user._id;
  const { date } = req.query;

  const result = await transactionService.getTransactionsByDate(
    userId,
    date,
  );

  res.status(200).json(successResponse(200, "Fetched successfully", result));
};
```

#### 3. Service (`backend/services/transaction.service.js`)

```javascript
function toDayRange(dateStr) {
  const [y, m, d] = dateStr.split("-").map(Number);
  const start = new Date(Date.UTC(y, m - 1, d, 0, 0, 0));
  const end = new Date(Date.UTC(y, m - 1, d + 1, 0, 0, 0));
  return { start, end };
}

async function getTransactionsByDate(userId, dateStr) {
  const { start, end } = toDayRange(dateStr);

  const rows = await Transaction.find({
    userId,
    date: { $gte: start, $lt: end },
  })
    .sort({ date: -1 })
    .lean();

  let totalIncome = 0;
  let totalExpense = 0;
  for (const tx of rows) {
    if (tx.type === "income") totalIncome += tx.amount;
    if (tx.type === "expense") totalExpense += tx.amount;
  }

  return {
    date: dateStr,
    summary: {
      totalIncome,
      totalExpense,
      net: totalIncome - totalExpense,
    },
    transactions: rows,
  };
}
```

### Mobile Files

#### 1. StatisticProvider (`mobile/lib/data/providers/statistic_provider.dart`)

```dart
Future<Map<String, dynamic>> fetchTransactionsByDate(String date) async {
  final response = await _apiService.getTransactionsByDate(date);
  if (response.success) {
    return response.data;
  }
  throw Exception('Failed to fetch transactions by date');
}
```

#### 2. MonthCalendarWidget (`mobile/lib/views/statistic/widgets/month_calendar_widget.dart`)

```dart
onDaySelected: (DateTime day) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(day);
  final data = await statisticProvider.fetchTransactionsByDate(formattedDate);
  _showBottomSheet(data);
}
```

### Khi Cô Hỏi Sâu Về Transactions By Date

**Q: Timezone được xử lý như thế nào?**
A: Backend dùng UTC để lưu trữ. Khi query, chuyển đổi date string thành UTC start/end của ngày để đảm bảo chính xác.

**Q: Nếu ngày không có giao dịch thì trả gì?**
A: Trả summary với totalIncome=0, totalExpense=0, net=0 và transactions là mảng rỗng.

**Q: Tại sao cần sort transactions theo date desc?**
A: Để hiển thị giao dịch mới nhất lên đầu trong bottom sheet.

---

## 📈 Tính Năng 7: Daily Stats

### 🎯 Nam - Tập Trung Vào Thống Kê Theo Ngày Trong Tháng

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ DAILY STATS FLOW                                        │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ Mobile:                                                  │
│  User mở màn hình thống kê tháng                       │
│   ↓                                                      │
│  StatisticProvider.fetchDailyStats(month, year)        │
│   ↓                                                      │
│  GET /api/statistics/daily?month=X&year=YYYY           │
│                                                          │
│ Backend:                                                 │
│  Routes: statistic_routes.js (daily endpoint)         │
│   ↓                                                      │
│  Controller: getDailyStats()                           │
│   ↓                                                      │
│  Service: getDailyStatsByMonth(userId, month, year)     │
│   │                                                     │
│   ├─ Tính start/end của tháng                          │
│   ├─ Aggregate transactions theo từng ngày             │
│   ├─ Tính totalIncome, totalExpense, net, count        │
│   └─ Trả {month, year, days}                          │
│                                                          │
│ Mobile:                                                  │
│  Hiển thị lịch tháng với màu sắc theo net value         │
│  (Xanh: net dương, Đỏ: net âm, Xám: không có giao dịch) │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/statistic_routes.js`)

```javascript
router.get(
  "/daily",
  authenticate,
  validate(getDailyStatsSchema, "query"),
  getDailyStats,
);
```

#### 2. Controller (`backend/controllers/statistic.controller.js`)

```javascript
exports.getDailyStats = async (req, res, next) => {
  const userId = req.user._id;
  const { month, year } = req.query;

  const result = await statisticService.getDailyStatsByMonth(
    userId,
    parseInt(month),
    parseInt(year),
  );

  res.status(200).json(successResponse(200, "Fetched successfully", result));
};
```

#### 3. Service (`backend/services/statistic.service.js`)

```javascript
async function getDailyStatsByMonth(userId, month, year) {
  const startDate = new Date(Date.UTC(year, month - 1, 1, 0, 0, 0));
  const endDate = new Date(Date.UTC(year, month, 1, 0, 0, 0));

  const rows = await Transaction.aggregate([
    {
      $match: {
        userId: new mongoose.Types.ObjectId(userId),
        date: { $gte: startDate, $lt: endDate },
      },
    },
    {
      $group: {
        _id: {
          y: { $year: "$date" },
          m: { $month: "$date" },
          d: { $dayOfMonth: "$date" },
        },
        totalIncome: {
          $sum: { $cond: [{ $eq: ["$type", "income"] }, "$amount", 0] },
        },
        totalExpense: {
          $sum: { $cond: [{ $eq: ["$type", "expense"] }, "$amount", 0] },
        },
        transactionCount: { $sum: 1 },
      },
    },
    { $sort: { "_id.y": 1, "_id.m": 1, "_id.d": 1 } },
  ]);

  const days = rows.map((r) => ({
    date: `${r._id.y}-${String(r._id.m).padStart(2, "0")}-${String(
      r._id.d,
    ).padStart(2, "0")}`,
    totalIncome: r.totalIncome,
    totalExpense: r.totalExpense,
    net: r.totalIncome - r.totalExpense,
    transactionCount: r.transactionCount,
  }));

  return { month, year, days };
}
```

### Mobile Files

#### 1. StatisticProvider (`mobile/lib/data/providers/statistic_provider.dart`)

```dart
Future<Map<String, dynamic>> fetchDailyStats(int month, int year) async {
  final response = await _apiService.getDailyStats(month, year);
  if (response.success) {
    return response.data;
  }
  throw Exception('Failed to fetch daily stats');
}
```

#### 2. MonthCalendarWidget (`mobile/lib/views/statistic/widgets/month_calendar_widget.dart`)

```dart
void _loadMonthData() async {
  final dailyStats = await statisticProvider.fetchDailyStats(_currentMonth, _currentYear);
  _updateCalendarDots(dailyStats['days']);
}

void _updateCalendarDots(List<dynamic> days) {
  // Xanh: net > 0, Đỏ: net < 0, Xám: không có giao dịch
}
```

### Khi Cô Hỏi Sâu Về Daily Stats

**Q: Tại sao dùng aggregation thay vì query thông thường?**
A: Vì cần group và tính toán theo từng ngày. Aggregation pipeline của MongoDB làm việc này hiệu quả hơn.

**Q: Nếu tháng không có giao dịch nào thì trả gì?**
A: Trả days là mảng rỗng, nhưng vẫn có month và year trong response.

**Q: TransactionCount dùng để làm gì?**
A: Để biết mỗi ngày có bao nhiêu giao dịch, có thể dùng để hiển thị số lượng trên UI.

---

## 💰 Tính Năng 8: Monthly Budget

### 🎯 Ngọc Anh - Tập Trung Vào Quản Lý Mục Tiêu Chi Tiêu Tháng

### Luồng Hoạt Động

```
┌──────────────────────────────────────────────────────────┐
│ MONTHLY BUDGET FLOW                                      │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. GET BUDGET SUMMARY:                                   │
│    Mobile: StatisticProvider.fetchBudgetSummary()       │
│      ↓                                                   │
│    GET /api/statistics/budget?month=X&year=YYYY         │
│      ↓                                                   │
│    Controller getBudgetSummary():                       │
│      - Gọi service getBudgetSummary()                   │
│      - Service: Tính actualExpense từ transactions      │
│      - Lấy targetAmount từ budget collection            │
│      - Tính remaining = targetAmount - actualExpense    │
│      - Xác định status (safe, near, over)               │
│      - Trả {targetAmount, actualExpense, remaining, status}│
│                                                          │
│ 2. SAVE BUDGET:                                          │
│    Mobile: StatisticProvider.saveBudget()               │
│      ↓                                                   │
│    POST /api/statistics/budget                          │
│      Body: {month, year, targetAmount}                 │
│      ↓                                                   │
│    Controller saveBudget():                            │
│      - Tìm hoặc tạo budget record                      │
│      - Lưu targetAmount                                │
│      - Trả budget mới                                  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Backend Files

#### 1. Routes (`backend/routes/statistic_routes.js`)

```javascript
router.get("/budget", authenticate, validate(getBudgetSchema, "query"), getBudgetSummary);
router.post("/budget", authenticate, validate(saveBudgetSchema, "body"), saveBudget);
```

#### 2. Controller (`backend/controllers/statistic.controller.js`)

```javascript
exports.getBudgetSummary = async (req, res, next) => {
  const userId = req.user._id;
  const { month, year } = req.query;

  const result = await statisticService.getBudgetSummary(
    userId,
    parseInt(month),
    parseInt(year),
  );

  res.status(200).json(successResponse(200, "Fetched successfully", result));
};

exports.saveBudget = async (req, res, next) => {
  const userId = req.user._id;
  const { month, year, targetAmount } = req.body;

  const result = await statisticService.saveBudget(
    userId,
    parseInt(month),
    parseInt(year),
    targetAmount,
  );

  res.status(200).json(successResponse(200, "Saved successfully", result));
};
```

#### 3. Service (`backend/services/statistic.service.js`)

```javascript
async function getBudgetSummary(userId, month, year) {
  // 1. Lấy hoặc tạo budget record
  let budget = await Budget.findOne({ userId, month, year }).lean();
  const targetAmount = budget?.targetAmount ?? 0;

  // 2. Tính actual expense từ transactions
  const actualExpense = await getMonthlyExpense(userId, month, year);

  // 3. Tính remaining và status
  const remaining = targetAmount - actualExpense;
  const status = computeBudgetStatus(targetAmount, actualExpense);

  return { month, year, targetAmount, actualExpense, remaining, status };
}

async function saveBudget(userId, month, year, targetAmount) {
  let budget = await Budget.findOne({ userId, month, year });
  
  if (budget) {
    budget.targetAmount = targetAmount;
  } else {
    budget = new Budget({ userId, month, year, targetAmount });
  }
  
  await budget.save();
  return budget;
}

function computeBudgetStatus(targetAmount, actualExpense) {
  if (targetAmount === 0) return "not_set";
  
  const percentage = (actualExpense / targetAmount) * 100;
  
  if (percentage >= 100) return "over";
  if (percentage >= 80) return "near";
  return "safe";
}
```

#### 4. Model (`backend/models/budget.model.js`)

```javascript
{
  userId: ObjectId,
  month: Number, // 1-12
  year: Number,
  targetAmount: Number,
  timestamps: { createdAt, updatedAt }
}
```

### Mobile Files

#### 1. StatisticProvider (`mobile/lib/data/providers/statistic_provider.dart`)

```dart
Future<Map<String, dynamic>> fetchBudgetSummary(int month, int year) async {
  final response = await _apiService.getBudgetSummary(month, year);
  if (response.success) {
    return response.data;
  }
  throw Exception('Failed to fetch budget summary');
}

Future<bool> saveBudget(int month, int year, double targetAmount) async {
  final response = await _apiService.saveBudget(month, year, targetAmount);
  return response.success;
}
```

#### 2. MonthBudgetCardWidget (`mobile/lib/views/statistic/widgets/month_budget_card_widget.dart`)

```dart
void _loadBudgetData() async {
  final budgetData = await statisticProvider.fetchBudgetSummary(_month, _year);
  setState(() {
    _targetAmount = budgetData['targetAmount'];
    _actualExpense = budgetData['actualExpense'];
    _remaining = budgetData['remaining'];
    _status = budgetData['status'];
  });
}

void _onSaveBudget() async {
  final success = await statisticProvider.saveBudget(_month, _year, _targetAmount);
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã lưu mục tiêu tháng')),
    );
  }
}
```

### Khi Cô Hỏi Sâu Về Monthly Budget

**Q: Nếu chưa set targetAmount thì status là gì?**
A: Status là "not_set". UI sẽ hiển thị thông báo "Chưa đặt mục tiêu".

**Q: ActualExpense được tính như thế nào?**
A: Từ tổng tất cả expense transactions trong tháng, không phân biệt wallet.

**Q: Ngưỡng nào để xác định status near/over?**
A: Near: chi tiêu >= 80% mục tiêu, Over: chi tiêu >= 100% mục tiêu.

---

## 🎯 Cheat Sheet - Câu Hỏi Thường Gặp Từ Cô Giáo

### 📌 Câu Hỏi Về Architecture

**Q: Cách hoạt động của REST API là gì?**
A:

1. Mobile gửi HTTP request (GET/POST/PUT/DELETE) → Backend
2. Request có header Authorization: Bearer <JWT token>
3. Backend routes nhận → Controller xử lý logic → Service làm tính toán
4. Service gọi Models để truy cập Database
5. Response trả về JSON → Mobile parse → UI update

**Q: JWT token dùng để làm gì?**
A: Xác thực danh tính user. Khi user login, backend tạo token chứa userId. Mỗi request sau đó, mobile gửi token này. Backend kiểm tra token hợp lệ rồi xác nhận đó là user nào.

**Q: Tại sao phải có middleware?**
A: Middleware là những hàm chạy trước controller để:

- `authenticate`: Check JWT token
- `validate`: Check input hợp lệ
- `errorHandler`: Xử lý lỗi
  Giúp code sạch, tái sử dụng.

### 📌 Câu Hỏi Về Dữ Liệu

**Q: Dữ liệu lưu ở đâu?**
A: MongoDB database trên cloud (Render). Dữ liệu không bao giờ lưu trên mobile, chỉ lưu temporary trong SharedPreferences để load nhanh lần tiếp theo.

**Q: Nếu database bị mất, dữ liệu có khôi phục được không?**
A: Render có automatic backup. Nếu muốn chắc chắn, nên dùng MongoDB Atlas có backup plan.

**Q: Dữ liệu của người A có nhìn thấy dữ liệu của người B không?**
A: Không. Vì mỗi query đều filter `{ userId: req.user._id }`. Backend chỉ trả dữ liệu của user đó.

### 📌 Câu Hỏi Về Performance

**Q: Nếu người dùng có 10,000 giao dịch, sao vậy?**
A: Chúng tôi dùng pagination. Khi fetch, backend chỉ trả 20 giao dịch/trang. Mobile có thể gọi lại để lấy trang tiếp theo.

**Q: Nếu user ngang công ty (500 người) dùng cùng lúc, server có chịu được không?**
A: Render free tier có giới hạn. Để scale, cần:

- Thêm index database
- Caching layer (Redis)
- Load balancing
- Premium hosting

### 📌 Câu Hỏi Về Bảo Mật

**Q: Password được lưu như thế nào?**
A: Không bao giờ lưu password nguyên bản. Backend dùng bcrypt để hash password trước khi lưu. Khi login, so sánh hash của password nhập với hash trong DB.

**Q: Nếu ai đó intercept network traffic, có lấy được token không?**
A: Có. Để an toàn, phải dùng HTTPS (không phải HTTP). Ứng dụng đang dùng HTTPS (Render + ngrok).

**Q: Nếu token bị lộ, sao vậy?**
A: Người đó có thể dùng token để gọi API như user thực. Để ngăn, nên:

- Đặt token expiry (hết hạn sau 1 giờ)
- Dùng refresh token để cấp token mới
- Logout để xóa token

### 📌 Câu Hỏi Về Tính Năng Cụ Thể

**Q: Tại sao lại có 3 loại ví (tiền mặt, ngân hàng, ví điện tử)?**
A: Mô phỏng quản lý tiền thực tế. Người dùng có thể:

- Chuyển tiền từ ATM (ngân hàng) → Ví điện tử (Momo) để chi tiêu
- Chuyển từ tiền mặt → Ngân hàng để dự trữ
  Cách cô giáo quản lý tiền cá nhân.

**Q: Balance của mỗi ví được tính như thế nào?**
A:

```
balance = Σ(income transactions) - Σ(expense transactions) + transfers_in - transfers_out
```

Backend tính lại mỗi lần fetch để đảm bảo chính xác.

**Q: Nếu user tạo giao dịch "chi tiêu" nhưng quay lại sửa thành "thu nhập", sao vậy?**
A: Backend sẽ:

1. Reverse delta cũ (trả lại tiền)
2. Apply delta mới (trừ tiền cách khác)
   Kết quả: balance sẽ thay đổi chính xác.

---

## 📄 Summary Cho Mỗi Thành Viên

### **Minh (Team Lead)**

✅ Phải hiểu: Toàn bộ architecture, Auth flow, JWT, API design
❓ Câu hỏi tiên lượng: "Cơ chế hoạt động của hệ thống?", "Làm sao đảm bảo security?", "Nếu server bị lỗi sao?"

### **Ngọc Anh**

✅ Phải hiểu: Wallet balance reconciliation, Transfer logic, Ownership check
❓ Câu hỏi tiên lượng: "Số dư được tính thế nào?", "Nếu transfer không thành công sao?", "Balance có bao giờ âm không?"

### **Chúc**

✅ Phải hiểu: Wallet APIs, Initialize wallets, GET endpoints
❓ Câu hỏi tiên lượng: "Tại sao mỗi user có 3 ví?", "Fetch wallets trả gì?", "Nếu user mới, ví được tạo khi nào?"

### **Nam**

✅ Phải hiểu: Statistics calculation, Monthly aggregation, Date range query
❓ Câu hỏi tiên lượng: "Thống kê tháng được tính như thế nào?", "Nếu xóa giao dịch, thống kê tự cập nhật không?", "Có thể xem thống kê quý/năm được không?"

### **Xuân**

✅ Phải hiểu: Transaction CRUD, Filtering, Balance update, Validation
❓ Câu hỏi tiên lượng: "Tạo giao dịch có làm thay đổi wallet balance không?", "Pagination hoạt động như thế nào?", "Search dùng regex hay LIKE?"

---

## 🚀 Khi Chuẩn Bị Cho Buổi Báo Cáo

1. **Trước 2 ngày**: Đọc kỹ file hướng dẫn này. Mỗi người focus vào phần của mình.
2. **Trước 1 ngày**: Trace code từ routes → controllers → services → models. Vẽ diagram nếu cần.
3. **Hôm báo cáo**:
   - Minh: Mở app demo, giải thích flow tổng thể
   - Các thành viên: Khi cô hỏi tính năng, nhanh chóng nói được luồng code
   - Luôn có sẵn API docs (Swagger UI) để chỉ endpoint khi cần
4. **Nếu cô hỏi "sâu"**:
   - Minh chỉ đến file cụ thể
   - Người chuyên trách giải thích logic đó
   - Nếu không biết, nói "để tôi kiểm tra code rồi quay lại" (không nói "không biết")

---

## 📌 Ghi Chú Cập Nhật

### Phiên bản 1.0 (21/04/2026)

- ✅ 5 tính năng chính hoàn thiện
- ❌ Lịch tháng (Calendar) - Chưa có backend
- ❌ Cảnh báo chi tiêu (Budget Alert) - Chưa có backend
- ❌ Nhóm (Group APIs) - Phase 2
- ❌ Thành viên nhóm (Members APIs) - Phase 2
- ❌ Giao dịch nhóm (Group Transactions) - Phase 2

### Để Cập Nhật Lần Sau

Khi nhóm hoàn thiện thêm tính năng, cập nhật file này bằng cách:

1. **Lịch Tháng (Calendar)**
   - Thêm section "Tính Năng 6: Calendar Management"
   - Liệt kê routes, controller, service, model
   - Giải thích luồng hoạt động
   - Nêu câu hỏi có thể gặp

2. **Cảnh Báo Chi Tiêu (Budget Alert)**
   - Thêm section "Tính Năng 7: Budget Alerts"
   - Giải thích cách tính budget vs spending
   - Cách trigger alert
   - Xử lý notification

3. **Nhóm (Group APIs) - Phase 2**
   - Thêm section "Tính Năng 8: Group Management"
   - 5 endpoints: CREATE, READ-list, READ-detail, UPDATE, DELETE

4. **Giao Dịch Nhóm (Group Transactions) - Phase 2**
   - Thêm section "Tính Năng 9: Group Transactions"
   - Khác biệt với personal transactions
   - Split logic

5. **Cập nhật phần "Không Trình Bày"** khi các tính năng hoàn thành

---

**Good luck với buổi báo cáo! 🚀**

**Tài liệu này có thể được cập nhật theo từng giai đoạn phát triển của dự án.**
