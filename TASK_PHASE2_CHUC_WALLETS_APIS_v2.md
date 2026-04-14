# 🎯 TASK PHASE 2: GROUP WALLETS APIs

**Assigned to:** 👩‍💻 **Lê Thị Anh Chúc**  
**Duration:** 3 ngày (Ngày 3-5)  
**Deadline:** Ngày 5, 18:00 (PR)  
**Branch:** `feature/group-wallets-apis`  
**Endpoints:** 5 (CREATE, LIST, DETAIL, UPDATE, DELETE)

---

## 📋 CÔNG VIỆC

Code 5 endpoints quản lý **ví chung của group**:

```
POST   /api/groups/:groupId/wallets              → Tạo ví
GET    /api/groups/:groupId/wallets              → Danh sách ví
GET    /api/groups/:groupId/wallets/:walletId    → Chi tiết ví
PATCH  /api/groups/:groupId/wallets/:walletId    → Update ví (balance, currency)
DELETE /api/groups/:groupId/wallets/:walletId    → Xóa ví
```

---

## 🕐 TIMELINE

### **Ngày 3 - Model + 2 endpoints**

- [ ] Tạo `backend/models/group_wallets.model.js`
  - Fields: groupId, name, balance, currency (VND/USD/EUR), timestamps
  - Validation: balance >= 0, currency enum
- [ ] Tạo `backend/controllers/group_wallets.controller.js`
  - `createWallet()` → POST
  - `listWallets()` → GET /
- [ ] Test 2 endpoints → 201, 200 ✅
- [ ] Commit + Push

### **Ngày 4 - 2 endpoints**

- [ ] `getWalletDetails()` → GET /:walletId
- [ ] `updateWallet()` → PATCH /:walletId
- [ ] Test 4 endpoints ✅
- [ ] Commit + Push

### **Ngày 5 - Routes + Delete + PR**

- [ ] Tạo `backend/routes/group_wallets.routes.js`
- [ ] Tạo `backend/validators/group_wallets.validator.js`
- [ ] `deleteWallet()` → DELETE /:walletId
- [ ] Test tất cả 5 endpoints ✅
- [ ] **Create PR** → Reviewer: @Minh08012005

---

## 📂 FILES CẦN TẠO

| File                                              | Công dụng                   |
| ------------------------------------------------- | --------------------------- |
| `backend/models/group_wallets.model.js`           | Schema + balance validation |
| `backend/controllers/group_wallets.controller.js` | 5 methods                   |
| `backend/routes/group_wallets.routes.js`          | Mount endpoints             |
| `backend/validators/group_wallets.validator.js`   | Validate balance, currency  |

---

## 💡 HƯỚNG CODE

### **Model (group_wallets.model.js)**

- Fields: groupId, name, balance, currency, timestamps
- Validations:
  - name: required, min 3 chars
  - balance: required, >= 0
  - currency: enum ['VND', 'USD', 'EUR']
- Indexes: `{groupId}`

### **Controller (group_wallets.controller.js)**

- `createWallet()`: Check group exists → Validate balance >= 0 → Create → return 201
- `listWallets()`: Find by groupId → return 200
- `getWalletDetails()`: Find by ID → return 200 hoặc 404
- `updateWallet()`: Validate balance >= 0 → Update → return 200 hoặc 404
- `deleteWallet()`: Delete by ID → return 200 hoặc 404

### **Routes (group_wallets.routes.js)**

- Use mergeParams: true
- JWT middleware

### **Validators (group_wallets.validator.js)**

- Validate name: required, min 3 chars
- Validate balance: >= 0
- Validate currency: must be in ['VND', 'USD', 'EUR']

---

## 🧪 TESTING CHECKLIST

**All 5 endpoints:**

- Success: valid input → 201/200 ✅
- Error: invalid balance / currency / not found → 400/404 ❌

---

## 📝 COMMIT PATTERN

```
Ngày 3: feat: Add group wallets model and create/list endpoints
Ngày 4: feat: Add wallet details and update endpoints
Ngày 5: feat: Add routes, validators, and delete endpoint
```

---

## ✅ CHECKLIST NGÀY 5

- [ ] 5 endpoints work
- [ ] Balance validation (>= 0) OK
- [ ] Currency enum OK
- [ ] Error handling OK
- [ ] Tested all cases

---

**Branch:** `feature/group-wallets-apis`  
**Deadline:** Ngày 5, 18:00
