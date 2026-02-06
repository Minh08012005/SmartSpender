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

Liên hệ: [Tên team lead] hoặc tạo issue trên GitHub
