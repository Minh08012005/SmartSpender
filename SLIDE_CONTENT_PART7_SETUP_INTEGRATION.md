# 📊 SLIDE RÚT GỌN - CÀI ĐẶT & TÍCH HỢP (CHAPTER 7)

---

## SLIDE 1: Tiêu đề

### Nội dung chính:

```
CHƯƠNG 7: CÀI ĐẶT VÀ TÍCH HỢP HỆ THỐNG
```

### Hình ảnh:

- Logo SmartSpender (chính giữa)
- 4 icons công nghệ chính: Node.js, Flutter, MongoDB, Express

---

## SLIDE 2: Yêu cầu & Chuẩn bị

### Nội dung chính:

```
YÊU CẦU HỆ THỐNG

• Node.js v18.x, Flutter v3.10.7+, MongoDB v5.x+
• Git, Java (Android), Xcode (iOS)
• VS Code, Postman, MongoDB Atlas
```

### Hình ảnh:

- Icons công nghệ: Node.js logo, Flutter logo, MongoDB logo

---

## SLIDE 3: Cài đặt Backend

### Nội dung chính:

```
CÀI ĐẶT VÀ CHẠY BACKEND

• cd backend → npm install
  (Express, Mongoose, JWT, Helmet, Bcrypt)

• Tạo .env: PORT, MONGODB_URI, JWT_SECRET, CORS

• npm run dev → http://localhost:3000
```

### Hình ảnh:

- Terminal screenshot hoặc cmd console icon
- npm logo

---

## SLIDE 4: Cài đặt Mobile

### Nội dung chính:

```
CÀI ĐẶT VÀ CHẠY MOBILE

• cd mobile → flutter pub get
  (Provider, Dio, Shared_preferences, Intl)

• Cấu hình API URL theo thiết bị:
  - Emulator: 10.0.2.2:3000
  - Simulator: localhost:3000
  - LAN: 192.168.x.x:3000

• flutter run → Chạy trên thiết bị
```

### Hình ảnh:

- Flutter logo
- Mobile phone with UI screenshot
- 3 device types icons (Emulator, Simulator, Physical device)

---

## SLIDE 5: Kiến trúc Hệ thống

### Nội dung chính:

```
KIẾN TRÚC MONOREPO

┌─────────────────────────┐
│ Mobile (Flutter) / Web  │
└───────────┬─────────────┘
            ↓ (HTTP + JWT)
┌────────────────────────────────┐
│ Backend API (Node.js + Express)│
│ Routes • Controllers • Services│
└───────────┬────────────────────┘
            ↓ (Mongoose)
┌─────────────────────────┐
│ MongoDB Database (Cloud)│
└─────────────────────────┘
```

### Hình ảnh:

- 3-layer architecture diagram (đơn giản, rõ ràng)

---

## SLIDE 6: Cấu trúc Backend Code

### Nội dung chính:

```
CẤU TRÚC BACKEND

backend/
├── controllers/  → Xử lý request
├── services/     → Business logic
├── models/       → MongoDB Schemas
├── routes/       → API Endpoints
├── middleware/   → Auth, Validate, Error
├── validators/   → Validation rules
└── tests/        → Unit & Integration tests
```

### Hình ảnh:

- Folder tree structure diagram desktop UI

---

## SLIDE 7: Cấu trúc Mobile Code

### Nội dung chính:

```
CẤU TRÚC MOBILE

mobile/lib/
├── core/      → Config, API Service
├── data/      → Models, State Management
├── screens/   → Auth, Home, Transactions, Wallet
├── widgets/   → Reusable Components
├── views/     → Tab Views & Navigation
└── theme/     → Material Design Theme
```

### Hình ảnh:

- Mobile app folder structure diagram

---

## SLIDE 8: Xác thực & Bảo mật

### Nội dung chính:

```
XÁC THỰC VÀ BẢO MẬT

• JWT Token: 7 ngày hạn sử dụng
  Header: Authorization: Bearer <token>

• Password: Bcrypt mã hóa (salt rounds: 10)
  Min 8 ký tự, 1 uppercase, 1 số

• Rate Limiting: 100 requests/15 phút

• CORS: Whitelist origins (dev, prod)
```

### Hình ảnh:

- Lock icon + Shield icon
- JWT token structure diagram

---

## SLIDE 9: Luồng Dữ liệu

### Nội dung chính:

```
LUỒNG REQUEST → RESPONSE

Client
  ↓ (HTTP + JWT)
Routes → Middleware → Auth Check
  ↓
Controller → Service → Models
  ↓
MongoDB Database
  ↓
Response: {success, statusCode, data, message}
```

### Hình ảnh:

- Sequence diagram hoặc flow chart (rút gọn)

---

## SLIDE 10: API Endpoints

### Nội dung chính:

```
API ENDPOINTS CHÍNH

🔐 Authentication:
  POST /auth/register, /auth/login

💳 Transactions:
  GET /transactions, POST /transactions
  PUT /transactions/:id, DELETE /transactions/:id

💰 Wallets:
  GET /wallets, PATCH /wallets/:id
  POST /wallets/transfer

📊 Statistics:
  GET /statistics/summary

📖 Swagger: http://localhost:3000/api-docs
```

### Hình ảnh:

- HTTP methods colors (GET=blue, POST=green, PUT=orange, DELETE=red)
- Swagger UI screenshot

---

## SLIDE 11: Testing & QA

### Nội dung chính:

```
KIỂM THỬ & ĐẢMBẢO CHẤT LƯỢNG

Backend - npm test:
✅ 13/13 test suites pass
✅ 149/149 tests pass

Mobile - flutter test:
✅ flutter analyze: 0 errors
✅ All widget tests pass

Coverage:
• Unit tests (services, validators)
• Integration tests (API endpoints)
• Widget tests (Mobile UI)
• E2E tests (Manual workflows)
```

### Hình ảnh:

- Test passed badges/checkmarks graphic
- Code coverage percentage chart

---

## SLIDE 12: Deployment & Production

### Nội dung chính:

```
TRIỂN KHAI HỆ THỐNG

🚀 Backend: Render
   URL: https://smartspender-x1fl.onrender.com

📱 Mobile: Play Store / App Store
   flutter build apk/ios

🌐 Web: GitHub Pages
   flutter build web --release

Auto-deploy:
✓ GitHub main branch → Auto-deploy
✓ Health check every 15 minutes
✓ Database: MongoDB Atlas
```

### Hình ảnh:

- Render logo, App Store logo, Play Store logo, GitHub Pages logo
- Deployment flow diagram

---

## SLIDE 13: Git Workflow

### Nội dung chính:

```
QUY TRÌNH PHÁT TRIỂN

1. git checkout -b feat/ten-tinh-nang
2. Code + Test locally
3. git commit -m "feat(scope): mo-ta"
4. git push origin feat/ten-tinh-nang
5. Pull Request → Review → Merge to dev
6. ✓ Tất cả tests phải pass
7. Deploy: dev → staging → main
```

### Hình ảnh:

- Git branching diagram (dev, main, feature branches)

---

## SLIDE 14: Công cụ & Môi trường

### Nội dung chính:

```
CÔNG CỤ PHÁT TRIỂN

💻 Code Editor: VS Code
   Extensions: Dart, Flutter, Thunder Client

🧪 API Testing: Postman
   Collection: backend/postman/

🗄️ Database: MongoDB Atlas + Compass
   Cloud: mongodb.com, GUI: Compass

📊 Monitoring:
   Backend logs: Render console
   Frontend: DevTools (Chrome)
```

### Hình ảnh:

- VS Code logo, Postman logo, MongoDB logo, GitHub logo

---

## SLIDE 15: Kết luận

### Nội dung chính:

```
KẾT LUẬN - HỆ THỐNG SẴN SÀNG

✅ Monorepo Backend + Mobile (Production-ready)
✅ Security: JWT + Bcrypt + Rate Limiting + CORS
✅ Testing: Unit + Integration + E2E
✅ Documentation: Swagger + README + Guides
✅ CI/CD: Auto-deploy từ GitHub
✅ Monitoring: Logs, Health checks

📞 Liên hệ & Hỗ trợ: Team SmartSpender
```

### Hình ảnh:

- SmartSpender logo (chính giữa)
- Team photo (nếu có)
- Checkmark badges

---

## 📐 HƯỚNG DẪN THIẾT KẾ SLIDE

### Bố cụ chuẩn:

```
┌─────────────────────────────────────┐
│  TIÊU ĐỀ                            │
│  (32-40pt, Bold, Xanh đậm)         │
├─────────────────────────────────────┤
│  • Nội dung 1                       │ 40%
│  • Nội dung 2                       │ text
│  • Nội dung 3                       │
│                                      │ 60%
│          [HÌNH ẢNH]                │ visual
│                                      │
└─────────────────────────────────────┘
```

### Màu sắc:

- **Chính:** Xanh lam (#007AFF) - Tiêu đề
- **Phụ:** Xanh lá (#34C759) - Bullet points
- **Background:** Trắng/Light Gray (#F5F5F5)
- **Text:** Xám đen (#1A1A1A)

### Typography:

- **Tiêu đề:** Bold 38pt
- **Nội dung:** Regular 20pt
- **Code:** Monospace 14pt (Fira Code)
- **Line height:** 1.6x

### Spacing:

- Margin: 40px
- Bullet indent: 30px
- Item spacing: 15px

---

## ✅ CHECKLIST SLIDE

- [ ] Màu sắc đẹp, nhất quán
- [ ] Font chọn rõ, dễ đọc
- [ ] Hình ảnh rõ nét (300+ dpi)
- [ ] Nội dung ngắn gọn (3-5 bullet max)
- [ ] Căn chỉnh lề đẹp
- [ ] Không quá tải thông tin
- [ ] Icons/logos phù hợp chủ đề
- [ ] Kiểm tra lỗi chính tả

---

## 📝 NOTES

- Tổng cộng: **15 slides** ngắn gọn
- Thời lượng trình chiếu: ~20-25 phút
- File: Dùng PowerPoint, Google Slides hoặc Figma
- Aspect ratio: 16:9
- Export: PNG/PDF cho presentation
