# 📊 Group Feature - Database Schema

**Phiên bản:** 1.0  
**Ngày tạo:** 14/4/2026  
**Người thiết kế:** Mai Huy Minh

---

## 📌 OVERVIEW - Tổng Quan 3 Collections

Bạn sẽ tạo **3 collections mới** để quản lý group feature:

| Collection      | Mục Đích                     | Primary Key      |
| --------------- | ---------------------------- | ---------------- |
| `groups`        | Lưu thông tin các nhóm       | `groupId (_id)`  |
| `group_members` | Lưu membership (user + role) | `memberId (_id)` |
| `group_wallets` | Lưu ví của nhóm              | `walletId (_id)` |

**Ghi chú:** Sửa collection `transactions` hiện tại bằng cách thêm field `groupId` (optional)

---

## 🗂️ COLLECTION 1: groups

**Mục đích:** Lưu thông tin nhóm chi tiêu

**MongoDB Schema Definition:**

```javascript
db.createCollection('groups', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'createdBy'],
      properties: {
        _id: {
          bsonType: 'objectId',
          description: 'ID duy nhất của nhóm',
        },
        name: {
          bsonType: 'string',
          minLength: 3,
          maxLength: 50,
          description: "Tên nhóm (ví: 'Du lịch Nha Trang')",
        },
        description: {
          bsonType: 'string',
          maxLength: 200,
          description: 'Mô tả chi tiết nhóm (optional)',
        },
        createdBy: {
          bsonType: 'objectId',
          description: 'User ID của người tạo nhóm (mặc định là admin)',
        },
        createdAt: {
          bsonType: 'date',
          description: 'Thời gian tạo',
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Thời gian cập nhật lần cuối',
        },
      },
    },
  },
});
```

**Indexes (để query nhanh):**

```javascript
// Index 1: Tìm nhanh groups được created bởi user
db.groups.createIndex({ createdBy: 1 });

// Index 2: Sắp xếp theo ngày tạo
db.groups.createIndex({ createdAt: -1 });
```

**Example Document:**

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "Du lịch Nha Trang",
  "description": "Chuyến đi tháng 5 cùng bạn bè",
  "createdBy": ObjectId("507f1f77bcf86cd799439010"),
  "createdAt": ISODate("2026-04-14T10:30:00.000Z"),
  "updatedAt": ISODate("2026-04-14T10:30:00.000Z")
}
```

---

## 👥 COLLECTION 2: group_members

**Mục đích:** Lưu mối quan hệ giữa users và groups (membership + role)

**Lý do tách riêng:**

- Một user có thể vào nhiều groups
- Một group có nhiều users
- Mỗi user trong group có role khác nhau (admin, member, viewer)

**MongoDB Schema Definition:**

```javascript
db.createCollection('group_members', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['groupId', 'userId', 'role'],
      properties: {
        _id: {
          bsonType: 'objectId',
          description: 'ID duy nhất của membership',
        },
        groupId: {
          bsonType: 'objectId',
          description: 'Foreign Key: groups._id',
        },
        userId: {
          bsonType: 'objectId',
          description: 'Foreign Key: users._id',
        },
        role: {
          enum: ['admin', 'member', 'viewer'],
          description:
            'Vai trò của user trong group: admin (full quyền), member (có), viewer (chỉ xem)',
        },
        joinedAt: {
          bsonType: 'date',
          description: 'Ngày user tham gia nhóm',
        },
      },
    },
  },
});
```

**Indexes:**

```javascript
// Index 1: Tìm members của một group (important!)
db.group_members.createIndex({ groupId: 1 });

// Index 2: Tìm groups của một user (important!)
db.group_members.createIndex({ userId: 1 });

// Index 3: Tìm member cụ thể (user + group) - UNIQUE
// Đảm bảo: Mỗi user chỉ vào một group 1 lần
db.group_members.createIndex({ groupId: 1, userId: 1 }, { unique: true });

// Index 4: Sắp xếp theo joinedAt
db.group_members.createIndex({ groupId: 1, joinedAt: -1 });
```

**Example Document:**

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439030"),
  "groupId": ObjectId("507f1f77bcf86cd799439011"),
  "userId": ObjectId("507f1f77bcf86cd799439010"),
  "role": "admin",
  "joinedAt": ISODate("2026-04-14T10:30:00.000Z")
}
```

---

## 💳 COLLECTION 3: group_wallets

**Mục đích:** Lưu ví (tài khoản chi tiêu) của mỗi nhóm

**Lý do:**

- Mỗi nhóm có thể có nhiều ví (ví: "Quỹ chính", "Quỹ ăn uống", "Quỹ xăng xe")
- Mỗi ví có balance (số tiền hiện tại)
- Giao dịch sẽ liên kết đến ví này

**MongoDB Schema Definition:**

```javascript
db.createCollection('group_wallets', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['groupId', 'name', 'currency'],
      properties: {
        _id: {
          bsonType: 'objectId',
          description: 'ID duy nhất của ví',
        },
        groupId: {
          bsonType: 'objectId',
          description: 'Foreign Key: groups._id',
        },
        name: {
          bsonType: 'string',
          minLength: 3,
          maxLength: 50,
          description: "Tên ví (ví: 'Quỹ chính', 'Ăn uống')",
        },
        balance: {
          bsonType: 'number',
          description: 'Số dư hiện tại của ví (VND)',
        },
        currency: {
          enum: ['VND', 'USD', 'EUR'],
          description: "Đơn vị tiền tệ (default 'VND')",
        },
        createdAt: {
          bsonType: 'date',
          description: 'Ngày tạo ví',
        },
        updatedAt: {
          bsonType: 'date',
          description: 'Ngày cập nhật lần cuối (số dư thay đổi)',
        },
      },
    },
  },
});
```

**Indexes:**

```javascript
// Index 1: Tìm ví của một group
db.group_wallets.createIndex({ groupId: 1 });

// Index 2: Tìm ví theo groupId + name (để check tên unique)
db.group_wallets.createIndex({ groupId: 1, name: 1 });

// Index 3: Sắp xếp theo ngày tạo
db.group_wallets.createIndex({ groupId: 1, createdAt: -1 });
```

**Example Document:**

```json
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "groupId": ObjectId("507f1f77bcf86cd799439011"),
  "name": "Quỹ chính",
  "balance": 5000000,
  "currency": "VND",
  "createdAt": ISODate("2026-04-14T11:00:00.000Z"),
  "updatedAt": ISODate("2026-04-14T12:00:00.000Z")
}
```

---

## 🔄 MODIFY COLLECTION 4: transactions (Hiện Tại)

**Thêm vào transaction schema:**

```javascript
db.transactions.updateMany(
  {},
  {
    $set: {
      groupId: null, // null = giao dịch cá nhân, có ObjectId = giao dịch nhóm
    },
  }
);

// Thêm index để tìm nhanh transactions của group
db.transactions.createIndex({ groupId: 1 });

// Tìm transactions của group + wallet
db.transactions.createIndex({ groupId: 1, walletId: 1 });
```

**Updated Fields:**

| Field      | Type             | Mô Tả                                                   |
| ---------- | ---------------- | ------------------------------------------------------- |
| `groupId`  | ObjectId \| null | Null = giao dịch cá nhân, ObjectId = giao dịch nhóm     |
| `walletId` | ObjectId         | Ví này liên kết đến group_wallets (nếu groupId != null) |

---

## 📋 QUICK SETUP GUIDE

**Để apply schema này, bạn làm theo các bước:**

### Bước 1: Connect MongoDB

```bash
# Bật MongoDB shell
mongosh
```

### Bước 2: Chọn database

```javascript
use smartspender  // Hoặc tên database của bạn
```

### Bước 3: Tạo 3 collections

**Tạo collection `groups`:**

```javascript
db.createCollection('groups', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'createdBy'],
      properties: {
        _id: { bsonType: 'objectId' },
        name: { bsonType: 'string', minLength: 3, maxLength: 50 },
        description: { bsonType: 'string', maxLength: 200 },
        createdBy: { bsonType: 'objectId' },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' },
      },
    },
  },
});

db.groups.createIndex({ createdBy: 1 });
db.groups.createIndex({ createdAt: -1 });
```

**Tạo collection `group_members`:**

```javascript
db.createCollection('group_members', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['groupId', 'userId', 'role'],
      properties: {
        _id: { bsonType: 'objectId' },
        groupId: { bsonType: 'objectId' },
        userId: { bsonType: 'objectId' },
        role: { enum: ['admin', 'member', 'viewer'] },
        joinedAt: { bsonType: 'date' },
      },
    },
  },
});

db.group_members.createIndex({ groupId: 1 });
db.group_members.createIndex({ userId: 1 });
db.group_members.createIndex({ groupId: 1, userId: 1 }, { unique: true });
db.group_members.createIndex({ groupId: 1, joinedAt: -1 });
```

**Tạo collection `group_wallets`:**

```javascript
db.createCollection('group_wallets', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['groupId', 'name', 'currency'],
      properties: {
        _id: { bsonType: 'objectId' },
        groupId: { bsonType: 'objectId' },
        name: { bsonType: 'string', minLength: 3, maxLength: 50 },
        balance: { bsonType: 'number' },
        currency: { enum: ['VND', 'USD', 'EUR'] },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' },
      },
    },
  },
});

db.group_wallets.createIndex({ groupId: 1 });
db.group_wallets.createIndex({ groupId: 1, name: 1 });
db.group_wallets.createIndex({ groupId: 1, createdAt: -1 });
```

### Bước 4: Thêm field vào transactions

```javascript
// Thêm groupId vào transactions
db.transactions.updateMany({}, { $set: { groupId: null } });

db.transactions.createIndex({ groupId: 1 });
db.transactions.createIndex({ groupId: 1, walletId: 1 });
```

---

## 🔗 RELATIONSHIPS (Mối Quan Hệ)

```
users (hiện tại)
  ↓ (1 user → nhiều groups)
  → group_members
    ↓
    → groups (1 group → 1 owner)
        ↓ (1 group → nhiều wallets)
        → group_wallets
            ↓ (1 wallet → nhiều transactions)
            → transactions (modified: thêm groupId)
```

---

## 🎯 KEY DESIGNS

| Design                              | Lý do                                |
| ----------------------------------- | ------------------------------------ |
| **Field `groupId` ở group_members** | Dễ query "Tìm users của group X"     |
| **Field `userId` ở group_members**  | Dễ query "Tìm groups của user Y"     |
| **Unique index groupId+userId**     | Đảm bảo user chỉ vào group 1 lần     |
| **Thêm `groupId` ở transactions**   | Phân biệt: giao dịch cá nhân vs nhóm |
| **field `walletId` ở transactions** | Biết giao dịch thuộc ví nào          |

---

**Tạo:** 14/4/2026  
**Version:** 1.0  
**Status:** ✅ Final
