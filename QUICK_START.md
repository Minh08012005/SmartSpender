# ⚡ QUICK START: Lệnh Git Cơ Bản + Task Của Bạn

**Cho:** Nguyễn Nhật Nam, Vũ Ngọc Anh, Lê Thị Anh Chúc, Hà Hoài Xuân  
**Mục đích:** Cheat sheet nhanh

---

## 🚀 SETUP LẦN ĐẦU TIÊN

```bash
# Clone repo
git clone https://github.com/Minh08012005/SmartSpender.git
cd SmartSpender

# Chuyển sang branch dev
git checkout dev
git pull origin dev

# Cài dependencies
cd backend && npm install
```

---

## 📅 BẮNG NGÀY (HẸP NGÀNH NGÀY)

### **Morning - Đi làm việc:**

```bash
git checkout dev && git pull origin dev
```

### **Start Coding - Tạo branch feature:**

```bash
git checkout -b feature/your-task-name
```

### **During Work - Commit thường xuyên (mỗi 1-2 endpoint):**

```bash
git add .
git commit -m "feat: Add one endpoint"
git push origin feature/your-task-name
```

### **End of Day - Push final code:**

```bash
git push origin feature/your-task-name

# Nếu chưa có PR: Tạo PR trên GitHub
# - Go to: https://github.com/Minh08012005/SmartSpender/pulls
# - Click: "New Pull Request"
# - Title: [BE] feat: Description of your work
# - Reviewer: @Minh08012005
```

---

## 👥 TASK CỦA TỪ NGƯỜI - PHASE 2 (Ngày 5-8)

### **📝 NAM (Nguyễn Nhật Nam) - Group APIs**

**Branch:** `feature/group-apis`

**Endpoints (5 cái):**

```
POST   /api/groups              → Tạo nhóm
GET    /api/groups              → Danh sách nhóm
GET    /api/groups/:groupId     → Chi tiết nhóm
PATCH  /api/groups/:groupId     → Cập nhật nhóm
DELETE /api/groups/:groupId     → Xóa nhóm
```

**Files to Create:**

- `backend/models/group.model.js`
- `backend/controllers/group.controller.js`
- `backend/routes/group.routes.js`
- `backend/validators/group.validator.js`

**Done by:** Ngày 8 tối

---

### **📝 NGỌC ANH (Vũ Ngọc Anh) - Members APIs**

**Branch:** `feature/group-members-apis`

**Endpoints (5 cái):**

```
POST   /api/groups/:groupId/members              → Thêm member
GET    /api/groups/:groupId/members              → Danh sách
GET    /api/groups/:groupId/members/:userId     → Chi tiết
PATCH  /api/groups/:groupId/members/:userId     → Đổi role
DELETE /api/groups/:groupId/members/:userId     → Xóa member
```

**Files to Create:**

- `backend/models/group_members.model.js`
- `backend/controllers/group_members.controller.js`
- `backend/routes/group_members.routes.js`
- `backend/validators/group_members.validator.js`

**Done by:** Ngày 8 tối

---

### **📝 CHÚC (Lê Thị Anh Chúc) - Wallets APIs**

**Branch:** `feature/group-wallets-apis`

**Endpoints (5 cái):**

```
POST   /api/groups/:groupId/wallets              → Tạo ví
GET    /api/groups/:groupId/wallets              → Danh sách
GET    /api/groups/:groupId/wallets/:walletId   → Chi tiết
PATCH  /api/groups/:groupId/wallets/:walletId   → Cập nhật
DELETE /api/groups/:groupId/wallets/:walletId   → Xóa
```

**Files to Create:**

- `backend/models/group_wallets.model.js`
- `backend/controllers/group_wallets.controller.js`
- `backend/routes/group_wallets.routes.js`
- `backend/validators/group_wallets.validator.js`

**Done by:** Ngày 8 tối

---

### **📝 XUÂN (Hà Hoài Xuân) - Transactions + Summary APIs**

**Branch:** `feature/group-transactions-apis`

**Endpoints (5 cái):**

```
POST   /api/groups/:groupId/transactions         → Tạo giao dịch
GET    /api/groups/:groupId/transactions         → Danh sách
PATCH  /api/groups/:groupId/transactions/:id     → Cập nhật
DELETE /api/groups/:groupId/transactions/:id     → Xóa
GET    /api/groups/:groupId/summary              → Tổng chi/thu
```

**Files to Create:**

- `backend/models/group_transactions.model.js`
- `backend/controllers/group_transactions.controller.js`
- `backend/routes/group_transactions.routes.js`
- `backend/validators/group_transactions.validator.js`

**Done by:** Ngày 8 tối

---

## 📚 FILES ĐỂ ĐỌC

| File                       | Khi Nào Đọc                      |
| -------------------------- | -------------------------------- |
| **PHASE_OVERVIEW.md**      | Hôm nay (overview 3 phase)       |
| **DETAILED_TASKS.md**      | Ngày 1 Phase (chi tiết task bạn) |
| **TEAM_WORKFLOW_GUIDE.md** | Lần đầu (học git workflow)       |

---

## ✅ CHECKLIST MỖI NGÀY

### **Morning (08:30)**

- [ ] `git pull origin dev` (cập nhật code mới)
- [ ] Check Slack/Teams for blockers

### **During Day**

- [ ] Code 1-2 endpoints
- [ ] Test với Postman
- [ ] Commit & push (nếu xong)

### **Evening (17:00)**

- [ ] Push code final
- [ ] Check: Có conflict không?
- [ ] PR ready cho next day?

---

## 🎯 RULES BẮTNHẤT

✅ **PHẢI:**

- Tạo **feature branch** (không commit trực tiếp vào dev)
- Commit **thường xuyên** (1 endpoint = 1 commit)
- **Test local** trước push
- **Tag @Minh08012005** trong PR

❌ **KHÔNG:**

- Push trực tiếp vào `dev` hoặc `main`
- Commit message: "fix", "update", "aaa"
- Force push (`git push -f`)

---

## 🆘 CÓ LỖI?

| Lỗi                        | Fix                                        |
| -------------------------- | ------------------------------------------ |
| "branch behind origin"     | `git pull origin dev`                      |
| "merge conflict"           | Giải quyết file, `git add .`, `git commit` |
| "forgot to commit"         | `git add .`, `git commit -m "..."`         |
| "need to see code changes" | `git diff` hoặc `git log --oneline`        |

---

## 📞 HELP

- **Git problem** → Message Minh
- **Task unclear** → Standup morning (08:30)
- **Blocked** → Tell Minh (will help)
- **Code review feedback** → Check PR comments

---

**Made by:** Minh 🚀  
**Last updated:** 13/4/2026
