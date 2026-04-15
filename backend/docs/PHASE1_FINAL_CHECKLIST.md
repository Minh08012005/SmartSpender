# ✅ PHASE 1 FINAL EXECUTION CHECKLIST

**Ngày:** 14/4/2026  
**Người phụ trách:** Mai Huy Minh  
**Status:** 🟢 READY TO EXECUTE  
**Timeline:** Hôm nay + Ngày 2 (2 ngày)

---

## 📋 PRE-EXECUTION CHECKLIST

Trước khi bắt đầu, kiểm tra:

- [ ] Máy có MongoDB installed? (mongosh hoặc mongo)
- [ ] Máy có Node.js installed? (node -v)
- [ ] Máy có Postman installed? (Desktop app hoặc web)
- [ ] Repository đã git clone local?
- [ ] `backend/.env` có MONGODB_URI?

---

## 🎯 DAY 1 EXECUTION (HÔM NAY - 3-4 GIỜ)

### **MORNING - SETUP MONGODB (09:00 - 11:00)**

**Task 1: Mở MongoDB Shell** (5 phút)

```bash
# Terminal 1
mongosh
# hoặc: mongo
```

Status: ⏳ In Progress / ✅ Done

**Task 2: Setup Collections** (10 phút)

```javascript
// Trong MongoDB shell:
use smartspender

// Copy-paste tất cả từ file: backend/mongodb-setup.js
// (Copy từ dòng 23 đến end)
```

Expected output:

```
✅ Collection "groups" created with indexes
✅ Collection "group_members" created with indexes
✅ Collection "group_wallets" created with indexes
✅ Collection "transactions" updated
```

Status: ⏳ In Progress / ✅ Done

**Task 3: Verify MongoDB Setup** (5 phút)

```javascript
// Trong MongoDB shell:
show collections
# Should see: groups, group_members, group_wallets, ...
```

Status: ⏳ In Progress / ✅ Done

---

### **LUNCH BREAK (11:00 - 12:00)**

---

### **AFTERNOON - SEEDING DATA (13:00 - 14:30)**

**Task 4: Get Real User IDs from Database** (10 phút)

```javascript
// Vẫn trong MongoDB shell:
db.users.find({}, { _id: 1, email: 1 }).limit(10);

// Copy 10 user IDs (ObjectIds)
```

Status: ⏳ In Progress / ✅ Done

**Task 5: Edit Seeding Script** (10 phút)

```bash
# Terminal 2
cd backend
nano seeds/group-seed.js
# Hoặc mở file bằng editor: backend/seeds/group-seed.js
```

**Find dòng ~20:**

```javascript
const SAMPLE_USER_IDS = [
  '507f1f77bcf86cd799439010',  // ← THAY CÁI NÀY
  ...
];
```

**Replace with real user IDs:**

```javascript
const SAMPLE_USER_IDS = [
  '65a1b2c3d4e5f6g7h8i9j0k1',  // Từ MongoDB query
  '65a1b2c3d4e5f6g7h8i9j0k2',
  ...
];
```

✅ Save file

Status: ⏳ In Progress / ✅ Done

**Task 6: Run Seeding Script** (10 phút)

```bash
# Still in backend folder:
node seeds/group-seed.js
```

Expected output:

```
✅ Connected to MongoDB
🌱 STARTING GROUP DATA SEEDING...

🏢 Creating 3 groups...
✅ Created 3 groups:
   1. Du lịch Nha Trang (ID: 65d1a2b3c4d5...)
   2. Nhóm nhà (ID: 65d1a2b3c4d5...)
   3. Du lịch Bali (ID: 65d1a2b3c4d5...)

✅ Created 10 members
✅ Created 5 wallets
✅ Created 15 transactions

🎉 SEEDING COMPLETED SUCCESSFULLY!

📌 GROUP IDs (use for testing):
   Group 1: 65d1a2b3c4d5...
   Group 2: 65d1a2b3c4d5...
   ...

📌 WALLET IDs (use for testing):
   Wallet 1: 65d1a2b3c4d5...
   ...
```

**📝 IMPORTANT:** Copy GROUP IDs + WALLET IDs để dùng ở Postman step tiếp

Status: ⏳ In Progress / ✅ Done

**Task 7: Verify Mock Data** (5 phút)

```javascript
// Quay lại MongoDB shell:
db.groups.countDocuments(); // Should be 3
db.group_members.countDocuments(); // Should be 10
db.group_wallets.countDocuments(); // Should be 5
db.transactions.find({ groupId: { $ne: null } }).count(); // Should be 15
```

Status: ⏳ In Progress / ✅ Done

---

### **EVENING - FINAL COMMIT (16:00 - 17:30)**

**Task 8: Git Add + Commit** (15 phút)

```bash
# Terminal 2 (backend folder):
git status
# Should show: new files + modified files

git add docs/ seeds/ postman/ *.js
# (mongodb-setup.js, mongodb-verify.js)

git commit -m "docs: Phase 1 complete - API spec, DB schema, seeding script, Postman collection ready for team"

git push origin docs/phase1-design

# Check: git log --oneline (should see latest commit)
```

Status: ⏳ In Progress / ✅ Done

**Task 9: Generate Summary Report** (5 phút)

Create file: `PHASE1_SUMMARY.txt`

```
PHASE 1 EXECUTION COMPLETED ✅
Date: 14/4/2026
Lead: Mai Huy Minh

DELIVERABLES CREATED:
✅ 1. API Specification (20 endpoints) → GROUP_API_SPECIFICATION.md
✅ 2. Database Schema (3 collections) → GROUP_DATABASE_SCHEMA.md
✅ 3. Seeding Script (mock data) → group-seed.js
✅ 4. Postman Collection (20 requests) → group-api.postman_collection.json
✅ 5. Postman Environment → SmartSpender-GroupAPI.postman_environment.json
✅ 6. MongoDB Setup Script → mongodb-setup.js
✅ 7. MongoDB Verify Script → mongodb-verify.js
✅ 8. Quick Start Guide → QUICK_START_EXECUTION.md
✅ 9. Team Kickoff Guide → TEAM_KICKOFF.md
✅ 10. This Checklist → PHASE1_FINAL_CHECKLIST.md

MONGODB SETUP:
✅ Collections created: groups, group_members, group_wallets
✅ Indexes created for performance
✅ transactions table updated with groupId field

MOCK DATA CREATED:
✅ 3 groups: Du lịch Nha Trang, Nhóm nhà, Du lịch Bali
✅ 10 members (3 admin, 7 member/viewer)
✅ 5 wallets (2-3 per group)
✅ 15 transactions

TEST STATUS:
✅ MongoDB collections verified
✅ Mock data verified
✅ Ready for Postman testing

NEXT STEPS:
1. Day 2 morning: Postman setup + test
2. Day 2 afternoon: Team Kickoff meeting (15:00)
3. Day 3-5: Team code (4 people, 5 endpoints each)
4. Day 6-7: Merge + integration test
5. Day 8-10: Security + Testing + Docs
6. Day 11-12: External API + Demo

Team Status: ✅ READY TO CODE
```

Status: ⏳ In Progress / ✅ Done

---

## 🟢 DAY 2 EXECUTION (NGÀY MAI - 3 GIỜ)

### **MORNING - POSTMAN SETUP (09:00 - 11:00)**

**Task 10: Import Postman Collection** (5 phút)

```
1. Open Postman (Desktop or Web)
2. Click "Import" button
3. Select file: backend/postman/group-api.postman_collection.json
4. Wait for import complete
5. Should see: SmartSpender - Group API collection + 20+ requests
```

Status: ⏳ In Progress / ✅ Done

**Task 11: Import Postman Environment** (5 phút)

```
1. Still in Postman
2. Click "Import" again
3. Select file: backend/postman/SmartSpender-GroupAPI.postman_environment.json
4. Should see: SmartSpender - Group API Environment
```

Status: ⏳ In Progress / ✅ Done

**Task 12: Get JWT Token** (10 phút)

```
1. In Postman, create AUTH request or use existing login endpoint
2. POST /api/auth/login
   Body: { email: "xxx@example.com", password: "xxx" }
3. Copy token from response
4. Update Postman variable: TOKEN = <your_jwt_token>
```

Status: ⏳ In Progress / ✅ Done

**Task 13: Update Postman Variables** (10 phút)

In Postman, update these variables:

| Variable  | Value                     | Source                  |
| --------- | ------------------------- | ----------------------- |
| BASE_URL  | http://localhost:3000/api | Default                 |
| TOKEN     | <jwt_from_login>          | From login request      |
| GROUP_ID  | <from_seeding_output>     | From seed script output |
| WALLET_ID | <from_seeding_output>     | From seed script output |
| MEMBER_ID | <any_user_id>             | From MongoDB users      |
| USER_ID   | <any_user_id>             | From MongoDB users      |

Status: ⏳ In Progress / ✅ Done

**Task 14: Test 1 Endpoint** (10 phút)

```
1. In Postman, go to "GROUP APIs" folder
2. Select request: "2. GET - Danh sách nhóm của user"
3. Click "Send"
4. Should see response: 3 groups in array
5. If OK → Postman setup success ✅
```

Status: ⏳ In Progress / ✅ Done

---

### **LUNCH BREAK (11:00 - 12:30)**

---

### **AFTERNOON - TEAM KICKOFF (13:00 - 15:30)**

**Task 15: Prepare Kickoff Content** (30 phút)

```
1. Open files:
   - backend/docs/GROUP_API_SPECIFICATION.md
   - backend/docs/GROUP_DATABASE_SCHEMA.md
   - backend/docs/TEAM_KICKOFF.md

2. Review slides (from TEAM_KICKOFF.md)
3. Prepare 2-3 sample Postman screenshots (optional but nice)
4. Prepare Q&A sheet
```

Status: ⏳ In Progress / ✅ Done

**Task 16: Run Team Kickoff Meeting** (20 phút)

```
Zoom/Online meeting at 15:00 with:
- Nguyễn Nhật Nam (Group APIs)
- Vũ Ngọc Anh (Members APIs)
- Lê Thị Anh Chúc (Wallets APIs)
- Hà Hoài Xuân (Transactions APIs)

Agenda (from TEAM_KICKOFF.md):
1. Welcome (1 min)
2. Project timeline (1 min)
3. 20 endpoints breakdown (3 min)
4. Database design explanation (2 min)
5. Task assignment to each person (5 min)
6. Available resources + Postman demo (2 min)
7. Development process (2 min)
8. Q&A (2 min)
9. Final confirmation (1 min)
```

Expected outcome:

- ✅ Team understands spec
- ✅ Team understands their task
- ✅ Team knows how to use Postman
- ✅ Team confirms READY ✅

Status: ⏳ In Progress / ✅ Done

---

## 📊 FINAL VERIFICATION CHECKLIST

### **MongoDB Setup ✅**

- [ ] 3 collections created: groups, group_members, group_wallets
- [ ] Indexes created
- [ ] Mock data seeded (3 groups, 10 members, 5 wallets, 15 transactions)
- [ ] transactions table has groupId field

### **Files Created ✅**

- [ ] GROUP_API_SPECIFICATION.md (20 endpoints spec)
- [ ] GROUP_DATABASE_SCHEMA.md (schema for 3 collections)
- [ ] group-seed.js (seeding script)
- [ ] group-api.postman_collection.json (Postman collection)
- [ ] SmartSpender-GroupAPI.postman_environment.json (Postman env)
- [ ] mongodb-setup.js (MongoDB setup script)
- [ ] mongodb-verify.js (MongoDB verify script)
- [ ] QUICK_START_EXECUTION.md (quick start guide)
- [ ] TEAM_KICKOFF.md (kickoff meeting guide)
- [ ] PHASE1_CHECKLIST.md (original checklist)

### **Testing ✅**

- [ ] MongoDB collections verified
- [ ] Mock data count verified (3/10/5/15)
- [ ] Postman collection import successful
- [ ] Postman environment import successful
- [ ] Test 1 endpoint (GET /groups) → response OK

### **Team Readiness ✅**

- [ ] Team understands 20 endpoints
- [ ] Team knows which 5 endpoints to code
- [ ] Team knows deadline (Day 5 tối)
- [ ] Team knows how to test (Postman)
- [ ] Team confirms "Ready to code" ✅

### **Git Commit ✅**

- [ ] All files staged: `git add`
- [ ] Commit message meaningful: `git commit -m "..."`
- [ ] Pushed to GitHub: `git push origin docs/phase1-design`

---

## 🚀 NEXT PHASE (DAY 3-5)

When all above ✅, team is ready for PHASE 2:

**Day 3-5 (Coding):**

- Nam code 5 Group APIs (branch: feature/group-apis)
- Ngọc Anh code 5 Members APIs (branch: feature/group-members-apis)
- Chúc code 5 Wallets APIs (branch: feature/group-wallets-apis)
- Xuân code 5 Transactions APIs (branch: feature/group-transactions-apis)

**Day 5 Evening:**

- All 4 create PRs
- Tag @Minh for review

**Day 6-7 (Review + Merge):**

- Minh review 4 PRs
- Request changes if needed
- Merge when OK
- Run integration tests

---

## ⏱️ TIME SUMMARY

| Task            | Duration | Total          |
| --------------- | -------- | -------------- |
| **Day 1**       |          |                |
| MongoDB Setup   | 10 min   |                |
| Seeding Script  | 20 min   |                |
| Git Commit      | 15 min   |                |
| **Day 1 Total** |          | **45 min**     |
| **Day 2**       |          |                |
| Postman Setup   | 30 min   |                |
| Team Kickoff    | 20 min   |                |
| **Day 2 Total** |          | **50 min**     |
| **GRAND TOTAL** |          | **~1.5 hours** |

**Status:** On track ✅

---

## 🎯 SUCCESS DEFINITION

✅ PHASE 1 = DONE when ALL of below are true:

```
✅ MongoDB collections exist + indexed
✅ Mock data seeded (3 groups + 10 members + 5 wallets)
✅ API Specification written (20 endpoints)
✅ Database Schema documented
✅ Postman collection created + tested
✅ Files committed to GitHub
✅ Team meeting completed
✅ Team confirms "READY TO CODE" ✅

==> PHASE 2 CAN BEGIN ✅
```

---

**Created:** 14/4/2026  
**Status:** 🟢 READY TO EXECUTE  
**Estimated Completion:** 14/4/2026 Evening OR 15/4/2026 Afternoon

---

Let's execute! 🚀
