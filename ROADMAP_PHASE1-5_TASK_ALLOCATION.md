# 📊 SMART SPENDER API - LỘ TRÌNH GIAO TASK (12 NGÀY)

**Team Lead:** Mai Huy Minh  
**Team Members:** Nguyễn Nhật Nam, Vũ Ngọc Anh, Lê Thị Anh Chúc, Hà Hoài Xuân  
**Mục tiêu:** Nâng cấp từ app quản lý chi tiêu **cá nhân** → **nhóm** + tích hợp Telegram Bot API

---

## 🎯 KẾ HOẠCH 12 NGÀY (5 PHASE)

```
┌──────────────────────────────────────┐
│ PHASE 1: DESIGN (Ngày 1-2)           │
│ Minh: Spec + Schema + Postman        │
│ Status: 📄 Planning                  │
└──────────────────────────────────────┘
           ↓ Ngày 3
┌──────────────────────────────────────┐
│ PHASE 2: BACKEND CODE (Ngày 3-7)     │
│ 4 people: 4 feature branches PARALLEL│
│ - Nam: Group APIs (5 endpoints)      │
│ - Ngọc Anh: Members APIs (5)         │
│ - Chúc: Wallets APIs (5)             │
│ - Xuân: Transactions + Summary (5)   │
│ Status: 💻 Coding                    │
└──────────────────────────────────────┘
           ↓ Ngày 8
┌──────────────────────────────────────┐
│ PHASE 3: SECURITY & TESTING (Ngày 8) │
│ - RBAC, Auth checks                  │
│ - Unit tests, Integration tests      │
│ Status: 🧪 Testing                   │
└──────────────────────────────────────┘
           ↓ Ngày 9
┌──────────────────────────────────────┐
│ PHASE 4: EXTERNAL APIs (Ngày 9)      │
│ Minh + 1: Telegram Bot Integration   │
│ Status: 🚀 Integration               │
└──────────────────────────────────────┘
           ↓ Ngày 10
┌──────────────────────────────────────┐
│ PHASE 5: DEMO & DEPLOY (Ngày 10-12)  │
│ Final testing + Documentation + Demo │
│ Status: ✅ Shipping                  │
└──────────────────────────────────────┘
```

---

## ✅ CÂU TRẢ LỜI: 5 NGƯỜI CÓ THỂ PARALLEL KHÔNG?

### **Trả lời: CÓ, HOÀN TOÀN CÓ ĐƯỢC** ✅

**Lý do:**

| Yếu tố                 | Tình Hình                                                        | Kết luận                       |
| ---------------------- | ---------------------------------------------------------------- | ------------------------------ |
| **Phụ thuộc lẫn nhau** | KHÔNG - mỗi người khác branch                                    | ✅ Song parallel OK            |
| **Database schema**    | Minh design Ngày 1, công khai Ngày 2 sáng                        | ✅ Team có schema trước code   |
| **Git workflow**       | 4 feature branches riêng (group, members, wallets, transactions) | ✅ Không conflict              |
| **Merge strategy**     | Merge sau Ngày 7, Minh review + integration test                 | ✅ Kiểm soát được              |
| **API dependencies**   | Group → Members/Wallets/Transactions (parent-child)              | ✅ OK (child wait group first) |

**Nhược điểm nhỏ:**

- Ngày 3 Nam cần tạo group trước, rồi Ngọc Anh/Chúc/Xuân tạo child collections
- **Giải pháp:** Nam tạo xong Group (Ngày 3) → push → sáng Ngày 4 Ngọc Anh/Chúc/Xuân pull + code Members/Wallets/Transactions

---

## 📋 TASK ASSIGNMENT

### **🎯 PHASE 1: DESIGN (Ngày 1-2)**

| Người    | Task                                         | File                            |
| -------- | -------------------------------------------- | ------------------------------- |
| **Minh** | API Spec + Schema + Postman + Seeding Script | `TASK_PHASE1_MINH_DESIGN_v2.md` |

---

### **💻 PHASE 2: BACKEND CODING (Ngày 3-7)**

| Người        | Feature                    | Endpoints                                      | Branch                            | Task File                                  |
| ------------ | -------------------------- | ---------------------------------------------- | --------------------------------- | ------------------------------------------ |
| **Nam**      | **Group**                  | CREATE, READ-list, READ-detail, UPDATE, DELETE | `feature/group-apis`              | `TASK_PHASE2_NAM_GROUP_APIS_v2.md`         |
| **Ngọc Anh** | **Members**                | ADD, LIST, DETAIL, CHANGE-ROLE, REMOVE         | `feature/group-members-apis`      | `TASK_PHASE2_NGOC_ANH_MEMBERS_APIS_v2.md`  |
| **Chúc**     | **Wallets**                | CREATE, LIST, DETAIL, UPDATE, DELETE           | `feature/group-wallets-apis`      | `TASK_PHASE2_CHUC_WALLETS_APIS_v2.md`      |
| **Xuân**     | **Transactions + Summary** | CREATE, LIST, UPDATE, DELETE, SUMMARY          | `feature/group-transactions-apis` | `TASK_PHASE2_XUAN_TRANSACTIONS_APIS_v2.md` |

---

### **🧪 PHASE 3: TESTING (Ngày 8)**

- NAM: RBAC middleware (chỉ admin mới delete)
- NGỌC ANH: Unit tests (80%+ coverage)
- [Lên Ngày 9]

---

### **🚀 PHASE 4: EXTERNAL API (Ngày 9)**

- MINH + 1 person: Tích hợp **Telegram Bot API**
  - When: Có giao dịch nhóm mới
  - Action: Send notification qua Telegram

---

### **✅ PHASE 5: FINAL (Ngày 10-12)**

- Final testing
- Documentation
- Demo + Report

---

## 📁 TẬP TIN TASK CẦN ĐỌC

**Để giao task cho team, bạn gửi link/copy content của các file này:**

```
1️⃣ TASK_PHASE1_MINH_DESIGN_v2.md              → Gửi cho Minh
2️⃣ TASK_PHASE2_NAM_GROUP_APIS_v2.md           → Gửi cho Nam
3️⃣ TASK_PHASE2_NGOC_ANH_MEMBERS_APIS_v2.md    → Gửi cho Ngọc Anh
4️⃣ TASK_PHASE2_CHUC_WALLETS_APIS_v2.md        → Gửi cho Chúc
5️⃣ TASK_PHASE2_XUAN_TRANSACTIONS_APIS_v2.md   → Gửi cho Xuân
```

**Hoặc tạo GitHub Issues cho mỗi người với nội dung task file.**

---

## 🧪 TESTING STRATEGY

### **Ngày 3-5: UNIT/SIMPLE TESTS (Khi coding)**

Mỗi người test 2 cases cho endpoint:

- ✅ **Success case:** Valid input → status 201/200
- ❌ **Error case:** Invalid input → status 400/404

**Tools:** Postman (manual test mỗi endpoint)

### **Ngày 6-7: INTEGRATION TEST (Sau merge)**

Minh sẽ test **end-to-end workflow:**

```
1. Create group (Nam's POST) → groupId
2. Add 2 members (Ngọc Anh's POST) → memberIds
3. Create wallet (Chúc's POST) → walletId
4. Create 3 transactions (Xuân's POST) → transactionIds
5. Get summary (Xuân's GET) → {income, expense, balance}
6. All 5 steps phải success
```

### **Ngày 8-9: ADVANCED TESTS**

- Unit tests (80%+ coverage)
- Error edge cases
- Performance testing

---

## 🔄 GIT WORKFLOW

### **Daily:**

```bash
# Sáng (pull latest)
git checkout dev && git pull origin dev

# Code
git checkout feature/your-branch

# Commit thường xuyên (1-2 endpoints = 1 commit)
git add .
git commit -m "feat: Add endpoint name"
git push origin feature/your-branch

# Chiều (push final)
git push origin feature/your-branch
```

### **Ngày 5 tối: Create PR**

```
Title: [BE] feat: Feature name (X endpoints)
Description: List 5 endpoints, test status
Reviewer: @Minh08012005
```

### **Ngày 6 sáng: Merge (Minh làm)**

Minh sẽ:

1. Review 4 PRs
2. Merge vào `dev` (nếu OK)
3. Test integration

---

## 📝 TRACKING & DEADLINES

| Giai đoạn                        | Deadline       | Status |
| -------------------------------- | -------------- | ------ |
| Phase 1: Design files ready      | Ngày 2, 15:00  | 📄     |
| Phase 2: All PRs created         | Ngày 5, 18:00  | 💻     |
| Phase 2: All merged + tested     | Ngày 7, 17:00  | ✅     |
| Phase 3: Security + Tests        | Ngày 8, 17:00  | 🧪     |
| Phase 4: Telegram API integrated | Ngày 9, 17:00  | 🚀     |
| Phase 5: Final demo ready        | Ngày 12, 12:00 | 📺     |

---

## 💬 DAILY STANDUP (Mỗi sáng, 15 phút)

**Câu hỏi:**

1. Hôm qua làm gì?
2. Hôm nay sẽ làm gì?
3. Có blocking issue không?

**Người**: Mỗi người (5 người)

---

## 🎓 REQUIREMENTS (Để pass môn)

✅ **REST API đầy đủ:** 20 endpoints (CRUD cho 4 feature)  
✅ **HTTP Status codes:** 201, 200, 400, 401, 403, 404, 500  
✅ **JWT Authentication:** Tất cả endpoints require token  
✅ **External API Integration:** Telegram Bot  
✅ **Database:** MongoDB 3 collections mới + modify 1 collection cũ  
✅ **Documentation:** Swagger + Postman collection  
✅ **Testing:** Manual test + unit test + integration test

---

## 🚀 GỢI Ý THỨ TỰ LÀMQUEUE

**Sáng Ngày 1 (Minh):**

- [ ] Gửi task file cho Nam (riêng email)
- [ ] Gửi task file cho Ngọc Anh (riêng email)
- [ ] Gửi task file cho Chúc (riêng email)
- [ ] Gửi task file cho Xuân (riêng email)
- [ ] Team meeting 15 phút: Giải thích lộ trình + Q&A

**Ngày 2 chiều:**

- [ ] All task files ready + shared
- [ ] Team understand + ready to code

**Ngày 3 sáng:**

- [ ] Nam start coding (pull design files)
- [ ] Ngọc Anh/Chúc/Xuân wait (vì phụ thuộc Nam's group)

**Ngày 3 chiều/tối:**

- [ ] Nam push Group APIs
- [ ] Other 3 pull + start coding

---

## ⚡ QUICK START ĐỂ GIAO TASK

### **Cách 1: Copy nội dung vào GitHub Issues**

```
1. Create Issue với title: [Task] PHASE 1 - Design for @Minh
2. Paste content từ TASK_PHASE1_MINH_DESIGN_v2.md
3. Assign @Minh08012005
4. Repeat cho 4 người khác
```

### **Cách 2: Tạo Project columns**

```
Column 1: To Do
  - [Task] Phase 1 Design
  - [Task] Phase 2 Group APIs
  - [Task] Phase 2 Members APIs
  - ...

Column 2: In Progress
  (Auto-move khi push branch)

Column 3: In Review
  (Auto-move khi create PR)

Column 4: Done
  (Auto-move khi merge)
```

### **Cách 3: Share files trực tiếp**

```
Gửi email / Slack cho mỗi người file task của họ
```

---

## ✨ SUMMARY

**5 người được giao:**

- ✅ **Minh:** 1 task (design) - 2 ngày
- ✅ **Nam:** 1 task (group) - 3 ngày
- ✅ **Ngọc Anh:** 1 task (members) - 3 ngày
- ✅ **Chúc:** 1 task (wallets) - 3 ngày
- ✅ **Xuân:** 1 task (transactions) - 3 ngày

**Total:** 20 API endpoints, 4 feature branches **PARALLEL**, **NO CONFLICTS**

**Deadline:** Ngày 5 tất cả PRs → Ngày 7 merge xong → Ngày 9 integration test xong

---

**Ready to ship!** 🚀
