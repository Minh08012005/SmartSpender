# 🎯 TASK PHASE 2: GROUP TRANSACTIONS APIs

**Assigned to:** 👨‍💻 **Hà Hoài Xuân**  
**Duration:** 3 ngày (Ngày 3-5)  
**Deadline:** Ngày 5, 18:00 (PR)  
**Branch:** `feature/group-transactions-apis`  
**Endpoints:** 5 (CREATE, LIST, UPDATE, DELETE, SUMMARY)

---

## 📋 CÔNG VIỆC

Code 5 endpoints quản lý **giao dịch + tổng hợp của group**:

```
POST   /api/groups/:groupId/transactions         → Tạo giao dịch
GET    /api/groups/:groupId/transactions         → Danh sách giao dịch
PATCH  /api/groups/:groupId/transactions/:id     → Update giao dịch
DELETE /api/groups/:groupId/transactions/:id     → Xóa giao dịch
GET    /api/groups/:groupId/summary              → Tổng chi/thu/dư
```

---

## 🕐 TIMELINE

### **Ngày 3 - Model + 2 endpoints**

- [ ] Tạo `backend/models/group_transactions.model.js`
  - Fields: groupId, userId, walletId, amount, type (income/expense), note, timestamps
  - Validation: amount > 0, type enum
- [ ] Tạo `backend/controllers/group_transactions.controller.js`
  - `createTransaction()` → POST
  - `listTransactions()` → GET /
- [ ] Test 2 endpoints → 201, 200 ✅
- [ ] Commit + Push

### **Ngày 4 - 2 endpoints**

- [ ] `updateTransaction()` → PATCH /:id
- [ ] `deleteTransaction()` → DELETE /:id
- [ ] Test 4 endpoints ✅
- [ ] Commit + Push

### **Ngày 5 - Routes + Summary + PR**

- [ ] Tạo `backend/routes/group_transactions.routes.js`
- [ ] Tạo `backend/validators/group_transactions.validator.js`
- [ ] `getSummary()` → GET /summary
  - Tính tổng income, expense, balance -> return 200
- [ ] Test tất cả 5 endpoints ✅
- [ ] **Create PR** → Reviewer: @Minh08012005

---

## 📂 FILES CẦN TẠO

| File                                                   | Công dụng             |
| ------------------------------------------------------ | --------------------- |
| `backend/models/group_transactions.model.js`           | Schema + type enum    |
| `backend/controllers/group_transactions.controller.js` | 5 methods             |
| `backend/routes/group_transactions.routes.js`          | Mount endpoints       |
| `backend/validators/group_transactions.validator.js`   | Validate amount, type |

---

## 💡 HƯỚNG CODE

### **Model (group_transactions.model.js)**

- Fields: groupId, userId (who did transaction), walletId, amount, type, note, timestamps
- Type enum: ['income', 'expense']
- Validations:
  - amount: required, > 0
  - type: required, enum
- Indexes: `{groupId}`, `{walletId}`, `{userId}`

### **Controller (group_transactions.controller.js)**

- `createTransaction()`: Validate amount > 0 → Check wallet exists → Create → return 201
- `listTransactions()`: Find by groupId → return 200
- `updateTransaction()`: Update amount/type/note → return 200 hoặc 404
- `deleteTransaction()`: Delete by ID → return 200 hoặc 404
- `getSummary()`:
  - Tội income transactions (type=income) → sum amount
  - Tội expense transactions (type=expense) → sum amount
  - balance = income - expense
  - Return: `{totalIncome, totalExpense, balance}`

### **Routes (group_transactions.routes.js)**

- Use mergeParams: true
- JWT middleware

### **Validators (group_transactions.validator.js)**

- Validate amount: required, > 0
- Validate type: required, must be ['income', 'expense']
- Validate note: optional, max 200 chars

---

## 🧪 TESTING CHECKLIST

**All 5 endpoints:**

✅ **POST /api/groups/:id/transactions**

- Success: amount + type + note → 201 ✅
- Error: amount <= 0 → 400 ❌

✅ **GET /api/groups/:id/transactions**

- Success: list → 200 ✅

✅ **PATCH /api/groups/:id/transactions/:tId**

- Success: update amount → 200 ✅
- Error: ID not found → 404 ❌

✅ **DELETE /api/groups/:id/transactions/:tId**

- Success: delete → 200 ✅
- Error: ID not found → 404 ❌

✅ **GET /api/groups/:id/summary**

- Success: return totalIncome, totalExpense, balance → 200 ✅

---

## 📝 COMMIT PATTERN

```
Ngày 3: feat: Add group transactions model and create/list endpoints
Ngày 4: feat: Add update and delete transaction endpoints
Ngày 5: feat: Add routes, validators, and summary endpoint
```

---

## ✅ CHECKLIST NGÀY 5

- [ ] 5 endpoints work
- [ ] Amount validation (> 0) OK
- [ ] Type enum OK
- [ ] Summary calculation correct (income - expense = balance)
- [ ] Error handling OK
- [ ] Tested all cases

---

## 💡 SUMMARY LOGIC

```
totalIncome = sum of all transactions where type='income'
totalExpense = sum of all transactions where type='expense'
balance = totalIncome - totalExpense

Return: {
  totalIncome: 5000000,
  totalExpense: 2000000,
  balance: 3000000
}
```

---

**Branch:** `feature/group-transactions-apis`  
**Deadline:** Ngày 5, 18:00
