# 🚀 PHASE 1 - QUICK START EXECUTION GUIDE

**Ngày:** 14/4/2026  
**Người phụ trách:** Mai Huy Minh (Team Lead)  
**Timeline:** Hôm nay + Ngày mai (2 ngày)  
**Status:** 🔥 READY TO EXECUTE

---

## ⚡ QUICK SUMMARY (30 giây)

Bạn sẽ:

1. ✅ Setup MongoDB (tạo 3 collections)
2. ✅ Lấy user IDs từ database
3. ✅ Chạy seeding script (tạo mock data)
4. ✅ Setup Postman (test API)
5. ✅ Commit + Team kickoff

**Thời gian:** ~30-45 phút

---

## 📋 STEP-BY-STEP EXECUTION

### **PHASE 1A: MongoDB Setup (15 phút)**

**Bước 1: Mở MongoDB Shell**

```bash
# Nếu dùng mongosh (v5.0+)
mongosh

# Nếu dùng mongo (v4.x)
mongo
```

**Bước 2: Chọn database**

```javascript
use smartspender
```

**Bước 3: Copy-paste MongoDB setup script**

Mở file: `backend/mongodb-setup.js`
Copy **tất cả code** (từ dòng 1 -> cuối)
Dán vào MongoDB shell

**Kết quả mong đợi:**

```
✅ Collection "groups" created with indexes
✅ Collection "group_members" created with indexes
✅ Collection "group_wallets" created with indexes
✅ Collection "transactions" updated
📊 VERIFICATION:
   groups: 0 documents
   group_members: 0 documents
   group_wallets: 0 documents
✅ MONGODB SETUP COMPLETED!
```

---

### **PHASE 1B: Lấy User IDs (5 phút)**

**Bước 1: Vẫn ở MongoDB Shell, chạy query này:**

```javascript
// Lấy 10 user IDs từ database
db.users.find({}, { _id: 1, email: 1 }).limit(10);
```

**Bước 2: Copy 10 cái ObjectId này**

Ví dụ output:

```
{ _id: ObjectId("65a1b2c3d4e5f6g7h8i9j0k1"), email: "user1@example.com" }
{ _id: ObjectId("65a1b2c3d4e5f6g7h8i9j0k2"), email: "user2@example.com" }
...
```

**Bước 3: Mở file `backend/seeds/group-seed.js`**

Tìm dòng ~20:

```javascript
const SAMPLE_USER_IDS = [
  '507f1f77bcf86cd799439010',
  '507f1f77bcf86cd799439011',
  ...
];
```

**Bước 4: THAY BẬT CÁC SAMPLE IDs bằng REAL IDs từ MongoDB**

Ví dụ:

```javascript
const SAMPLE_USER_IDS = [
  '65a1b2c3d4e5f6g7h8i9j0k1',  // User 1 - Minh
  '65a1b2c3d4e5f6g7h8i9j0k2',  // User 2 - Nam
  '65a1b2c3d4e5f6g7h8i9j0k3',  // User 3 - Ngọc Anh
  ...
];
```

✅ **Lưu file**

---

### **PHASE 1C: Chạy Seeding Script (5 phút)**

**Bước 1: Mở terminal, navigate to backend folder**

```bash
cd backend
```

**Bước 2: Chạy seeding script**

```bash
node seeds/group-seed.js
```

**Bước 3: Xác nhận output tương tự**

```
✅ Connected to MongoDB
🌱 STARTING GROUP DATA SEEDING...

🏢 Creating 3 groups...
✅ Created 3 groups:
   1. Du lịch Nha Trang (ID: 65d1a2b3c4d5e6f7g8h9i0j1)
   2. Nhóm nhà (ID: 65d1a2b3c4d5e6f7g8h9i0j2)
   3. Du lịch Bali (ID: 65d1a2b3c4d5e6f7g8h9i0j3)

👥 Creating 10 members...
✅ Created 10 members

💳 Creating 5 wallets...
✅ Created 5 wallets:
   1. Quỹ chính: 5000000 VND
   2. Quỹ ăn uống: 2000000 VND
   ...

💰 Creating 15 sample transactions...
✅ Created 15 transactions

📊 SEEDING SUMMARY:
✅ Groups created: 3
✅ Members created: 10
✅ Wallets created: 5
✅ Transactions created: 15

🎉 SEEDING COMPLETED SUCCESSFULLY!

📌 GROUP IDs (use for testing):
   Group 1: 65d1a2b3c4d5e6f7g8h9i0j1
   Group 2: 65d1a2b3c4d5e6f7g8h9i0j2
   Group 3: 65d1a2b3c4d5e6f7g8h9i0j3

📌 WALLET IDs (use for testing):
   Wallet 1: 65d1a2b3c4d5e6f7g8h9i0j4
   Wallet 2: 65d1a2b3c4d5e6f7g8h9i0j5
   ...

✅ Disconnected from MongoDB
```

**📝 IMPORTANT:** Copy những IDs này (Group IDs, Wallet IDs) để dùng ở Postman step tiếp

---

### **PHASE 1D: Setup Postman (10 phút)**

**Bước 1: Mở Postman (Desktop or Web)**

**Bước 2: Import Collection**

```
Click "Import" → Chọn file:
backend/postman/group-api.postman_collection.json
```

**Bước 3: Setup Environment Variables**

Trong Postman, tìm phần **Variables**:

| Variable       | Value                       | Ghi chú                 |
| -------------- | --------------------------- | ----------------------- |
| BASE_URL       | `http://localhost:3000/api` | Base URL của API        |
| TOKEN          | `your_jwt_token_here`       | Dùng token từ login     |
| GROUP_ID       | `65d1a2b3c4d5e6f7g8h9i0j1`  | Copy từ seeding output  |
| WALLET_ID      | `65d1a2b3c4d5e6f7g8h9i0j4`  | Copy từ seeding output  |
| MEMBER_ID      | `65a1b2c3d4e5f6g7h8i9j0k1`  | User ID từ MongoDB      |
| USER_ID        | `65a1b2c3d4e5f6g7h8i9j0k1`  | Giống MEMBER_ID         |
| TRANSACTION_ID | `65d1a2b3c4d5e6f7g8h9i0j0`  | Transaction ID (nếu có) |

**Bước 4: Test 1 endpoint (GET Groups)**

```
1. Click folder "GROUP APIs"
2. Click request "GET - Danh sách nhóm của user"
3. Click "Send"
4. Xem response (nên thấy 3 groups từ seeding)
```

✅ **Nếu thấy 3 groups -> OK!**

---

## ✅ FINAL VERIFICATION

**Chạy script này để verify tất cả:**

```bash
# MongoDB verification
mongosh
use smartspender
db.groups.countDocuments()  # Should be 3
db.group_members.countDocuments()  # Should be 10
db.group_wallets.countDocuments()  # Should be 5
db.transactions.find({ groupId: { $ne: null } }).count()  # Should be 15
```

**Postman verification:**

- ✅ Import collection thành công
- ✅ 20+ requests visible
- ✅ Test 1 endpoint → get response OK

---

## 🔗 GIT COMMIT

Khi tất cả setup xong, commit lên GitHub:

```bash
cd backend
git add docs/ seeds/ postman/ mongodb-setup.js
git commit -m "docs: Phase 1 complete - API spec, schema, seeding, and Postman collection ready"
git push origin docs/phase1-design
```

---

## 🎤 TEAM KICKOFF (Ngày 2 chiều 15:00)

**Bước 1: Chuẩn bị content (15 phút)**

File: `backend/docs/GROUP_API_SPECIFICATION.md`
File: `backend/docs/GROUP_DATABASE_SCHEMA.md`

**Bước 2: Giải thích cho team (10 phút)**

> "Chúng ta vừa setup group feature hoàn toàn:
>
> - 3 collections mới: groups, group_members, group_wallets
> - 20 endpoints sẽ code từ Ngày 3
> - Mock data sẵn sàng để test
> - Postman collection để test from day 1
>
> Mỗi thành viên sẽ code 5 endpoints:
>
> - Nam: Group APIs
> - Ngọc Anh: Members APIs
> - Chúc: Wallets APIs
> - Xuân: Transactions APIs
>
> Deadline: Ngày 5 tối PR
> Minh review + merge: Ngày 6-7"

**Bước 3: Q&A (5 phút)**

**Bước 4: Team confirmation**

> ✅ "Team ready to code?" → Accept

---

## 🎯 SUCCESS CRITERIA

PHASE 1 = DONE khi:

- ✅ 3 collections tạo trong MongoDB
- ✅ 3 groups + 10 members + 5 wallets được seed
- ✅ Postman collection import OK + test 1 endpoint success
- ✅ Commit lên GitHub
- ✅ Team hiểu spec + ready code
- ✅ Team kickoff xác nhận

---

## 📞 TROUBLESHOOTING

**Q: MongoDB setup lỗi?**
A: Copy commands từ `MONGODB_SETUP.js` vào mongosh từng cái 1 (không copy tất cả cùng lúc)

**Q: Seeding script error "user not found"?**
A: User IDs bạn copy sai. Chạy lại query `db.users.find({})` để lấy real IDs

**Q: Postman import lỗi?**
A: File JSON syntax error. Mở https://jsonlint.com/ validate file

**Q: Can't connect MongoDB?**
A: Check `.env` file có `MONGODB_URI` không

---

**⏱️ Estimated Time:** ~45 phút  
**📅 Deadline:** Hôm nay hoặc ngày mai  
**✅ Status:** READY TO EXECUTE

---

Let's go! 🚀
