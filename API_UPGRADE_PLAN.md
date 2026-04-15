# 📋 Kế Hoạch Nâng Cấp: Từ Chi Tiêu Cá Nhân → Quản Lý Chi Tiêu Nhóm

**Thời hạn:** 3 tuần  
**Nhân lực:** 5 thành viên  
**Phương pháp:** Chỉnh sửa/mở rộng, KHÔNG xây lại từ đầu

---

## 1️⃣ TÓM TẮT THAY ĐỔI

### **Hiện tại (Personal Expense Manager)**

```
1 User → Nhiều Wallet → Nhiều Transaction
     ↓
   Chi tiêu cá nhân
```

### **Nâng cấp (Team Expense Manager)**

```
1 Group → Nhiều Member (User) → Chia Wallet → Chia Transaction
     ↓
   Chi tiêu nhóm, chia lưỡng chi phí, theo dõi ai nợ ai
```

---

## 2️⃣ NHỮNG CÁI CẦN CHỈNH SỬA

### **A. Backend Database (MongoDB)**

#### **Thêm 3 collection mới:**

| Collection        | Công dụng                         | Ví dụ                                                 |
| ----------------- | --------------------------------- | ----------------------------------------------------- |
| **groups**        | Lưu thông tin nhóm                | `{name: "Nhóm du lịch Nha Trang", createdBy: userId}` |
| **group_members** | Lưu ai là thành viên của nhóm nào | `{groupId, userId, role: "admin"/"member"}`           |
| **group_wallets** | Ví chung của nhóm                 | `{groupId, name: "Quỹ nhóm", balance}`                |

#### **Thay đổi nhỏ collection cũ:**

| Collection       | Thay đổi                        | Lý do                                                                          |
| ---------------- | ------------------------------- | ------------------------------------------------------------------------------ |
| **transactions** | Thêm field `groupId` (optional) | Để phân biệt: giao dịch cá nhân `groupId=null` vs giao dịch nhóm `groupId=123` |
| **wallets**      | Thêm field `groupId` (optional) | Ví chung của nhóm vs ví cá nhân                                                |

**⚠️ Rủi ro:** Không có → vì field optional, dữ liệu cũ vẫn sống sót

---

### **B. Backend API (Node.js Express)**

#### **Giữ nguyên API cũ (không động):**

```
GET /api/transactions       ← User cá nhân vẫn dùng được
GET /api/wallets
POST /api/transactions
...
```

#### **Thêm API mới cho Group:**

| Endpoint                               | Phương thức | Công dụng                   |
| -------------------------------------- | ----------- | --------------------------- |
| `/api/groups`                          | GET         | Lấy danh sách nhóm của user |
| `/api/groups`                          | POST        | Tạo nhóm mới                |
| `/api/groups/:groupId`                 | GET         | Xem chi tiết nhóm           |
| `/api/groups/:groupId`                 | PATCH       | Chỉnh sửa thông tin nhóm    |
| `/api/groups/:groupId/members`         | POST        | Thêm member vào nhóm        |
| `/api/groups/:groupId/members`         | GET         | Lấy danh sách members       |
| `/api/groups/:groupId/members/:userId` | DELETE      | Xóa member khỏi nhóm        |
| `/api/groups/:groupId/wallets`         | GET         | Lấy danh sách ví nhóm       |
| `/api/groups/:groupId/wallets`         | POST        | Tạo ví chung                |
| `/api/groups/:groupId/transactions`    | GET         | Lấy giao dịch nhóm          |
| `/api/groups/:groupId/transactions`    | POST        | Tạo giao dịch nhóm          |
| `/api/groups/:groupId/summary`         | GET         | Tổng chi/thu/số dư nhóm     |

**⚠️ Rủi ro:** Không có → vì API mới độc lập, không ảnh hưởng API cũ

---

### **C. Mobile Frontend (Flutter)**

#### **Giữ nguyên màn hình cũ:**

- Home tab (hiển thị cá nhân)
- Wallet tab (ví cá nhân)
- Transaction tab (giao dịch cá nhân)
- Settings tab

#### **Thêm tab mới:**

- **Groups tab** → Xem danh sách nhóm, tạo/tham gia nhóm
  - Màn hình: "Nhóm tôi tham gia"
  - Nút: "+ Tạo nhóm mới" hoặc "Tham gia nhóm"

#### **Thêm màn hình trong Group:**

- Group dashboard (xem members, ví chung, giao dịch nhóm, tổng chi)
- Tạo giao dịch nhóm (ai chi tiền, ai đóng góp)

**⚠️ Rủi ro:** Thấp → chỉ thêm tab mới, không sửa tab cũ

---

## 3️⃣ KHÔNG CÓ RỦI RO? → KIỂM TRA

| Rủi ro                   | Xảy ra?  | Lý do                                                |
| ------------------------ | -------- | ---------------------------------------------------- |
| **Dữ liệu cũ mất?**      | ❌ KHÔNG | Field mới optional, dữ liệu cũ vẫn sống              |
| **API cũ bị vỡ?**        | ❌ KHÔNG | API cũ không thay đổi, chỉ thêm API mới              |
| **Mobile app cũ crash?** | ❌ KHÔNG | Tab cũ không sửa, chỉ thêm tab mới                   |
| **User experience xấu?** | ⚠️ THẤP  | User cũ vẫn dùng bình thường, có thêm tính năng nhóm |
| **Performance giảm?**    | ❌ KHÔNG | Thêm collection, nhưng query tối ưu hóa được         |

**✅ Kết luận: Hoàn toàn có thể xử lý được, không bị vỡ app**

---

## 4️⃣ TIMELINE CHI TIẾT (3 TUẦN)

### **TUẦN 1: Chuẩn Bị + Backend API**

#### **Ngày 1-2 (Thứ 2-3): Lên kế hoạch + Thiết kế Schema**

- **Việc làm:**
  - Lập spec API chi tiết (endpoint, request/response)
  - Vẽ database schema (3 collection mới)
  - Review yêu cầu của môn học
- **Ai làm:** 1 dev backend (leader technical)
- **Output:** Tài liệu spec đầy đủ

#### **Ngày 3-5 (Thứ 4-6): Code API Endpoints**

- **Việc làm:**
  - Tạo 3 collection mới (groups, group_members, group_wallets)
  - Code 10-12 API endpoints Group
  - Test từng endpoint (Postman)
- **Ai làm:** 2 dev backend (song song công việc)
- **Output:**
  - MongoDB collections tạo xong
  - 12 API endpoints hoạt động
  - Swagger doc cập nhật

#### **Ngày 6-7 (Thứ 7-CN): Fix bugs + Security + Optimize**

- **Việc làm:**
  - Test backward compatibility (API cũ vẫn work?)
  - Thêm authentication/authorization (chỉ admin/member mới thao tác được)
  - Performance testing (database query nhanh không?)
- **Ai làm:** 2 dev backend
- **Output:**
  - API endpoints 100% ổn định
  - Test pass tất cả

### **TUẦN 2: Mobile Frontend**

#### **Ngày 1-2 (Thứ 2-3): Design UI + Setup State**

- **Việc làm:**
  - Design màn Groups tab (wireframe)
  - Setup Provider/State management cho Group
  - Xây dựng data model (Group, Member, GroupWallet)
- **Ai làm:** 1 dev frontend (design) + 1 dev frontend (code)
- **Output:** UI mockup, state architecture sẵn

#### **Ngày 3-4 (Thứ 4-5): Code UI**

- **Việc làm:**
  - Code Groups tab (danh sách nhóm, tạo/tham gia)
  - Code Group detail screen (members, wallets, transactions)
  - Code tạo giao dịch nhóm
- **Ai làm:** 2 dev frontend (song song)
- **Output:**
  - Groups tab hoạt động
  - Có thể tạo, xem, tham gia nhóm
  - Có thể tạo giao dịch nhóm

#### **Ngày 5-7 (Thứ 6-CN): Test + Polish**

- **Việc làm:**
  - Integration test (gọi API, check response)
  - UI testing (click, scroll, input)
  - Bug fix
- **Ai làm:** 2 dev frontend
- **Output:**
  - Mobile app hoạt động trơn tru
  - Không crash khi tạo nhóm/giao dịch

### **TUẦN 3: Integration + External API + Demo**

#### **Ngày 1-2 (Thứ 2-3): E2E Test + Fix Bugs**

- **Việc làm:**
  - Test end-to-end: Mobile app → API → Database
  - Fix bugs phát hiện
  - Test backward compatibility (cá nhân vẫn hoạt động?)
- **Ai làm:** Tất cả (2 BE, 2 FE, 1 leader test)
- **Output:**
  - Toàn bộ hệ thống ổn định
  - Không bug lớn

#### **Ngày 3-4 (Thứ 4-5): Tích Hợp External API (tùy chọn)**

- **Việc làm:** Chọn 1 trong các lựa chọn sau:
  - **Google Sheets API:** Export danh sách giao dịch nhóm ra cái sheet
  - **Telegram Bot API:** Thông báo khi có giao dịch nhóm mới
  - **Email API:** Gửi báo cáo chi tiêu nhóm hàng tuần
- **Ai làm:** 1 dev backend (nếu API backend) hoặc 1 dev frontend (nếu API frontend)
- **Output:**
  - Tích hợp 1 external API
  - Demo được tính năng mới

#### **Ngày 5-7 (Thứ 6-CN): Documentation + Demo + Submit**

- **Việc làm:**
  - Viết README upgrade (giải thích thay đổi)
  - Viết API documentation (Swagger)
  - Chuẩn bị video demo
  - Viết báo cáo (3-5 trang)
- **Ai làm:** 1 leader (coordination) + 1 dev (technical writing)
- **Output:**
  - Tài liệu hoàn chỉnh
  - Video demo 5-10 phút
  - Báo cáo sẵn sàng submit

---

## 5️⃣ PHÂN CÔNG CỤ THỂ (5 NGƯỜI)

### **Backend (2 người)**

| Người               | Tuần 1                       | Tuần 2          | Tuần 3                   |
| ------------------- | ---------------------------- | --------------- | ------------------------ |
| **Dev 1 (Lead BE)** | Design spec + code Group API | Support FE test | E2E test + External API  |
| **Dev 2**           | Code Group Member/Wallet API | Support FE test | E2E test + Documentation |

### **Frontend (2 người)**

| Người               | Tuần 1 | Tuần 2                           | Tuần 3               |
| ------------------- | ------ | -------------------------------- | -------------------- |
| **Dev 3 (Lead FE)** | -      | Design UI + code Groups tab      | E2E test + Demo prep |
| **Dev 4**           | -      | Code Group details + transaction | E2E test + UI polish |

### **Leader (1 người)**

| Vai trò       | Tuần 1                       | Tuần 2        | Tuần 3                      |
| ------------- | ---------------------------- | ------------- | --------------------------- |
| **Leader/PM** | Daily standup + coordination | Daily standup | Final test + Report writing |

---

## 6️⃣ CÔNG NGHỆ HIỆN TẠI (KHÔNG THAY ĐỔI)

```
Backend:
  ✅ Node.js + Express (giữ nguyên)
  ✅ MongoDB (giữ nguyên, chỉ thêm collection)
  ✅ JWT Authentication (giữ nguyên)

Frontend:
  ✅ Flutter (giữ nguyên)
  ✅ Provider state management (giữ nguyên)

Deployment:
  ✅ Render.com (giữ nguyên)
  ✅ GitHub Pages Flutter Web (giữ nguyên)
```

**→ Không cần học công nghệ mới, chỉ mở rộng hiện tại**

---

## 7️⃣ CHECKLIST TUÂN THỦ YÊU CẦU MÔN HỌC

### **Môn: Lập Trình API**

- ✅ **REST API chuẩn:** Dùng HTTP methods đúng (GET, POST, PATCH, DELETE)
- ✅ **HTTP Status codes:** 200, 201, 400, 401, 403, 404, 500
- ✅ **API Documentation:** Swagger YAML
- ✅ **Security:** JWT auth, role-based access control
- ✅ **External API Integration:** Tích hợp ít nhất 1 API (Google Sheets/Telegram/Email)
- ✅ **Web API:** Có, RESTful endpoints
- ✅ **Data persistence:** MongoDB

---

## 8️⃣ NHỮNG ĐIỀU CẦN LƯU Ý

### **1. Không làm lại từ đầu**

- ✅ Dùng code cũ làm base
- ✅ Chỉ thêm logic mới cho Group

### **2. Backward compatibility**

- ✅ API cũ vẫn hoạt động (cá nhân chi tiêu)
- ✅ Mobile cũ có thể update lên mà không crash

### **3. Scope rõ ràng**

- ✅ Chỉ làm những cái trong timeline
- ✅ Không thêm tính năng phụ (vd: machine learning, AI, vân vân)

### **4. Daily standup**

- Mỗi sáng 15 phút check progress
- Ai blocked? Ai cần help?

### **5. Testing**

- Unit test ít nhất 3 endpoint quan trọng
- Integration test (API + Mobile together)

---

## 9️⃣ KẾT LUẬN

| Câu hỏi                          | Trả lời                                         |
| -------------------------------- | ----------------------------------------------- |
| **Có thể làm trong 3 tuần?**     | ✅ **CÓ** - với 5 người, timeline rõ ràng       |
| **Có bị vỡ app?**                | ❌ **KHÔNG** - backward compatible, test kỹ     |
| **Có việc học công nghệ mới?**   | ❌ **KHÔNG** - dùng cái cũ, mở rộng thôi        |
| **Có tuân thủ yêu cầu môn học?** | ✅ **CÓ** - REST API + External API Integration |
| **Có tài liệu/demo rõ ràng?**    | ✅ **CÓ** - Tuần 3 viết đầy đủ                  |

---

**Bạn sẵn sàng giới thiệu plan này với nhóm API chưa?** 🚀
