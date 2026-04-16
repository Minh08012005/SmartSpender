# 🎯 TASK PHASE 2: GROUP MEMBERS APIs

**Assigned to:** 👩‍💻 **Vũ Ngọc Anh**  
**Duration:** 3 ngày (Ngày 3-5)  
**Deadline:** Ngày 5, 18:00 (PR)  
**Branch:** `feature/group-members-apis`  
**Endpoints:** 5 (ADD, LIST, DETAIL, CHANGE-ROLE, REMOVE)

---

## 📋 CÔNG VIỆC

Code 5 endpoints quản lý **members trong group**:

```
POST   /api/groups/:groupId/members              → Thêm member
GET    /api/groups/:groupId/members              → Danh sách members
GET    /api/groups/:groupId/members/:userId      → Chi tiết member
PATCH  /api/groups/:groupId/members/:userId      → Đổi role (admin/member/viewer)
DELETE /api/groups/:groupId/members/:userId      → Xóa member
```

---

## 🕐 TIMELINE

### **Ngày 3 - Model + 2 endpoints**

- [ ] Tạo `backend/models/group_members.model.js`
  - Fields: groupId, userId, role (enum), joinedAt
  - Validation: role must be enum
  - Unique index: `{groupId, userId}`
- [ ] Tạo `backend/controllers/group_members.controller.js`
  - `addMember()` → POST
  - `listMembers()` → GET /
- [ ] Test 2 endpoints → 201, 200 ✅
- [ ] Commit + Push

### **Ngày 4 - 2 endpoints**

- [ ] `getMemberDetails()` → GET /:userId
- [ ] `updateMemberRole()` → PATCH /:userId
- [ ] Test 4 endpoints ✅
- [ ] Commit + Push

### **Ngày 5 - Routes + Delete + PR**

- [ ] Tạo `backend/routes/group_members.routes.js`
- [ ] Tạo `backend/validators/group_members.validator.js`
- [ ] `deleteMember()` → DELETE /:userId
- [ ] Test tất cả 5 endpoints ✅
- [ ] **Create PR** → Reviewer: @Minh08012005

---

## 📂 FILES CẦN TẠO

| File                                              | Công dụng          |
| ------------------------------------------------- | ------------------ |
| `backend/models/group_members.model.js`           | Schema + role enum |
| `backend/controllers/group_members.controller.js` | 5 methods          |
| `backend/routes/group_members.routes.js`          | Mount endpoints    |
| `backend/validators/group_members.validator.js`   | Validate role      |

---

## 💡 HƯỚNG CODE

### **Model (group_members.model.js)**

- Fields: groupId, userId, role, joinedAt
- Role enum: ['admin', 'member', 'viewer']
- Unique constraint: 1 user chỉ join 1 group 1 lần
- Indexes: `{groupId}`, `{userId}`, `{groupId, userId}` unique

### **Controller (group_members.controller.js)**

- `addMember()`: Check group + user exists → Check not already member → Create → return 201
- `listMembers()`: Find by groupId → Populate user info → return 200
- `getMemberDetails()`: Find by (groupId, userId) → return 200 hoặc 404
- `updateMemberRole()`: Validate role enum → Update → return 200 hoặc 404
- `deleteMember()`: Delete by (groupId, userId) → return 200 hoặc 404

### **Routes (group_members.routes.js)**

- Use mergeParams: true (để access :groupId)
- Thêm JWT middleware

### **Validators (group_members.validator.js)**

- Validate userId: required, valid ObjectId
- Validate role: required, must be in ['admin', 'member', 'viewer']

---

## 🧪 TESTING CHECKLIST

**All endpoints:**

- Success case: correct input → 201/200 ✅
- Error case: invalid input / not found → 400/404 ❌

---

## 📝 COMMIT PATTERN

```
Ngày 3: feat: Add group members model and add/list endpoints
Ngày 4: feat: Add member details and role update endpoints
Ngày 5: feat: Add routes, validators, and delete endpoint
```

---

## ✅ CHECKLIST NGÀY 5

- [ ] 5 endpoints work
- [ ] Role validation OK
- [ ] Unique constraint prevent duplicate members
- [ ] Error handling OK
- [ ] Tested all cases

---

**Branch:** `feature/group-members-apis`  
**Deadline:** Ngày 5, 18:00
