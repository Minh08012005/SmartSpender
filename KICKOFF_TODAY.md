# 🚀 KICKOFF HÔM NAY (Day 1) - CẦN LÀM GÌ?

**Cho:** Mai Huy Minh (Team Lead)  
**Thời gian:** Hôm nay (13/4/2026)

---

## 🎯 CÁI CẦN LÀM HÔM NAY

### **Chiều Nay (15:00):**

**Meeting tập trung - 30 phút**

Giới thiệu với team 5 người:

- Nguyễn Nhật Nam
- Vũ Ngọc Anh
- Lê Thị Anh Chúc
- Hà Hoài Xuân

**Nội dung:**

```
"Chúng ta sắp bắt đầu project di sản cho môn Lập Trình API.

4 GIAI ĐOẠN trong 12 NGÀY:

1. Ngày 1-2: Tôi (Minh) design spec + schema
2. Ngày 3-7: Các bạn code 20 endpoints (mỗi người 5 cái)
3. Ngày 8-10: Security + Tests + Documentation
4. Ngày 11-12: Telegram integration + Demo

📋 Xem chi tiết: PHASE_OVERVIEW_12DAYS.md (trong repo)"
```

**Chia file cho team:**

```
Toàn bộ team đọc:
👉 PHASE_OVERVIEW_12DAYS.md (tóm tắt cả 4 phase)
👉 QUICK_START.md (cheat sheet git commands)

Mỗi người xem phần của họ:
👉 DETAILED_TASKS_12DAYS.md → phần của bạn (phase nào)
```

**15 phút Q&A:**

- "Ai làm gì?"
- "Deadline là khi nào?"
- "Ai review code?"

---

### **Buổi Chiều - Evening (17:00-20:00):**

**Minh tập trung viết PHASE 1:**

#### **Task 1: API Specification (20 endpoints)**

File: `PHASE1_API_SPEC.md` (hoặc Google Doc)

Liệt kê chi tiết:

```markdown
# API Specification - 20 Endpoints

## Group APIs (Nam)

1. Create Group
   - POST /api/groups
   - Body: { name: "string", description?: "string" }
   - Response: { groupId, name, createdBy, createdAt }
   - Status: 201

2. List Groups
   - GET /api/groups
   - Response: [{ groupId, name, memberCount }]
   - Status: 200

... (repeat for 5 endpoints)

## Members APIs (Ngọc Anh)

... (5 endpoints)

## Wallets APIs (Chúc)

... (5 endpoints)

## Transactions APIs (Xuân)

... (5 endpoints)
```

**Format tối thiểu cho mỗi endpoint:**

- Method (POST, GET, PATCH, DELETE)
- Path
- Request body (if any)
- Response (expected output)
- Status codes (201, 200, 400, 404, 500)

**Dự kiến xong trong 2 giờ**

---

#### **Task 2: Database Schema (3 collections)**

File: `PHASE1_SCHEMA.md`

```markdown
# Database Schema

## Collection: groups

{
\_id: ObjectId,
name: String, // min 3 chars
description: String, // optional
createdBy: ObjectId, // admin by default
createdAt: Date,
updatedAt: Date
}

## Collection: group_members

{
\_id: ObjectId,
groupId: ObjectId,
userId: ObjectId,
role: "admin" | "member" | "viewer", // required
joinedAt: Date,
Indexes: { groupId + userId unique }
}

## Collection: group_wallets

{
\_id: ObjectId,
groupId: ObjectId,
name: String, // "Quỹ nhóm", "Xe", etc.
balance: Number, // >= 0
currency: String, // "VND" default
createdAt: Date,
Indexes: { groupId }
}
```

**Dự kiến xong trong 1 giờ**

---

#### **Task 3: Postman Collection Template**

**Mục đích:** Template để 4 người test endpoints

**Export từ Postman:**

- Create new collection "SmartSpender Groups API"
- Add folders:
  - Groups (with 5 request templates)
  - Members (with 5 request templates)
  - Wallets (with 5 request templates)
  - Transactions (with 5 request templates)

**Cho mỗi request:**

- Show method + path
- Example body (POST requests)
- Example headers (Authorization: Bearer TOKEN)

**Export:** `POSTMAN_TEMPLATE.json`

**Dự kiến xong trong 1 giờ**

---

#### **Task 4: Seeding Script**

File: `backend/seeds/group-seed.js`

```javascript
// Create test data
const createTestData = async () => {
  // 1. Create 3 groups
  const group1 = await Group.create({
    name: "Du lịch Nha Trang",
    createdBy: userId1,
  });

  // 2. Add members
  await GroupMember.create({
    groupId: group1._id,
    userId: userId1,
    role: "admin",
  });

  // 3. Create wallets
  await GroupWallet.create({
    groupId: group1._id,
    name: "Quỹ chung",
    balance: 5000000,
  });
};

// Run: node backend/seeds/group-seed.js
```

**Dự kiến xong trong 1 giờ**

---

### **Tối Hôm Nay (20:00):**

**Commit và Share:**

```bash
git checkout dev
git pull origin dev
git checkout -b docs/phase1-design

# Create/commit files
git add PHASE1_API_SPEC.md
git add PHASE1_SCHEMA.md
git add POSTMAN_TEMPLATE.json
git add backend/seeds/group-seed.js

git commit -m "docs: Phase 1 design - API spec, schema, postman, seeding"

git push origin docs/phase1-design

# Create PR (optional) or just push
```

**Share link với team (Slack/Discord):**

```
"Phase 1 design file ready!

👉 API Spec: PHASE1_API_SPEC.md
👉 Schema: PHASE1_SCHEMA.md
👉 Postman: POSTMAN_TEMPLATE.json
👉 Seeding: backend/seeds/group-seed.js

Ngày mai sáng 08:30 standup + Q&A.

Nếu bạn có câu hỏi, message tôi hôm nay!"
```

---

## ✅ CHECKLIST HÔM NAY

- [ ] **15:00:** Team meeting (30 mins)
  - Giới thiệu 4 phase + 12 ngày timeline
  - Share PHASE_OVERVIEW_12DAYS.md
  - Q&A (nếu có)

- [ ] **17:00-20:00:** Minh viết Phase 1 (4 tasks)
  - [ ] API Specification (1-2 giờ)
  - [ ] Database Schema (1 giờ)
  - [ ] Postman Template (1 giờ)
  - [ ] Seeding Script (1 giờ)

- [ ] **20:00+:** Commit + Push
  - [ ] Commit to `docs/phase1-design` branch
  - [ ] Share links with team

---

## 🎯 NGÀY MAI (Day 2)

### **Sáng 08:30 - Team Standup**

```
Minh present Phase 1:
- "API spec có 20 endpoints, mỗi người 5 cái"
- "Schema 3 collections, tôi đã design"
- "Postman template sẵn để test"
- "Seeding script để tạo test data"

15 phút Q&A:
- "Có mấy fields?"
- "Role gì là gì?"
- "Endpoint nào khó nhất?"
```

### **Ngày 2 Chiều**

- Final approval of spec
- Ngày 3 sáng → 4 người bắt đầu code

---

## 📞 RESOURCES

| File                         | Content                     | Khi Dùng                    |
| ---------------------------- | --------------------------- | --------------------------- |
| **PHASE_OVERVIEW_12DAYS.md** | 4 phase overview + timeline | Share with team             |
| **DETAILED_TASKS_12DAYS.md** | Chi tiết công việc          | Mỗi person read phần của họ |
| **QUICK_START.md**           | Git commands + recap        | Hàng ngày                   |
| **Phần bạn tạo:**            |                             |                             |
| PHASE1_API_SPEC.md           | 20 endpoints detail         | Ngày 1-2 (tạo)              |
| PHASE1_SCHEMA.md             | Database schema             | Ngày 1-2 (tạo)              |
| POSTMAN_TEMPLATE.json        | Postman collection          | Ngày 1-2 (tạo)              |
| backend/seeds/group-seed.js  | Seeding script              | Ngày 1-2 (tạo)              |

---

## 💡 TIPS FOR SUCCESS

1. **Viết spec cẩn thận** - Team sẽ follow cái này
2. **Postman template clear** - Giúp team test dễ hơn
3. **Seeding script work** - Để team có test data sẵn
4. **Daily standups** - Catch issues early
5. **Same-day merge** - Không block team

---

## ⏰ TIME ESTIMATE

- **Team meeting:** 30 mins
- **API Spec:** 2 hours
- **Schema:** 1 hour
- **Postman:** 1 hour
- **Seeding:** 1 hour
- **Commit + push:** 30 mins
- **TOTAL:** ~6 hours

**→ Xong trước 20:00, rest of evening free!**

---

**Ready to start? Let's go! 🚀**

---

**Tạo:** 13/4/2026  
**Status:** Ready for today's kickoff
