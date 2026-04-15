# 🎤 TEAM KICKOFF MEETING - PHASE 1 COMPLETION

**Ngày:** 14/4/2026 (Ngày 2, chiều 15:00)  
**Thời lượng:** 15-20 phút  
**Người main:** Mai Huy Minh (Team Lead)  
**Thành viên:** Nam, Ngọc Anh, Chúc, Xuân

---

## 📌 MEETING AGENDA

### **Phần 1: Welcome (1 phút)**

> "Xin chào cả nhóm! Hôm nay chúng ta sẽ đi vào PHASE 1 completion checklist.
> Tôi vừa hoàn thiện design cho 20 APIs, database schema, seeding scripts,
> và Postman templates. Mọi thứ đã sẵn sàng để các bạn code từ ngày 3."

---

### **Phần 2: Giải Thích Tổng Quan (5 phút)**

#### **Slide 1: Project Timeline**

```
DAY 1-2: PHASE 1 - DESIGN ← WE ARE HERE
DAY 3-5: PHASE 2 - CODE (4 người song parallel)
DAY 6-7: Merge + Integration test
DAY 8-10: Phase 3 (Security, Test, Docs)
DAY 11-12: Phase 4 (Telegram, Demo)
```

#### **Slide 2: 20 Endpoints Breakdown**

```
📁 GROUP APIs (5 endpoints) - Nguyễn Nhật Nam
   1. POST /api/groups (create)
   2. GET /api/groups (list)
   3. GET /api/groups/:id (detail)
   4. PATCH /api/groups/:id (update)
   5. DELETE /api/groups/:id (delete)

👥 MEMBERS APIs (5 endpoints) - Vũ Ngọc Anh
   1. POST /api/groups/:id/members
   2. GET /api/groups/:id/members
   3. GET /api/groups/:id/members/:userId
   4. PATCH /api/groups/:id/members/:userId
   5. DELETE /api/groups/:id/members/:userId

💳 WALLETS APIs (5 endpoints) - Lê Thị Anh Chúc
   1. POST /api/groups/:id/wallets
   2. GET /api/groups/:id/wallets
   3. GET /api/groups/:id/wallets/:walletId
   4. PATCH /api/groups/:id/wallets/:walletId
   5. DELETE /api/groups/:id/wallets/:walletId

💰 TRANSACTIONS APIs (5 endpoints) - Hà Hoài Xuân
   1. POST /api/groups/:id/transactions
   2. GET /api/groups/:id/transactions
   3. PATCH /api/groups/:id/transactions/:txId
   4. DELETE /api/groups/:id/transactions/:txId
   5. GET /api/groups/:id/summary (tổng chi/thu)
```

#### **Slide 3: Database Design (3 Collections)**

```
┌─────────────────────────────────────────┐
│ GROUPS COLLECTION                       │
│ _id, name, description, createdBy, ... │
└─────────────────────────────────────────┘
              ↓
┌─────────────────────────────────────────┐
│ GROUP_MEMBERS COLLECTION                │
│ _id, groupId, userId, role, ...         │
│ (thể hiện: user X là gì trong group Y) │
└─────────────────────────────────────────┘
        ↓
┌─────────────────────────────────────────┐
│ GROUP_WALLETS COLLECTION                │
│ _id, groupId, name, balance, ...        │
│ (ví của group: "Quỹ chính", ....)       │
└─────────────────────────────────────────┘
        ↓
    TRANSACTIONS (existing)
    + thêm groupId field
```

---

### **Phần 3: Phase 2 Task Assignment (5 phút)**

#### **Giải Thích từng người:**

**👨‍💻 Nam (Nguyễn Nhật Nam) - GROUP APIs**

> "Nam bạn sẽ code 5 Group endpoints. Mục tiêu: user có thể tạo nhóm,
> xem danh sách, xem chi tiết, cập nhật, xóa.
>
> Files cần tạo:
>
> - backend/models/group.model.js
> - backend/controllers/group.controller.js
> - backend/routes/group.routes.js
> - backend/validators/group.validator.js
>
> Deadline: Ngày 5 tối, PR cho Minh review"

**👩‍💻 Ngọc Anh (Vũ Ngọc Anh) - MEMBERS APIs**

> "Ngọc Anh sẽ code 5 Members APIs. Mục tiêu: quản lý thành viên,
> thêm/xóa/cập nhật role (admin, member, viewer).
>
> Files tương tự:
>
> - group_members.model.js
> - group_members.controller.js
> - group_members.routes.js
> - group_members.validator.js
>
> Deadline: Ngày 5 tối"

**👩‍💻 Chúc (Lê Thị Anh Chúc) - WALLETS APIs**

> "Chúc sẽ code 5 Wallets APIs. Mục tiêu: tạo/quản lý ví (tài khoản chi tiêu).
>
> Tương tự files như trên, nhưng cho wallets.
>
> Deadline: Ngày 5 tối"

**👨‍💻 Xuân (Hà Hoài Xuân) - TRANSACTIONS APIs**

> "Xuân sẽ code 5 Transactions APIs + 1 summary endpoint
> (để lấy tổng chi/thu của group).
>
> Deadline: Ngày 5 tối"

---

### **Phần 4: Resources Available (3 phút)**

**Các file bạn có:**

```
✅ API Specification: backend/docs/GROUP_API_SPECIFICATION.md
   → Detail từng endpoint (request, response, status codes)

✅ Database Schema: backend/docs/GROUP_DATABASE_SCHEMA.md
   → Mô tả 3 collections (fields, indexes, relationships)

✅ Postman Collection: backend/postman/group-api.postman_collection.json
   → 20 requests sẵn để test

✅ Mock Data:  node backend/seeds/group-seed.js
   → Chạy lệnh này để có 3 groups + 10 members + 5 wallets test data

✅ Quick Start: backend/docs/QUICK_START_EXECUTION.md
   → Step-by-step setup hướng dẫn
```

**Cách dùng:**

1. **Mỗi thành viên đọc spec** cho phần của mình
2. **Test bằng Postman** (import collection)
3. **Follow spec chính xác** (request/response format)

---

### **Phần 5: Development Process (3 phút)**

#### **Workflow từng ngày (Ngày 3-5):**

**Ngày 3:**

```
Sáng:  Setup branch feature/xxx-apis
       Tạo models + schema
Chiều: Test models
       1 commit
```

**Ngày 4:**

```
Sáng:  Code controller methods 1-3
Chiều: Code controller methods 4-5
       Test với Postman
       2-3 commits
```

**Ngày 5:**

```
Sáng-chiều: Fine-tune + test lại
            Add routes + validators
            Final test
Tối:        Push to GitHub
            Create PR
            Tag @Minh08012005
```

---

### **Phần 6: Q&A (2 phút)**

**Các câu hỏi phổ biến:**

**Q: "Tôi không hiểu spec, giải thích detail cái này?"**
A: "Mình sẽ giải thích chi tiết hôm nay. File spec rất kỹ, có request/response examples. Nếu còn confuse, ping mình trên Slack"

**Q: "Làm sao để test API mà chưa deploy?"**
A: "Dùng Postman. Mình có sẵn collection với 20 requests. Import vào → test local"

**Q: "Deadline ngày 5 có khắt khe không?"**
A: "Rất khắt khe. Vì Minh cần merge + test integration ngày 6-7. Nếu bạn muốn delay, báo hôm nay"

**Q: "Các bộ phận có liên quan không? (references)"**
A: "Có! Ví dụ, Members APIs cần biết groupId. Wallets cần groupId. Nên hãy làm từ Group APIs trước (Nam), rồi đến Members, đến Wallets, cuối là Transactions"

---

### **Phần 7: Final Confirmation (1 phút)**

> "Mình tóm tắt:
>
> ✅ PHASE 1 đã hoàn thiện hôm nay
> ✅ Database setup xong, mock data ready
> ✅ Postman collection để test
> ✅ Spec chi tiết cho từng endpoint
>
> Ngày 3-5: Các bạn code 5 endpoints/người
> Ngày 6-7: Minh merge + test
> Ngày 8-10: Phase 3 (security, test, docs - team làm song song)
> Ngày 11-12: Phase 4 + Demo
>
> **Ai ready để code ngày 3?** ✋✋✋
>
> OK, mình hiểu tất cả đã ready. **Team kickoff CONFIRMED!** 🎉
>
> Follow spec, test bằng Postman, push PR ngày 5 tối.
> Mình review + merge ngay hôm sau.
>
> Let's go! 🚀"

---

## 📺 OPTIONAL: Screen Share Demo (5 phút, tuỳ chọn)

Nếu có thời gian, bạn có thể demo:

1. **Mở Postman** → Import collection
2. **Test 1 endpoint:** GET /api/groups → Thấy 3 groups từ seeding
3. **Show spec file:** GROUP_API_SPECIFICATION.md
4. **Answer real-time questions**

---

## 📝 DELIVERABLES AFTER MEETING

**Mỗi thành viên sẽ nhận:**

```
📧 Slack message:

"PHASE 1 Kickoff complete! 🎉

Files bạn cần:
- Spec của phần bạn: docs/GROUP_API_SPECIFICATION.md (section của bạn)
- Database schema: docs/GROUP_DATABASE_SCHEMA.md
- Postman để test: postman/group-api.postman_collection.json
- Quick start guide: docs/QUICK_START_EXECUTION.md

Task của bạn (Ngày 3-5):
[Copy task của mỗi người từ DETAILED_TASKS_12DAYS.md]

Deadline: Ngày 5 tối PR
Expected PR notes: "Tested with Postman ✅"

Hỏi gì → tag @Minh hoặc reply message"
```

---

## ✅ SUCCESS CRITERIA (Sau meeting)

- ✅ Team hiểu 20 endpoints là gì
- ✅ Team hiểu task assignment (ai code cái gì)
- ✅ Team biết dùng Postman để test
- ✅ Team confident để code từ ngày 3
- ✅ Team confirm ready ✅

---

**Duration:** 15-20 phút  
**Time:** Hôm nay (Ngày 2) chiều 15:00  
**Location:** Online Zoom (hoặc on-site)

**Ready to lead? 🚀**
