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

## 🌐 Chuẩn hóa Deploy Link Test Công Khai (Vercel)

Mục tiêu: ai mở link Vercel cũng test được, không còn lỗi gọi nhầm localhost.

### 1) Build web production chuẩn

Chạy từ thư mục `mobile`:

```bash
flutter pub get
flutter build web --release --pwa-strategy=none --dart-define=APP_ENV=production --dart-define=API_BASE_URL=https://smartspender-x1fl.onrender.com
```

Ý nghĩa:

- `APP_ENV=production`: ép app chạy config production.
- `API_BASE_URL=...onrender.com`: khóa API backend thật, không rơi về localhost.
- `--pwa-strategy=none`: tránh cache service worker cũ gây lệch bản build khi test.

### 2) Deploy trực tiếp artifact web lên Vercel

Chạy từ thư mục root repo:

```bash
npx vercel deploy --prod mobile/build/web
```

Nếu chưa login Vercel, CLI sẽ yêu cầu đăng nhập một lần.

### 3) Kiểm tra sau deploy (bắt buộc)

- Mở link Vercel trên điện thoại (4G và WiFi).
- Test `Đăng ký` và `Đăng nhập`.
- Nếu backend vừa ngủ (Render free tier), chờ 20-60 giây rồi thử lại.

### 4) Biến môi trường backend cần có

Trên backend host (Render), đảm bảo có:

- `CORS_ALLOWED_ORIGINS` (tùy chọn): thêm custom domain nếu có.

Lưu ý: backend đã cho phép sẵn origin `https://*.vercel.app`.
