# MongoDB ERD (Entity Relationship Diagram) - SmartSpender

## 📊 Sơ Đồ Quan Hệ Thực Thể (ERD) - MongoDB Collections

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SMARTSPENDER - MongoDB Schema                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│           USERS Collection               │
├──────────────────────────────────────────┤
│ _id: ObjectId (PK)                      │
│ email: String (Unique, Index)           │
│ password: String (Hash)                 │
│ fullName: String                        │
│ createdAt: Date                         │
│ updatedAt: Date                         │
└──────────────────────────────────────────┘
           │
           │ 1 ──── N
           │ (Reference)
           │
      ┌────┴────────────────────────────┬───────────┬─────────────┐
      │                                  │           │             │
      ▼                                  ▼           ▼             ▼
┌──────────────────────────┐  ┌─────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
│   WALLETS Collection     │  │ TRANSACTIONS        │  │ WALLET_TRANSFERS     │  │ NOTIFICATIONS        │
├──────────────────────────┤  │ Collection          │  │ Collection           │  │ Collection           │
│ _id: ObjectId (PK)       │  ├─────────────────────┤  ├──────────────────────┤  ├──────────────────────┤
│ userId: ObjectId (FK)    │  │ _id: ObjectId (PK)  │  │ _id: ObjectId (PK)   │  │ _id: ObjectId (PK)   │
│ walletType: String       │  │ userId: ObjectId    │  │ userId: ObjectId     │  │ userId: ObjectId (FK)│
│   (cash|bank|ewallet)    │  │   (FK -> Users)     │  │   (FK -> Users)      │  │ title: String        │
│ balance: Number          │  │ amount: Number      │  │ fromWalletType:      │  │ message: String      │
│ name: String             │  │ type: String        │  │   String             │  │ type: String         │
│ description: String      │  │   (income|expense)  │  │ toWalletType:        │  │ isRead: Boolean      │
│ lastUpdated: Date        │  │ walletType: String  │  │   String             │  │ createdAt: Date      │
│ createdAt: Date          │  │ category: String    │  │ amount: Number       │  │ updatedAt: Date      │
│ updatedAt: Date          │  │ date: Date          │  │ note: String         │  └──────────────────────┘
│                          │  │ note: String        │  │ date: Date           │
│ Index:                   │  │ title: String       │  │ createdAt: Date      │
│ - userId: 1, type: 1    │  │ createdAt: Date     │  │ updatedAt: Date      │
│                          │  │ updatedAt: Date     │  │                      │
│                          │  │                     │  │ Index:               │
│                          │  │ Index:              │  │ - userId: 1,         │
│                          │  │ - userId: 1,        │  │   date: -1           │
│                          │  │   date: -1          │  │                      │
│                          │  │ - userId: 1,        │  └──────────────────────┘
│                          │  │   type: 1,          │
│                          │  │   category: 1       │
│                          │  │ - title: text,      │
│                          │  │   note: text        │
│                          │  └─────────────────────┘
└──────────────────────────┘

```

## 📋 Quan Hệ Giữa Các Collections

### 1. **USERS ↔ WALLETS** (1:N - One-to-Many)

- **Relationship Type**: Referenced (Foreign Key)
- **Mô tả**: Mỗi người dùng (User) có nhiều ví (Wallets)
- **Default Wallets**: 3 ví mặc định cho mỗi người dùng
  - `cash` - Tiền mặt
  - `bank` - Ngân hàng
  - `ewallet` - Ví điện tử

```javascript
// Field trong Wallets:
userId: ObjectId; // -> Users._id
```

---

### 2. **USERS ↔ TRANSACTIONS** (1:N - One-to-Many)

- **Relationship Type**: Referenced (Foreign Key)
- **Mô tả**: Mỗi người dùng có nhiều giao dịch (Transactions)
- **Transaction Types**:
  - `income` - Thu nhập
  - `expense` - Chi tiêu
- **Indexed Fields**: `userId` + `date` (để tối ưu hóa query lịch sử giao dịch)

```javascript
// Fields trong Transactions:
userId: ObjectId; // -> Users._id
walletType: String; // Liên kết tới Wallets (by type)
category: String; // Danh mục chi tiêu
date: Date; // Ngày giao dịch
```

---

### 3. **USERS ↔ WALLET_TRANSFERS** (1:N - One-to-Many)

- **Relationship Type**: Referenced (Foreign Key)
- **Mô tả**: Mỗi người dùng có nhiều lần chuyển tiền giữa ví
- **Transfer Logic**:
  - Chuyển từ ví nguồn (`fromWalletType`)
  - Đến ví đích (`toWalletType`)
  - Cùng user, không cross-user transfer

```javascript
// Fields trong WalletTransfers:
userId: ObjectId; // -> Users._id
fromWalletType: String; // Ví nguồn (cash|bank|ewallet)
toWalletType: String; // Ví đích (cash|bank|ewallet)
amount: Number; // Số tiền chuyển
```

---

### 4. **USERS ↔ NOTIFICATIONS** (1:N - One-to-Many)

- **Relationship Type**: Referenced (Foreign Key)
- **Mô tả**: Mỗi người dùng nhận nhiều thông báo
- **Notification Types**:
  - `general` - Thông báo chung
  - (có thể mở rộng: transaction, wallet, etc.)

```javascript
// Fields trong Notifications:
userId: ObjectId; // -> Users._id
isRead: Boolean; // Trạng thái đọc thông báo
```

---

## 🔑 Chỉ Mục (Indexes)

| Collection          | Index                          | Purpose                                |
| ------------------- | ------------------------------ | -------------------------------------- |
| **Users**           | `email` (unique)               | Unique constraint + fast lookup        |
| **Wallets**         | `userId` + `walletType`        | Query ví theo user và type             |
| **Transactions**    | `userId` + `date` (desc)       | Query giao dịch theo user và thời gian |
| **Transactions**    | `userId` + `type` + `category` | Query thống kê theo loại và danh mục   |
| **Transactions**    | `title` + `note` (text)        | Full-text search giao dịch             |
| **WalletTransfers** | `userId` + `date` (desc)       | Query lịch sử chuyển tiền              |
| **Notifications**   | `userId`                       | Query thông báo theo user              |

---

## 💾 Quan Hệ Embedding vs Referencing

### **Phương pháp sử dụng: REFERENCING** (được sử dụng)

- ✅ **Lý do**: Dữ liệu linh hoạt, không bị trùng lặp, dễ cập nhật
- ✅ **Thích hợp cho**: SmartSpender vì thường query từng collection riêng
- ✅ **Hiệu suất**: Có index => query nhanh

### **Không sử dụng Embedding** vì:

- ❌ WalletType là string enum, thay đổi hiếm khi, nhưng quan hệ là 1:N
- ❌ Transactions có thể bị cập nhật hoặc xóa, nếu embed vào Wallets sẽ phức tạp
- ❌ Notifications là tạm thời, nên để riêng

---

## 📐 Clean Architecture Mapping

```
┌─────────────────────────────────────────────────────────────────┐
│                    MONGODB COLLECTIONS                         │
│                     (Presentation)                             │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    CONTROLLERS (API Layer)                      │
│  - auth.controller.js                                           │
│  - transaction.controller.js                                    │
│  - wallet.controller.js                                         │
│  - notification.controller.js                                   │
│  - statistic.controller.js                                      │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    SERVICES (Business Logic)                    │
│  - auth.service.js                                              │
│  - transaction.service.js                                       │
│  - wallet.service.js                                            │
│  - notification.service.js                                      │
│  - statistic.service.js                                         │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    MODELS (Entity / Schema)                     │
│  - User                    (Entity: người dùng)                 │
│  - Wallet                  (Entity: ví tiền)                    │
│  - Transaction             (Entity: giao dịch)                  │
│  - WalletTransfer          (Entity: chuyển tiền)                │
│  - Notification            (Entity: thông báo)                  │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌─────────────────────────────────────────────────────────────────┐
│                    MONGODB DATABASE                             │
│  - users collection                                             │
│  - wallets collection                                           │
│  - transactions collection                                      │
│  - wallettransfers collection                                   │
│  - notifications collection                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Các Trường Hợp Sử Dụng (Use Cases)

### 1. **Tạo Giao Dịch (Create Transaction)**

```
User → Transaction.insert()
        + Wallet.findByIdAndUpdate() [update balance]
        + Notification.insert() [notify if needed]
```

### 2. **Thống Kê Chi Tiêu (Get Statistics)**

```
User → Transaction.aggregate()
        [match: userId + date range, group: by category/type]
```

### 3. **Chuyển Tiền (Wallet Transfer)**

```
User → WalletTransfer.insert()
     → Wallet.updateOne() [fromWallet -= amount]
     → Wallet.updateOne() [toWallet += amount]
     → Notification.insert() [notify success]
```

### 4. **Lấy Thông Báo (Get Notifications)**

```
User → Notification.find({userId, isRead: false})
```

---

## 🔄 Data Flow Diagram

```
┌───────────────────────────────────────────────────────────────────┐
│                     SMARTSPENDER DATA FLOW                        │
└───────────────────────────────────────────────────────────────────┘

1. USER REGISTRATION / LOGIN
   ┌─────┐
   │User │
   └────┬┘
        │
        ▼
   ┌──────────────────┐
   │ Auth Service     │
   │ - Hash password  │
   │ - Create token   │
   └────┬─────────────┘
        │
        ▼
   ┌──────────────────┐
   │ Users Collection │
   └──────────────────┘

2. CREATE TRANSACTION
   ┌──────────────┐
   │ Transaction  │
   │ (New Record) │
   └────┬─────────┘
        │
        ▼
   ┌──────────────────────┐
   │ Validation           │
   │ - Check user exists  │
   │ - Check amount > 0   │
   │ - Check category     │
   └────┬─────────────────┘
        │
        ├──────────────────────────┬────────────────────┐
        ▼                          ▼                    ▼
   ┌──────────────┐      ┌─────────────────┐  ┌──────────────────┐
   │ Transaction  │      │ Wallet Update   │  │ Notification     │
   │ Insert       │      │ Update balance  │  │ Create           │
   └──────────────┘      └─────────────────┘  └──────────────────┘

3. WALLET TRANSFER
   ┌──────────────────────┐
   │ Transfer Request     │
   │ (from, to, amount)   │
   └────┬─────────────────┘
        │
        ▼
   ┌──────────────────────┐
   │ Validation           │
   │ - Check balance      │
   │ - Check wallet exist │
   └────┬─────────────────┘
        │
        ├──────────┬──────────┬──────────────┐
        ▼          ▼          ▼              ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────────┐
   │Wallet1  │ │Wallet2  │ │Transfer │ │Notification │
   │Decrease │ │Increase │ │Insert   │ │Create        │
   └─────────┘ └─────────┘ └─────────┘ └──────────────┘
```

---

## 📝 Ghi Chú & Tối Ưu

### ✅ Điểm Mạnh

- **Simple & Clear**: Mô hình dữ liệu rõ ràng
- **Scalable**: Dễ thêm mới collections hoặc fields
- **Indexed**: Các trường quan trọng đều được index
- **Referencing**: Giảm trùng lặp dữ liệu

### ⚠️ Cần Chú Ý

- **Data Consistency**: Khi xóa User, cần xóa/cập nhật Wallets, Transactions, etc.
- **Cascade Delete**: Implement cascading delete trong service layer
- **Transaction Atomicity**: Nếu cần transaction ACID (cross-collection), cần dùng MongoDB Transactions (4.0+)

### 🚀 Cải Tiến Tương Lai

- Thêm **Budget Collection** (ngân sách hàng tháng)
- Thêm **Recurring Transactions** (giao dịch lặp lại)
- Thêm **Shared Wallet** (ví chung cho nhóm)
- Thêm **Transaction Tags** (tag giao dịch cho filtering)

---

## 📌 Summary Table

| Collection          | Document Count       | Purpose             | Primary Query       |
| ------------------- | -------------------- | ------------------- | ------------------- |
| **users**           | 1000s                | User accounts       | email, \_id         |
| **wallets**         | ~3,000s (3 per user) | User wallets        | userId + walletType |
| **transactions**    | 100,000s             | Transaction history | userId + date       |
| **wallettransfers** | 10,000s              | Transfer history    | userId + date       |
| **notifications**   | 100,000s             | Notifications       | userId + isRead     |
