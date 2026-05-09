# SmartSpender - Class Diagram & Visual Architecture

## 🎯 Class Diagram (Entity-Relationship)

```mermaid
classDiagram
    class User {
        ObjectId _id
        String email*
        String password*
        String fullName
        Date createdAt
        Date updatedAt
        --
        Methods
        register()
        login()
        getProfile()
        updateProfile()
    }

    class Wallet {
        ObjectId _id
        ObjectId userId (FK)
        String walletType
        Number balance
        String name
        String description
        Date lastUpdated
        Date createdAt
        Date updatedAt
        --
        Methods
        updateBalance()
        getBalance()
        transfer()
    }

    class Transaction {
        ObjectId _id
        ObjectId userId (FK)
        Number amount
        String type
        String walletType
        String category
        String title
        String note
        Date date
        Date createdAt
        Date updatedAt
        --
        Methods
        create()
        update()
        delete()
        getHistory()
    }

    class WalletTransfer {
        ObjectId _id
        ObjectId userId (FK)
        String fromWalletType
        String toWalletType
        Number amount
        String note
        Date date
        Date createdAt
        Date updatedAt
        --
        Methods
        execute()
        validateTransfer()
    }

    class Notification {
        ObjectId _id
        ObjectId userId (FK)
        String title
        String message
        String type
        Boolean isRead
        Date createdAt
        Date updatedAt
        --
        Methods
        markAsRead()
        delete()
        send()
    }

    %% Relationships
    User "1" --> "3" Wallet : owns
    User "1" --> "many" Transaction : creates
    User "1" --> "many" WalletTransfer : performs
    User "1" --> "many" Notification : receives
    Wallet "1" <-- "many" Transaction : uses
    WalletTransfer "N" --> "2" Wallet : transfers_between
```

---

## 📊 Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    USERS ||--o{ WALLETS : owns
    USERS ||--o{ TRANSACTIONS : creates
    USERS ||--o{ WALLET_TRANSFERS : performs
    USERS ||--o{ NOTIFICATIONS : receives
    WALLETS ||--o{ TRANSACTIONS : "linked to"
    WALLETS ||--o{ WALLET_TRANSFERS : "transfers between"

    USERS {
        string _id PK "ObjectId"
        string email UK "unique, indexed"
        string password "hashed"
        string fullName
        datetime createdAt
        datetime updatedAt
    }

    WALLETS {
        string _id PK "ObjectId"
        string userId FK "Reference to Users"
        string walletType "cash|bank|ewallet"
        number balance "VND"
        string name "Display name"
        string description
        datetime lastUpdated
        datetime createdAt
        datetime updatedAt
    }

    TRANSACTIONS {
        string _id PK "ObjectId"
        string userId FK "Reference to Users"
        number amount "VND"
        string type "income|expense"
        string walletType "cash|bank|ewallet"
        string category "Category enum"
        string title
        string note
        datetime date
        datetime createdAt
        datetime updatedAt
    }

    WALLET_TRANSFERS {
        string _id PK "ObjectId"
        string userId FK "Reference to Users"
        string fromWalletType "Source wallet"
        string toWalletType "Destination wallet"
        number amount "VND"
        string note
        datetime date
        datetime createdAt
        datetime updatedAt
    }

    NOTIFICATIONS {
        string _id PK "ObjectId"
        string userId FK "Reference to Users"
        string title
        string message
        string type "general|transaction|transfer"
        boolean isRead
        datetime createdAt
        datetime updatedAt
    }
```

---

## 🔄 Data Flow Architecture

```mermaid
graph TB
    subgraph Client["🖥️ Frontend (Flutter Mobile & Web)"]
        UI["UI Components"]
    end

    subgraph API["🔌 API Layer (Express.js)"]
        AuthCtrl["Auth Controller"]
        TransCtrl["Transaction Controller"]
        WalletCtrl["Wallet Controller"]
        NotifCtrl["Notification Controller"]
        StatCtrl["Statistic Controller"]
    end

    subgraph Service["⚙️ Service Layer (Business Logic)"]
        AuthSvc["Auth Service"]
        TransSvc["Transaction Service"]
        WalletSvc["Wallet Service"]
        NotifSvc["Notification Service"]
        StatSvc["Statistic Service"]
    end

    subgraph Middleware["🛡️ Middleware"]
        AuthMid["Auth Middleware"]
        ValidateMid["Validation Middleware"]
        ErrorMid["Error Handler"]
        RateLimitMid["Rate Limiting"]
    end

    subgraph Models["📦 Data Layer (Mongoose Models)"]
        UserModel["User Model"]
        WalletModel["Wallet Model"]
        TransModel["Transaction Model"]
        TransferModel["WalletTransfer Model"]
        NotifModel["Notification Model"]
    end

    subgraph DB["💾 MongoDB Database"]
        UsersCol["users collection"]
        WalletsCol["wallets collection"]
        TransCol["transactions collection"]
        TransferCol["wallettransfers collection"]
        NotifCol["notifications collection"]
    end

    %% Flow connections
    UI -->|HTTP Request| AuthMid
    AuthMid -->|Request + User| ValidateMid
    ValidateMid -->|Validated| ErrorMid

    ErrorMid -->|Route| AuthCtrl
    ErrorMid -->|Route| TransCtrl
    ErrorMid -->|Route| WalletCtrl
    ErrorMid -->|Route| NotifCtrl
    ErrorMid -->|Route| StatCtrl

    AuthCtrl -->|Call| AuthSvc
    TransCtrl -->|Call| TransSvc
    WalletCtrl -->|Call| WalletSvc
    NotifCtrl -->|Call| NotifSvc
    StatCtrl -->|Call| StatSvc

    AuthSvc -->|Query/Mutate| UserModel
    TransSvc -->|Query/Mutate| TransModel
    TransSvc -->|Query/Mutate| WalletModel
    TransSvc -->|Query/Mutate| NotifModel

    WalletSvc -->|Query/Mutate| WalletModel
    WalletSvc -->|Query/Mutate| TransferModel
    WalletSvc -->|Query/Mutate| NotifModel

    NotifSvc -->|Query/Mutate| NotifModel
    StatSvc -->|Query| TransModel
    StatSvc -->|Query| TransferModel

    UserModel -->|Mongoose| UsersCol
    WalletModel -->|Mongoose| WalletsCol
    TransModel -->|Mongoose| TransCol
    TransferModel -->|Mongoose| TransferCol
    NotifModel -->|Mongoose| NotifCol

    UsersCol -->|MongoDB| MongoServer["MongoDB Server"]
    WalletsCol -->|MongoDB| MongoServer
    TransCol -->|MongoDB| MongoServer
    TransferCol -->|MongoDB| MongoServer
    NotifCol -->|MongoDB| MongoServer

    %% Response flow
    MongoServer -->|Response| UsersCol
    MongoServer -->|Response| WalletsCol
    MongoServer -->|Response| TransCol
    MongoServer -->|Response| TransferCol
    MongoServer -->|Response| NotifCol

    Models -->|Formatted Data| API
    API -->|JSON Response| UI

    style Client fill:#e1f5ff
    style API fill:#f3e5f5
    style Service fill:#e8f5e9
    style Middleware fill:#fff3e0
    style Models fill:#fce4ec
    style DB fill:#f1f8e9
```

---

## 🔀 Transaction Flow Diagram

```mermaid
sequenceDiagram
    participant User
    participant UI
    participant API as API<br/>(Controller)
    participant Service as Service<br/>(Business Logic)
    participant Middleware as Middleware
    participant Models as Models
    participant DB as MongoDB

    %% Flow for Creating Transaction
    User->>UI: Input transaction data
    UI->>API: POST /api/transactions
    API->>Middleware: Validate JWT Token
    Middleware-->>API: ✅ Valid Token

    API->>Middleware: Validate Request Body
    Middleware-->>API: ✅ Valid Data

    API->>Service: createTransaction(data)
    Service->>Models: findById(userId)
    Models->>DB: db.users.findById()
    DB-->>Models: User document
    Models-->>Service: User found

    Service->>Models: findOne({userId, walletType})
    Models->>DB: db.wallets.findOne()
    DB-->>Models: Wallet document
    Models-->>Service: Wallet found

    Note over Service: Check balance if expense

    Service->>Models: insertOne(transaction)
    Models->>DB: db.transactions.insertOne()
    DB-->>Models: ✅ Inserted
    Models-->>Service: New transaction

    Service->>Models: updateOne({walletType}, {balance})
    Models->>DB: db.wallets.updateOne()
    DB-->>Models: ✅ Updated
    Models-->>Service: Wallet updated

    Service->>Models: insertOne(notification)
    Models->>DB: db.notifications.insertOne()
    DB-->>Models: ✅ Inserted
    Models-->>Service: Notification created

    Service-->>API: ✅ Success Response
    API-->>UI: 200 + Transaction data
    UI-->>User: ✅ Display Success
```

---

## 💱 Wallet Transfer Flow

```mermaid
sequenceDiagram
    participant User
    participant UI
    participant API as API
    participant Service as Service
    participant DB as MongoDB

    User->>UI: Request wallet transfer
    UI->>API: POST /api/wallets/transfer

    API->>Service: executeTransfer({fromType, toType, amount})

    Service->>DB: Check fromWallet.balance >= amount
    alt Insufficient Balance
        Service-->>API: ❌ Error: Insufficient balance
        API-->>UI: 400 Error
        UI-->>User: ❌ Error message
    else Balance OK
        Service->>DB: Begin Transaction

        Service->>DB: Insert WalletTransfer record
        Service->>DB: Update fromWallet (balance -= amount)
        Service->>DB: Update toWallet (balance += amount)
        Service->>DB: Insert Notification

        Service->>DB: Commit Transaction

        Service-->>API: ✅ Success
        API-->>UI: 200 + Transfer data
        UI-->>User: ✅ Transfer successful
    end
```

---

## 📈 Statistic Aggregation Pipeline

```mermaid
graph LR
    A["📊 Statistics Request<br/>(month/year)"] -->|aggregate| B["Filter<br/>userId + date range"]
    B -->|$match| C["Match expense/income<br/>transactions"]
    C -->|$group| D["Group by<br/>category"]
    D -->|$sort| E["Sort by<br/>total amount"]
    E -->|$project| F["Format output"]
    F -->|Response| G["📈 Chart Data<br/>(Pie/Bar Chart)"]

    style A fill:#e1f5ff
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style D fill:#e8f5e9
    style E fill:#fce4ec
    style F fill:#f1f8e9
    style G fill:#c8e6c9
```

---

## 🗂️ Embedded vs Referenced Pattern

### Current Design: REFERENCING (Được sử dụng)

```mermaid
graph TB
    subgraph Referencing["✅ REFERENCING (Current)"]
        User1["👤 User Collection<br/>{ _id, email, fullName }"]
        Wallet1["💰 Wallet Collection<br/>{ userId (FK), balance }"]
        Trans1["📝 Transaction Collection<br/>{ userId (FK), amount }"]

        User1 -->|_id| Wallet1
        User1 -->|_id| Trans1
    end

    style User1 fill:#c8e6c9
    style Wallet1 fill:#c8e6c9
    style Trans1 fill:#c8e6c9
    style Referencing fill:#e8f5e9
```

**Ưu điểm:**

- ✅ Dữ liệu không bị trùng lặp
- ✅ Dễ cập nhật (update một chỗ)
- ✅ Linh hoạt (thêm collection mới dễ dàng)
- ✅ Query riêng biệt → performance tốt

---

### Alternative: EMBEDDING (Không sử dụng)

```mermaid
graph TB
    subgraph Embedding["❌ EMBEDDING (Not Used)"]
        User2["👤 User Document<br/>{ _id, email, fullName,<br/>wallets: [{...}],<br/>transactions: [{...}] }"]
    end

    style User2 fill:#ffcdd2
    style Embedding fill:#ffebee
```

**Nhược điểm:**

- ❌ Document lớn → slow query
- ❌ 16MB limit của MongoDB
- ❌ Trùng lặp dữ liệu
- ❌ Cập nhật phức tạp

---

## 🔐 Data Security Model

```mermaid
graph TB
    subgraph Input["🔴 Untrusted Input"]
        A["Frontend Data"]
    end

    subgraph Validation["🟡 Validation Layer"]
        B["Input Validation"]
        C["Type Checking"]
        D["Range Checking"]
    end

    subgraph Auth["🟢 Authentication & Authorization"]
        E["JWT Verification"]
        F["User ID Check"]
        G["Permission Check"]
    end

    subgraph Business["🔵 Business Logic"]
        H["Sanitize"]
        I["Transform"]
        J["Validate Rules"]
    end

    subgraph Storage["🟣 Storage"]
        K["Encrypt Sensitive"]
        L["Hash Password"]
        M["MongoDB Storage"]
    end

    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
    I --> J
    J --> K
    K --> L
    L --> M

    style Input fill:#ffcdd2
    style Validation fill:#ffe0b2
    style Auth fill:#c8e6c9
    style Business fill:#bbdefb
    style Storage fill:#e1bee7
```

---

## 📊 Index Strategy

```mermaid
graph TB
    subgraph Indexes["Optimized Indexes"]
        A["Users<br/>- email (unique)<br/>- createdAt"]
        B["Wallets<br/>- userId, walletType"]
        C["Transactions<br/>- userId, date DESC<br/>- userId, type, category<br/>- title, note (text)"]
        D["WalletTransfers<br/>- userId, date DESC"]
        E["Notifications<br/>- userId, isRead<br/>- createdAt (TTL)"]
    end

    style A fill:#bbdefb
    style B fill:#bbdefb
    style C fill:#bbdefb
    style D fill:#bbdefb
    style E fill:#bbdefb
```

---

## 🎯 Growth Roadmap

```mermaid
timeline
    title SmartSpender Data Schema Evolution

    M1 : Phase 1: MVP
         : Users (Auth)
         : Wallets (3 types)
         : Transactions (Income/Expense)
         : Current: May 2026

    M2 : Phase 2: Enhanced
         : WalletTransfers (Internal transfers)
         : Notifications (User alerts)
         : Statistics (Monthly reports)

    M3 : Phase 3: Advanced
         : RecurringTransactions (Auto-create)
         : Budget Collection (Spending limits)
         : Tags (Custom categories)
         : Sharing (Shared wallets)

    M4 : Phase 4: Analytics
         : Goals (Saving targets)
         : Insights (AI recommendations)
         : Reports (Export/PDF)
         : Multi-currency (FX support)
```

---

## 📋 Collection Statistics

```mermaid
pie title Document Distribution (10,000 users)
    "Users" : 10000
    "Wallets" : 30000
    "Transactions" : 500000
    "WalletTransfers" : 50000
    "Notifications" : 1000000
```

---

## 🚀 Performance Considerations

```mermaid
graph LR
    A["Query Type"] -->|Simple| B["Single Collection<br/>+ indexes"]
    A -->|Complex| C["Aggregation Pipeline<br/>+ indexes"]
    A -->|Real-time| D["WebSocket<br/>+ Caching"]

    B -->|Examples| B1["Find user wallets<br/>Find transactions"]
    C -->|Examples| C1["Monthly statistics<br/>Category breakdown"]
    D -->|Examples| D1["Balance updates<br/>Notifications"]

    B1 --> E["✅ < 100ms"]
    C1 --> F["✅ < 500ms"]
    D1 --> G["✅ Real-time"]

    style E fill:#c8e6c9
    style F fill:#c8e6c9
    style G fill:#c8e6c9
```
