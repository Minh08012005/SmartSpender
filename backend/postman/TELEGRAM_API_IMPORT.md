# 📱 SmartSpender Telegram API - Postman Collection

## 🚀 Quick Start

Hướng dẫn import và test **Telegram Bot API** trong Postman

---

## 📋 Files có trong collection

```
📁 postman/
├── telegram-api.postman_collection.json    ← Collection chính
├── SmartSpender-TelegramAPI.postman_environment.json    ← Environment setup
└── TELEGRAM_API_IMPORT.md                   ← Hướng dẫn này
```

---

## ✅ Bước 1: Import Collection vào Postman

### **Cách 1: Drag & Drop (Nhanh nhất)**

1. Mở Postman
2. Vào Collections tab (bên trái)
3. **Drag & drop** file `telegram-api.postman_collection.json` vào Collections
4. ✅ Collection được import!

### **Cách 2: Import bằng menu**

1. Click **"File"** → **"Import"**
2. Chọn file `telegram-api.postman_collection.json`
3. Click **"Import"**
4. ✅ Finished!

---

## 🔧 Bước 2: Setup Environment

1. Click **"Environment"** (gear icon) bên phải
2. Click **"Import"**
3. Chọn file `SmartSpender-TelegramAPI.postman_environment.json`
4. ✅ Environment imported!

### **Hoặc: Manually setup**

Nếu không có environment file, bạn có thể tạo manual:

1. Click **Environment** (gear icon)
2. Click **"+"** để tạo environment mới
3. Đặt tên: `SmartSpender - Telegram API`
4. Thêm các variables:

```
BASE_URL          = http://localhost:3000/api
TELEGRAM_BOT_TOKEN = 8395244826:AAEbmx97eVsRMZp3zSzKvpvEgF-lXX_nyWk
TELEGRAM_CHAT_ID   = -5241273804
GROUP_NAME         = SmartSpender Test Group
```

5. Click **"Save"**

---

## 🧪 Bước 3: Test APIs

### **1️⃣ Health Check (Kiểm tra trạng thái)**

Collection → **📱 Telegram Service Health** → **1. GET - Health Check**

```
Method: GET
URL: http://localhost:3000/api/telegram/health
```

**Expected Response:**

```json
{
  "status": "ok",
  "configured": true,
  "hasToken": true,
  "hasChatId": true
}
```

✅ Nếu `configured: true` → Telegram service ready!

---

### **2️⃣ Send Test Notification**

Collection → **🔔 Test Notifications** → **1. POST - Test Notification**

```
Method: POST
URL: http://localhost:3000/api/telegram/test
```

**Request Body:**

```json
{
  "amount": 50000,
  "note": "Test transaction from Postman",
  "type": "expense"
}
```

**Expected Response:**

```json
{
  "status": "success",
  "message": "Test notification sent to Telegram ✅",
  "data": {
    "success": true,
    "messageId": 123456
  }
}
```

**✨ Kiểm tra:** Mở Telegram group "smart-spender-test" → Xem được message không? ✅

---

### **3️⃣ Custom Notification (Gửi thật)**

Collection → **💬 Custom Notifications** → **1. POST - Custom Notification**

```
Method: POST
URL: http://localhost:3000/api/telegram/notify
```

**Request Body:**

```json
{
  "groupName": "Du Lịch Nha Trang",
  "amount": 150000,
  "type": "expense",
  "note": "Tiền ăn cơm trưa"
}
```

**Response:**

```json
{
  "status": "success",
  "message": "Notification sent to Telegram ✅"
}
```

---

## 📝 Danh sách Endpoints

| No  | Endpoint           | Method | Mục đích                    |
| --- | ------------------ | ------ | --------------------------- |
| 1   | `/telegram/health` | GET    | Kiểm tra trạng thái service |
| 2   | `/telegram/test`   | POST   | Gửi thông báo test          |
| 3   | `/telegram/notify` | POST   | Gửi custom notification     |

---

## 🧮 Variables Reference

### **Trong Collection:**

| Variable             | Giá trị                     | Mục đích                   |
| -------------------- | --------------------------- | -------------------------- |
| `BASE_URL`           | `http://localhost:3000/api` | Base URL của backend       |
| `TELEGRAM_BOT_TOKEN` | `8395244826:AA...`          | Token bot (from BotFather) |
| `TELEGRAM_CHAT_ID`   | `-5241273804`               | Chat ID của group test     |
| `GROUP_NAME`         | `SmartSpender Test Group`   | Tên group mặc định         |

### **Cách sử dụng trong requests:**

```
URL: {{BASE_URL}}/telegram/health
      ↑↑ Postman sẽ replace bằng giá trị thực
```

---

## ⚠️ Troubleshooting

### **Problem: Response 404 Not Found**

**Nguyên nhân:** Backend chưa chạy hoặc route chưa được register

**Giải pháp:**

```bash
cd backend
npm run dev
```

---

### **Problem: Response 500 Internal Server Error**

**Nguyên nhân:** Telegram token/chatID không hợp lệ

**Giải pháp:**

1. Kiểm tra `.env` file có token và chat ID không
2. Kiểm tra format token (phải có dạng `xxx:AAA...`)
3. Kiểm tra chat ID (phải là số âm cho group: `-123456...`)

---

### **Problem: Message không xuất hiện Telegram**

**Nguyên nhân:** Bot chưa được thêm vào group

**Giải pháp:**

1. Mở Telegram group "smart-spender-test"
2. Add bot **@artspender_bot** vào group
3. Gửi `/start` vào group
4. Retry request

---

### **Problem: 400 Bad Request**

**Nguyên nhân:** Request body không hợp lệ

**Giải pháp:**

- Kiểm tra `groupName`, `amount`, `type` có bắt buộc không
- `type` phải là `"income"` hoặc `"expense"`
- `amount` phải là number (không cần quotes)

```javascript
// ✅ Đúng
{
  "groupName": "Du Lịch",
  "amount": 100000,
  "type": "expense"
}

// ❌ Sai
{
  "groupName": "Du Lịch",
  "amount": "100000",
  "type": "Expense"
}
```

---

## 🎯 Test Cases Có sẵn trong Collection

### **✅ Success Cases:**

1. ✅ Health check
2. ✅ Test notification (default)
3. ✅ Test với amount khác (250000)
4. ✅ Test Income type
5. ✅ Custom notification (3 loại group khác nhau)

### **❌ Error Cases:**

6. ❌ Missing required fields
7. ❌ Invalid type value

---

## 🔄 Integration Test Flow

**Order để test:**

```
1. GET /telegram/health
   ↓ (Check if configured)
2. POST /telegram/test
   ↓ (Check if Telegram working)
3. POST /telegram/notify (custom)
   ↓ (Check if message appears)
4. Mở Telegram → Xem messages ✅
```

---

## 📚 Tài liệu Thêm

- Telegram Bot API: https://core.telegram.org/bots/api
- Postman docs: https://learning.postman.com/docs/

---

## 💪 Ready to Test?

1. ✅ Chạy backend: `npm run dev`
2. ✅ Open Postman
3. ✅ Import collection
4. ✅ Select environment
5. ✅ Click "Send" trên endpoints
6. ✅ Xem message xuất hiện Telegram!

---

**Happy Testing! 🚀**

Created: 16/4/2026  
By: Mai Huy Minh (Team Lead)
