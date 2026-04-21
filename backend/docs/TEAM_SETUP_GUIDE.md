# 🚀 HƯỚNG DẪN SETUP NHANH CHO NHÓM LẬP TRÌNH (Phase 2)

**Dành cho:** 4 thành viên lập trình  
**Mục tiêu:** Setup môi trường local để bắt tay code từng API  
**Thời gian ước tính:** 30-45 phút toàn bộ  
**Ngày Setup:** 15/4/2026 sáng

---

## 📋 CHECKLIST SETUP BAN ĐẦU

Trước khi bắt đầu, bạn cần các công cụ này:

- [ ] **Git** - để clone repo (website: https://git-scm.com/download)
- [ ] **Node.js** v18+ - để chạy server (website: https://nodejs.org)
- [ ] **MongoDB** (local) - database (website: https://www.mongodb.com/try/download/community)
- [ ] **Postman** - để test API (website: https://www.postman.com/downloads)
- [ ] **VS Code** hoặc IDE yêu thích (website: https://code.visualstudio.com)

---

## 📥 BƯỚC 1: CÀI ĐẶT CÁC CÔNG CỤ (10-15 phút)

### 1.1 Cài Node.js

**Windows:**

1. Vào https://nodejs.org (LTS version)
2. Download file `.msi`
3. Chạy file, click "Next" tới hết, tick "Add to PATH"
4. Restart máy (hoặc terminal)
5. Kiểm tra: Mở terminal, gõ:
   ```bash
   node -v
   npm -v
   ```
   Thấy phiên bản = ✅ OK

**Mac:**

```bash
# Nếu có Homebrew:
brew install node

# Kiểm tra:
node -v
npm -v
```

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install nodejs npm

# Kiểm tra:
node -v
npm -v
```

---

### 1.2 Cài MongoDB (Local)

**Windows:**

1. Vào https://www.mongodb.com/try/download/community
2. Download MSI installer
3. Run, chọn "Complete"
4. Install MongoDB Compass (GUI)
5. MongoDB sẽ tự chạy như service
6. Kiểm tra: Mở terminal, gõ:
   ```bash
   mongosh
   # hoặc
   mongo
   ```
   Thấy shell = ✅ OK

**Mac:**

```bash
# Homebrew:
brew tap mongodb/brew
brew install mongodb-community

# Start MongoDB:
brew services start mongodb-community

# Kiểm tra:
mongosh
```

**Linux (Ubuntu):**

```bash
# Cài MongoDB:
sudo apt update
sudo apt install -y mongodb

# Start:
sudo systemctl start mongodb

# Kiểm tra:
mongosh
```

---

### 1.3 Cài Git

- **Windows:** https://git-scm.com/download/win → Download + Install
- **Mac:** `brew install git`
- **Linux:** `sudo apt install git`

Kiểm tra:

```bash
git --version
```

---

### 1.4 Cài Postman (Optional nhưng recommended)

Download: https://www.postman.com/downloads/

---

## 📂 BƯỚC 2: CLONE REPO (5 phút)

Mở terminal/PowerShell, chạy:

```bash
# Chọn folder để lưu project (ví dụ Desktop):
cd Desktop

# Clone repo:
git clone https://github.com/your-org/SmartSpender.git

# Vào thư mục backend:
cd SmartSpender/backend
```

**Kết quả:** Thự mục `SmartSpender/` chứa toàn bộ code

---

## 🔧 BƯỚC 3: SETUP BACKEND (10-15 phút)

### 3.1 Cài Dependencies

Vẫn ở trong `SmartSpender/backend/`, chạy:

```bash
npm install
```

**Thời gian:** 2-5 phút (phụ thuộc internet)

**Kết quả:** Thư mục `node_modules/` được tạo (không commit vào Git)

---

### 3.2 Tạo File `.env` (LẤY TỪ TEAM LEAD)

Nhờ **Mai Huy Minh** gửi file `.env`, hoặc tự tạo:

Tạo file `backend/.env`:

```bash
# Linux/Mac:
touch .env

# Windows PowerShell:
New-Item -Name ".env" -ItemType "file"
```

**Nội dung `.env`** (nhờ Minh cung cấp hoặc dùng template này):

```env
# Database
MONGODB_URI=mongodb://localhost:27017/smartspender

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-secret-key-here-dev
JWT_EXPIRE=7d

# Optional: Email, logging, etc.
LOG_LEVEL=debug
```

**⚠️ Quan trọng:**

- `.env` không commit vào Git (tìm nó trong `.gitignore`)
- Mỗi người local khác nhau là bình thường

---

### 3.3 Kiểm Tra MongoDB Connection

Chạy trong `backend/`:

```bash
npm run dev
```

**Mong muốn thấy:**

```
📡 MongoDB connected successfully
🚀 Server running on port 3000
```

Nếu thấy lỗi kết nối MongoDB:

- ✅ Kiểm tra MongoDB đang chạy: `mongosh` (terminal riêng)
- ✅ Kiểm tra MONGODB_URI trong `.env` = `mongodb://localhost:27017/smartspender`
- ✅ Kiểm tra port 3000 không bị chiếm: `lsof -i :3000` (Mac/Linux)

---

## 📊 BƯỚC 4: SETUP MOCK DATA (5-10 phút)

### 4.1 Kiểm Tra Collections Tồn Tại

Mở terminal riêng, chạy:

```bash
mongosh
# hoặc: mongo
```

Trong MongoDB shell:

```javascript
// Chuyển sang database:
use smartspender

// Kiểm tra collections:
show collections
```

**Kỳ vọng:** Thấy `groups`, `group_members`, `group_wallets`, `transactions`, `users`

**Nếu chưa có:** Liên hệ Minh để chạy `mongodb-setup.js`

---

### 4.2 Kiểm Tra Mock Data

Vẫn trong MongoDB shell:

```javascript
db.groups.countDocuments(); // Should be 3+
db.group_members.countDocuments(); // Should be 10+
db.group_wallets.countDocuments(); // Should be 5+
db.users.countDocuments(); // Should be 20+
```

**✅ OK:** Có dữ liệu  
**❌ Không có:** Nhờ Minh seed data bằng `npm run seed` (backend/)

---

## 🌐 BƯỚC 5: SETUP POSTMAN (5 phút)

### 5.1 Import Collection

1. Mở **Postman** (Desktop)
2. Click **Import** (góc trái)
3. Chọn file: `SmartSpender/backend/postman/group-api.postman_collection.json`
4. Click **Import**

Kết quả: Thấy collection **"SmartSpender - Group API"** với 20+ requests

---

### 5.2 Import Environment

1. Click **Import** lại
2. Chọn file: `SmartSpender/backend/postman/SmartSpender-GroupAPI.postman_environment.json`
3. Click **Import**

Kết quả: Thấy environment **"SmartSpender - Group API"**

---

### 5.3 Thiết Lập Environment Variables

1. Click environment dropdown (góc phải)
2. Chọn **"SmartSpender - Group API"**
3. Click icon "👁" để mở biến

**Các biến cần set:**

| Variable    | Value                       | Ghi chú                          |
| ----------- | --------------------------- | -------------------------------- |
| `BASE_URL`  | `http://localhost:3000/api` | Default                          |
| `TOKEN`     | _(lấy từ login)_            | Sau bước 5.4                     |
| `GROUP_ID`  | _(từ MongoDB hoặc seed)_    | `db.groups.findOne()._id`        |
| `WALLET_ID` | _(từ MongoDB hoặc seed)_    | `db.group_wallets.findOne()._id` |
| `MEMBER_ID` | _(user bất kỳ)_             | `db.users.findOne()._id`         |
| `USER_ID`   | _(user bất kỳ)_             | `db.users.findOne()._id`         |

---

### 5.4 Lấy JWT Token

1. Trong Postman, tìm request: **"1. POST - Register / Login"** (Group Authentication folder)
2. Tạo body:

   ```json
   {
     "email": "user@example.com",
     "password": "password123"
   }
   ```

   _(Hoặc nhờ Minh cung cấp user test)_

3. Click **Send**
4. Copy `token` từ response
5. Paste vào environment variable `TOKEN`

---

### 5.5 Test 1 Request

1. Chọn request: **"2. GET - Danh sách nhóm của user"** (GROUP APIs folder)
2. Click **Send**
3. Nếu thấy response với status **200** + data groups = ✅ **OK**

---

## ✅ BƯỚC 6: KIỂM TRA CUỐI CÙNG (2 phút)

Chạy checklist này trong terminal (folder `backend/`):

```bash
# 1. Kiểm tra Node.js + npm:
node -v && npm -v

# 2. Kiểm tra server chạy:
npm run dev
# Nếu thấy: "Server running on port 3000" = OK

# 3-4. Kiểm tra MongoDB (terminal riêng):
mongosh
# Trong shell, gõ:
use smartspender
db.groups.countDocuments()
```

**Checklist:**

- [ ] Node.js v18+ cài xong
- [ ] MongoDB local chạy
- [ ] Repo clone thành công
- [ ] `npm install` chạy xong (folder `node_modules/` tồn tại)
- [ ] `.env` file tạo + có MONGODB_URI
- [ ] Server chạy: `npm run dev` → thấy "Server running"
- [ ] MongoDB có collections + mock data
- [ ] Postman import collection + environment
- [ ] Postman test 1 request thành công (status 200)

**Nếu tất cả ✅ = SETUP HOÀN TẤT! 🎉**

---

## 🔥 BƯỚC 7: BẮT ĐẦU CODE (Tùy theo task)

Dựa trên task assign của bạn:

### **Nguyễn Nhật Nam - Group APIs**

- Start branch: `git checkout -b feature/group-apis`
- Code 5 endpoints: POST, GET, PUT, DELETE groups
- File: `backend/routes/group.route.js` + controller
- Postman test: "GROUP APIs" folder
- **Deadline:** 19/4/2026 tối

### **Vũ Ngọc Anh - Members APIs**

- Start branch: `git checkout -b feature/group-members-apis`
- Code 5 endpoints: Add member, remove member, list members, etc.
- File: `backend/routes/members.route.js` + controller
- Postman test: "MEMBERS APIs" folder
- **Deadline:** 19/4/2026 tối

### **Lê Thị Anh Chúc - Wallets APIs**

- Start branch: `git checkout -b feature/group-wallets-apis`
- Code 5 endpoints: Create wallet, get wallet, update wallet, etc.
- File: `backend/routes/wallet.route.js` + controller
- Postman test: "WALLETS APIs" folder
- **Deadline:** 19/4/2026 tối

### **Hà Hoài Xuân - Transactions APIs**

- Start branch: `git checkout -b feature/group-transactions-apis`
- Code 5 endpoints: Create transaction, get history, statistics, etc.
- File: `backend/routes/transaction.route.js` + controller
- Postman test: "TRANSACTIONS APIs" folder
- **Deadline:** 19/4/2026 tối

---

## 🆘 CẦN GIÚP ĐỠ?

### Lỗi Thường Gặp:

| Lỗi                                              | Giải Pháp                                                                    |
| ------------------------------------------------ | ---------------------------------------------------------------------------- |
| `MongoDB connection refused`                     | Chạy `mongosh` trong terminal khác để bật MongoDB                            |
| `EADDRINUSE :::3000`                             | Port 3000 bị chiếm: Tìm process: `lsof -i :3000`, kill process hoặc đổi port |
| `npm ERR! not found`                             | Chạy lại `npm install` trong `backend/` folder                               |
| `.env file not found`                            | Tạo file `.env` trong `backend/` (không có tên file)                         |
| `Cannot POST /api/groups`                        | Kiểm tra route file + controller tồn tại trong code                          |
| Postman "Unable to get local issuer certificate" | Đóng SSL verification: Settings → Disable SSL certificate verification       |

### Liên Hệ:

- **Team Lead:** Mai Huy Minh (Slack: @minh)
- **Tech Support:** Nguyễn Nhật Nam (Slack: @nam)
- **Docs:** Xem `backend/docs/` folder

---

## 📚 TÀI LIỆU HỮU ÍCH

- **API Spec:** `backend/docs/GROUP_API_SPECIFICATION.md`
- **DB Schema:** `backend/docs/GROUP_DATABASE_SCHEMA.md`
- **Postman Guide:** `backend/postman/IMPORT_SAFE_USE_THIS.md`
- **Git Guide:** `backend/docs/GIT_COMMIT_GUIDE.md`
- **Team Timeline:** Root folder `WORKFLOW_TIMELINE_12DAYS.md`

---

## 🎯 TIMELINE

| Ngày     | Mục tiêu                                 | Status      |
| -------- | ---------------------------------------- | ----------- |
| 15/4     | Setup môi trường xong                    | ⏳ Today    |
| 16-19/4  | Code + test từng API (5 endpoints/người) | ⏳ Upcoming |
| 19/4 tối | Submit PR                                | ⏳ Deadline |
| 20-21/4  | Code review + merge                      | ⏳ Upcoming |
| 22-26/4  | Integration + security + docs            | ⏳ Upcoming |

---

**Created:** 14/4/2026  
**Updated:** 15/4/2026  
**Status:** ✅ READY FOR TEAM SETUP

---

**Chúc các bạn setup thành công! Code vui vẻ! 🚀**
