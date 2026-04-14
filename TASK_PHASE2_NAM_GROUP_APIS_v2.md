# 🎯 TASK PHASE 2: GROUP APIs

**Assigned to:** 👨‍💻 **Nguyễn Nhật Nam**  
**Duration:** 3 ngày (Ngày 3-5)  
**Deadline:** Ngày 5, 18:00 (PR)  
**Branch:** `feature/group-apis`  
**Endpoints:** 5 (CREATE, READ-list, READ-detail, UPDATE, DELETE)

---

## 📋 CÔNG VIỆC

Code 5 endpoints quản lý **nhóm (Group)**:

```
POST   /api/groups              → Tạo nhóm
GET    /api/groups              → Danh sách nhóm user
GET    /api/groups/:groupId     → Chi tiết nhóm
PATCH  /api/groups/:groupId     → Update nhóm
DELETE /api/groups/:groupId     → Xóa nhóm
```

---

## 🕐 TIMELINE

### **Ngày 3 - Model + 2 endpoints**

- [ ] Tạo `backend/models/group.model.js`
  - Schema: name, description, createdBy, timestamps
  - Validation: name min 3 chars
  - Indexes
- [ ] Tạo `backend/controllers/group.controller.js`
  - `createGroup()` → POST
  - `listGroups()` → GET /
- [ ] Test 2 endpoints (Postman) → 201, 200 ✅
- [ ] Commit + Push

### **Ngày 4 - 2 endpoints**

- [ ] `getGroupDetails()` → GET /:id
- [ ] `updateGroup()` → PATCH /:id
- [ ] Test 4 endpoints lại ✅
- [ ] Commit + Push

### **Ngày 5 - Routes + Delete + PR**

- [ ] Tạo `backend/routes/group.routes.js` (mount 5 endpoints)
- [ ] Tạo `backend/validators/group.validator.js` (validate input)
- [ ] `deleteGroup()` → DELETE /:id
- [ ] Test tất cả 5 endpoints ✅
- [ ] Fix bugs (nếu có)
- [ ] **Create PR** → Title: `[BE] feat: Group APIs (5 endpoints)` → Tag @Minh08012005

---

## 📂 FILES CẦN TẠO

| File                                      | Công dụng                          |
| ----------------------------------------- | ---------------------------------- |
| `backend/models/group.model.js`           | Schema + validation                |
| `backend/controllers/group.controller.js` | 5 methods (C-R-R-U-D)              |
| `backend/routes/group.routes.js`          | Mount 5 endpoints + JWT middleware |
| `backend/validators/group.validator.js`   | Validate request body              |

---

## 💡 HƯỚNG CODE

### **Model (group.model.js)**

- Schema với fields: name, description, createdBy, timestamps
- Validation: name required + min 3 chars
- Pre-save hook (if needed)
- Indexes: createdBy

### **Controller (group.controller.js)**

- `createGroup()`: Lấy name + description từ request → validate → save DB → return 201
- `listGroups()`: Lấy userId từ JWT → find groups → return 200
- `getGroupDetails()`: Lấy groupId từ URL → find by ID → return 200 hoặc 404
- `updateGroup()`: Validate input → findByIdAndUpdate → return 200 hoặc 404
- `deleteGroup()`: findByIdAndDelete → return 200 hoặc 404

### **Routes (group.routes.js)**

- Mount 5 methods vào router
- Thêm JWT middleware (protect)

### **Validators (group.validator.js)**

- Validate name: required, min 3 chars
- Validate description: optional, max 200 chars
- Validate groupId: valid ObjectId

---

## 🧪 TESTING CHECKLIST

**Mỗi endpoint test 2 cases:**

✅ **POST /api/groups**

- Success: valid name + description → 201 ✅
- Error: missing name → 400 ❌

✅ **GET /api/groups**

- Success: list groups → 200 ✅
- Error: not authenticated → 401 ❌

✅ **GET /api/groups/:groupId**

- Success: valid ID → 200 ✅
- Error: invalid ID → 404 ❌

✅ **PATCH /api/groups/:groupId**

- Success: update name → 200 ✅
- Error: missing name → 400 ❌

✅ **DELETE /api/groups/:groupId**

- Success: delete → 200 ✅
- Error: ID not found → 404 ❌

---

## 📝 COMMIT PATTERN

```
Ngày 3:
git commit -m "feat: Add group model and create/list endpoints"

Ngày 4:
git commit -m "feat: Add group details and update endpoints"

Ngày 5:
git commit -m "feat: Add routes, validators, and delete endpoint"
```

---

## ✅ CHECKLIST NGÀY 5

- [ ] Tất cả 5 endpoints work
- [ ] Error handling OK (400, 401, 404)
- [ ] Tested with Postman
- [ ] No console.log in code
- [ ] Commit messages rõ ràng
- [ ] PR description đầy đủ

---

## 🆘 CÓ BLOCKING?

- JWT error? → Kiểm tra req.user.\_id
- Route not found? → Append route vào app.js: `app.use('/api/groups', groupRoutes)`
- Validation error? → Check validator middleware
- Conflict? → Hỏi Minh

---

**Branch:** `feature/group-apis`  
**Deadline PR:** Ngày 5, 18:00  
**Next Phase:** Ngày 6-7 merge + integration test
