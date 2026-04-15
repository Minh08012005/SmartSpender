# ✅ Kiểm Chứng Kiến Trúc SmartSpender & Phân Quyền Nhóm

---

## 1️⃣ BACKEND: CÓ PHẢI LÀ ĐÚNG CHUẨN WEB API KHÔNG?

### **Trả Lời: ✅ ĐÚNG, ĐÃ LÀ CHUẨN REST API**

#### **Chứng Minh: SmartSpender Backend (Node.js + Express)**

```
Backend hiện tại
├── Node.js + Express ✅
├── REST API endpoints ✅
│   ├── GET /api/transactions          (lấy danh sách)
│   ├── POST /api/transactions         (tạo mới)
│   ├── PUT /api/transactions/:id      (cập nhật)
│   ├── DELETE /api/transactions/:id   (xóa)
│   └── ... (wallets, auth, statistics)
├── HTTP Methods đúng ✅
│   ├── GET (lấy dữ liệu)
│   ├── POST (tạo dữ liệu)
│   ├── PATCH/PUT (cập nhật)
│   └── DELETE (xóa)
├── HTTP Status Codes ✅
│   ├── 200 OK
│   ├── 201 Created
│   ├── 400 Bad Request
│   ├── 401 Unauthorized
│   ├── 403 Forbidden
│   ├── 404 Not Found
│   └── 500 Server Error
├── JSON Format ✅
│   └── Request/Response đều JSON
├── Authentication ✅
│   └── JWT Token (xác thực user)
├── Database ✅
│   └── MongoDB (lưu trữ đúng chuẩn)
└── Middleware ✅
    ├── Auth middleware (kiểm tra token)
    ├── Validation middleware (validate input)
    ├── Error handling middleware
    └── Rate limiting middleware
```

### **Kết Luận: ✅ 100% Là Đúng Chuẩn Web API REST**

SmartSpender backend **hoàn toàn thỏa mãn yêu cầu RFC 7231 (HTTP/REST)**

---

## 2️⃣ FRONTEND: FLUTTER CÓ CHẠY ĐA NỀN TẢNG KHÔNG?

### **Trả Lời: ✅ CÓ, FLUTTER LÀ MULTI-PLATFORM FRAMEWORK**

#### **Flutter Hỗ Trợ Nền Tảng Nào?**

```
Frontend hiện tại: Flutter
└── Một codebase → Compile ra 6 nền tảng

1. 📱 Mobile Android
   └── flutter build apk

2. 📱 Mobile iOS
   └── flutter build ios

3. 🌐 Web
   └── flutter build web
   ✅ Hiện tại đã deploy: GitHub Pages

4. 🖥️ Windows Desktop
   └── flutter build windows

5. 🖥️ macOS Desktop
   └── flutter build macos

6. 🖥️ Linux Desktop
   └── flutter build linux
```

#### **Sơ Đồ: Một Codebase → Nhiều Platform**

```
┌─────────────────────────────────────────┐
│   lib/  (Dart Code - Shared)            │
│   ├── screens/                          │
│   ├── views/                            │
│   ├── models/                           │
│   ├── providers/                        │
│   └── main.dart                         │
└──────────────────┬──────────────────────┘
                   │
       ┌───────────┼───────────────────────────────┐
       │           │                               │
   ┌───▼──┐   ┌───▼──┐   ┌──────┐   ┌──────┐
   │ iOS  │   │Andr  │   │ Web  │   │ Win  │
   │      │   │oid   │   │      │   │      │
   └──────┘   └──────┘   └──────┘   └──────┘
```

### **Ưu Điểm của Flutter (Đó Là Tại Sao SmartSpender Chọn):**

| Điểm                  | Chi tiết                                         |
| --------------------- | ------------------------------------------------ |
| **Codebase duy nhất** | Một code → 6 platform (tiết kiệm thời gian)      |
| **Hot reload**        | Sửa code → App tự update ngay (phát triển nhanh) |
| **Beautiful UI**      | Material Design + Cupertino Design (đẹp sẵn)     |
| **Performance**       | Compiled → Native performance (nhanh)            |
| **Community**         | Lớn, nhiều package, support tốt                  |

### **Kết Luận: ✅ SmartSpender Dùng Flutter Rất Hợp Lý**

---

## 3️⃣ QUẢN LÝ CHI TIÊU NHÓM: CẦN ADMIN & PHÂN QUYỀN KHÔNG?

### **Trả Lời: ✅ CÓ, BẮT BUỘC PHẢI CÓ**

#### **Tại Sao Cần Admin & Phân Quyền?**

**Ví Dụ Thực Tế: Nhóm Du Lịch Nha Trang (5 người)**

```
Tình huống 1: Không có role/permission
─────────────────────────────────────
User A: "Tôi xóa hạng mục chi tiêu của cả nhóm đi"
Result: ❌ Ai Ng: "Ơi tại sao chi tiêu của tôi mất?"

User B: "Tôi sửa lại số tiền giao dịch của A"
Result: ❌ Gây tranh cãi, không công bằng

User C: "Tôi rút hết tiền quỹ"
Result: ❌ Nhóm giải tán!

→ CHAOS! Không ai có trách nhiệm, ai cũng có quyền tối đa
```

```
Tình huống 2: CÓ role/permission
──────────────────────────────
Admin (Minh): Người tạo nhóm
  ├─ Toàn quyền: tạo/sửa/xóa giao dịch, phân va
ích, xóa member
  └─ Trách nhiệm: Quản lý quỹ, phê duyệt chi tiêu lớn

Member (5 người khác):
  ├─ Có quyền: Tạo giao dịch cá nhân, xem báo cáo
  ├─ Không quyền: Sửa/xóa giao dịch người khác, rút tiền
  └─ Phải submitted cho admin approve (tuỳ rule)

→ NHŨ NGẠCH, TRÁCH NHIỆM RÕ RÀNG
```

---

## 4️⃣ KIẾN TRÚC PHÂN QUYỀN CHO SMARTSPENDER GROUP

### **A. Roles (Vai Trò) Cần Có**

```javascript
// backend/models/group_members.model.js
const GroupMember = {
  groupId: ObjectId,
  userId: ObjectId,
  role: enum[("admin", "member", "viewer")], // ← Role
  joinedAt: Date,
};

// 4 loại role:
// 1. Admin (người tạo group hoặc được promote)
//    - Tạo/sửa/xóa giao dịch
//    - Thêm/xóa member
//    - Xem chi tiết tài chính
//    - Phê duyệt chi tiêu lớn (tuỳ chọn)

// 2. Member (thành viên bình thường)
//    - Tạo giao dịch cá nhân
//    - Xem báo cáo chung
//    - Không thể sửa/xóa giao dịch người khác
//    - Không thể thêm/xóa member

// 3. Viewer (chỉ xem)
//    - Xem báo cáo
//    - Không được tạo/sửa/xóa gì cả
//    - Dùng cho người không chính thức tham gia

// (tuỳ chọn: Thêm Accountant nếu muốn quản lý tài chính)
```

### **B. Permissions (Quyền) Chi Tiết**

```javascript
// backend/middleware/role-based-access.middleware.js

Permissions = {
  create_transaction: ["admin", "member"],
  edit_own_transaction: ["admin", "member"], // Member chỉ sửa của mình
  edit_other_transaction: ["admin"],
  delete_transaction: ["admin"],
  view_summary: ["admin", "member", "viewer"],
  invite_member: ["admin"],
  remove_member: ["admin"],
  change_member_role: ["admin"],
  view_member_list: ["admin", "member"], // viewer không thấy email
  settle_debt: ["admin", "member"],
  export_report: ["admin"],
};
```

### **C. Ví Dụ: API Endpoint với Phân Quyền**

```javascript
// ✅ ĐÚNG: Kiểm tra role trước khi thực hành

// Endpoint: POST /api/groups/:groupId/members
// Tác vụ: Thêm member vào nhóm
router.post(
  "/:groupId/members",
  authenticate,
  authorize("invite_member"),
  async (req, res) => {
    // Chỉ admin mới thêm member được
    // ← Middleware authorize kiểm tra role

    const groupId = req.params.groupId;
    const userId = req.body.userId;

    // Thêm member vào group
    await GroupMember.create({ groupId, userId, role: "member" });

    res.json({ status: "success" });
  },
);

// Endpoint: DELETE /api/groups/:groupId/members/:userId
// Tác vụ: Xóa member khỏi nhóm
router.delete(
  "/:groupId/members/:userId",
  authenticate,
  authorize("remove_member"),
  async (req, res) => {
    // Chỉ admin mới xóa member được

    await GroupMember.deleteOne({ groupId, userId });

    res.json({ status: "success" });
  },
);

// Endpoint: PUT /api/transactions/:id
// Tác vụ: Sửa giao dịch
router.put("/:id", authenticate, async (req, res) => {
  const transaction = await Transaction.findById(req.params.id);

  // ✅ KIỂM TRA:
  // - Nếu user là admin → cho sửa
  // - Nếu user là creator của transaction → cho sửa
  // - Nếu user khác → từ chối

  const isAdmin = await checkUserIsAdmin(req.user.id, transaction.groupId);
  const isCreator = transaction.createdBy === req.user.id;

  if (!isAdmin && !isCreator) {
    return res.status(403).json({ error: "Không có quyền sửa giao dịch này" });
  }

  // Cho phép sửa
  await Transaction.findByIdAndUpdate(req.params.id, req.body);

  res.json({ status: "success" });
});
```

### **D. Database Schema với Phân Quyền**

```
Collections:
├── groups
│   ├── _id: ObjectId
│   ├── name: String
│   ├── createdBy: userId (admin mặc định)
│   └── createdAt: Date
│
├── group_members  ← COLLECTION QUẢN LÝ QUYỀN
│   ├── _id: ObjectId
│   ├── groupId: ObjectId
│   ├── userId: ObjectId
│   ├── role: 'admin' | 'member' | 'viewer'  ← QUY/NHŨ NGẠCH
│   └── joinedAt: Date
│
├── transactions
│   ├── _id: ObjectId
│   ├── groupId: ObjectId
│   ├── createdBy: userId  ← Ai tạo giao dịch
│   ├── amount: Number
│   ├── type: 'income' | 'expense'
│   └── createdAt: Date
│
└── group_wallets
    ├── _id: ObjectId
    ├── groupId: ObjectId
    ├── name: String
    └── balance: Number
```

---

## 5️⃣ FLOW KIỂM TRA QUYỀN (Authorization Flow)

```
User gửi request
        ↓
┌───────────────────────────────────────────┐
│ Step 1: Authentication (xác thực)         │
│ "Bạn là ai?" (kiểm tra JWT token)        │
│ Nếu token invalid → 401 Unauthorized      │
└───────────────────┬───────────────────────┘
                    ↓
┌───────────────────────────────────────────┐
│ Step 2: Authorization (phân quyền)        │
│ "Bạn có quyền làm cái này không?"         │
│ Kiểm tra role của user trong group        │
│ Nếu không có quyền → 403 Forbidden        │
└───────────────────┬───────────────────────┘
                    ↓
┌───────────────────────────────────────────┐
│ Step 3: Business Logic                    │
│ Thực hiện tác vụ (tạo/sửa/xóa giao dịch) │
└───────────────────┬───────────────────────┘
                    ↓
Response 200 OK + Success
```

---

## 6️⃣ IMPLEMENTATION ROADMAP: Tích Hợp Phân Quyền

### **Tuần 1: Backend Setup**

**Ngày 1-2:**

- Tạo collection `group_members` trong MongoDB
- Thêm field `role` vào `group_members`

**Ngày 3-4:**

- Viết middleware `authenticate.middleware.js` (kiểm tra token ✓ có)
- Viết middleware `authorize.middleware.js` (kiểm tra role)
  ```javascript
  // middleware/authorize.middleware.js
  const authorize = (requiredRole) => {
    return async (req, res, next) => {
      const userId = req.user.id;
      const groupId = req.params.groupId;

      const member = await GroupMember.findOne({ userId, groupId });

      if (!member) {
        return res.status(403).json({ error: "Không phải thành viên" });
      }

      const roleHierarchy = {
        admin: 3,
        member: 2,
        viewer: 1,
      };

      if (roleHierarchy[member.role] < roleHierarchy[requiredRole]) {
        return res.status(403).json({ error: "Không đủ quyền" });
      }

      next();
    };
  };
  ```

**Ngày 5-7:**

- Thêm kiểm tra role vào tất cả endpoints
- Test: Tạo 3 user với role khác nhau, test xem ai được làm gì

### **Tuần 2: Frontend UI**

- Hiển thị member list với role
- UI cho thay đổi role (chỉ admin)
- Popup "Bạn không có quyền" nếu cố sửa giao dịch người khác

### **Tuần 3: E2E Test + Polish**

- Test: Admin có thể mời/xóa member
- Test: Member không thể xóa member
- Test: Viewer chỉ xem, không làm gì

---

## 7️⃣ CHECKLIST: PHÂN QUYỀN NHÓM

- [ ] Database: Tạo collection `group_members` với field `role`
- [ ] Backend: Viết middleware `authenticate` + `authorize`
- [ ] Backend: Thêm kiểm tra role vào endpoint quan trọng
- [ ] Backend: Test từng endpoint
- [ ] Frontend: Hiển thị role của member
- [ ] Frontend: UI để thay đổi role (admin)
- [ ] Frontend: Disable button nếu user không có quyền
- [ ] Frontend: Show error message "Không có quyền" khi bị từ chối
- [ ] E2E: Test toàn bộ authen + authorization flow
- [ ] Documentation: Ghi rõ role và permission

---

## 8️⃣ KẾT LUẬN

| Câu Hỏi                                | Trả Lời                                                           |
| -------------------------------------- | ----------------------------------------------------------------- |
| **Backend đúng chuẩn Web API?**        | ✅ **CÓ** - REST API chuẩn RFC 7231                               |
| **Flutter chạy đa nền tảng?**          | ✅ **CÓ** - 6 platform (iOS, Android, Web, Windows, macOS, Linux) |
| **Quản lý nhóm cần admin/phân quyền?** | ✅ **CÓ, BẮT BUỘC** - Nếu không chaos!                            |

**→ SmartSpender có đầy đủ foundation, chỉ cần thêm phân quyền vào là hoàn hảo!** 🚀
