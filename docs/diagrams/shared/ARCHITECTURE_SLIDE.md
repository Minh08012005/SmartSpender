# Biểu đồ Kiến trúc SmartSpender - Phiên bản Slide (Tối ưu)

> **Phiên bản này được tối ưu hóa cho slide trình bày**
>
> - Chỉ 3 layers chính
> - Mỗi layer 2-3 thành phần
> - Rõ ràng, dễ hiểu, vừa 1 trang slide
> - Có thể in/chiếu mà không bị vỡ

---

## 📊 Biểu đồ Kiến trúc Tổng thể (Slide-Friendly)

```mermaid
%%{init: {
    'theme': 'base',
    'themeVariables': {
        'primaryColor': '#e3f2fd',
        'primaryTextColor': '#0d47a1',
        'primaryBorderColor': '#1976d2',
        'lineColor': '#1565c0',
        'secondaryColor': '#ffffff',
        'fontSize': '16px'
    }
}}%%

graph TD
    subgraph Client ["📱 CLIENT LAYER<br/>(Giao diện người dùng)"]
        WebApp["Flutter Web<br/>GitHub Pages"]
        MobileApp["Flutter Mobile<br/>Android/iOS"]
    end

    subgraph API ["🌐 API LAYER<br/>(Tầng giao tiếp)"]
        Rest["REST API<br/>HTTPS + JWT"]
    end

    subgraph Backend ["⚙️ BACKEND LAYER<br/>(Xử lý logic)"]
        Server["Node.js Express<br/>Render Hosting"]
        Auth["Middleware Pipeline<br/>Auth | Validation | Error Handler"]
        Logic["Controllers & Services<br/>Transaction | Wallet | Statistics"]
    end

    subgraph Database ["💾 DATABASE LAYER<br/>(Lưu trữ dữ liệu)"]
        MongoDB["MongoDB Atlas<br/>Collections: users,<br/>transactions, wallets"]
    end

    subgraph DevOps ["🚀 DEVOPS (CI/CD)"]
        GitHub["GitHub<br/>Version Control"]
        Actions["GitHub Actions<br/>Auto Deploy"]
    end

    %% Luồng dữ liệu chính
    WebApp -->|Request| Rest
    MobileApp -->|Request| Rest
    Rest -->|API Call| Server
    Server --> Auth
    Auth --> Logic
    Logic -->|Query| MongoDB

    %% Deployment
    GitHub -->|Push Code| Actions
    Actions -->|Deploy| Server
    Actions -->|Build & Deploy| WebApp

    %% Định dạng màu
    style Client fill:#e3f2fd,stroke:#1976d2,stroke-width:3px,color:#0d47a1
    style API fill:#fce4ec,stroke:#c2185b,stroke-width:3px,color:#880e4f
    style Backend fill:#fff3e0,stroke:#f57c00,stroke-width:3px,color:#e65100
    style Database fill:#f3e5f5,stroke:#7b1fa2,stroke-width:3px,color:#4a148c
    style DevOps fill:#e8f5e9,stroke:#388e3c,stroke-width:3px,color:#1b5e20
```

---

## 📐 Mô tả từng Layer

### 1️⃣ CLIENT LAYER (Tầng Khách hàng)

- **Flutter Web:** Chạy trên trình duyệt
- **Flutter Mobile:** Chạy trên điện thoại Android/iOS

### 2️⃣ API LAYER (Tầng Giao tiếp)

- **REST API:** Chuẩn HTTP/HTTPS
- **JWT Authentication:** Token xác thực an toàn

### 3️⃣ BACKEND LAYER (Tầng Xử lý)

- **Express Server:** Nhận request từ client
- **Middleware:** Xác thực, kiểm tra, xử lý lỗi
- **Controllers & Services:** Logic xử lý nghiệp vụ

### 4️⃣ DATABASE LAYER (Tầng Lưu trữ)

- **MongoDB Atlas:** Cơ sở dữ liệu cloud
- **Collections:** Bảng dữ liệu chính

### 5️⃣ DEVOPS (Tự động hóa triển khai)

- **GitHub:** Quản lý mã nguồn
- **GitHub Actions:** Tự động build & deploy

---

## 🔄 Luồng Dữ liệu Ví dụ: Tạo Giao dịch

```
1. User mở app & nhập dữ liệu
   ↓
2. Client gửi POST request qua HTTPS
   (kèm JWT token trong header)
   ↓
3. Backend nhận request
   - Xác thực JWT ✓
   - Kiểm tra dữ liệu ✓
   - Xử lý logic ✓
   ↓
4. Lưu vào MongoDB
   ↓
5. Trả response 201 Created
   ↓
6. Client update UI
   ✓ Xong!
```

---

## 💡 Điểm nổi bật

✅ **3 Layers rõ ràng** - Dễ giải thích trên slide  
✅ **Rất ít chi tiết** - Không bị rối mắt  
✅ **Đủ thông tin** - Vẫn hiểu được kiến trúc  
✅ **Dễ nhớ** - Phù hợp cho trình bày miệng  
✅ **Vừa slide** - Không bị vỡ khi chiếu

---

**Để xem chi tiết hơn → Xem tài liệu báo cáo: `CHAPTER_7_8_REPORT.md`** 📄

---

_Phiên bản này được tối ưu hóa cho người trình bày slides._  
_Ngày cập nhật: 01/04/2026_
