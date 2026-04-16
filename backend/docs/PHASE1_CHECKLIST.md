# ✅ PHASE 1 - COMPLETION CHECKLIST & GUIDE

**Ngày:** 14/4/2026  
**Người phụ trách:** Mai Huy Minh (Team Lead)  
**Status:** ✅ PHASE 1 READY (Chỉnh sửa + Share với team)

---

## 📚 4 FILES ĐÃ ĐƯỢC TẠO

Tôi đã tạo **4 files quan trọng** cho bạn. Dưới đây là vị trí + nội dung mỗi file:

### **File 1️⃣: API Specification (20 endpoints)**

**Vị trí:** `backend/docs/GROUP_API_SPECIFICATION.md`

**Nội dung:**

- ✅ Mô tả chi tiết 20 endpoints
- ✅ Request/Response examples
- ✅ Status codes (201, 400, 401, 403, 404)
- ✅ Phân chia theo 4 nhóm:
  - Nam: 5 Group APIs
  - Ngọc Anh: 5 Members APIs
  - Chúc: 5 Wallets APIs
  - Xuân: 5 Transactions APIs

**Cách sử dụng:**

1. Mở file để **review lại nội dung**
2. **Share link** với team (dùng GitHub hoặc Google Drive)
3. Mỗi thành viên sẽ code theo spec này

---

### **File 2️⃣: Database Schema (3 collections)**

**Vị trí:** `backend/docs/GROUP_DATABASE_SCHEMA.md`

**Nội dung:**

- ✅ Schema cho 3 collections: `groups`, `group_members`, `group_wallets`
- ✅ Field definitions (type, min/max length, etc.)
- ✅ Indexes (để query nhanh)
- ✅ Example documents (JSON format)
- ✅ Hướng dẫn setup MongoDB

**Cách sử dụng:**

1. **Copy commands** từ file (phần "QUICK SETUP GUIDE")
2. **Chạy trên MongoDB shell** để tạo collections + indexes:
   ```bash
   mongosh
   use smartspender
   # Paste MongoDB commands từ file
   ```
3. **Xác nhận** collections được tạo:
   ```bash
   show collections  # sẽ thấy: groups, group_members, group_wallets
   ```

---

### **File 3️⃣: Database Seeding Script**

**Vị trị:** `backend/seeds/group-seed.js`

**Nội dung:**

- ✅ Script Node.js tạo mock data
- ✅ Tạo 3 groups + 10 members + 5 wallets + 15 transactions
- ✅ Ready to run ngay

**Cách sử dụng:**

1. **Chỉnh sửa user IDs** trong file (dòng ~20):

   ```javascript
   const SAMPLE_USER_IDS = [
     '507f1f77bcf86cd799439010', // Thay bằng real user ID từ DB
     '507f1f77bcf86cd799439011',
     // ... etc
   ];
   ```

2. **Chạy script:**

   ```bash
   cd backend
   node seeds/group-seed.js
   ```

3. **Xác nhận output:**
   ```
   ✅ Created 3 groups
   ✅ Created 10 members
   ✅ Created 5 wallets
   ✅ Created 15 transactions
   🎉 SEEDING COMPLETED!
   ```

---

### **File 4️⃣: Postman Collection**

**Vị trí:** `backend/postman/group-api.postman_collection.json`

**Nội dung:**

- ✅ 20+ requests (tất cả endpoints)
- ✅ Environment variables setup ({{BASE_URL}}, {{TOKEN}}, {{GROUP_ID}})
- ✅ Example bodies + headers
- ✅ Organized in 4 folders

**Cách sử dụng:**

1. **Mở Postman** (desktop app hoặc web)
2. **Click Import** → Chọn file `group-api.postman_collection.json`
3. **Setup environment variables:**
   - Điền BASE_URL: `http://localhost:3000/api`
   - Điền TOKEN: Lấy từ login endpoint
   - Điền GROUP_ID, WALLET_ID, etc. (sau khi chạy seeding script)
4. **Test endpoints** bằng cách click mỗi request → Send

---

## 🎯 QUICK CHECKLIST (Hôm nay)

### **Buổi sáng (08:30 - 12:00):**

- [ ] **Đọc hiểu 4 files vừa tạo** (15 phút)
- [ ] **Review spec + schema** (1 giờ)
  - Check: 20 endpoints đầy đủ không?
  - Check: Schema logic có hợp lý không?
  - Check: Indexes đủ chưa?
- [ ] **Chuẩn bị MongoDB setup** (30 phút)
  - Kết nối MongoDB
  - Chạy commands tạo collections + indexes
  - Verify: `show collections`

### **Buổi chiều (13:00 - 17:00):**

- [ ] **Chỉnh sửa SAMPLE_USER_IDs** trong seeding script (15 phút)
- [ ] **Chạy seeding script** (5 phút)
  - `node backend/seeds/group-seed.js`
  - Copy GROUP_ID + WALLET_ID từ output
- [ ] **Setup Postman** (30 phút)
  - Import collection
  - Điền environment variables
  - Test 2-3 endpoints (login, create group, list groups)
  - Verify response format

### **Buổi tối (17:00 - 18:00):**

- [ ] **Commit to Git** (5 phút)
  ```bash
  git add backend/docs/ backend/seeds/ backend/postman/
  git commit -m "docs: Add Phase 1 design - API spec, schema, and seeding script"
  git push origin docs/phase1-design
  ```
- [ ] **Gửi summary cho team** (5 phút)
  - Share 4 files links
  - Giải thích tóm tắt cái mỗi người cần làm

### **Ngày 2 - Buổi sáng (08:30 - 12:00):**

- [ ] **Review + Fine-tune spec** nếu có issue từ team
- [ ] **Prepare team kickoff meeting** (nội dung + slides)

### **Ngày 2 - Buổi trưa (13:00 - 15:00):**

- [ ] **TEAM KICKOFF MEETING (15 phút)**
  - Giải thích spec: 20 endpoints là gì
  - Giải thích schema: 3 collections liên quan như thế nào
  - Q&A & addressing concerns
  - **Confirmation:** Team ready to code? ✅

---

## 📖 GIẢI THÍCH CHI TIẾT (Để Hiểu Rõ)

### **Tại sao chia 20 endpoints thành 4 nhóm?**

Vì đây là **nhóm feature lớn**, nên tôi chia để mỗi thành viên encode **5 endpoints cùng lúc** (parallel work):

```
4 người = 4 nhóm features
├─ Nam: Group APIs (tạo/xem/sửa nhóm)
├─ Ngọc Anh: Members APIs (quản lý thành viên)
├─ Chúc: Wallets APIs (quản lý ví)
└─ Xuân: Transactions APIs (quản lý giao dịch)

Mỗi nhóm code song song (Ngày 3-5)
→ Tiết kiệm 3-4 ngày!
```

---

### **Tại sao cần 3 collections?**

**Vấn đề:** 1 user → nhiều groups, 1 group → nhiều users. Nếu dùng "users.groups" array → sẽ rất lộn xộn.

**Giải pháp:** Tách riêng collection `group_members` để lưu **mối quan hệ**:

```
Collection: groups
_id: "group1"
name: "Du lịch"

Collection: group_members
groupId: "group1"  ← liên kết
userId: "user1"    ← liên kết
role: "admin"

→ Vậy là "user1 là admin của group1"
```

**Benefit:**

- Dễ query "Tìm tất cả groups của user1"
- Dễ query "Tìm tất cả members của group1"
- Dễ update role (chỉ cần update 1 document)

---

### **Tại sao cần seeding script?**

**Không:** Team phải **tạo data bằng tay** qua Postman:

- POST /groups
- POST /members
- POST /wallets
- ...= Tốn 30 phút/người, lặp lại → **lãng phí**

**Có script:** Team chạy 1 command `node seeds/group-seed.js` → **ngay có 30 documents** để test việc = Tiết kiệm **~1 giờ/người**

---

## 🔧 LỖI THƯỜNG GẶP + FIX

### **Lỗi 1: "SAMPLE_USER_IDs không tồn tại"**

**Triệu chứng:** Chạy seeding script → Error: user not found

**Fix:**

1. Query users trong MongoDB:
   ```bash
   mongosh
   use smartspender
   db.users.find({}, {_id: 1, email: 1}).limit(5)
   ```
2. Copy 10 user IDs
3. Paste vào `backend/seeds/group-seed.js` dòng ~20

---

### **Lỗi 2: "Collections không được tạo"**

**Triệu chứng:** `show collections` không thấy `groups`, `group_members`

**Fix:**

1. Chạy lại MongoDB setup commands:
   ```bash
   db.createCollection("groups", {...})
   db.createCollection("group_members", {...})
   db.createCollection("group_wallets", {...})
   ```
2. Verify bằng `show collections`

---

### **Lỗi 3: "Postman import failed"**

**Triệu chứng:** Import collection.json → Error

**Fix:**

1. Check file `group-api.postman_collection.json` là valid JSON
2. Dùng online JSON validator: https://jsonlint.com/
3. Copy-paste JSON vào validator → nếu lỗi → sẽ báo dòng nào

---

## 📊 DELIVERABLES SUMMARY

| File               | Vị trí                                              | Mục Đích                     | Status |
| ------------------ | --------------------------------------------------- | ---------------------------- | ------ |
| API Spec           | `backend/docs/GROUP_API_SPECIFICATION.md`           | Spec chi tiết 20 endpoints   | ✅     |
| DB Schema          | `backend/docs/GROUP_DATABASE_SCHEMA.md`             | Schema 3 collections + setup | ✅     |
| Seeding Script     | `backend/seeds/group-seed.js`                       | Tạo mock data                | ✅     |
| Postman Collection | `backend/postman/group-api.postman_collection.json` | Test API                     | ✅     |

---

## 🚀 NEXT STEPS (NGÀY 3 TRỞ ĐI)

1. **Ngày 3-5:** Mỗi thành viên code 5 endpoints:
   - Nam: Group APIs
   - Ngọc Anh: Members APIs
   - Chúc: Wallets APIs
   - Xuân: Transactions APIs

2. **Ngày 6-7:** Minh review + merge 4 PRs

3. **Ngày 8-10:** Phase 3 (Security, Testing, Docs)

4. **Ngày 11-12:** Phase 4 (Telegram Integration)

---

## 💡 KEY NOTES CHO TEAM

Khi share với team, nhớ nói:

> "Các bạn có **API Specification chi tiết** trong file `GROUP_API_SPECIFICATION.md`.
>
> Mỗi thành viên sẽ code **5 endpoints** theo spec này (Ngày 3-5).
>
> Database schema đã được design sẵn, chúng ta tạo 3 collections vào Ngày 1-2.
>
> Sau đó chạy seeding script để có mock data để test.
>
> Postman collection sẽ giúp các bạn test API.
>
> **Đừng endorse code trước khi test bằng Postman!**"

---

## 📞 FINAL CHECKLIST (Trước khi đi ngủ Ngày 2)

- ✅ 4 files tạo xong
- ✅ MongoDB collections setup xong (groups, group_members, group_wallets)
- ✅ Seeding script chạy thành công
- ✅ Postman collection import thành công + test 2-3 endpoints
- ✅ Commit + Push branch `docs/phase1-design`
- ✅ Share với team + xác nhận hiểu
- ✅ **Team ready to code Ngày 3** ✅

---

**Tạo:** 14/4/2026  
**Status:** ✅ PHASE 1 COMPLETE (Ready for team)
