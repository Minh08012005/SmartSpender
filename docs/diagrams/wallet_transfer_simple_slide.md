# Sequence Diagram - Wallet Transfer (Simplified for Slide)

Biểu đồ luồng chuyển tiền giữa các ví - phiên bản rút gọn dành cho slide thuyết trình.

```mermaid
sequenceDiagram
    participant User as Người dùng
    participant UI as UI Flutter
    participant API as API Backend
    participant Auth as Auth Middleware
    participant DB as Database

    User->>UI: Nhâm / Sửa / Xóa giao dịch
    UI->>API: POST /api/wallets/transfer<br/>(Authorization: Bearer JWT)
    API->>Auth: Verify JWT
    
    alt JWT valid
        Auth->>API: ✓ Authorized
        API->>DB: Fetch wallets + validate
        alt Validation passed
            DB-->>API: ✓ Wallets exist, sufficient balance
            API->>DB: Update balances + create transfer record
            DB-->>API: 200 OK
            API-->>UI: Success response
            UI-->>User: Chuyển tiền thành công
        else Validation failed
            DB-->>API: ✗ Error (insufficient funds / invalid wallet)
            API-->>UI: 400 Bad Request
            UI-->>User: Số dư không đủ
        end
    else JWT invalid
        Auth-->>API: 401 Unauthorized
        API-->>UI: 401 Unauthorized
        UI-->>User: Vui lòng đăng nhập lại
    end
```

## Flow Overview

| Step | Action | Status |
|------|--------|--------|
| 1 | User submits transfer request | UI ← User |
| 2 | Send HTTP request with JWT | API ← UI |
| 3 | Verify authentication token | Auth Middleware |
| 4 | Validate inputs + check balance | Database Query |
| 5 | Update wallets + create transfer record | Database Update |
| 6 | Return success/error response | UI ← API |

## Key Points

- **Main Feature**: Chuyển tiền giữa 2 ví của cùng một người dùng
- **Validation**: Kiểm tra JWT, kiểm tra số dư đủ, kiểm tra ví hợp lệ
- **Atomic Operation**: Promise.all() để update 2 ví cùng lúc
- **Audit Trail**: Tạo `WalletTransfer` record để tracking
- **Error Handling**: 401 (unauthorized), 400 (bad request)
