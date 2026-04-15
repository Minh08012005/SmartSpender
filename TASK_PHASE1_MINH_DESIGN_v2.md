# 🎯 TASK PHASE 1: DESIGN & SETUP

**Assigned to:** 👨‍💼 **Mai Huy Minh** (Team Lead)  
**Duration:** 2 ngày (Ngày 1-2)  
**Deadline:** Ngày 2, 15:00 (Team ready to code)  
**Status:** NOT STARTED

---

## 📋 CÔNG VIỆC CHỮ YÊUCẦU

1. ✅ **API Specification** - 20 endpoints (5 cho mỗi người)
2. ✅ **Database Schema** - 3 collections mới + modify transactions
3. ✅ **Postman Collection** - Template cho team test
4. ✅ **Seeding Script** - Mock data
5. ✅ **Team Kickoff** - Giải thích spec cho team

---

## 🕐 TIMELINE

### **Ngày 1**

- [ ] Phân tích DETAILED_TASKS_12DAYS.md + API_UPGRADE_PLAN.md
- [ ] Vẽ sơ đồ 3 collections (ERD)
- [ ] Liệt kê 20 endpoints đầy đủ
- [ ] Commit branch `docs/phase1-design` (draft)

### **Ngày 2**

- [ ] Hoàn thiện API spec
- [ ] Hoàn thiện schema
- [ ] Tạo Postman template (20 requests)
- [ ] Tạo seeding script
- [ ] **Team Kickoff** (15 phút) → Team "ready to code"
- [ ] Commit final + Push

---

## 📂 FILES CẦN TẠO

### **1. API Specification** (`backend/docs/GROUP_API_SPECIFICATION.md`)

**Nội dung:**

- Base URL, authentication format
- 20 endpoints (5 khối):
  - **Group** (Nam): CREATE, READ-list, READ-detail, UPDATE, DELETE
  - **Members** (Ngọc Anh): ADD, LIST, DETAIL, CHANGE-role, REMOVE
  - **Wallets** (Chúc): CREATE, LIST, DETAIL, UPDATE, DELETE
  - **Transactions** (Xuân): CREATE, LIST, UPDATE, DELETE, SUMMARY
- Mỗi endpoint: Method, Path, Description, Request body, Response, Status codes

---

### **2. Database Schema** (`backend/docs/GROUP_DATABASE_SCHEMA.md`)

**Nội dung:**

- **groups**: `{name, description, createdBy, timestamps}`
- **group_members**: `{groupId, userId, role[admin|member|viewer], joinedAt}`
  - Indexes: `{groupId, userId}` unique, `{groupId}`, `{userId}`
- **group_wallets**: `{groupId, name, balance, currency[VND|USD|EUR], timestamps}`
  - Index: `{groupId}`
- **transactions**: Thêm field `groupId` (optional) để phân biệt giao dịch cá nhân vs nhóm

---

### **3. Postman Collection** (`backend/postman/group-api.postman_collection.json`)

**Cấu trúc:**

```
📁 SmartSpender - Group API
  📁 Authentication
  📁 Group APIs (Nam - 5 requests)
  📁 Members APIs (Ngọc Anh - 5 requests)
  📁 Wallets APIs (Chúc - 5 requests)
  📁 Transactions APIs (Xuân - 5 requests)
```

**Mỗi request có:**

- Environment vars: `{{BASE_URL}}`, `{{TOKEN}}`, `{{GROUP_ID}}`, `{{WALLET_ID}}`, `{{USER_ID}}`
- Example request body
- Example response
- Tests (optional)

---

### **4. Seeding Script** (`backend/seeds/group-seed.js`)

**Hướng code:**

- Connect MongoDB
- Clear old data từ 3 collections
- Create 3 groups (hardcode userId từ DB)
- Create 10 members (2-3 per group)
- Create 5 wallets (1-2 per group)
- Log thành công + lỗi
- Chạy: `node backend/seeds/group-seed.js`

---

## ✅ CHECKLIST

- [ ] API spec chi tiết cho 20 endpoints
- [ ] Schema rõ ràng (fields, types, constraints)
- [ ] Postman template dễ dùng
- [ ] Seeding script chạy được
- [ ] Team hiểu hết → Ready to code

---

## 📝 COMMIT MESSAGE

```
docs: Phase 1 design - API spec, schema, Postman, seeding script
```

---

**Deadline:** Ngày 2, 15:00  
**Next:** Ngày 3-5 - 4 người code 4 feature branches song parallel
