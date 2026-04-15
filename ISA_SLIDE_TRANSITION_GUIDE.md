# 📊 Hướng Dẫn Thiết Kế Slide ISA từ SmartSpender

**Mục đích:** Chuyển đổi slide CNPM sang slide ISA với cùng 1 dự án SmartSpender

---

## 🔄 So Sánh: CNPM Slide vs ISA Slide

### CNPM (Công Nghệ Phần Mềm) - Focus VÀO GÌ?

**Chủ đề:** "Cách làm" (Process & Implementation)

- ✅ Quy trình phát triển (Agile, Scrum)
- ✅ Kiểm thử (Unit test, Integration test)
- ✅ Triển khai (CI/CD, GitHub Actions)
- ✅ Quản lý lỗi (Error handling, Logging)
- ✅ Code structure (Controllers, Services, Models)
- ✅ Công nghệ cụ thể (Express, Flutter, MongoDB)

### ISA (Kiến Trúc Hệ Thống Thông Tin) - Focus VÀO GÌ?

**Chủ đề:** "Cách thiết kế" (Architecture & Design)

- ✅ **Mô hình kiến trúc** (3-Tier, Client-Server, Event-Driven)
- ✅ **Thiết kế lớp** (Presentation, Application, Data layers)
- ✅ **Giao tiếp giữa thành phần** (API, Message Queue, Services)
- ✅ **Nhân tố kiến trúc** (Scalability, Reliability, Maintainability)
- ✅ **Design patterns** (MVC, Repository, Observer)
- ✅ **Sơ đồ chính thức** (Logical, Deployment, Component, Sequence)

---

## 📋 CẤU TRÚC SLIDE ISA CHO SmartSpender

### Tổng quan: **8-10 slides chính**

| Slide | Tên                          | Nội dung chính                                | Lấy từ CNPM? |
| ----- | ---------------------------- | --------------------------------------------- | ------------ |
| 1     | Giới thiệu SmartSpender      | Tên dự án, mục tiêu, team members             | ✅ Có        |
| 2     | Tổng quan Kiến trúc          | 3 lớp chính (Presentation, Application, Data) | ✅ Chỉnh sửa |
| 3     | Logical Architecture Diagram | Chi tiết bên trong 3 lớp                      | ❌ Tạo mới   |
| 4     | Deployment Diagram           | Cách triển khai thực tế                       | ✅ Chỉnh sửa |
| 5     | Component Diagram            | Các module trong backend & mobile             | ✅ Chỉnh sửa |
| 6     | Sequence Diagrams            | Flows (login, CRUD)                           | ✅ Chỉnh sửa |
| 7     | Design Patterns              | MVC, Repository, Observer                     | ❌ Tạo mới   |
| 8     | Nhân tố Kiến trúc            | Scalability, Reliability, Security            | ❌ Tạo mới   |
| 9     | Hướng mở rộng                | Path to Microservices, Event-Driven           | ❌ Tạo mới   |

---

## 📝 CHI TIẾT TỪNG SLIDE

### **SLIDE 1: Giới Thiệu SmartSpender** ✅ Giữ lại từ CNPM

**Nội dung (không thay đổi):**

- Tên dự án: SmartSpender
- Mục tiêu: Ứng dụng quản lý chi tiêu cá nhân
- Team: Mai Huy Minh (leader), 5 thành viên
- GitHub link

**Biểu đồ:** Logo + Team table (giữ nguyên)

---

### **SLIDE 2: Tổng quan Kiến trúc** ✅ Chỉnh sửa từ CNPM

**CNPM (cũ):**

```
Class Diagram + Database Schema + API Endpoints list
(Focus: Implementation details)
```

**ISA (mới):** 👈 CẦN THAY ĐỔI

```
3-LAYER ARCHITECTURE:

┌──────────────────┐
│  PRESENTATION    │  ← Flutter Web/Mobile
│  (Client Layer)  │     Provider State Mgmt
├──────────────────┤
│  APPLICATION     │  ← Express.js Server
│  (Business Logic)│     Controllers, Services
├──────────────────┤
│  DATA            │  ← MongoDB
│  (Database)      │     Collections, O DM
└──────────────────┘

Flow: Client → REST API (JWT) → Server → DB
```

**Yếu tố nhấn mạnh:**

- 3 lớp rõ ràng
- Tách biệt trách nhiệm
- Loosely coupled via REST API

---

### **SLIDE 3: Logical Architecture Diagram** ❌ TẠO MỚI

**Mục đích:** Show chi tiết từng layer & thành phần bên trong

**Nội dung (Mermaid diagram):**

```
PRESENTATION LAYER:
  ├─ Screens (Login, Home, Transaction, Wallet, Profile)
  ├─ Providers (Auth, Transaction, Wallet, Statistics)
  └─ Widgets (Forms, Lists, Cards)

APPLICATION LAYER:
  ├─ Routes (auth/, transactions/, wallets/, statistics/)
  ├─ Middleware (JWT, Validation, Rate Limit, Error Handler)
  ├─ Controllers (Auth, Transaction, Wallet, Statistic)
  └─ Services (Auth, Transaction, Wallet, Statistic)

DATA LAYER:
  ├─ Models (User, Transaction, Wallet)
  └─ MongoDB Collections (users, transactions, wallets)
```

**Biểu đồ kiểu:**

```
                      CLIENT (Flutter)
                      ↙ ↓ ↘
            Screens → Providers → Widgets
                         ↓
                    REST API (HTTPS + JWT)
                         ↓
                  ┌──────SERVER──────┐
           Routes → Middleware → Controllers → Services
                                               ↓
                                    ┌─────────────────┐
                                    │ MongoDB Models  │
                                    │ (ODM Mongoose)  │
                                    └─────────────────┘
```

---

### **SLIDE 4: Deployment Diagram** ✅ Chỉnh sửa từ CNPM

**CNPM (cũ):**

- Docker containers
- GitHub Actions pipeline
- Render + MongoDB Atlas

**ISA (mới):** 👈 THÊM CHÍ TIẾ KIẾN TRÚC

```
┌─────────────────────────────────────────┐
│     CLIENTS                              │
│  ├─ Flutter Web (GitHub Pages)          │
│  └─ Flutter Mobile (APK/iOS)            │
└─────────────┬───────────────────────────┘
              │ (HTTPS + REST API)
┌─────────────▼───────────────────────────┐
│   API GATEWAY / Load Balancer           │
│  (Single entry point, rate limiting)    │
└─────────────┬───────────────────────────┘
              │
┌─────────────▼───────────────────────────┐
│  APPLICATION SERVER (Node.js Express)   │
│  Hosted on: Render                      │
│  Components:                             │
│  ├─ Controllers                         │
│  ├─ Services                            │
│  └─ Middleware Pipeline                 │
└─────────────┬───────────────────────────┘
              │ (Mongoose ODM)
┌─────────────▼───────────────────────────┐
│  DATABASE (MongoDB Atlas)               │
│  Collections:                           │
│  ├─ users                               │
│  ├─ transactions                        │
│  └─ wallets                             │
└─────────────────────────────────────────┘

CI/CD:
GitHub Repo → GitHub Actions → Auto Deploy → Render + GitHub Pages
```

**Nhấn mạn ISA:**

- Tầng mạng (Network): HTTPS + JWT
- Tầng ứng dụng: Middleware pipeline
- Tầng dữ liệu: ODM (Object-Document Mapping)
- Khả năng mở rộng: Có thể thêm API Gateway, Cache, Message Queue

---

### **SLIDE 5: Component Diagram** ✅ Chỉnh sửa từ CNPM

**CNPM (cũ):**

- Code folder structure
- File organization

**ISA (mới):** 👈 FOCUS VÀO DEPENDENCIES & INTERFACES

```
BACKEND COMPONENTS:

┌─ AuthComponent
│  ├─ Interface: auth.routes.ts
│  ├─ AuthController
│  ├─ AuthService
│  └─ UserModel (MongoDB)
│
├─ TransactionComponent
│  ├─ Interface: transaction.routes.ts
│  ├─ TransactionController
│  ├─ TransactionService
│  └─ Transaction Model (MongoDB)
│
├─ WalletComponent
│  ├─ Interface: wallet.routes.ts
│  ├─ WalletController
│  ├─ WalletService
│  └─ Wallet Model (MongoDB)
│
├─ StatisticComponent
│  ├─ Interface: statistic.routes.ts
│  ├─ StatisticController
│  ├─ StatisticService
│
└─ CrossCutting Concerns
   ├─ JWT Middleware
   ├─ Validation Middleware
   ├─ Error Handler
   └─ Logger

MOBILE COMPONENTS:

├─ AuthModule
│  ├─ LoginScreen
│  ├─ AuthProvider
│  └─ ApiService (call Auth endpoints)
│
├─ TransactionModule
│  ├─ TransactionScreen
│  ├─ TransactionProvider
│  └─ Repository (fetch from API)
│
├─ WalletModule
│  ├─ WalletScreen
│  ├─ WalletProvider
│
└─ SharedModule
   ├─ Models (Serializable)
   ├─ Widgets
   └─ Constants
```

**Biểu đồ kiểu:**

```
          Auth Component
                │
                └─ Implements AuthService Interface
                             │
                        Required by
                       /    |    \
        Controller   Service Model
           (HTTP)  (Logic) (Data)
```

---

### **SLIDE 6: Sequence Diagrams** ✅ Chỉnh sửa từ CNPM

**CNPM (cũ):**

- Các steps kỹ thuật (call stack, database operations)

**ISA (mới):** 👈 EMPHASIZE ARCHITECTURE FLOWS

**3 Sequence Diagrams chính:**

#### **Diagram 6.1: AUTHENTICATION FLOW**

```
User → LoginScreen
    → TransactionProvider.login(email, pwd)
    → Validation (client-side)
    → ApiService.post('/api/auth/login', {email, pwd})
    → Network (HTTPS)
    → AuthController.login()
    → AuthService.verify()
    → UserModel.findOne()
    → MongoDB (find user)
    ← bcrypt.compare()
    ← JWT.sign()
    ← Response {token, user}
    ← AuthProvider.setToken()
    ← UI Navigate to Home
```

**Kiến trúc nhấn mạn:**

- Stateless authentication (JWT)
- Client-side validation
- Middleware chain (JWT)
- Service-Model separation

#### **Diagram 6.2: CREATE TRANSACTION FLOW**

```
User Form → TransactionScreen
    → TransactionProvider.submitTransaction()
    → Client validation
    → ApiService.post('/api/transactions', data)
    → [JWT Header: Bearer token]
    → Express Middleware:
        [Auth JWT ✓] → [Validate Schema ✓] → [Rate Limit ✓]
    → TransactionController.createTransaction()
    → TransactionService.create()
    → Auto-update WalletService.updateBalance()
    → Mongoose Query
    → MongoDB Insert
    ← Response {success, data}
    ← Provider.notifyListeners()
    ← UI Refresh TransactionList
```

**Kiến trúc nhấn mạn:**

- Middleware pipeline
- Business logic layer (Service separates from Controller)
- Database transaction (update wallet + transaction atomically)
- State notification (Provider pattern)

#### **Diagram 6.3: FILTER & FETCH TRANSACTIONS**

```
User Filter Form → TransactionScreen (month, year, category)
    → TransactionProvider.fetchTransactions(filters)
    → ApiService.get('/api/transactions?month=3&year=2026')
    → [JWT Header]
    → Middleware pipeline
    → TransactionController.getTransactions()
    → Build MongoDB Query
    → TransactionService.findByFilters()
    → MongoDB find({userId, date {...}, category {...}})
    ← Aggregate & Sort
    ← Response [transactions]
    ← Provider.transactions = [...]
    ← UI Rebuild ListView
```

**Kiến trúc nhấn mạn:**

- Query parameter validation
- Complex query building
- Stateless API (each request independent)
- Provider state pattern

---

### **SLIDE 7: Design Patterns** ❌ TẠO MỚI

**Mục đích:** Show các design patterns áp dụng trong architecture

**Nội dung:**

#### **Pattern 1: MVC (Model-View-Controller)**

```
VIEW (Presentation Layer):
  ├─ Flutter Screens
  ├─ Widgets
  └─ User Input/Display

CONTROLLER (API Endpoints & Http Layer):
  ├─ Handle HTTP requests
  ├─ Call Service
  └─ Format responses

MODEL (Data & Service Layer):
  ├─ Business Logic (Service)
  ├─ Data Model (Mongoose)
  └─ Database operations
```

#### **Pattern 2: Repository Pattern (Implicit)**

```
Flutter Provider
    ├─ Acts as Repository
    ├─ Abstracts API calls
    └─ Provides data to Widgets

OR Backend Service
    ├─ Abstract DB queries
    ├─ Provide data to Controller
    └─ Handle business logic
```

#### **Pattern 3: Middleware Pattern**

```
Incoming Request
    → Auth Middleware (verify JWT)
    → Validation Middleware (check schema)
    → Rate Limit Middleware (throttle)
    → Error Handler (catch exceptions)
    → Handler (controller)
    → Response
```

#### **Pattern 4: Provider Pattern (Mobile)**

```
Provider = ChangeNotifier + Listeners
    ├─ Encapsulates state
    ├─ Notifies UI on changes
    └─ Separates business logic from UI

Alternative: Redux, Riverpod, BLoC
(But SmartSpender uses Provider)
```

---

### **SLIDE 8: Nhân Tố Kiến Trúc (–ilities)** ❌ TẠO MỚI

**Mục đích:** Analyze kiến trúc dựa trên các nhân tố chất lượng

**Nội dung (Bảng):**

| Nhân Tố              | Mức Độ     | Giải Pháp                                                                                                       |
| -------------------- | ---------- | --------------------------------------------------------------------------------------------------------------- |
| **Scalability**      | Trung bình | 3-Tier có giới hạn. Cơ sở dữ liệu không thể scale horizontal. Giải pháp: Thêm Cache, API Gateway, Load Balancer |
| **Reliability**      | Cao        | JWT stateless, độc lập từng request. Error handling ở middleware. Backup MongoDB Atlas.                         |
| **Maintainability**  | Cao        | MVC tách rõ. Service chứa logic. Dễ test từng layer.                                                            |
| **Security**         | Cao        | JWT authentication, password hashing (bcrypt), HTTPS/TLS, Rate limiting, Input validation, CORS                 |
| **Performance**      | Trung bình | MongoDB indexes trên userId, date. Middleware giới hạn request. Cần thêm: Cache layer, CDN                      |
| **Interoperability** | Tốt        | REST API chuẩn. JSON serialization. Platform-agnostic (Flutter Web + Mobile + future Desktop)                   |

**Cơ hội cải thiện:**

- 📈 Thêm Redis Cache → Improve performance
- 🔄 Implement Event-Driven (Message Queue) → Improve scalability
- 🐝 Refactor to Microservices → Independent scaling per service
- 🌍 Add CDN → Reduce network latency
- 📊 Add Monitoring/Observability → Better reliability

---

### **SLIDE 9: Hướng Mở Rộng & Các Khả Năng Nâng Cấp** ❌ TẠO MỚI

**Mục đích:** Giải thích phát triển từ 3-Tier sang kiến trúc cao cấp hơn

#### **PHASE 1 (Hiện tại): Monolithic 3-Tier**

✅ Đủ cho: ~1k-10k users, 1 team, startup

```
Express App (all features)
    └─ MongoDB (monolithic DB)
```

#### **PHASE 2: Thêm Infrastructure Components**

```
API Gateway (rate limit, auth, routing)
    └─ Express App + Cache (Redis)
         └─ MongoDB + Read Replica
```

✅ Support: ~10k-100k users

#### **PHASE 3: Strangler Pattern (Extract Services)**

```
API Gateway
    ├─ Auth Service (separate)
    ├─ Transaction Service (keep in monolith)
    ├─ Wallet Service (keep)
    └─ Notification Service (async)

Message Queue (RabbitMQ/Kafka) for async events
```

#### **PHASE 4: Microservices + Event-Driven**

```
API Gateway
    ├─ Auth μS (PostgreSQL)
    ├─ Transaction μS (MongoDB)
    ├─ Wallet μS (PostgreSQL)
    ├─ Notification μS (Redis)
    └─ Statistics μS (MongoDB)

Event Bus (Kafka) for real-time updates
Kubernetes for orchestration
```

**Diagram hình ảnh:**

```
MONOLITH              STRANGLER          MICROSERVICES
--------- ──────────────────→ ───────────────────→

┌────────┐   ┌──────┐┌───┐   ┌──┐┌──┐┌──┐┌──┐┌──┐
│ Mono   │   │ GW  ││Svc│   │M1││M2││M3││M4││M5│
│ 1 App  │   │    │└───┘   └──┘└──┘└──┘└──┘└──┘
│1 DB   │   │    │         1 DB each μS
└────────┘   └──┘─┘

Time to Market:  Nhanh        Vừa         Chậm
Scalability:     Kém         Tốt         Rất tốt
Complexity:      Thấp        Trung       Cao
DevOps Skills:   Thấp        Trung       Cao
```

---

## 🎯 TÓMLƯỢC: GIỮ LẠI / CHỈNH SỬA / TẠO MỚI

| Nội Dung               | Hành động    | Ghi chú                                         |
| ---------------------- | ------------ | ----------------------------------------------- |
| Giới thiệu, team       | ✅ Giữ lại   | Không thay đổi                                  |
| 3-Layer Overview       | 🔄 Chỉnh sửa | Thêm architectural perspective                  |
| Logical Architecture   | ❌ Tạo mới   | Chi tiết bên trong layers                       |
| Deployment diagram     | 🔄 Chỉnh sửa | Thêm architectural components (Gateway, etc.)   |
| Component diagram      | 🔄 Chỉnh sửa | Focus vào dependencies, interfaces              |
| Sequence diagrams      | 🔄 Chỉnh sửa | Emphasize architecture flows, layer transitions |
| Design Patterns        | ❌ Tạo mới   | MVC, Repository, Middleware, Provider           |
| Architectural –ilities | ❌ Tạo mới   | Scalability, Reliability, Security analysis     |
| Evolution Roadmap      | ❌ Tạo mới   | 3-Tier → Strangler → Microservices              |

---

## 📊 CỐU TRÚC FILE NỊP ĐỀ

Nếu dùng **Markdown + Mermaid** (sau đó convert PPT/PDF):

```
SmartSpender-ISA-Report/
├── 01-introduction.md          # Slide 1
├── 02-overview-architecture.md # Slide 2
├── 03-logical-architecture.md  # Slide 3
├── 04-deployment-diagram.md    # Slide 4
├── 05-component-diagram.md     # Slide 5
├── 06-sequence-diagrams.md     # Slide 6 (3 diagrams)
├── 07-design-patterns.md       # Slide 7
├── 08-architectural-qualities.md # Slide 8
├── 09-evolution-roadmap.md     # Slide 9
└── README.md                    # Index + summary
```

---

## 🚀 BẢN TIẾP THEO

Bạn muốn tôi:

1. **Tạo chi tiết từng slide** (viết nội dung + Mermaid diagrams)?
2. **Tạo slide CNPM để so sánh** có thể xem cấu trúc cũ?
3. **Tạo template PowerPoint** có thể copy-paste nội dung?

Chọn 1 trong 3 để tôi tập trung giúp! 👉
