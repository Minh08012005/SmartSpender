# 📋 DETAILED TASKS - 4 PHASE TRONG 12 NGÀY

**Dành cho:** Mai Huy Minh, Nguyễn Nhật Nam, Vũ Ngọc Anh, Lê Thị Anh Chúc, Hà Hoài Xuân

---

## 🎯 PHASE 1: DESIGN (Ngày 1-2)

### **👨‍💼 MINH (Mai Huy Minh) - Team Lead**

**Timeline:** Ngày 1-2 (2 ngày)  
**Deadline:** Ngày 2 chiều (15:00) - Team ready to code

**Công Việc (Cần Làm):**

#### **1. API Specification (20 endpoints)**

Liệt kê từng endpoint:

```
## Group APIs (5 endpoints - Nam)
POST   /api/groups              Request: {name, description}
GET    /api/groups              Response: [{groupId, name, members}]
GET    /api/groups/:groupId     Response: {groupId, name, members, wallets}
PATCH  /api/groups/:groupId     Request: {name, description}
DELETE /api/groups/:groupId     Response: {message: "deleted"}

## Members APIs (5 endpoints - Ngọc Anh)
POST   /api/groups/:groupId/members
GET    /api/groups/:groupId/members
GET    /api/groups/:groupId/members/:userId
PATCH  /api/groups/:groupId/members/:userId     (change role)
DELETE /api/groups/:groupId/members/:userId

## Wallets APIs (5 endpoints - Chúc)
POST   /api/groups/:groupId/wallets
GET    /api/groups/:groupId/wallets
GET    /api/groups/:groupId/wallets/:walletId
PATCH  /api/groups/:groupId/wallets/:walletId
DELETE /api/groups/:groupId/wallets/:walletId

## Transactions APIs (5 endpoints - Xuân)
POST   /api/groups/:groupId/transactions
GET    /api/groups/:groupId/transactions
PATCH  /api/groups/:groupId/transactions/:id
DELETE /api/groups/:groupId/transactions/:id
GET    /api/groups/:groupId/summary              (tổng chi/thu)
```

**Format cho mỗi endpoint:**

```
Method: POST
Path: /api/groups
Description: Create a new group
Request body: { name: "string", description?: "string" }
Response: { groupId: "123", name: "...", createdBy: "userId" }
Status codes: 201 Created, 400 Bad Request, 401 Unauthorized
```

**Deliverable:** 1 file markdown or Google Doc (20 endpoints)

---

#### **2. Database Schema (3 collections)**

**Collection 1: groups**

```javascript
{
  _id: ObjectId,
  name: String,           // Required, min 3 chars
  description: String,    // Optional
  createdBy: ObjectId,    // UserId (admin mặc định)
  createdAt: Date,
  updatedAt: Date
}
```

**Collection 2: group_members**

```javascript
{
  _id: ObjectId,
  groupId: ObjectId,      // Foreign key to groups
  userId: ObjectId,       // Foreign key to users
  role: "admin" | "member" | "viewer",  // Required
  joinedAt: Date,

  // Indexes needed:
  // - { groupId: 1, userId: 1 }  (unique)
  // - { groupId: 1 }
}
```

**Collection 3: group_wallets**

```javascript
{
  _id: ObjectId,
  groupId: ObjectId,      // Foreign key
  name: String,           // "Quỹ nhóm", "Xe", etc.
  balance: Number,        // >= 0
  currency: String,       // "VND", default "VND"
  createdAt: Date,

  // Index:
  // - { groupId: 1 }
}
```

**Note:** Transactions collection tích hợp vào collection `transactions` hiện tại (add field `groupId` optional)

**Deliverable:** 1 file diagram or markdown (schema definition)

---

#### **3. Postman Collection Template**

Tạo 1 Postman collection với:

- Environment variables: `BASE_URL`, `TOKEN`, `GROUP_ID`, `MEMBER_ID`, `WALLET_ID`
- Folder structure:
  ```
  SmartSpender Groups API
  ├── Groups (POST, GET, GET/:id, PATCH, DELETE)
  ├── Members (POST, GET, GET/:id, PATCH, DELETE)
  ├── Wallets (POST, GET, GET/:id, PATCH, DELETE)
  └── Transactions (POST, GET, PATCH, DELETE, Summary)
  ```
- Each request has example request body + expected response

**Deliverable:** 1 JSON file (postman_collection.json)

---

#### **4. Database Seeding Script**

File: `backend/seeds/group-seed.js`

```javascript
// Tạo:
// - 3 groups (Du lịch, Nhà, Project)
// - 10 members (3 admin, 7 member)
// - 5 wallets (2 per group)

// Run: node backend/seeds/group-seed.js
```

**Deliverable:** 1 JavaScript file (executable script)

---

#### **5. Team Kickoff (Ngày 2 tối)**

Check list:

- [ ] Share spec + schema + Postman with team
- [ ] 15 phút Q&A (làm rõ confusing points)
- [ ] Team acknowledge: "Ready to code"
- [ ] Commit spec to GitHub (branch `docs/phase1-design`)

---

**PHASE 1 DONE Khi:**

- ✅ API spec written + shared
- ✅ Database schema finalized
- ✅ Postman template ready
- ✅ Seeding script ready
- ✅ Team understood + ready to code

---

## 💻 PHASE 2: CODE BACKEND APIs (Ngày 3-7)

### **🔴 IMPORTANT: 4 NGƯỜI CODE CÙNG LÚC (PARALLEL)**

**Timeline:** Ngày 3-5 (coding) + Ngày 6-7 (merge + integration test)

---

### **👨‍💻 NAM (Nguyễn Nhật Nam) - Group APIs**

**Branch:** `feature/group-apis`  
**Ngày:** 3-5 (3 ngày code)  
**Deadline PR:** Ngày 5 tối (18:00)

**5 Endpoints:**

1. **POST /api/groups** (Tạo nhóm)
   - Input: { name, description? }
   - Output: { groupId, name, createdBy, createdAt }
   - Status: 201

2. **GET /api/groups** (Danh sách nhóm của user)
   - Output: [{ groupId, name, memberCount }]
   - Status: 200

3. **GET /api/groups/:groupId** (Chi tiết nhóm)
   - Output: { groupId, name, members: [], wallets: [], createdBy }
   - Status: 200

4. **PATCH /api/groups/:groupId** (Cập nhật)
   - Input: { name?, description? }
   - Only admin can update
   - Status: 200

5. **DELETE /api/groups/:groupId** (Xóa)
   - Only admin can delete
   - Status: 200

**Files to Create:**

- [ ] `backend/models/group.model.js` (schema + validation)
- [ ] `backend/controllers/group.controller.js` (5 methods)
- [ ] `backend/routes/group.routes.js` (mount endpoints)
- [ ] `backend/validators/group.validator.js` (validate input)

**Daily Workflow (Ngày 3-5):**

- Ngày 3: Model + schema (1 commit)
- Ngày 4: Controller methods 1-3 (2-3 commits)
- Ngày 5: Controller methods 4-5 + routes + PR (2 commits)

**Testing (Postman):**

- [ ] Test mỗi endpoint (valid input)
- [ ] Test error cases (invalid input, not found)
- [ ] Document results

**Commit Messages:**

```
feat: Create Group model and schema
feat: Add POST /api/groups endpoint
feat: Add GET /api/groups endpoints
feat: Add PATCH/DELETE /api/groups endpoints
feat: Add group routes and validators
```

**PR Notes:**

- "Tested with Postman ✅"
- "Ready to merge, tag @Minh08012005"

---

### **👩‍💻 NGỌC ANH (Vũ Ngọc Anh) - Members APIs**

**Branch:** `feature/group-members-apis`  
**Ngày:** 3-5  
**Deadline PR:** Ngày 5 tối

**5 Endpoints:**

1. **POST /api/groups/:groupId/members** (Thêm member)
   - Input: { userId, role: "admin"|"member"|"viewer" }
   - Only admin
   - Status: 201

2. **GET /api/groups/:groupId/members** (Danh sách)
   - Output: [{ userId, email, role, joinedAt }]

3. **GET /api/groups/:groupId/members/:userId** (Chi tiết)
   - Output: { userId, email, role, joinedAt }

4. **PATCH /api/groups/:groupId/members/:userId** (Đổi role)
   - Input: { role: "admin"|"member"|"viewer" }
   - Only admin

5. **DELETE /api/groups/:groupId/members/:userId** (Xóa)
   - Only admin
   - Status: 200

**Files:**

- [ ] `backend/models/group_members.model.js`
- [ ] `backend/controllers/group_members.controller.js`
- [ ] `backend/routes/group_members.routes.js`
- [ ] `backend/validators/group_members.validator.js`

**Workflow:**

- Ngày 3: Model + schema (with role enum)
- Ngày 4: Controllers 1-3
- Ngày 5: Controllers 4-5 + routes + PR

---

### **👩‍💻 CHÚC (Lê Thị Anh Chúc) - Wallets APIs**

**Branch:** `feature/group-wallets-apis`  
**Ngày:** 3-5  
**Deadline PR:** Ngày 5 tối

**5 Endpoints:**

1. **POST /api/groups/:groupId/wallets** (Tạo ví)
   - Input: { name, balance, currency: "VND" }
   - Status: 201

2. **GET /api/groups/:groupId/wallets** (Danh sách)

3. **GET /api/groups/:groupId/wallets/:walletId** (Chi tiết)

4. **PATCH /api/groups/:groupId/wallets/:walletId** (Cập nhật)
   - Only admin

5. **DELETE /api/groups/:groupId/wallets/:walletId** (Xóa)
   - Only admin

**Files:**

- [ ] `backend/models/group_wallets.model.js`
- [ ] `backend/controllers/group_wallets.controller.js`
- [ ] `backend/routes/group_wallets.routes.js`
- [ ] `backend/validators/group_wallets.validator.js`

---

### **👨‍💻 XUÂN (Hà Hoài Xuân) - Transactions APIs**

**Branch:** `feature/group-transactions-apis`  
**Ngày:** 3-5  
**Deadline PR:** Ngày 5 tối

**5 Endpoints:**

1. **POST /api/groups/:groupId/transactions** (Tạo giao dịch)
   - Input: { amount, type: "income"|"expense", note }

2. **GET /api/groups/:groupId/transactions** (Danh sách)

3. **PATCH /api/groups/:groupId/transactions/:id** (Cập nhật)
   - Only creator hoặc admin

4. **DELETE /api/groups/:groupId/transactions/:id** (Xóa)
   - Only creator hoặc admin

5. **GET /api/groups/:groupId/summary** (Tổng chi/thu)
   - Output: { totalIncome, totalExpense, balance }
   - Status: 200

**Files:**

- [ ] `backend/models/group_transactions.model.js`
- [ ] `backend/controllers/group_transactions.controller.js`
- [ ] `backend/routes/group_transactions.routes.js`
- [ ] `backend/validators/group_transactions.validator.js`

---

### **Ngày 6-7: MERGE + INTEGRATION TEST**

**Người phụ trách:** Minh

- [ ] **Ngày 6 sáng:** Review 4 PRs (Nam, Ngọc Anh, Chúc, Xuân)
- [ ] **Ngày 6 chiều:** Merge nếu OK, request changes nếu cần
- [ ] **Ngày 7:** Fix + re-merge any PRs na
- [ ] **Ngày 7 tối:** Integration test (tất cả 20 endpoints work together)
- [ ] **Result:** `dev` branch stable + ready Phase 3

**Integration Test Checklist:**

- [ ] Create group (Nam's POST)
- [ ] Add 2 members (Ngọc Anh's POST)
- [ ] Create wallet (Chúc's POST)
- [ ] Create 3 transactions (Xuân's POST)
- [ ] Get summary (Xuân's GET summary)
- [ ] All 5-6 calls should succeed in sequence

---

## 🔒 PHASE 3: Security, Testing, Docs (Ngày 8-10)

**Timeline:** 3 ngày, **4 NGƯỜI LÀM SONG SONG**

---

### **👨‍💻 NAM - Security Review (Ngày 8-9)**

**Branch:** `feature/group-apis-security`

**Công Việc:**

1. **Add RBAC Middleware** (Role-Based Access Control)
   - Create `backend/middleware/group-rbac.middleware.js`
   - Check user's role in group (admin, member, viewer)
   - Enforce: DELETE/PATCH require admin

2. **Verify Authentication**
   - Ensure JWT token checked on all endpoints
   - 401 if missing/invalid token
   - 403 if not authorized for action

3. **Input Validation**
   - Validate all inputs (name length, amount > 0, etc.)
   - Sanitize (remove whitespace, escape HTML)
   - Return 400 if invalid

4. **Error Handling**
   - No sensitive data in error messages
   - Proper HTTP status codes (400, 401, 403, 404, 500)
   - Logging suspicious activities

**Files:**

- [ ] `backend/middleware/group-rbac.middleware.js`
- [ ] Update routes (add RBAC checks)

**PR by:** Ngày 9 tối

---

### **👩‍💻 NGỌC ANH - Unit Tests (Ngày 8-10)**

**Branch:** `feature/group-unit-tests`

**Công Việc:**

Viết unit tests cho:

1. Group model (validation, creation)
2. GroupMember model (role validation)
3. GroupWallet model (balance validation)
4. GroupTransaction model
5. All controllers (5 test cases per method)

**Target:** >= 80% code coverage

**Files:**

- [ ] `backend/tests/unit/group.test.js`
- [ ] `backend/tests/unit/group_members.test.js`
- [ ] `backend/tests/unit/group_wallets.test.js`
- [ ] `backend/tests/unit/group_transactions.test.js`

**Example Test:**

```javascript
describe("Group Controller", () => {
  test("POST /api/groups creates group", () => {
    // Arrange: mock data
    // Act: call endpoint
    // Assert: check response
  });
});
```

**PR by:** Ngày 10 tối  
**Coverage Report:** Attach in PR

---

### **👩‍💻 CHÚC - Integration Tests (Ngày 8-10)**

**Branch:** `feature/group-integration-tests`

**Công Việc:**

1. **E2E Tests** (End-to-End)
   - Full workflow: Create group → Add members → Create wallet → Transactions
   - All in 1 test

2. **Performance Tests**
   - Each endpoint should respond < 500ms
   - List operations (50 items) < 300ms

**Files:**

- [ ] `backend/tests/integration/group-e2e.test.js`
- [ ] `backend/tests/performance/group-perf.test.js`

**Example E2E Test:**

```javascript
describe("Group E2E", () => {
  test("Complete workflow", async () => {
    // 1. Create group
    // 2. Add member
    // 3. Create wallet
    // 4. Create transaction
    // 5. Get summary
    // All should succeed
  });
});
```

**PR by:** Ngày 10 tối

---

### **👨‍💻 XUÂN - API Documentation (Ngày 8-10)**

**Branch:** `feature/group-api-docs`

**Công Việc:**

1. **Swagger/OpenAPI Docs**
   - Update `backend/swagger.yaml` or `/docs`
   - 20 endpoints with full schema
   - Example requests + responses
   - Error codes

2. **API Guide (Markdown)**
   - File: `backend/docs/GROUP_API_GUIDE.md`
   - Short description per endpoint
   - cURL examples
   - Role requirements

3. **Postman Collection Update**
   - Add all 20 endpoints (production-ready)
   - Tests/assertions in each request
   - Documentation

4. **README Update**
   - Add "Group Feature" section (3-5 lines)
   - Link to detailed guides

**Files:**

- [ ] Update `backend/swagger.yaml` (20 endpoints documented)
- [ ] Create `backend/docs/GROUP_API_GUIDE.md`
- [ ] Update `backend/postman/collection.json`
- [ ] Update `README.md`

**PR by:** Ngày 10 tối

---

**PHASE 3 DONE Khi:**

- ✅ Security review passed (RBAC implemented)
- ✅ Unit tests passing (>= 80% coverage)
- ✅ E2E tests passing
- ✅ Performance tests OK (< 500ms)
- ✅ API docs complete (Swagger + guide)
- ✅ All PRs merged to dev

---

## 🔌 PHASE 4: Telegram Bot Integration (Ngày 11-12)

**Timeline:** 2 ngày  
**Người:** Nam + Xuân (2-3 gio code, 2 người)

---

### **Task: Telegram Notification on New Transaction**

**Bản chất:** Khi có transaction nhóm mới → gửi tin Telegram

**Setup (Ngày 11 sáng - 30 phút):**

1. Tạo Telegram Bot (@BotFather)
   - Get TOKEN từ BotFather
   - Create/Find Telegram group chat cho SmartSpender
   - Get CHAT_ID

2. Thêm environment variables:
   ```
   TELEGRAM_BOT_TOKEN=123456:ABCDEF
   TELEGRAM_GROUP_CHAT_ID=-123456789
   ```

**Code (Ngày 11 sáng-chiều - 1 giờ):**

File: `backend/services/telegram.service.js`

```javascript
const axios = require("axios");

const sendNotification = async (groupName, transaction) => {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_GROUP_CHAT_ID;

  const message = `📝 [${groupName}]
💰 ${transaction.type === "income" ? "+" : "-"} ${transaction.amount}đ
📌 ${transaction.note || "No note"}`;

  try {
    await axios.post(`https://api.telegram.org/bot${token}/sendMessage`, {
      chat_id: chatId,
      text: message,
    });
  } catch (err) {
    console.error("Telegram error:", err.message);
  }
};

module.exports = { sendNotification };
```

Update `backend/routes/transactions.js`:

```javascript
const { sendNotification } = require("../services/telegram.service");

router.post("/:groupId/transactions", async (req, res) => {
  // ... validation ...

  const transaction = await Transaction.create({
    groupId,
    ...req.body,
  });

  const group = await Group.findById(groupId);

  // Send Telegram notification
  await sendNotification(group.name, transaction);

  res.json({ status: "success", data: transaction });
});
```

**Testing (Ngày 11 chiều - 30 phút):**

1. Create transaction via Postman
2. Check Telegram group chat → message appear
3. Test with different amounts + notes
4. Test error handling (invalid token → log error, don't crash)

**Commit:**

```
feat: Add Telegram notification service
feat: Integrate Telegram notifications to transaction endpoint
test: Test Telegram integration
```

**PR by:** Ngày 11 tối

---

### **Ngày 12: Demo + Report**

**Morning (09:00-12:00): Demo**

Người: Minh + Nam + Xuân

- [ ] Show Postman: Call all 20 endpoints
- [ ] Show Telegram: Create transaction → notification appears
- [ ] Show test results (coverage >= 80%)
- [ ] Show documentation (Swagger)

**Afternoon (13:00-17:00): Report Writing**

Người: Xuân

**Report Outline (3-5 pages):**

1. **Executive Summary** (1 page)
   - What was built
   - 20 APIs, Telegram integration, security, tests

2. **Architecture** (1 page)
   - System design
   - Database schema (3 collections)
   - Endpoints overview

3. **Technical Details** (1-2 pages)
   - API endpoints list
   - Security measures (RBAC, JWT)
   - Testing results (coverage, E2E)
   - Telegram integration

4. **Deployment Guide** (1 page)
   - How to run locally
   - Environment variables needed
   - Database setup

5. **Conclusions** (0.5 page)
   - What we learned
   - Next steps (Mobile app, more integrations)

**Files:**

- [ ] `backend/REPORT.md` or PDF

---

**PHASE 4 DONE Khi:**

- ✅ Telegram integration working
- ✅ Demo successful
- ✅ Report written
- ✅ All code committed + merged to dev

---

## 🎯 FINAL CHECKLIST (Ngày 12 Chiều)

- [ ] 20 API endpoints working
- [ ] Security review passed (RBAC)
- [ ] Tests passing (>= 80% coverage)
- [ ] Documentation complete (Swagger + guide)
- [ ] Telegram integration working
- [ ] Demo successful
- [ ] Report written
- [ ] All code in dev branch
- [ ] Postman collection ready
- [ ] README updated

---

## 📊 TIMELINE AT A GLANCE

```
Day 1-2:   Phase 1 (Minh designs)
Day 3-5:   Phase 2 (4 people code) + Day 6-7 (Minh merges)
Day 8-10:  Phase 3 (4 people test/doc/security)
Day 11-12: Phase 4 (Nam + Xuân = Telegram) + Demo
```

---

**Tạo:** 13/4/2026  
**Status:** Ready to execute
