# MongoDB Schema Details - SmartSpender

## 📚 Chi Tiết Cấu Trúc Các Collections

### 1️⃣ **Users Collection** (Người Dùng)

#### Purpose

Lưu trữ thông tin cơ bản của người dùng hệ thống.

#### Schema Definition

```javascript
{
  _id: ObjectId,                    // MongoDB internal ID
  email: String,                    // Unique, indexed, lowercase
  password: String,                 // Hash (bcrypt)
  fullName: String,                 // Tên đầy đủ
  createdAt: Date,                  // Timestamp tự động
  updatedAt: Date                   // Timestamp tự động
}
```

#### Key Features

- ✅ `email` là duy nhất (unique index)
- ✅ `password` không bao giờ được trả về trong response
- ✅ Timestamps tự động cập nhật

#### Example Document

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  email: "user@example.com",
  password: "$2b$10$encrypted_hash_here",
  fullName: "Nguyễn Văn A",
  createdAt: ISODate("2026-05-09T10:00:00Z"),
  updatedAt: ISODate("2026-05-09T10:00:00Z")
}
```

#### Indexes

```javascript
{
  email: 1,          // Unique index for fast login
  createdAt: 1       // For sorting users by registration date
}
```

---

### 2️⃣ **Wallets Collection** (Ví Tiền)

#### Purpose

Quản lý nhiều ví tiền cho mỗi người dùng (Tiền mặt, Ngân hàng, Ví điện tử).

#### Schema Definition

```javascript
{
  _id: ObjectId,                              // MongoDB internal ID
  userId: ObjectId,                           // Reference to Users
  walletType: String,                         // Enum: 'cash' | 'bank' | 'ewallet'
  balance: Number,                            // Current balance (VND)
  name: String,                               // Display name
  description: String,                        // Optional description
  lastUpdated: Date,                          // Last balance update
  createdAt: Date,                            // Timestamp
  updatedAt: Date                             // Timestamp
}
```

#### Wallet Types

- `cash` → Tiền mặt
- `bank` → Ngân hàng
- `ewallet` → Ví điện tử (Momo, ZaloPay, etc.)

#### Key Features

- ✅ 3 ví mặc định tạo khi user đăng ký
- ✅ Balance >= 0 (không âm)
- ✅ Indexed by userId + walletType

#### Example Document

```javascript
{
  _id: ObjectId("507f191e810c19729de860ea"),
  userId: ObjectId("507f1f77bcf86cd799439011"),
  walletType: "cash",
  balance: 1500000,                    // 1.5M VND
  name: "Tiền mặt",
  description: "Ví tiền mặt hàng ngày",
  lastUpdated: ISODate("2026-05-09T15:30:00Z"),
  createdAt: ISODate("2026-05-01T10:00:00Z"),
  updatedAt: ISODate("2026-05-09T15:30:00Z")
}
```

#### Indexes

```javascript
{
  userId: 1, walletType: 1           // Find wallet by user and type
}
```

#### Business Rules

- Mỗi user có đúng 3 wallets (tự động tạo)
- Balance không thể âm
- Cập nhật balance khi có transaction hoặc transfer

---

### 3️⃣ **Transactions Collection** (Giao Dịch)

#### Purpose

Ghi lại tất cả giao dịch chi tiêu hoặc thu nhập của người dùng.

#### Schema Definition

```javascript
{
  _id: ObjectId,                              // MongoDB internal ID
  userId: ObjectId,                           // Reference to Users
  amount: Number,                             // Transaction amount
  type: String,                               // 'income' | 'expense'
  walletType: String,                         // Enum: 'cash' | 'bank' | 'ewallet'
  category: String,                           // Category (from constants)
  date: Date,                                 // Transaction date
  note: String,                               // Optional note
  title: String,                              // Transaction title
  createdAt: Date,                            // Timestamp
  updatedAt: Date                             // Timestamp
}
```

#### Transaction Types

```javascript
type: {
  ("income", // Thu nhập: lương, thưởng, etc.
    "expense"); // Chi tiêu: ăn, mua sắm, etc.
}

walletType: {
  ("cash", // Tiền mặt
    "bank", // Ngân hàng
    "ewallet"); // Ví điện tử
}

category: [
  // EXPENSE CATEGORIES
  "food", // Ăn uống
  "transportation", // Giao thông
  "shopping", // Mua sắm
  "entertainment", // Giải trí
  "utilities", // Tiện ích
  "health", // Y tế
  "education", // Giáo dục
  "other", // Khác

  // INCOME CATEGORIES
  "salary", // Lương
  "bonus", // Thưởng
  "investment", // Đầu tư
  "business", // Kinh doanh
  "gift", // Quà tặng
  "other_income", // Khác
];
```

#### Key Features

- ✅ Indexed by userId + date (DESC) → lấy lịch sử giao dịch
- ✅ Indexed by userId + type + category → thống kê
- ✅ Full-text search trên title + note
- ✅ Amount >= 0

#### Example Documents

**Income Transaction**

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439012"),
  userId: ObjectId("507f1f77bcf86cd799439011"),
  amount: 10000000,                   // 10M VND
  type: "income",
  walletType: "bank",
  category: "salary",
  date: ISODate("2026-05-01T00:00:00Z"),
  note: "Lương tháng 5",
  title: "Lương nhận từ công ty",
  createdAt: ISODate("2026-05-01T10:00:00Z"),
  updatedAt: ISODate("2026-05-01T10:00:00Z")
}
```

**Expense Transaction**

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439013"),
  userId: ObjectId("507f1f77bcf86cd799439011"),
  amount: 250000,                     // 250K VND
  type: "expense",
  walletType: "cash",
  category: "food",
  date: ISODate("2026-05-09T12:30:00Z"),
  note: "Ăn cơm trưa với bạn",
  title: "Ăn trưa",
  createdAt: ISODate("2026-05-09T12:30:00Z"),
  updatedAt: ISODate("2026-05-09T12:30:00Z")
}
```

#### Indexes

```javascript
{
  userId: 1, date: -1                        // Query history by date
}
{
  userId: 1, type: 1, category: 1            // For statistics
}
{
  title: 'text', note: 'text'                // Full-text search
}
```

#### Business Rules

- Amount > 0
- Type: income hoặc expense
- Category phải hợp lệ (từ constants)
- Date không thể trong tương lai quá xa

---

### 4️⃣ **WalletTransfers Collection** (Chuyển Tiền)

#### Purpose

Ghi lại tất cả các lần chuyển tiền giữa các ví (nội bộ).

#### Schema Definition

```javascript
{
  _id: ObjectId,                              // MongoDB internal ID
  userId: ObjectId,                           // Reference to Users
  fromWalletType: String,                     // Source wallet type
  toWalletType: String,                       // Destination wallet type
  amount: Number,                             // Transfer amount
  note: String,                               // Optional note
  date: Date,                                 // Transfer date
  createdAt: Date,                            // Timestamp
  updatedAt: Date                             // Timestamp
}
```

#### Key Features

- ✅ Internal transfer (cùng user)
- ✅ Amount > 0
- ✅ Indexed by userId + date

#### Example Document

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439014"),
  userId: ObjectId("507f1f77bcf86cd799439011"),
  fromWalletType: "bank",
  toWalletType: "cash",
  amount: 500000,                     // 500K VND
  note: "Rút tiền từ ngân hàng",
  date: ISODate("2026-05-09T14:00:00Z"),
  createdAt: ISODate("2026-05-09T14:00:00Z"),
  updatedAt: ISODate("2026-05-09T14:00:00Z")
}
```

#### Indexes

```javascript
{
  userId: 1, date: -1                 // Query transfer history
}
```

#### Business Rules

- fromWalletType !== toWalletType
- Amount > 0
- User phải có cả 2 ví (from + to)
- Số dư từ ví phải >= amount
- Không chuyển tiền sang chính ví đó

#### Transaction Logic (Atomic Operation)

```javascript
1. Kiểm tra balance của fromWallet >= amount
2. Insert WalletTransfer document
3. Update fromWallet: balance -= amount
4. Update toWallet: balance += amount
5. Create Notification nếu success
```

---

### 5️⃣ **Notifications Collection** (Thông Báo)

#### Purpose

Lưu trữ thông báo cho người dùng về các hành động quan trọng.

#### Schema Definition

```javascript
{
  _id: ObjectId,                              // MongoDB internal ID
  userId: ObjectId,                           // Reference to Users
  title: String,                              // Notification title
  message: String,                            // Notification message
  type: String,                               // Type (general, transaction, etc.)
  isRead: Boolean,                            // Read status
  createdAt: Date,                            // Timestamp
  updatedAt: Date                             // Timestamp
}
```

#### Notification Types

```javascript
type: {
  ("general", // Thông báo chung
    "transaction", // Giao dịch mới
    "transfer", // Chuyển tiền
    "warning", // Cảnh báo
    "achievement"); // Thành tựu
}
```

#### Key Features

- ✅ isRead = false: chưa đọc
- ✅ Indexed by userId
- ✅ Có thể xóa notification cũ (TTL)

#### Example Document

```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439015"),
  userId: ObjectId("507f1f77bcf86cd799439011"),
  title: "Giao dịch thành công",
  message: "Bạn vừa thực hiện giao dịch chi tiêu 250K thành công.",
  type: "transaction",
  isRead: false,
  createdAt: ISODate("2026-05-09T12:30:00Z"),
  updatedAt: ISODate("2026-05-09T12:30:00Z")
}
```

#### Indexes

```javascript
{
  userId: 1, isRead: 1                // Query unread notifications
}
{
  createdAt: 1,                       // TTL index (auto delete old)
  expireAfterSeconds: 2592000         // Delete after 30 days
}
```

#### Business Rules

- Mỗi transaction/transfer tạo 1 notification
- Notification tự động được đánh dấu là đã đọc khi user xem
- TTL: Xóa notification sau 30 ngày

---

## 🔗 Relationship Summary

| Collection          | References     | Referenced By                                         | Cardinality |
| ------------------- | -------------- | ----------------------------------------------------- | ----------- |
| **Users**           | -              | Wallets, Transactions, WalletTransfers, Notifications | 1:N         |
| **Wallets**         | Users          | Transactions, WalletTransfers                         | N:1         |
| **Transactions**    | Users, Wallets | Notifications                                         | N:1         |
| **WalletTransfers** | Users, Wallets | Notifications                                         | N:1         |
| **Notifications**   | Users          | -                                                     | N:1         |

---

## 📊 Data Size Estimation

```
Assuming 10,000 users:

Users:              ~10,000 documents × 200 bytes = ~2 MB
Wallets:            ~30,000 documents × 300 bytes = ~9 MB
Transactions:       ~500,000 documents × 400 bytes = ~200 MB
WalletTransfers:    ~50,000 documents × 350 bytes = ~17.5 MB
Notifications:      ~1,000,000 documents × 300 bytes = ~300 MB

Total Estimated Size: ~530 MB (without indexes)
With Indexes: ~650-800 MB
```

---

## 🛡️ Data Validation & Constraints

### Field-level Validation

```javascript
// Amount fields
amount: {
  type: Number,
  min: [0.01, 'Amount must be greater than 0'],
  max: [1000000000, 'Amount is too large']
}

// Balance fields
balance: {
  type: Number,
  min: [0, 'Balance cannot be negative']
}

// String enums
type: {
  enum: ['income', 'expense']
}
category: {
  enum: VALID_CATEGORIES
}
```

### Application-level Validation (Service Layer)

- ✅ User authentication check
- ✅ Wallet existence validation
- ✅ Sufficient balance check
- ✅ Category validation
- ✅ Date range validation
- ✅ Duplicate transaction prevention

---

## 🔐 Security Considerations

1. **Password Hashing**: Sử dụng bcrypt, không lưu plain text
2. **JWT Tokens**: Token nên chứa userId, exp, role
3. **Rate Limiting**: Giới hạn số request trên API
4. **Input Validation**: Sanitize tất cả input
5. **Audit Trail**: Log tất cả thay đổi quan trọng
6. **Field-level Security**:
   - `password` select: false
   - Không expose internal IDs
   - Hash sensitive data

---

## 📈 Query Patterns

### Frequently Used Queries

**1. Get User Transactions for Report**

```javascript
db.transactions
  .find({
    userId: ObjectId("..."),
    date: {
      $gte: startDate,
      $lte: endDate,
    },
  })
  .sort({ date: -1 })
  .limit(100);
```

**2. Get Wallet Balance**

```javascript
db.wallets.findOne({
  userId: ObjectId("..."),
  walletType: "cash",
});
```

**3. Calculate Monthly Spending by Category**

```javascript
db.transactions.aggregate([
  {
    $match: {
      userId: ObjectId("..."),
      type: "expense",
      date: { $gte: monthStart, $lte: monthEnd },
    },
  },
  {
    $group: {
      _id: "$category",
      total: { $sum: "$amount" },
    },
  },
  {
    $sort: { total: -1 },
  },
]);
```

**4. Get Unread Notifications**

```javascript
db.notifications
  .find({
    userId: ObjectId("..."),
    isRead: false,
  })
  .sort({ createdAt: -1 })
  .limit(10);
```

---

## 🎯 Migration & Seeding

### Initial Data for New User

```javascript
// 1. Create User
user = {
  email: "user@example.com",
  password: hashedPassword,
  fullName: "Nguyễn Văn A",
};

// 2. Create 3 Default Wallets
wallets = [
  { userId, walletType: "cash", balance: 0, name: "Tiền mặt" },
  { userId, walletType: "bank", balance: 0, name: "Ngân hàng" },
  { userId, walletType: "ewallet", balance: 0, name: "Ví điện tử" },
];

// 3. Initialize Welcome Notification
notification = {
  userId,
  title: "Chào mừng",
  message: "Bạn đã tạo tài khoản thành công",
  type: "general",
};
```

---

## 📝 Notes & Future Enhancements

### Current Limitations

- ❌ Không support cross-user transactions
- ❌ Không support recurring transactions
- ❌ Không support budget tracking
- ❌ Không support transaction split

### Suggested Future Collections

```javascript
// Budget Collection
{
  userId: ObjectId,
  month: Number,
  year: Number,
  category: String,
  limit: Number,
  spent: Number
}

// RecurringTransactions Collection
{
  userId: ObjectId,
  title: String,
  amount: Number,
  frequency: String, // 'daily', 'weekly', 'monthly'
  nextDate: Date,
  isActive: Boolean
}

// Tags Collection
{
  userId: ObjectId,
  name: String,
  color: String
}

// TaggingMap (for Transactions)
{
  transactionId: ObjectId,
  tagId: ObjectId
}
```
