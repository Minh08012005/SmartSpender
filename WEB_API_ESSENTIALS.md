# 🌐 Web API - Bản Chất & Cách Sử Dụng Thực Tế

---

## 1️⃣ BẢN CHẤT WEB API (Cô Giáo Muốn Dạy Gì?)

### **Định Nghĩa Đơn Giản**

Web API = **Cách để 2 ứng dụng nói chuyện với nhau qua Internet**

```
Ứng dụng A           (HTTP Request)           Server B
(Frontend)      ──────────────────→           (API)
            ←──────────────────
           (HTTP Response)
```

### **Cô Giáo Muốn Sinh Viên Hiểu**

Cô muốn sinh viên hiểu:

1. **REST API là gì?** (Phần 1 của môn)
   - Cách viết API đúng chuẩn (GET, POST, PUT, DELETE)
   - HTTP Methods, Status Codes
   - Request/Response format (JSON)
   - **Mục đích:** Hiểu lý thuyết + viết API chính xác

2. **Cách SỬ DỤNG một API bên ngoài** (Phần 2 của môn)
   - Lấy API key từ ai?
   - Làm sao để call API đó?
   - Xử lý response như thế nào?
   - Xử lý lỗi/timeout?
   - **Mục đích:** Biết tích hợp 3rd-party API vào app

3. **Từ lý thuyết → Thực hành** (Bài tập lớn)
   - Code 1 Web API của riêng mình (backend)
   - Tích hợp ít nhất 1 external API vào
   - Viết client (mobile/web) gọi API này
   - **Mục đích:** Toàn diện: BE API + External API + FE Client

---

## 2️⃣ CÁC LOẠI API VÀ CÁCH SỬ DỤNG

### **Loại 1: REST API (Mà Bạn Viết - Backend)**

**Bản chất:** Bạn tạo API để **FE/Mobile gọi**

```
Ví dụ: SmartSpender API
GET /api/transactions        ← Mobile gọi
POST /api/transactions       ← Mobile gọi
GET /api/groups/:id          ← Mobile gọi
POST /api/groups/:id/invite  ← Mobile gọi
```

**Cô Giáo Dạy:**

- ✅ Cách design endpoint (route)
- ✅ Cách parse request (body, query, params)
- ✅ Cách trả response (format JSON)
- ✅ HTTP Status codes (200, 201, 400, 401, 404, 500)
- ✅ Authentication (JWT token)
- ✅ Validation (input validation)
- ✅ Error handling

**Bạn làm:** Viết backend API (Node.js/Express)

---

### **Loại 2: 3rd-Party API (Mà Người Khác Viết - Bên Ngoài)**

**Bản chất:** Bạn **CALL API của dịch vụ khác**

```
Các ví dụ:

1. Google Sheets API
   ↑ Google cung cấp
   Bạn gọi: POST /v4/spreadsheets/:spreadsheetId/values
   Để: Export dữ liệu ra sheet

2. Telegram Bot API
   ↑ Telegram cung cấp
   Bạn gọi: POST /bot:token/sendMessage
   Để: Gửi tin nhắn

3. MapBox API
   ↑ MapBox cung cấp
   Bạn gọi: GET /geocoding/v5/mapbox.places/:query
   Để: Tìm tọa độ từ địa chỉ

4. Facebook API (không khuyến khích cho dự án công nghệ)
   ↑ Facebook cung cấp
   Bạn gọi: GET /me/friends
   Để: Lấy bạn bè

5. Open Weather API
   ↑ OpenWeather cung cấp
   Bạn gọi: GET /data/2.5/weather?q=:city
   Để: Lấy dữ liệu thời tiết
```

**Cô Giáo Dạy:**

- ✅ Cách lấy API key
- ✅ Cách đọc documentation
- ✅ Cách format request (endpoint, params, headers)
- ✅ Cách xử lý response
- ✅ Cách handle error (rate limit, timeout, invalid key)
- ✅ Rate limiting (mỗi API có giới hạn gọi/phút)
- ✅ Authentication (API key, OAuth, Bearer token)

**Bạn làm:** Gọi API bên ngoài từ backend/frontend

---

## 3️⃣ CẤU TRÚC CALL API TỪ BACKEND

### **Sơ đồ luồng**

```
Frontend (Mobile/Web)
        ↓
    [Button: "Submit"]
        ↓
  Call Your API
  POST /api/groups/:id/transactions
        ↓
  Your Backend (Node.js)
        ↓
  ┌─────────────────────────────────┐
  │ Step 1: Parse request           │
  │ (Get groupId, amount, type)     │
  └─────────────────────────────────┘
        ↓
  ┌─────────────────────────────────┐
  │ Step 2: Validate               │
  │ (Check groupId valid? amount > 0?)
  └─────────────────────────────────┘
        ↓
  ┌─────────────────────────────────┐
  │ Step 3: Call External API       │
  │ (Optional - không phải lúc nào) │
  │ Example: Google Sheets API      │
  │ Để export dữ liệu              │
  └─────────────────────────────────┘
        ↓
  ┌─────────────────────────────────┐
  │ Step 4: Save to Database        │
  │ INSERT into transactions        │
  └─────────────────────────────────┘
        ↓
  ┌─────────────────────────────────┐
  │ Step 5: Return Response         │
  │ {status: "success", data: {...}}│
  └─────────────────────────────────┘
        ↓
  Frontend (nhận response)
        ↓
  [Update UI, show success message]
```

---

## 4️⃣ GỢI Ý API MIỄN PHÍ CHO NHÓM SINH VIÊN

### **TOP 3 API NÊN DÙNG (Dễ, Miễn Phí, Nhanh)**

#### **API #1: Google Sheets API ⭐⭐⭐ (KHUYẾN NGHỊ NHẤT)**

**Bản chất:** Đọc/ghi dữ liệu vào Google Sheet (Excel online)

**Tại sao tốt cho sinh viên?**

- ✅ **Miễn phí hoàn toàn** (trong giới hạn)
- ✅ **Dễ setup:** 5 phút lấy API key
- ✅ **Dễ dùng:** Có thể export report, backup dữ liệu
- ✅ **Thực tế:** Công ty thực tế cũng dùng
- ✅ **Security:** Không cần token phức tạp

**Ví dụ dùng:**

```javascript
// Backend (Node.js)
// Call Google Sheets API để export danh sách giao dịch
POST /api/groups/:id/export-report
Kết quả: Tạo 1 file sheet mới với dữ liệu nhóm
```

**Setup (3 bước):**

1. Vào Google Cloud Console
2. Enable "Google Sheets API"
3. Tạo Service Account → Download JSON key
4. Share sheet cho service account email

**Giới hạn:** 300 request/phút (miễn phí)

---

#### **API #2: Telegram Bot API ⭐⭐ (THỨ 2 KHUYẾN NGHỊ)**

**Bản chất:** Gửi tin nhắn qua Telegram

**Tại sao tốt cho sinh viên?**

- ✅ **Miễn phí hoàn toàn**
- ✅ **Siêu dễ setup:** Chỉ cần API token
- ✅ **Thực tế:** Cơ sở có dùng cho alerts/notifications
- ✅ **Có sẵn:** Không cần tạo account ngân hàng/thẻ

**Ví dụ dùng:**

```javascript
// Backend khi có giao dịch nhóm mới
POST /api/groups/:id/transactions
  ↓
Call Telegram Bot API
POST /bot:TOKEN/sendMessage
  ↓
Gửi tin nhắn cho group chat Telegram
"[SmartSpender] Nhóm 'Du lịch Nha Trang' vừa có giao dịch: 500k - Xe đi chợ"
```

**Setup (2 bước):**

1. Tạo bot Telegram (@BotFather)
2. Lấy token → Done

**Giới hạn:** Không giới hạn (miễn phí)

---

#### **API #3: Open Weather API ⭐ (Nếu muốn)**

**Bản chất:** Lấy dữ liệu thời tiết

**Tại sao?**

- ✅ Miễn phí (60 request/phút)
- ✅ Có thể tích hợp vào app (ví dụ: chi tiêu theo thời tiết)

**Ví dụ (có thể không cần):**

```
GET /data/2.5/weather?q=HoChiMinh&appid=YOUR_KEY
Response: {temp: 28°C, humidity: 80%, weather: "Sunny"}
```

---

### **❌ CÁC API KHÔNG NÊN DÙNG (Vì Phức Tạp)**

| API                | Tại sao không                                                | Thay thế                     |
| ------------------ | ------------------------------------------------------------ | ---------------------------- |
| **Facebook API**   | Cần login FB, phức tạp setup, bây giờ Facebook hạn chế quyền | Google Sheets → export       |
| **MapBox API**     | Cần credit card, giới hạn token                              | Không cần (trừ nếu đặc biệt) |
| **Stripe/PayPal**  | Cần setup payment gateway, phức tạp                          | Không cần cho demo           |
| **SendGrid Email** | Có free tier nhưng cần verify domain                         | Telegram thay thế            |

---

## 5️⃣ CÁCH TÍCH HỢP 3RD-PARTY API VÀO SMARTSPENDER

### **Kịch Bản 1: Export Giao Dịch Nhóm → Google Sheets**

**Luồng:**

```
User click "Export Report"
    ↓
Frontend call: POST /api/groups/:id/export
    ↓
Backend:
  1. Lấy tất cả transactions của group từ DB
  2. Call Google Sheets API → tạo sheet mới
  3. Ghi dữ liệu vào sheet
  4. Trả về URL của sheet
    ↓
Frontend:
  Hiển thị: "✅ Report export thành công! Bấm đây để xem"
  Link: https://docs.google.com/spreadsheets/d/...
```

**Code (Node.js):**

```javascript
// backend/routes/groups.js
router.post("/:id/export", async (req, res) => {
  try {
    // 1. Lấy dữ liệu
    const transactions = await Transaction.find({ groupId: req.params.id });

    // 2. Call Google Sheets API (code chi tiết bạn code sau)
    const sheetUrl = await exportToGoogleSheets(transactions);

    // 3. Trả về
    res.json({ status: "success", sheetUrl });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

**Độ khó:** ⭐⭐ (tương đối dễ, cần học library `googleapis`)

---

### **Kịch Bản 2: Notify qua Telegram Khi Có Giao Dịch Nhóm**

**Luồng:**

```
User tạo giao dịch nhóm
POST /api/groups/:id/transactions {amount: 500000, ...}
    ↓
Backend:
  1. Validate dữ liệu
  2. Lưu vào DB
  3. Call Telegram Bot API → Gửi tin nhắn
  4. Trả response thành công
    ↓
Nhóm Telegram chat nhận tin nhắn:
  "[SmartSpender] Nguyễn Văn A vừa thêm giao dịch:
   Loại: Chi tiêu
   Số tiền: 500.000đ
   Nhóm: Du lịch Nha Trang
   Ghi chú: Xe taxi"
```

**Code (Node.js):**

```javascript
// backend/routes/groups.js
router.post("/:id/transactions", async (req, res) => {
  try {
    // 1. Validate
    if (!req.body.amount || req.body.amount <= 0) {
      return res.status(400).json({ error: "Invalid amount" });
    }

    // 2. Lưu DB
    const transaction = await Transaction.create({
      groupId: req.params.id,
      ...req.body,
    });

    // 3. Call Telegram Bot API
    const telegramToken = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_GROUP_CHAT_ID;
    await axios.post(
      `https://api.telegram.org/bot${telegramToken}/sendMessage`,
      {
        chat_id: chatId,
        text: `📝 Giao dịch mới: ${transaction.amount}đ`,
      },
    );

    // 4. Trả về
    res.json({ status: "success", data: transaction });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
```

**Độ khó:** ⭐ (siêu dễ, chỉ gọi 1 API)

---

## 6️⃣ GỢI Ý CHO NHÓM BẠN

### **Chọn Tích Hợp Nào?**

**Nếu muốn DỄ + NHANH NHẤT → Chọn Telegram Bot API**

- ✅ Setup trong 10 phút
- ✅ Code trong 30 phút
- ✅ Miễn phí, không giới hạn
- ✅ Có ích thực (nhóm nhận notification)

**Nếu muốn CÓ GIÁ TRỊ HƠN → Chọn Google Sheets API**

- ✅ Sinh viên học được cách export/report (thực tế công ty)
- ✅ Ghi điểm với cô giáo (chuyên nghiệp hơn)
- ✅ Cần code nhiều hơn (tốt cho bài tập)
- ⚠️ Setup 30 phút (hơi phức tạp, nhưng doable)

**Nếu muốn LÀM CẢ 2 → Telegram + Google Sheets**

- Telegram: Notification khi có giao dịch mới
- Google Sheets: Export report hàng tuần
- Độ khó: ⭐⭐⭐ (nhưng công nhân cộng lại)
- **Ghi điểm nhất với cô**

---

## 7️⃣ TÓMLƯỢC: CỤC BỘ YÊUCẦU MÔN HỌC

| Yêu cầu                   | Cách thực hiện                                          |
| ------------------------- | ------------------------------------------------------- |
| **Viết REST API**         | ✅ Backend SmartSpender mở rộng (Group, Member, Wallet) |
| **Tích hợp External API** | ✅ Telegram Bot HOẶC Google Sheets                      |
| **Client sử dụng API**    | ✅ Mobile Flutter + Web Flutter                         |
| **Documentation**         | ✅ Swagger YML + README                                 |
| **Security**              | ✅ JWT auth + role-based access                         |

---

## 8️⃣ LỘ TRÌNH RECOMMEND

**Tuần 1:** Backend API (không external API trước)
**Tuần 2:** Mobile UI + gọi API
**Tuần 3:**

- Ngày 1-2: Tích hợp Telegram Bot (dễ, nhanh)
- Ngày 3-5: Nếu có thời gian, thêm Google Sheets (bonus)
- Ngày 6-7: Test + Demo + Report

---

**Sẵn sàng bắt đầu backend API chưa?** 🚀
