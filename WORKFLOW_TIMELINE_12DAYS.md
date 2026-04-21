# 📅 SMART SPENDER API - WORKFLOW TIMELINE (12 NGÀY)

**Team Lead:** Mai Huy Minh  
**Team Members:** Nguyễn Nhật Nam, Vũ Ngọc Anh, Lê Thị Anh Chúc, Hà Hoài Xuân

---

## 🎯 OVERVIEW: AI CÓ THỂLÀM GÌ KHI AI XONG

```
┌─────────────────────────────────────────────────────────┐
│ MINH HOÀN XONG (Ngày 1-2)                              │
│ ↓↓↓                                                      │
│ 4 NGƯỜI CÓ SCHEMA → BẮT ĐẦU CODE NGAY TỪ NGÀY 2-3     │
│ ↓↓↓                                                      │
│ NGÀY 5: TẤT CẢ 4 NGƯỜI PUSH PR                         │
│ ↓↓↓                                                      │
│ NGÀY 6-7: MINH MERGE + INTEGRATION TEST                │
│ ↓↓↓                                                      │
│ NGÀY 8-9: SECURITY + EXTERNAL API                      │
│ ↓↓↓                                                      │
│ NGÀY 12: DEMO + SHIP                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 TIMELINE: 12 NGÀY CHI TIẾT

### ⏱️ **NGÀY 1-2: MINH DESIGN (Phase 1)**

| Thời gian      | Công việc                                                 | Người                  | Output          |
| -------------- | --------------------------------------------------------- | ---------------------- | --------------- |
| **Ngày 1**     | Parse spec từ files cũ → liệt kê 20 endpoints → vẽ schema | Minh                   | Draft files     |
| **Ngày 2**     | Hoàn thiện spec + schema + Postman + seeding script       | Minh                   | 4 files ready   |
| **Ngày 2 tối** | Team Kickoff (15 min): Giải thích + Q&A                   | Minh + Team            | Team understand |
| **Người khác** | Setup laptop: `git clone`, `npm install`                  | Nam/Ngọc Anh/Chúc/Xuân | Ready to code   |

**Minh Output:**

```
✅ backend/docs/GROUP_API_SPECIFICATION.md
✅ backend/docs/GROUP_DATABASE_SCHEMA.md
✅ backend/postman/group-api.postman_collection.json
✅ backend/seeds/group-seed.js
```

**Status:**

```
git checkout docs/phase1-design
git add .
git commit -m "docs: Phase 1 COMPLETE - API spec, schema, Postman, seeding"
git push origin docs/phase1-design
```

---

### ⏱️ **NGÀY 3: NAM CODE (SOLO) - Nam làm 1 người full day**

| Thời gian      | Công việc                                                 | Người              | Output                 |
| -------------- | --------------------------------------------------------- | ------------------ | ---------------------- |
| **Sáng**       | Pull Minh's spec files + Create branch feature/group-apis | Nam                | Branch ready           |
| **Sáng**       | Code Group model (with validation, indexes, pre-hooks)    | Nam                | group.model.js ✅      |
| **Chiều**      | Code Group controller (5 methods: C-R-R-U-D)              | Nam                | group.controller.js ✅ |
| **Chiều**      | Test 3 endpoints (POST, GET /, GET :id) với Postman       | Nam                | Test ✅ ✅ ✅          |
| **Tối**        | Commit + Push                                             | Nam                | PR ready (draft)       |
| **Người khác** | Watch Nam's code in GitHub / Ask questions / Chuẩn bị     | Ngọc Anh/Chúc/Xuân | Learn pattern          |

**Nam Output (Push at end of day):**

```
✅ backend/models/group.model.js
✅ backend/controllers/group.controller.js
✨ 3/5 endpoints tested
```

**Status:**

```
git checkout feature/group-apis
git add models/group.model.js controllers/group.controller.js
git commit -m "feat: Add group model and first 3 endpoints"
git push origin feature/group-apis
```

---

### ⏱️ **NGÀY 4: NAM FINISH + (Ngọc Anh/Chúc/Xuân PREP)**

| Thời gian      | Công việc                                                                 | Người              | Output                                  |
| -------------- | ------------------------------------------------------------------------- | ------------------ | --------------------------------------- |
| **Sáng**       | Code Group routes + validators                                            | Nam                | group.routes.js + group.validator.js ✅ |
| **Sáng**       | Implement DELETE endpoint                                                 | Nam                | 5/5 endpoints done                      |
| **Chiều**      | Test ALL 5 endpoints (Postman)                                            | Nam                | All tests ✅✅✅✅✅                    |
| **Chiều**      | Code review: naming, error handling, JWT checks                           | Nam                | Fix bugs (if any)                       |
| **Tối**        | Push final commit                                                         | Nam                | Feature branch ready for PR             |
| **Người khác** | Setup branches + First commit (folder structure)                          | Ngọc Anh/Chúc/Xuân | Branches ready                          |
| **Người khác** | Read Nam's code + understand pattern (Model-Controller-Routes-Validators) | Ngọc Anh/Chúc/Xuân | Ready to code                           |

**Nam Output:**

```
✅ backend/routes/group.routes.js
✅ backend/validators/group.validator.js
✅ All 5 endpoints tested & working
```

**Status:**

```
git add routes/group.routes.js validators/group.validator.js
git commit -m "feat: Add routes, validators, and DELETE endpoint"
git push origin feature/group-apis
```

**Others Status:**

```
# Ngọc Anh
git checkout feature/group-members-apis
mkdir -p backend/models backend/controllers backend/routes backend/validators
git add .
git commit -m "feat: Setup folder structure for members APIs"
git push origin feature/group-members-apis

# Chúc (tương tự)
git checkout feature/group-wallets-apis
...

# Xuân (tương tự)
git checkout feature/group-transactions-apis
...
```

---

### ⏱️ **NGÀY 5: TẤT CẢ 4 NGƯỜI CODE PARALLEL**

| Thời gian    | Công việc                                                    | Người              | Output                                 |
| ------------ | ------------------------------------------------------------ | ------------------ | -------------------------------------- |
| **Sáng sơm** | All 4 pull Nam's group.model.js + .controller.js (reference) | Ngọc Anh/Chúc/Xuân | Code reference ready                   |
| **Sáng**     | Code model + controller cho feature của mình                 | Ngọc Anh/Chúc/Xuân | group_members.model.js + controller ✅ |
| **Chiều**    | Code routes + validators + final endpoint                    | Ngọc Anh/Chúc/Xuân | Hoàn thành 5 endpoints                 |
| **Chiều**    | Test ALL 5 endpoints (Postman)                               | Ngọc Anh/Chúc/Xuân | All tests ✅                           |
| **Tối**      | Push final + Create PR vào branch `dev`                      | Ngọc Anh/Chúc/Xuân | 4 PRs ready                            |
| **Nam**      | Review + finalize Group PR                                   | Nam                | Group PR merge-ready                   |

**All 4 Output:**

```
✅ Nam:     5/5 Group endpoints ✅✅✅✅✅
✅ Ngọc Anh: 5/5 Members endpoints ✅✅✅✅✅
✅ Chúc:     5/5 Wallets endpoints ✅✅✅✅✅
✅ Xuân:     5/5 Transactions endpoints ✅✅✅✅✅
```

**Status (Ngày 5 tối):**

```
# Mỗi người
git add .
git commit -m "feat: Complete [feature] - 5 endpoints tested"
git push origin feature/[your-feature]

# Tạo PR (GitHub)
Title: [BE] feat: [Feature] management APIs (5 endpoints)
Reviewer: @Minh08012005
Description: List 5 endpoints + test results
```

---

### ⏱️ **NGÀY 6: MINH REVIEW + MERGE**

| Thời gian | Công việc                                             | Người                  | Output                      |
| --------- | ----------------------------------------------------- | ---------------------- | --------------------------- |
| **Sáng**  | Review 4 PRs (code style, validation, error handling) | Minh                   | Approved / Request changes  |
| **Chiều** | 4 người fix bugs (nếu có) + rebase                    | Nam/Ngọc Anh/Chúc/Xuân | PRs ready merge             |
| **Tối**   | Merge 4 PRs vào `dev` (à, pull latest)                | Minh                   | dev branch has 20 endpoints |

**Status:**

```
git checkout dev
git pull origin dev
git merge feature/group-apis
git merge feature/group-members-apis
git merge feature/group-wallets-apis
git merge feature/group-transactions-apis
git push origin dev
```

---

### ⏱️ **NGÀY 7: INTEGRATION TEST (Minh làm)**

| Thời gian      | Công việc                                                                    | Người | Output           |
| -------------- | ---------------------------------------------------------------------------- | ----- | ---------------- |
| **Sáng**       | Pull dev branch (có 20 endpoints merged)                                     | Minh  | Dev branch ready |
| **Sáng-Chiều** | Test end-to-end workflow: Group → Members → Wallets → Transactions → Summary | Minh  | Workflow ✅      |
| **Tối**        | Document test results + known issues                                         | Minh  | Test report      |

**Integration Test Workflow:**

```
1. POST /api/groups (Nam's) → groupId
2. POST /api/groups/:id/members (Ngọc Anh's) → memberIds
3. POST /api/groups/:id/wallets (Chúc's) → walletId
4. POST /api/groups/:id/transactions (Xuân's) → transactionIds
5. GET /api/groups/:id/summary (Xuân's) → {income, expense, balance}

Check: Tất cả 5 requests success → 20 endpoints ✅
```

**Status:**

```
All 20 endpoints working together ✅
Dev branch stable → Ready Phase 3
```

---

### ⏱️ **NGÀY 8: SECURITY + TESTS (Phase 3)**

| Thời gian  | Công việc                             | Người    | Output                 |
| ---------- | ------------------------------------- | -------- | ---------------------- |
| **Ngày 8** | Add RBAC middleware + Auth checks     | Nam      | group.middleware.js ✅ |
| **Ngày 8** | Unit tests (80%+ coverage)            | Ngọc Anh | group.test.js ✅       |
| **Ngày 8** | Integration tests + Performance tests | Chúc     | integration.test.js ✅ |
| **Ngày 8** | Error edge cases + Postman test suite | Xuân     | Final test suite ✅    |

**Output:**

```
✅ RBAC security checks enabled
✅ Unit tests 80%+
✅ Integration E2E tests
✅ Performance tests
```

---

### ⏱️ **NGÀY 9: EXTERNAL API INTEGRATION (Phase 4)**

| Thời gian  | Công việc                                                                       | Người    | Output                  |
| ---------- | ------------------------------------------------------------------------------- | -------- | ----------------------- |
| **Ngày 9** | Setup Telegram Bot API key                                                      | Minh     | Token ready             |
| **Ngày 9** | Create endpoint: POST /api/groups/:id/transactions → Send Telegram notification | Minh + 1 | Telegram integration ✅ |
| **Ngày 9** | Test: Create transaction → Receive Telegram message                             | Minh + 1 | Telegram ✅             |

**Output:**

```
✅ Telegram Bot API integrated
✅ Notifications working
✅ Feature tested
```

---

### ⏱️ **NGÀY 10-12: FINAL + DEMO (Phase 5)**

| Thời gian         | Công việc                                 | Người | Output     |
| ----------------- | ----------------------------------------- | ----- | ---------- |
| **Ngày 10**       | Final integration test (whole app)        | Minh  | QA ✅      |
| **Ngày 11**       | Write API documentation (Swagger updated) | Xuân  | Swagger ✅ |
| **Ngày 11**       | Write README + setup guide                | Nam   | Docs ✅    |
| **Ngày 12 sáng**  | Prepare demo video (10 min)               | Minh  | Demo 📹    |
| **Ngày 12 chiều** | Demo to teacher + Submit report           | Minh  | 🎉 SHIPPED |

**Output:**

```
✅ Full API documentation
✅ Setup guide
✅ Demo video
✅ Final report
✅ Ready to submit
```

---

## 📊 **QUICK REFERENCE: AI LÀM GÌ KHI NÀO**

### **MINH (Team Lead)**

```
Ngày 1-2:   Design 4 files (spec, schema, Postman, seeding)
Ngày 3-4:   Guide + answer questions
Ngày 6:     Review 4 PRs + merge
Ngày 7:     Integration test
Ngày 8:     Support security implementation
Ngày 9:     Implement Telegram API
Ngày 10-12: Final test + demo + submit
```

### **NAM (Group APIs)**

```
Ngày 1-2:   Setup + understand spec
Ngày 3-4:   CODE Group APIs (5 endpoints)
Ngày 5:     Push PR, test
Ngày 6-7:   Review feedback + merge
Ngày 8:     RBAC middleware
Ngày 9:     Support Telegram integration
Ngày 10-11: Documentation
Ngày 12:    Demo
```

### **NGỌC ANH (Members APIs)**

```
Ngày 1-4:   Setup + prepare + learn from Nam
Ngày 5:     CODE Members APIs (5 endpoints) + push PR
Ngày 6-7:   Review feedback + merge
Ngày 8:     Unit tests (80%+)
Ngày 9-12:  Support final testing + demo
```

### **CHÚC (Wallets APIs)**

```
Ngày 1-4:   Setup + prepare + learn from Nam
Ngày 5:     CODE Wallets APIs (5 endpoints) + push PR
Ngày 6-7:   Review feedback + merge
Ngày 8:     Integration tests
Ngày 9-12:  Support final testing + demo
```

### **XUÂN (Transactions APIs)**

```
Ngày 1-4:   Setup + prepare + learn from Nam
Ngày 5:     CODE Transactions APIs (5 endpoints) + push PR
Ngày 6-7:   Review feedback + merge
Ngày 8:     Error edge cases + test suite
Ngày 9-12:  Documentation + support final testing + demo
```

---

## 🎯 **KEY MILESTONES**

| Milestone                   | Deadline       | Status | Action                      |
| --------------------------- | -------------- | ------ | --------------------------- |
| **Design files ready**      | Ngày 2, 15:00  | 🎯     | Team Kickoff → Start coding |
| **4 PRs created**           | Ngày 5, 18:00  | 🎯     | Minh review + merge         |
| **All merged + integrated** | Ngày 7, 17:00  | ✅     | Ready Phase 3               |
| **Tests + Security done**   | Ngày 8, 17:00  | 🧪     | RBAC + Unit tests ✅        |
| **Telegram API integrated** | Ngày 9, 17:00  | 🚀     | Feature ready               |
| **Final demo ready**        | Ngày 12, 12:00 | 📺     | Submit + pass ✅            |

---

## 💬 **DAILY STANDUP (Mỗi sáng, 15 phút)**

**Questions:**

1. Hôm qua làm gì, có block không?
2. Hôm nay sẽ làm gì?
3. Cần help gì?

**Attendance:** All 5 people

---

## 🔑 **KEY SUCCESS FACTORS**

✅ **Minh hoàn xong Ngày 2 → Team làm Ngày 3-5**  
✅ **Nam code Ngày 3-4 → Others có reference → Ngày 5 code parallel**  
✅ **Commit nhỏ, thường xuyên** (1-2 features = 1 commit)  
✅ **Test local trước push** (Postman)  
✅ **Daily standup** (15 min morning)  
✅ **No force push** (git push -f banned)

---

## 🚀 **READY TO START?**

```
✅ Minh: Hoàn thành design hôm nay (Ngày 1)?
   → Nam code Ngày 3-4, others code Ngày 5
   → Deadline loose (buffer)

❌ Minh: Hoàn thành Ngày 2?
   → Nam code Ngày 4-5
   → Deadline tight (stress)
```

**Khuyến nghị:** Hoàn thành Ngày 1 → Timeline tiện lợi hơn 💪

---

**Last updated:** 14/04/2026  
**Made for:** SmartSpender Team API Project
