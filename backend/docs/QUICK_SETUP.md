# ⚡ QUICK SETUP (5 phút cho những người vội)

**TL;DR - Chỉ làm những dòng lệnh này:**

```bash
# 1. Clone repo
git clone https://github.com/your-org/SmartSpender.git
cd SmartSpender/backend

# 2. Cài dependencies
npm install

# 3. Tạo .env file (copy từ team)
# hoặc dùng template:
cat > .env << EOF
MONGODB_URI=mongodb://localhost:27017/smartspender
PORT=3000
NODE_ENV=development
JWT_SECRET=dev-secret-key
JWT_EXPIRE=7d
EOF

# 4. Kiểm tra MongoDB chạy (terminal khác)
mongosh

# 5. Chạy server (terminal này)
npm run dev

# 6. Nếu thấy "Server running on port 3000" = OK ✅
```

---

## 🛠️ TOOLS CẢN CÀI TRƯỚC

**Nếu chưa cài:**

- **Node.js 18+**: https://nodejs.org
- **MongoDB**: https://mongodb.com/try/download/community
- **Postman**: https://postman.com/downloads (optional)

---

## 📌 SETUP POSTMAN (Nếu dùng)

```bash
# 1. Mở Postman
# 2. Import → chọn: backend/postman/group-api.postman_collection.json
# 3. Import → chọn: backend/postman/SmartSpender-GroupAPI.postman_environment.json
# 4. Set environment variable: BASE_URL = http://localhost:3000/api
# 5. Test 1 request → Status 200 = OK ✅
```

---

## 📂 FOLDER STRUCTURE TỰ HỌC

```
SmartSpender/
├── backend/
│   ├── .env                    ← YOU CREATE THIS
│   ├── docs/
│   │   ├── GROUP_API_SPECIFICATION.md  ← API spec (đọc trước)
│   │   ├── GROUP_DATABASE_SCHEMA.md    ← DB schema
│   │   └── GIT_COMMIT_GUIDE.md         ← Git guide
│   ├── routes/                 ← Where you code
│   ├── controllers/            ← Controllers
│   ├── models/                 ← Schemas
│   └── postman/                ← Test cases
└── ...
```

---

## 🚀 BẮT ĐẦU CODE

**Tạo feature branch của bạn:**

```bash
# Theo task:
git checkout -b feature/group-apis                # Nam
git checkout -b feature/group-members-apis        # Ngọc Anh
git checkout -b feature/group-wallets-apis        # Chúc
git checkout -b feature/group-transactions-apis   # Xuân
```

**Mỗi ngày push commit:**

```bash
git add .
git commit -m "feat: add get groups endpoint"
git push origin feature/xxxxx
```

---

## ❌ LỖI THƯỜNG GẶP

| Lỗi                          | Fix                                                             |
| ---------------------------- | --------------------------------------------------------------- |
| `MongoDB connection refused` | Chạy `mongosh` (terminal khác) để bật MongoDB                   |
| `Cannot find module express` | Chạy `npm install` trong `backend/`                             |
| `EADDRINUSE :::3000`         | Port 3000 bị chiếm - đóng port cũ hoặc đổi PORT=3001 trong .env |
| `.env file not found`        | Tạo file `.env` trong folder `backend/`                         |

---

## 📞 HELP

- **API Spec:** `backend/docs/GROUP_API_SPECIFICATION.md`
- **DB Schema:** `backend/docs/GROUP_DATABASE_SCHEMA.md`
- **Team:** Slack @minh hoặc @nam

---

**Done? Bắt tay vào code! 🚀**
