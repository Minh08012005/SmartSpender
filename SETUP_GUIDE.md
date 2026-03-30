# 🚀 Hướng Dẫn Setup Nhanh - SmartSpender

## ⚡ Setup 5 phút

### Bước 1: Clone repo

```bash
git clone https://github.com/Minh08012005/SmartSpender.git
cd SmartSpender
```

### Bước 2: Cài dependencies

```bash
# Backend
cd backend
npm install

# Mobile
cd ../mobile
flutter pub get
```

### Bước 3: Tạo file `.env` trong folder `backend/`

```env
MONGODB_URI=mongodb+srv://your_connection_string
JWT_SECRET=your_jwt_secret
PORT=3000
```

> ⚠️ Hỏi team lead để lấy file `.env` đầy đủ

### Bước 4: Chạy Backend

```bash
cd backend
npm start
```

Thấy `Server running on port 3000` và `MongoDB connected` là OK ✅

### Bước 5: Chạy Mobile App

```bash
cd mobile
flutter run
```

---

## 📱 Chọn Môi Trường Test

Mở file `mobile/lib/core/config/app_config.dart`:

### 🖥️ Test trên EMULATOR (mặc định)

```dart
static const bool usePhysicalDevice = false;  // ← Giữ nguyên
```

Không cần sửa gì, chạy thẳng!

### 📲 Test trên ĐIỆN THOẠI THẬT (cùng WiFi)

1. **Tìm IP máy bạn:**

   ```bash
   # Windows
   ipconfig

   # Mac/Linux
   ifconfig
   ```

   Tìm dòng `IPv4 Address` (ví dụ: `192.168.1.xxx`)

2. **Sửa file `app_config.dart`:**

   ```dart
   static const String localNetworkIP = '192.168.1.xxx';  // ← IP của bạn
   static const bool usePhysicalDevice = true;            // ← Đổi thành true
   ```

3. **Mở firewall (Windows - chạy CMD với quyền Admin):**

   ```cmd
   netsh advfirewall firewall add rule name="Node.js Backend" dir=in action=allow protocol=TCP localport=3000
   ```

4. **Hot reload** (nhấn `r` trong terminal Flutter) và test!

---

## 🔧 Troubleshooting

| Lỗi                             | Giải pháp                                       |
| ------------------------------- | ----------------------------------------------- |
| `Connection timeout`            | Kiểm tra backend đang chạy (`npm start`)        |
| `MongoDB not connected`         | Kiểm tra file `.env` và internet                |
| `Điện thoại không kết nối được` | Chạy lệnh firewall ở trên                       |
| `IP không đúng`                 | Chạy `ipconfig` lại, IP có thể đổi khi đổi WiFi |

---

## 📂 Cấu Trúc Project

```
SmartSpender/
├── backend/          # Node.js + Express + MongoDB
│   ├── server.js
│   └── .env          # ⚠️ Không commit file này!
│
└── mobile/           # Flutter app
    └── lib/
        └── core/config/app_config.dart  # ← Cấu hình API URL
```

---

## 🧪 Test Login

**Tài khoản test:**

```
Email: test@example.com
Password: Test@123456
```

> Hoặc tự đăng ký tài khoản mới qua app

---

## ❓ Cần hỗ trợ?

Liên hệ: Minh(Leader) hoặc tạo issue trên GitHub

---

## 🌐 Chuẩn hóa Deploy Link Test Công Khai (GitHub Pages)

Mục tiêu: ai mở link công khai (GitHub Pages) cũng test được, không còn lỗi gọi nhầm localhost.

### 1) Build web production chuẩn

Chạy từ thư mục `mobile`:

```bash
flutter pub get
flutter build web --release --pwa-strategy=none --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://smartspender-x1fl.onrender.com
```

### 2) Publish lên GitHub Pages (đã có workflow)

Repository đã có workflow Actions để build và publish `mobile/build/web` lên `gh-pages` khi có push lên `main`.

Nếu muốn publish thủ công, có thể dùng `gh-pages` package hoặc `peaceiris/actions-gh-pages` locally, nhưng khuyến nghị dùng workflow đã sẵn sàng.

### 3) Kiểm tra sau publish (bắt buộc)

- Mở link Pages trên điện thoại (ví dụ `https://<username>.github.io/SmartSpender/`).
- Test `Đăng ký` và `Đăng nhập`.
- Nếu backend vừa ngủ (Render free tier), chờ 20-60 giây rồi thử lại.

### 4) Biến môi trường backend cần có

Trên backend host (Render), đảm bảo có:

- `CORS_ALLOWED_ORIGINS` (tùy chọn): thêm custom domain nếu có (ví dụ `https://<username>.github.io`).

Lưu ý: backend đã được cập nhật để cho phép `https://*.github.io` và `https://*.onrender.com`.

---

## 🔄 Giải pháp tránh manual trigger backend mỗi lần

### Giải pháp 1: Setup Keep-Alive Service (Miễn phí)

**Bước 1:** Tạo service keep-alive trên Render

1. Vào [Render Dashboard](https://dashboard.render.com)
2. Click "New" → "Background Worker"
3. Connect GitHub repo
4. Cấu hình:
   - **Name:** `smartspender-keep-alive`
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `npm run keep-alive`

**Bước 2:** Set environment variable

- `NODE_ENV=production`

Service này sẽ ping `/health` endpoint mỗi 10 phút để giữ backend luôn thức.

### Giải pháp 2: Upgrade Render Plan (Trả phí)

- Upgrade lên **Starter Plan** ($7/tháng)
- Service sẽ luôn chạy, không ngủ
- Phù hợp cho production app

### Giải pháp 3: Sử dụng UptimeRobot (Miễn phí)

1. Đăng ký [UptimeRobot](https://uptimerobot.com/)
2. Thêm monitor cho URL: `https://smartspender-x1fl.onrender.com/health`
3. Set ping interval: 5 phút
4. Chọn alert khi down

### Giải pháp 4: Setup Cron Job Local (Tạm thời)

Nếu test local nhiều, chạy:

```bash
cd backend
npm run keep-alive
```

Để script chạy ngầm và ping backend mỗi 10 phút.
