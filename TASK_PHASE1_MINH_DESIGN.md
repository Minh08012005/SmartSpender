# 🎯 TASK PHASE 1: DESIGN & SETUP

**Assigned to:** 👨‍💼 **Mai Huy Minh** (Team Lead)  
**Duration:** 2 ngày (Ngày 1-2)  
**Deadline:** Ngày 2, 15:00 (Team ready to code)  
**Status:** NOT STARTED

---

## 📋 LÀM CÔNG VIỆC GÌ?

Bạn là team lead, nên công việc của bạn là:

1. ✅ **Thiết kế API Specification** cho 20 endpoints (5 cho Nam, 5 cho Ngọc Anh, 5 cho Chúc, 5 cho Xuân)
2. ✅ **Vẽ Database Schema** cho 3 collections mới (groups, group_members, group_wallets)
3. ✅ **Tạo Postman Collection Template** cho team test API
4. ✅ **Viết Database Seeding Script** để tạo mock data
5. ✅ **Team Kickoff** để giải thích cho team biết

---

## 🕐 TIMELINE CHI TIẾT

### **Ngày 1 (Hôm nay)**

**Buổi sáng (08:30 - 12:00):**

- [ ] Phân tích file `DETAILED_TASKS_12DAYS.md` + `API_UPGRADE_PLAN.md`
- [ ] Vẽ schema ERD cho 3 collections
- [ ] Liệt kê 20 endpoints (tên, method, request, response, status codes)

**Buổi chiều (13:00 - 17:00):**

- [ ] Viết **API Specification** file (markdown)
- [ ] Viết database schema details
- [ ] Review lại 2 file vừa viết

**Buổi tối (17:00 - 18:00):**

- [ ] Commit branch `docs/phase1-design`
- [ ] Push to GitHub
- [ ] Gửi link cho team xem draft

---

### **Ngày 2 (Sáng)**

**Buổi sáng (08:30 - 11:00):**

- [ ] Tạo **Postman Collection** (import từ template mẫu)
  - Thêm 20 endpoints
  - Thêm environment variables
  - Thêm example request/response

**Buổi sáng (11:00 - 12:00):**

- [ ] Viết **Database Seeding Script**
  - File: `backend/seeds/group-seed.js`
  - Tạo 3 groups, 10 members, 5 wallets mock data

**Buổi chiều (13:00 - 15:00):**

- [ ] **Team Kickoff meeting** (15 phút)
  - Giải thích spec + schema cho team
  - Giải thích task của mỗi người (Nam, Ngọc Anh, Chúc, Xuân)
  - Q&A: Ai không hiểu?
  - Team acknowledge: "Ready to code"

---

## 📂 FILES CẦN TẠO/EDIT

### **1. API Specification** (`backend/docs/GROUP_API_SPECIFICATION.md`)

**Cấu trúc file:**

````markdown
# Group API Specification

## Base URL

`http://localhost:3000/api`

## Authentication

All endpoints require JWT token in header:
`Authorization: Bearer <token>`

---

## Group APIs (5 endpoints - Nguyễn Nhật Nam)

### 1. POST /groups - Tạo nhóm mới

**Method:** POST  
**Path:** `/api/groups`  
**Description:** Tạo một nhóm chi tiêu mới

**Request Body:**

```json
{
  "name": "Du lịch Nha Trang",
  "description": "Quỹ chi cho chuyến đi Nha Trang tháng 5"
}
```
````

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Du lịch Nha Trang",
    "description": "...",
    "createdBy": "userId",
    "memberCount": 1,
    "createdAt": "2026-04-14T10:00:00Z"
  }
}
```

**Status Codes:**

- `201 Created` - Tạo thành công
- `400 Bad Request` - Thiếu field hoặc invalid
- `401 Unauthorized` - Chưa login
- `500 Internal Server Error` - Lỗi server

**Error Example:**

```json
{
  "success": false,
  "error": "Group name must be at least 3 characters"
}
```

---

### 2. GET /groups - Danh sách nhóm của user

[...]

### 3. GET /groups/:groupId - Chi tiết nhóm

[...]

### 4. PATCH /groups/:groupId - Cập nhật nhóm

[...]

### 5. DELETE /groups/:groupId - Xóa nhóm

[...]

---

## Members APIs (5 endpoints - Vũ Ngọc Anh)

[Tương tự format trên, liệt kê 5 endpoints cho members]

---

## Wallets APIs (5 endpoints - Lê Thị Anh Chúc)

[Tương tự format trên, liệt kê 5 endpoints cho wallets]

---

## Transactions APIs (5 endpoints - Hà Hoài Xuân)

[Tương tự format trên, liệt kê 5 endpoints cho transactions + summary]

````

---

### **2. Database Schema** (`backend/docs/GROUP_DATABASE_SCHEMA.md`)

```markdown
# Group Feature - Database Schema

## Collection 1: groups

```javascript
db.createCollection("groups", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "createdBy"],
      properties: {
        _id: { bsonType: "objectId" },
        name: {
          bsonType: "string",
          minLength: 3,
          maxLength: 50,
          description: "Tên nhóm"
        },
        description: {
          bsonType: "string",
          maxLength: 200,
          description: "Mô tả nhóm (optional)"
        },
        createdBy: {
          bsonType: "objectId",
          description: "ID của user tạo nhóm (admin mặc định)"
        },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" }
      }
    }
  }
});

// Indexes
db.groups.createIndex({ createdBy: 1 });
````

## Collection 2: group_members

```javascript
db.createCollection("group_members", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["groupId", "userId", "role"],
      properties: {
        _id: { bsonType: "objectId" },
        groupId: {
          bsonType: "objectId",
          description: "Foreign key: groups._id",
        },
        userId: { bsonType: "objectId", description: "Foreign key: users._id" },
        role: {
          enum: ["admin", "member", "viewer"],
          description: "Vai trò trong nhóm",
        },
        joinedAt: { bsonType: "date" },
      },
    },
  },
});

// Indexes
db.group_members.createIndex({ groupId: 1, userId: 1 }, { unique: true });
db.group_members.createIndex({ groupId: 1 });
db.group_members.createIndex({ userId: 1 });
```

## Collection 3: group_wallets

```javascript
db.createCollection("group_wallets", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["groupId", "name", "currency"],
      properties: {
        _id: { bsonType: "objectId" },
        groupId: {
          bsonType: "objectId",
          description: "Foreign key: groups._id",
        },
        name: { bsonType: "string", minLength: 3, maxLength: 50 },
        balance: { bsonType: "number", description: "Số dư hiện tại" },
        currency: { enum: ["VND", "USD", "EUR"] },
        createdAt: { bsonType: "date" },
        updatedAt: { bsonType: "date" },
      },
    },
  },
});

// Indexes
db.group_wallets.createIndex({ groupId: 1 });
```

## Modify Collection: transactions

Thêm field `groupId` (optional) vào transactions schema để phân biệt:

- `groupId = null` → giao dịch cá nhân
- `groupId = "123"` → giao dịch nhóm

```javascript
// Thêm index
db.transactions.createIndex({ groupId: 1 });
```

```

---

### **3. Postman Collection** (`backend/postman/group-api.postman_collection.json`)

Làm file Postman với structure:

```

📁 SmartSpender - Group API
📁 Authentication
POST Login
POST Register
📁 Group APIs (Nguyễn Nhật Nam)
POST Create Group
GET List Groups
GET Get Group Details
PATCH Update Group
DELETE Delete Group
📁 Members APIs (Vũ Ngọc Anh)
[5 endpoints]
📁 Wallets APIs (Lê Thị Anh Chúc)
[5 endpoints]
📁 Transactions APIs (Hà Hoài Xuân)
[5 endpoints]

````

Mỗi request có:
- ✅ Environment variable: `{{BASE_URL}}`, `{{TOKEN}}`, `{{GROUP_ID}}`
- ✅ Example request body
- ✅ Example response
- ✅ Tests script (nếu có)

---

### **4. Database Seeding Script** (`backend/seeds/group-seed.js`)

**Tạo file:**

```javascript
// backend/seeds/group-seed.js

const mongoose = require('mongoose');
const Group = require('../models/group.model');
const GroupMember = require('../models/group_members.model');
const GroupWallet = require('../models/group_wallets.model');

const seedGroupData = async () => {
  try {
    console.log('🌱 Seeding group data...');

    // Clear old data
    await Group.deleteMany({});
    await GroupMember.deleteMany({});
    await GroupWallet.deleteMany({});

    // Get a user ID (from database) - hardcode cho testing
    const userId = '507f1f77bcf86cd799439010'; // EXAMPLE - change me

    // 1. Create 3 groups
    const group1 = await Group.create({
      name: 'Du lịch Nha Trang',
      description: 'Chuyến đi tháng 5',
      createdBy: userId
    });

    const group2 = await Group.create({
      name: 'Nhóm nhà',
      description: 'Chi tiêu chung nhà',
      createdBy: userId
    });

    const group3 = await Group.create({
      name: 'Du lịch Bali',
      description: 'Chuyến đi tháng 6',
      createdBy: userId
    });

    console.log('✅ Created 3 groups');

    // 2. Create members
    await GroupMember.create([
      { groupId: group1._id, userId, role: 'admin', joinedAt: new Date() },
      // Thêm 9 members nữa (thay userId tương ứng)
    ]);

    console.log('✅ Created 10 members');

    // 3. Create wallets
    await GroupWallet.create([
      { groupId: group1._id, name: 'Quỹ chính', balance: 5000000, currency: 'VND' },
      { groupId: group1._id, name: 'Quỹ ăn uống', balance: 2000000, currency: 'VND' },
      // Thêm 3 wallets nữa
    ]);

    console.log('✅ Created 5 wallets');
    console.log('🎉 Seeding completed!');
  } catch (error) {
    console.error('❌ Seeding failed:', error);
  }
};

// Run seed
seedGroupData();
````

**Cách chạy:**

```bash
node backend/seeds/group-seed.js
```

---

## ✅ CHECKLIST HÀNG NGÀY

### **Ngày 1:**

- [ ] Đọc file DETAILED_TASKS_12DAYS.md + API_UPGRADE_PLAN.md
- [ ] Vẽ sơ đồ 3 collections (ERD diagram)
- [ ] Liệt kê 20 endpoints đầy đủ
- [ ] Viết API Specification file (GROUP_API_SPECIFICATION.md)
- [ ] Viết Database Schema file (GROUP_DATABASE_SCHEMA.md)
- [ ] Commit + Push branch `docs/phase1-design`

### **Ngày 2:**

- [ ] Tạo Postman Collection (20 endpoints + env vars)
- [ ] Tạo Database Seeding Script (group-seed.js)
- [ ] Review lại tất cả files (có missing gì không?)
- [ ] Team Kickoff meeting (15 phút)
  - Giải thích spec + schema
  - Giải thích task mỗi người
  - Kiểm tra team hiểu chưa
- [ ] Final commit + Push
- [ ] **Team ready to code ✅**

---

## 📤 DELIVERABLES

**Cần gửi 4 files vào folder `backend/docs/` hoặc `backend/postman/`:**

1. ✅ `GROUP_API_SPECIFICATION.md` - API chi tiết (20 endpoints)
2. ✅ `GROUP_DATABASE_SCHEMA.md` - Database schema (3 collections)
3. ✅ `group-api.postman_collection.json` - Postman collection
4. ✅ `group-seed.js` - Seeding script

**Commit message:**

```
docs: Add Phase 1 design - API spec, schema, and seeding script
```

---

## 🚀 GHI CHÚ QUAN TRỌNG

- ⚠️ **Spec chi tiết là KEY** - Nếu spec chưa rõ, team sẽ code lâu hơn + có bug nhiều
- ⚠️ **Postman template để team test nhanh hơn** - Không phải test từng endpoint bằng tay
- ⚠️ **Seeding script giúp testing dễ hơn** - Mock data đã có, team không cần tạo data
- ⚠️ **Kickoff meeting tối ưu thời gian** - Team hiểu ngay = code nhanh

---

## 💬 CẦN HỎI CÓ GÌ?

Nếu không rõ gì:

1. Xem lại file `DETAILED_TASKS_12DAYS.md` (section PHASE 1)
2. Xem lại file `WEB_API_ESSENTIALS.md` (REST API chuẩn)
3. Hỏi Cô Giáo (nếu scope lệch)

---

**Status:** 🚀 Ready to start?  
**Next Phase:** Ngày 3 - 4 người code cùng lúc (song parallel)
