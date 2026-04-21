# 📚 Group API Specification - SmartSpender

**Phiên bản:** 1.0  
**Ngày tạo:** 14/4/2026  
**Người thiết kế:** Mai Huy Minh

---

## 🔐 I. AUTHENTICATION

Tất cả các endpoint đều yêu cầu **JWT Token** trong header:

```
Authorization: Bearer <your_jwt_token>
```

**Status khi lỗi authentication:**

- `401 Unauthorized` - Chưa login hoặc token hết hạn
- `403 Forbidden` - Không có quyền truy cập

---

## 📁 II. GROUP APIs (5 endpoints - Nguyễn Nhật Nam)

### 1️⃣ POST /api/groups - Tạo nhóm mới

**Mô tả:** Tạo một nhóm chi tiêu mới

**Request Body:**

```json
{
  "name": "Du lịch Nha Trang",
  "description": "Chuyến đi tháng 5 cùng bạn bè"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Du lịch Nha Trang",
    "description": "Chuyến đi tháng 5 cùng bạ bè",
    "createdBy": "507f1f77bcf86cd799439010",
    "memberCount": 1,
    "createdAt": "2026-04-14T10:30:00Z",
    "updatedAt": "2026-04-14T10:30:00Z"
  }
}
```

**Status Codes:**

- `201 Created` - Tạo thành công
- `400 Bad Request` - Tên nhóm < 3 ký tự
- `401 Unauthorized` - Không có token
- `500 Internal Server Error` - Lỗi server

**Validation:**

- `name` - Bắt buộc, độ dài 3-50 ký tự
- `description` - Tùy chọn, max 200 ký tự

---

### 2️⃣ GET /api/groups - Danh sách nhóm của user

**Mô tả:** Lấy tất cả nhóm mà user là thành viên

**Query Parameters:**

```
?skip=0&limit=10&sortBy=createdAt&order=desc
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "groupId": "507f1f77bcf86cd799439011",
      "name": "Du lịch Nha Trang",
      "description": "Chuyến đi tháng 5",
      "memberCount": 3,
      "walletCount": 2,
      "createdBy": "507f1f77bcf86cd799439010",
      "createdAt": "2026-04-14T10:30:00Z"
    }
  ],
  "total": 5,
  "page": 1
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token

---

### 3️⃣ GET /api/groups/:groupId - Chi tiết nhóm

**Mô tả:** Lấy thông tin chi tiết của 1 nhóm (bao gồm members + wallets)

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Du lịch Nha Trang",
    "description": "Chuyến đi tháng 5",
    "createdBy": {
      "userId": "507f1f77bcf86cd799439010",
      "email": "minh@example.com"
    },
    "members": [
      {
        "userId": "507f1f77bcf86cd799439010",
        "email": "minh@example.com",
        "role": "admin",
        "joinedAt": "2026-04-14T10:30:00Z"
      }
    ],
    "wallets": [
      {
        "walletId": "507f1f77bcf86cd799439012",
        "name": "Quỹ chính",
        "balance": 5000000,
        "currency": "VND"
      }
    ],
    "createdAt": "2026-04-14T10:30:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Nhóm không tồn tại
- `403 Forbidden` - Không phải thành viên nhóm

---

### 4️⃣ PATCH /api/groups/:groupId - Cập nhật nhóm

**Mô tả:** Cập nhật tên/mô tả nhóm (chỉ admin)

**Request Body:**

```json
{
  "name": "Du lịch Nha Trang 2026",
  "description": "Cập nhật mô tả mới"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Du lịch Nha Trang 2026",
    "description": "Cập nhật mô tả mới",
    "updatedAt": "2026-04-14T11:00:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Cập nhật thành công
- `400 Bad Request` - Dữ liệu không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Nhóm không tồn tại

**Quyền:** Chỉ admin của nhóm

---

### 5️⃣ DELETE /api/groups/:groupId - Xóa nhóm

**Mô tả:** Xóa nhóm (chỉ admin, xóa cascade tất cả data liên quan)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Nhóm đã bị xóa thành công"
}
```

**Status Codes:**

- `200 OK` - Xóa thành công
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Nhóm không tồn tại

**Quyền:** Chỉ admin của nhóm

---

## 👥 III. MEMBERS APIs (5 endpoints - Vũ Ngọc Anh)

### 1️⃣ POST /api/groups/:groupId/members - Thêm thành viên

**Mô tả:** Thêm một user vào nhóm (chỉ admin)

**Request Body:**

```json
{
  "userId": "507f1f77bcf86cd799439020",
  "role": "member"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "memberId": "507f1f77bcf86cd799439030",
    "groupId": "507f1f77bcf86cd799439011",
    "userId": "507f1f77bcf86cd799439020",
    "email": "user@example.com",
    "role": "member",
    "joinedAt": "2026-04-14T11:00:00Z"
  }
}
```

**Status Codes:**

- `201 Created` - Thêm thành công
- `400 Bad Request` - User đã là thành viên
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Nhóm hoặc user không tồn tại

**Roles:** `admin`, `member`, `viewer`

---

### 2️⃣ GET /api/groups/:groupId/members - Danh sách thành viên

**Mô tả:** Lấy danh sách tất cả thành viên của nhóm

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "memberId": "507f1f77bcf86cd799439010",
      "userId": "507f1f77bcf86cd799439010",
      "email": "minh@example.com",
      "role": "admin",
      "joinedAt": "2026-04-14T10:30:00Z"
    },
    {
      "memberId": "507f1f77bcf86cd799439020",
      "userId": "507f1f77bcf86cd799439020",
      "email": "nam@example.com",
      "role": "member",
      "joinedAt": "2026-04-14T11:00:00Z"
    }
  ],
  "total": 2
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Nhóm không tồn tại

---

### 3️⃣ GET /api/groups/:groupId/members/:userId - Chi tiết thành viên

**Mô tả:** Lấy thông tin chi tiết của 1 thành viên

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "memberId": "507f1f77bcf86cd799439010",
    "groupId": "507f1f77bcf86cd799439011",
    "userId": "507f1f77bcf86cd799439010",
    "email": "minh@example.com",
    "role": "admin",
    "joinedAt": "2026-04-14T10:30:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Thành viên không tồn tại

---

### 4️⃣ PATCH /api/groups/:groupId/members/:userId - Thay đổi role

**Mô tả:** Cập nhật role của thành viên (chỉ admin)

**Request Body:**

```json
{
  "role": "viewer"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "memberId": "507f1f77bcf86cd799439020",
    "userId": "507f1f77bcf86cd799439020",
    "email": "nam@example.com",
    "role": "viewer",
    "updatedAt": "2026-04-14T11:30:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Cập nhật thành công
- `400 Bad Request` - Role không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Thành viên không tồn tại

---

### 5️⃣ DELETE /api/groups/:groupId/members/:userId - Xóa thành viên

**Mô tả:** Xóa một thành viên khỏi nhóm (chỉ admin)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Thành viên đã bị xóa khỏi nhóm"
}
```

**Status Codes:**

- `200 OK` - Xóa thành công
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Thành viên không tồn tại

---

## 💳 IV. WALLETS APIs (5 endpoints - Lê Thị Anh Chúc)

### 1️⃣ POST /api/groups/:groupId/wallets - Tạo ví mới

**Mô tả:** Tạo ví chi tiêu cho nhóm

**Request Body:**

```json
{
  "name": "Quỹ chính",
  "balance": 5000000,
  "currency": "VND"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "walletId": "507f1f77bcf86cd799439012",
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Quỹ chính",
    "balance": 5000000,
    "currency": "VND",
    "createdAt": "2026-04-14T11:00:00Z"
  }
}
```

**Status Codes:**

- `201 Created` - Tạo thành công
- `400 Bad Request` - Dữ liệu không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Nhóm không tồn tại

---

### 2️⃣ GET /api/groups/:groupId/wallets - Danh sách ví

**Mô tả:** Lấy tất cả ví của nhóm

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "walletId": "507f1f77bcf86cd799439012",
      "groupId": "507f1f77bcf86cd799439011",
      "name": "Quỹ chính",
      "balance": 5000000,
      "currency": "VND",
      "createdAt": "2026-04-14T11:00:00Z"
    }
  ],
  "total": 1
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Nhóm không tồn tại

---

### 3️⃣ GET /api/groups/:groupId/wallets/:walletId - Chi tiết ví

**Mô tả:** Lấy thông tin chi tiết ví

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "walletId": "507f1f77bcf86cd799439012",
    "groupId": "507f1f77bcf86cd799439011",
    "name": "Quỹ chính",
    "balance": 5000000,
    "currency": "VND",
    "transactionCount": 25,
    "createdAt": "2026-04-14T11:00:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Ví không tồn tại

---

### 4️⃣ PATCH /api/groups/:groupId/wallets/:walletId - Cập nhật ví

**Mô tả:** Cập nhật tên ví (chỉ admin)

**Request Body:**

```json
{
  "name": "Quỹ ăn uống",
  "balance": 3000000
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "walletId": "507f1f77bcf86cd799439012",
    "name": "Quỹ ăn uống",
    "balance": 3000000,
    "updatedAt": "2026-04-14T11:30:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Cập nhật thành công
- `400 Bad Request` - Dữ liệu không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Ví không tồn tại

---

### 5️⃣ DELETE /api/groups/:groupId/wallets/:walletId - Xóa ví

**Mô tả:** Xóa ví từ nhóm (chỉ admin)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Ví đã bị xóa thành công"
}
```

**Status Codes:**

- `200 OK` - Xóa thành công
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải admin
- `404 Not Found` - Ví không tồn tại

---

## 💰 V. TRANSACTIONS APIs (5 endpoints - Hà Hoài Xuân)

### 1️⃣ POST /api/groups/:groupId/transactions - Tạo giao dịch

**Mô tả:** Tạo giao dịch mới cho nhóm

**Request Body:**

```json
{
  "walletId": "507f1f77bcf86cd799439012",
  "amount": 500000,
  "type": "expense",
  "category": "food",
  "note": "Tiền ăn cơm tối",
  "createdBy": "507f1f77bcf86cd799439010"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "data": {
    "transactionId": "507f1f77bcf86cd799439040",
    "groupId": "507f1f77bcf86cd799439011",
    "walletId": "507f1f77bcf86cd799439012",
    "amount": 500000,
    "type": "expense",
    "category": "food",
    "note": "Tiền ăn cơm tối",
    "createdBy": "507f1f77bcf86cd799439010",
    "createdAt": "2026-04-14T12:00:00Z"
  }
}
```

**Status Codes:**

- `201 Created` - Tạo thành công
- `400 Bad Request` - Dữ liệu không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải thành viên
- `404 Not Found` - Nhóm hoặc ví không tồn tại

---

### 2️⃣ GET /api/groups/:groupId/transactions - Danh sách giao dịch

**Mô tả:** Lấy danh sách giao dịch của nhóm (có filter)

**Query Parameters:**

```
?walletId=507f1f77bcf86cd799439012&type=expense&skip=0&limit=20
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "transactionId": "507f1f77bcf86cd799439040",
      "groupId": "507f1f77bcf86cd799439011",
      "walletId": "507f1f77bcf86cd799439012",
      "amount": 500000,
      "type": "expense",
      "category": "food",
      "note": "Tiền ăn cơm tối",
      "createdBy": {
        "userId": "507f1f77bcf86cd799439010",
        "email": "minh@example.com"
      },
      "createdAt": "2026-04-14T12:00:00Z"
    }
  ],
  "total": 25,
  "page": 1
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Nhóm không tồn tại

---

### 3️⃣ PATCH /api/groups/:groupId/transactions/:transactionId - Cập nhật giao dịch

**Mô tả:** Cập nhật giao dịch (chỉ người tạo hoặc admin)

**Request Body:**

```json
{
  "amount": 600000,
  "note": "Sửa thành 600k"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "transactionId": "507f1f77bcf86cd799439040",
    "amount": 600000,
    "note": "Sửa thành 600k",
    "updatedAt": "2026-04-14T12:30:00Z"
  }
}
```

**Status Codes:**

- `200 OK` - Cập nhật thành công
- `400 Bad Request` - Dữ liệu không hợp lệ
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải creator hoặc admin
- `404 Not Found` - Giao dịch không tồn tại

---

### 4️⃣ DELETE /api/groups/:groupId/transactions/:transactionId - Xóa giao dịch

**Mô tả:** Xóa giao dịch (chỉ creator hoặc admin)

**Response (200 OK):**

```json
{
  "success": true,
  "message": "Giao dịch đã bị xóa thành công"
}
```

**Status Codes:**

- `200 OK` - Xóa thành công
- `401 Unauthorized` - Không có token
- `403 Forbidden` - Không phải creator hoặc admin
- `404 Not Found` - Giao dịch không tồn tại

---

### 5️⃣ GET /api/groups/:groupId/summary - Tổng kết chi tiêu

**Mô tả:** Lấy tóm tắt chi tiêu + thu nhập của nhóm

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "groupId": "507f1f77bcf86cd799439011",
    "totalIncome": 10000000,
    "totalExpense": 5500000,
    "balance": 4500000,
    "transactionCount": 32,
    "currency": "VND",
    "period": "all"
  }
}
```

**Status Codes:**

- `200 OK` - Thành công
- `401 Unauthorized` - Không có token
- `404 Not Found` - Nhóm không tồn tại

---

## 📊 VI. ERROR RESPONSE CHUNG

Tất cả endpoint khi có lỗi sẽ trả về format:

```json
{
  "success": false,
  "error": "Mô tả lỗi chi tiết",
  "code": "ERROR_CODE"
}
```

**Common Error Codes:**

- `VALIDATION_ERROR` - Dữ liệu không hợp lệ
- `NOT_FOUND` - Resource không tồn tại
- `UNAUTHORIZED` - Không có token
- `FORBIDDEN` - Không có quyền
- `CONFLICT` - Xung đột (ví: user đã là thành viên)
- `SERVER_ERROR` - Lỗi server

---

**Tạo:** 14/4/2026  
**Version:** 1.0  
**Status:** ✅ Final
