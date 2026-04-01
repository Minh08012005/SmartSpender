# Biểu đồ Kiến trúc hệ thống 3 lớp (3-Tier)

> **📌 Chọn phiên bản phù hợp với nhu cầu của bạn:**
>
> | Phiên bản                | Mục đích                 | Kích thước  | Link                                                                   |
> | ------------------------ | ------------------------ | ----------- | ---------------------------------------------------------------------- |
> | 📊 **SLIDE**             | Trình bày slide, báo cáo | Vừa 1 trang | [ARCHITECTURE_SLIDE.md](./ARCHITECTURE_SLIDE.md) ⭐                    |
> | 📌 **3-TIER** (File này) | Tổng quan cơ bản         | 1 trang     | Xem bên dưới                                                           |
> | 📚 **CHI TIẾT**          | Tài liệu báo cáo đầy đủ  | 5+ trang    | [COMPREHENSIVE_ARCHITECTURE_VI.md](./COMPREHENSIVE_ARCHITECTURE_VI.md) |
>
> **💡 Khuyến nghị:** Dùng **ARCHITECTURE_SLIDE.md** cho slide vì vừa vặn & rõ ràng nhất!

## Tổng quan nhanh (Quick Overview)

```mermaid
%%{init: {
    'theme': 'base',
    'themeVariables': {
        'primaryColor': '#e8eaf6',
        'primaryTextColor': '#1a237e',
        'primaryBorderColor': '#3f51b5',
        'lineColor': '#3949ab',
        'secondaryColor': '#ffffff',
        'tertiaryColor': '#f5f5f5',
        'mainBkg': '#ffffff',
        'nodeBorder': '#3f51b5',
        'clusterBkg': '#fafafa',
        'clusterBorder': '#7986cb',
        'fontSize': '15px'
    }
}}%%

graph TD
    subgraph Presentation_Layer ["📱 PRESENTATION LAYER - Client"]
        A["Flutter Web App<br/>GitHub Pages"]
        B["Flutter Mobile App<br/>APK/iOS"]
    end

    subgraph Network["🌐 NETWORK"]
        REST["HTTPS REST API<br/>JWT Bearer Token"]
    end

    subgraph Application_Layer ["⚙️ APPLICATION LAYER - Backend"]
        C["Node.js / Express Server<br/>Render Hosting"]
        D["🛡️ Middleware Pipeline<br/>Auth | Validation | Rate-Limit"]
        E["Controllers & Services<br/>Transaction | Wallet | Statistics"]
    end

    subgraph Data_Layer ["💾 DATA LAYER - Database"]
        F["MongoDB Atlas<br/>Collections:<br/>users, transactions,<br/>wallets, transfers"]
    end

    subgraph DevOps["🚀 DEVOPS"]
        GIT["GitHub Repository<br/>Version Control"]
        ACTIONS["GitHub Actions<br/>CI/CD Pipeline"]
    end

    %% Kết nối luồng
    A & B -->|HTTPS Request| REST
    REST -->|API Call| C
    C --> D
    D --> E
    E -->|Mongoose ODM| F

    GIT -->|Push Code| ACTIONS
    ACTIONS -->|Auto Deploy| C
    ACTIONS -->|Build & Deploy| A

    %% Định dạng màu sắc
    style Presentation_Layer fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    style Network fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    style Application_Layer fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Data_Layer fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style DevOps fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
```

---

## Các thành phần chính

### 1️⃣ **Presentation Layer (Client)**

- **Flutter Web:** Deployed trên GitHub Pages
- **Flutter Mobile:** APK (Android) + IPA (iOS)
- **State Management:** Provider (ChangeNotifier)
- **HTTP Client:** Dio library

### 2️⃣ **Application Layer (Backend)**

- **Framework:** Node.js + Express.js
- **Middleware:** JWT Auth, Input Validation, Rate Limiting, Error Handling
- **Controllers:** AuthController, TransactionController, WalletController, StatisticController
- **Services:** Business logic layer
- **Validators:** Joi schema + express-validator

### 3️⃣ **Data Layer (Database)**

- **MongoDB Atlas** (Cloud database)
- **Collections:** users, transactions, wallets, wallet_transfers
- **ORM:** Mongoose
- **Backup:** Atlas automatic backup

### 4️⃣ **DevOps & Infrastructure**

- **VCS:** GitHub repository
- **CI/CD:** GitHub Actions workflows
- **Backend Hosting:** Render
- **Database Hosting:** MongoDB Atlas
- **Web Hosting:** GitHub Pages + Cloudflare Pages

---

## 📊 Data Flow Example - CREATE TRANSACTION

```
Mobile App (UI)
    ↓ [User tạo giao dịch]
TransactionForm (Validation)
    ↓ [Form valid]
TransactionProvider
    ↓ [submitTransaction()]
ApiService (Dio HTTP Client)
    ↓ [POST /api/transactions]
HTTPS Network
    ↓ [Bearer JWT Header]
Express Router
    ↓ [Route matching]
Middleware Pipeline
    ├─ JWT Verification ✓
    ├─ Schema Validation ✓
    └─ Rate Limit Check ✓
    ↓
TransactionController
    ↓ [createTransaction()]
TransactionService
    ↓ [Business logic]
Mongoose Model
    ↓ [MongoDB Insert]
Database (Stored)
    ↓
Response { success: true, data: {...} }
    ↓ [HTTPS Response 201]
ApiService (Parse JSON)
    ↓
Provider State Update
    ↓ [notifyListeners()]
UI Rebuild
    ↓
New transaction appears ✓
```

---

## 🔐 Security Features

- ✅ **JWT Authentication** - Stateless, secure token
- ✅ **Password Hashing** - bcrypt with salt rounds
- ✅ **HTTPS/TLS** - All communications encrypted
- ✅ **CORS** - Origin whitelist
- ✅ **Rate Limiting** - 100 requests per 15 minutes
- ✅ **Input Validation** - Joi schema + express-validator
- ✅ **Error Handling** - No sensitive data exposure
- ✅ **Helmet.js** - Security headers

---

**Để chi tiết hơn → Xem: [COMPREHENSIVE_ARCHITECTURE.md](./COMPREHENSIVE_ARCHITECTURE.md)** 🔍
