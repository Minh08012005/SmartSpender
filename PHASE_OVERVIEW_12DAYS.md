# 📊 PLAN 4 PHASE - TRONG 12 NGÀY (Compressed)

**Môn:** Lập Trình API & Web  
**Nhóm:** SmartSpender API Team  
**Nhóm Trưởng:** Mai Huy Minh  
**Thành Viên:** Nguyễn Nhật Nam, Vũ Ngọc Anh, Lê Thị Anh Chúc, Hà Hoài Xuân  
**Timeline:** 12 NGÀY (không lùi)

---

## ⏱️ TIMELINE TỔNG QUAN

```
DAY 1-2           DAY 3-7              DAY 8-10            DAY 11-12
┌──────────┐      ┌──────────┐        ┌──────────┐        ┌──────────┐
│ PHASE 1  │  →   │ PHASE 2  │  +  →  │ PHASE 3  │  +  →  │ PHASE 4  │
│ Design   │      │ Code API │        │ Security │        │ External │
└──────────┘      └──────────┘        │ + Test   │        │ API Only │
                  (20 endpoints)       │ + Docs   │        │ + Demo   │
                                      └──────────┘        └──────────┘
```

### **Đặc Điểm:**

- ✅ Phase 2 & 3 **OVERLAP** (Song song, không chờ)
- ✅ Phase 4 **HẠN CHẾ SCOPE** (Chỉ Telegram Bot, không Google Sheets)
- ✅ Daily standup track progress
- ✅ Merge code ngay, không chờ

---

## 📋 PHASE 1: Design (Ngày 1-2)

**Người phụ trách:** Minh  
**Deadline:** Cuối Ngày 2 (tối)

### **Công Việc:**

1. **API Specification** (20 endpoints)
   - Nam: 5 Group endpoints
   - Ngọc Anh: 5 Members endpoints
   - Chúc: 5 Wallets endpoints
   - Xuân: 5 Transactions endpoints

2. **Database Schema** (3 collections)
   - `groups`
   - `group_members` (có role)
   - `group_wallets`
   - Indexes cho performance

3. **Postman Collection Template**
   - Environment variables
   - Folder structure

4. **Database Seeding Script**
   - 3 test groups
   - 10 test members
   - 5 test wallets

### **Deliverable:**

✅ API spec document  
✅ Database schema  
✅ Postman template  
✅ Seeding script  
✅ Team approved (ready code)

**Branch:** `docs/phase1-design`

---

## 💻 PHASE 2: Code Backend APIs (Ngày 3-7)

**Timeline:** 5 ngày, **4 người code CÓ LẠP SONG SONG**

### **👨‍💻 NAM - Group APIs (Ngày 3-5)**

```
POST   /api/groups              (Tạo nhóm)
GET    /api/groups              (Danh sách)
GET    /api/groups/:groupId     (Chi tiết)
PATCH  /api/groups/:groupId     (Cập nhật)
DELETE /api/groups/:groupId     (Xóa)
```

**Files:** 4 files (model, controller, routes, validator)  
**Deadline:** Ngày 5 tối  
**Branch:** `feature/group-apis`

---

### **👩‍💻 NGỌC ANH - Members APIs (Ngày 3-5)**

```
POST   /api/groups/:groupId/members
GET    /api/groups/:groupId/members
GET    /api/groups/:groupId/members/:userId
PATCH  /api/groups/:groupId/members/:userId
DELETE /api/groups/:groupId/members/:userId
```

**Files:** 4 files  
**Deadline:** Ngày 5 tối  
**Branch:** `feature/group-members-apis`

---

### **👩‍💻 CHÚC - Wallets APIs (Ngày 3-5)**

```
POST   /api/groups/:groupId/wallets
GET    /api/groups/:groupId/wallets
GET    /api/groups/:groupId/wallets/:walletId
PATCH  /api/groups/:groupId/wallets/:walletId
DELETE /api/groups/:groupId/wallets/:walletId
```

**Files:** 4 files  
**Deadline:** Ngày 5 tối  
**Branch:** `feature/group-wallets-apis`

---

### **👨‍💻 XUÂN - Transactions APIs (Ngày 3-5)**

```
POST   /api/groups/:groupId/transactions
GET    /api/groups/:groupId/transactions
PATCH  /api/groups/:groupId/transactions/:id
DELETE /api/groups/:groupId/transactions/:id
GET    /api/groups/:groupId/summary          (Tổng chi/thu)
```

**Files:** 4 files  
**Deadline:** Ngày 5 tối  
**Branch:** `feature/group-transactions-apis`

---

### **Ngày 6-7: Merge + Integration Testing**

- [ ] Minh review + merge 4 PRs (same day)
- [ ] Kiểm tra conflict
- [ ] Test tất cả 20 endpoints hoạt động

**Result:** `dev` branch có 20 endpoints working

---

## 🔒 PHASE 3: Security, Testing, Docs (Ngày 8-10)

**Timeline:** 3 ngày, **4 người làm SONG SONG**

### **👨‍💻 NAM - Security Review (Ngày 8-9)**

- ✅ Add RBAC middleware (role-based access)
- ✅ Verify JWT authentication
- ✅ Input validation + sanitization
- ✅ Error handling (không expose sensitive info)

**PR:** Tag Minh, merge Ngày 9

---

### **👩‍💻 NGỌC ANH - Unit Tests (Ngày 8-10)**

- ✅ Unit tests cho models (3 files)
- ✅ Unit tests cho controllers (4 files)
- ✅ Coverage >= 80%

**Target:** ✅ All tests passing

---

### **👩‍💻 CHÚC - Integration Tests (Ngày 8-10)**

- ✅ E2E tests (create group → add members → create wallet → transaction)
- ✅ Performance tests (< 500ms)

**Target:** ✅ All flows working

---

### **👨‍💻 XUÂN - Documentation (Ngày 8-10)**

- ✅ Swagger/OpenAPI docs (20 endpoints)
- ✅ API guide markdown (short, concise)
- ✅ Update Postman collection
- ✅ Update README

**Target:** ✅ Docs production-ready

---

## 🔌 PHASE 4: External API Integration + Demo (Ngày 11-12)

**Scope:** Chỉ **TELEGRAM BOT** (không Google Sheets - quá phức tạp cho 12 ngày)  
**Người phụ trách:** Nam + Xuân (2 người)

### **Công Việc:**

#### **Task: Tích Hợp Telegram Bot Notification**

**Bản chất:** Khi có giao dịch nhóm mới → gửi tin nhắn Telegram

**Luồng:**

```
User POST /api/groups/:id/transactions
    ↓
Save to DB
    ↓
Call Telegram Bot API (gửi tin)
    ↓
Nhóm chat Telegram nhận notification:
"[SmartSpender] Nguyễn Văn A vừa tạo giao dịch:
 Loại: Chi tiêu
 Số tiền: 500k
 Nhóm: Du lịch"
```

**Setup (2 bước):**

1. Tạo Telegram Bot (@BotFather)
2. Lấy token + group chat ID

**Code (30 phút):**

```javascript
// backend/services/telegram.service.js
const sendTelegramNotification = async (groupName, transaction) => {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_GROUP_CHAT_ID;

  const message = `📝 [${groupName}]
Loại: ${transaction.type}
Số tiền: ${transaction.amount}đ
Ghi chú: ${transaction.note}`;

  await axios.post(
    `https://api.telegram.org/bot${token}/sendMessage`,
    { chat_id: chatId, text: message },
  );
};

// backend/routes/transactions.js
router.post("/:groupId/transactions", async (req, res) => {
  const trans = await Transaction.create({...});
  const group = await Group.findById(groupId);

  // Call Telegram
  await sendTelegramNotification(group.name, trans);

  res.json({ status: "success" });
});
```

**Files to Create:**

- `backend/services/telegram.service.js` (Telegram util)
- Update `backend/routes/transactions.js` (thêm notification)

**Testing:**

- [ ] Create transaction, check Telegram chat
- [ ] Test error handling (nếu token invalid)

**Deadline:** Ngày 12 sáng

---

### **Ngày 12 (Chiều): Demo + Report**

- ✅ Demo tất cả 20 endpoints (Postman)
- ✅ Demo Telegram notification
- ✅ Show test results
- ✅ Chuẩn bị báo cáo

---

## 👥 TASK MATRIX TÓMLƯỢC

| Phase | Ngày  | Người      | Task                            | Status         |
| ----- | ----- | ---------- | ------------------------------- | -------------- |
| **1** | 1-2   | Minh       | API Spec + DB Schema            | 🎯 Leader      |
| **2** | 3-5   | Nam        | Group APIs (5 endpoints)        | 👨‍💻 Code        |
| **2** | 3-5   | Ngọc Anh   | Members APIs (5 endpoints)      | 👩‍💻 Code        |
| **2** | 3-5   | Chúc       | Wallets APIs (5 endpoints)      | 👩‍💻 Code        |
| **2** | 3-5   | Xuân       | Transactions APIs (5 endpoints) | 👨‍💻 Code        |
| **2** | 6-7   | Minh       | Review + Merge PRs              | 🔍 Review      |
| **3** | 8-10  | Nam        | Security Review                 | 🔒 Security    |
| **3** | 8-10  | Ngọc Anh   | Unit Tests                      | ✅ QA          |
| **3** | 8-10  | Chúc       | Integration Tests               | ✅ QA          |
| **3** | 8-10  | Xuân       | Documentation                   | 📚 Docs        |
| **4** | 11-12 | Nam + Xuân | Telegram Integration            | 🔌 Integration |
| **4** | 12    | Tất cả     | Demo + Report                   | 📊 Final       |

---

## 🎯 ACCEPTANCE CRITERIA

### **PHASE 1 - DONE Khi:**

- ✅ API spec written (20 endpoints)
- ✅ Database schema finalized
- ✅ Team ready to code

### **PHASE 2 - DONE Khi:**

- ✅ 20 endpoints merged to dev
- ✅ All Postman tests pass
- ✅ No conflicts in dev branch

### **PHASE 3 - DONE Khi:**

- ✅ Security review passed
- ✅ Code coverage >= 80%
- ✅ E2E tests passing
- ✅ Documentation complete
- ✅ Swagger valid

### **PHASE 4 - DONE Khi:**

- ✅ Telegram integration working
- ✅ Notifications send successfully
- ✅ Demo video/screenshots ready
- ✅ Report written

---

## 📅 CRITICAL PATH (Đường Dẫn Tới Deadline)

```
Day 1-2:  Minh design
          ↓ (ngày 3)
Day 3-5:  4 người code APIs (PARALLEL)
          ↓ (ngày 6)
Day 6-7:  Minh merge, test integration
          ↓ (ngày 8)
Day 8-10: Nam (security), Ngọc Anh (unit test),
          Chúc (integration), Xuân (docs) - PARALLEL
          ↓ (ngày 11)
Day 11-12: Nam + Xuân integrate Telegram
          ↓ (ngày 12 chiều)
          Demo + Report
```

⚠️ **KEY:** Phase 2 & 3 OVERLAP → không chờ, code cùng lúc

---

## 🔄 DAILY WORKFLOW

### **Standup (08:30 - 09:00)**

```
Mỗi người báo (1 phút):
1. Hôm qua hoàn thành?
2. Hôm nay làm gì?
3. Có bị block không?

Ví dụ (Ngày 5 - Nam):
- "Xong 4/5 endpoints, còn DELETE"
- "Hôm nay hoàn thành DELETE + test + PR"
- "Không block"
```

### **During Day (09:00 - 17:00)**

```
1. Pull dev (cập nhật code mới)
2. Code (mục tiêu: 1 endpoint/2h)
3. Test local (Postman)
4. Commit khi xong (không chờ)
5. Push (afternoon)
```

### **Evening (16:00 - 17:00)**

```
- Push final code
- Check no conflicts
- PR ready to review
```

---

## 🚀 SUCCESS FACTORS

1. **Parallel work:** Phase 2 & 3 cùng lúc (tiết kiệm 2-3 ngày)
2. **Same-day review:** Minh review PR ngay (không block)
3. **Telegram only:** Không Google Sheets (quá phức tạp)
4. **Scope locked:** Không thêm feature phụ
5. **Daily sync:** Standup 15 phút (catch issues early)

---

## 📞 FILES TO READ

| Ngày      | File                     | Content                    |
| --------- | ------------------------ | -------------------------- |
| **Today** | PHASE_OVERVIEW_12DAYS.md | This file (tổng quan)      |
| **Day 1** | DETAILED_TASKS_12DAYS.md | Chi tiết Phase 1 (Minh)    |
| **Day 3** | DETAILED_TASKS_12DAYS.md | Chi tiết Phase 2 (4 người) |
| **Day 8** | DETAILED_TASKS_12DAYS.md | Chi tiết Phase 3 + Phase 4 |
| **Daily** | QUICK_START.md           | Git commands + task recap  |

---

## 🎉 DELIVERABLES CUỐI CÙNG (Day 12)

1. ✅ Backend API (20 endpoints)
2. ✅ Database (3 collections)
3. ✅ Security + RBAC (role-based)
4. ✅ Tests (unit + integration, 80%+ coverage)
5. ✅ Documentation (Swagger + Guide)
6. ✅ Telegram Bot Integration
7. ✅ Demo video/screenshots
8. ✅ Report (3-5 pages)

---

**Ready to execute? Let's go! 🚀**

**Tạo ngày:** 13/4/2026  
**Status:** Compressed to 12 days, ready to share with team
