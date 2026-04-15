# Sequence Diagram - Wallet Transfer (Slide Version)

Biểu đồ luồng chuyển tiền giữa ví - phiên bản tối ưu cho slide trình bày.

```mermaid
sequenceDiagram
    title Sequence Diagram - Chuyển tiền giữa các ví
    participant User as User
    participant UI as UI Flutter
    participant Provider as Provider (State)
    participant Service as WalletService
    participant API as API Backend
    participant Auth as Auth Middleware
    participant Controller as Wallet Controller
    participant DB as Database

    User->>UI: Thực hiện chuyển tiền
    UI->>UI: Validate input (from ≠ to, amount > 0)
    UI->>Provider: submitTransfer(from, to, amount, note)
    Provider->>Service: transferFunds(from, to, amount, note)
    Service->>API: POST /api/wallets/transfer<br/>(Authorization: Bearer JWT)<br/>{fromWalletId, toWalletId, amount, note}
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward {from, to, amount, note}

        par Fetch wallets
            Controller->>DB: Wallet.findById(from)
            DB-->>Controller: fromWallet
        and
            Controller->>DB: Wallet.findById(to)
            DB-->>Controller: toWallet
        end

        alt Validate business logic
            alt from === to
                Controller-->>API: 400 "Không được chuyển từ ví này sang chính nó"
                API-->>Service: 400 error
            else amount ≤ 0
                Controller-->>API: 400 "Số tiền phải lớn hơn 0"
                API-->>Service: 400 error
            else fromWallet.balance < amount
                Controller-->>API: 400 "Số dư không đủ"
                API-->>Service: 400 error
            else ✓ All valid
                Controller->>DB: fromWallet.balance -= amount
                Controller->>DB: toWallet.balance += amount

                par Save wallets
                    Controller->>DB: fromWallet.save()
                and
                    Controller->>DB: toWallet.save()
                end

                Controller->>DB: WalletTransfer.create({<br/>fromWalletId, toWalletId,<br/>amount, note, status: 'completed'<br/>})
                DB-->>Controller: transfer record

                Controller-->>API: 200 { data: {fromWallet, toWallet} }
                API-->>Service: 200 success
                Service-->>Provider: updateWallets(data)
                Provider-->>UI: notifyListeners()
            end
        end

        alt Success
            UI->>UI: Show success + refresh balance
            UI->>User: ✓ Chuyển tiền thành công
        else Error
            UI->>UI: Show error message
            UI->>User: ✗ Chuyển tiền thất bại
        end
    else JWT invalid
        Auth-->>API: 401 Unauthorized
        API-->>Service: 401 error
        Service-->>Provider: setAuthError()
        Provider-->>UI: showAuthError("Vui lòng đăng nhập lại")
    end
```

## 📋 Chi tiết kỹ thuật

### Endpoint

```
POST /api/wallets/transfer
Authorization: Bearer JWT
Content-Type: application/json

{
  "fromWalletId": "wallet_id_1",
  "toWalletId": "wallet_id_2",
  "amount": 100000,
  "note": "Chuyển từ tiền mặt sang ngân hàng"
}
```

### Response (200 Success)

```json
{
  "success": true,
  "data": {
    "fromWallet": {
      "id": "wallet_id_1",
      "walletType": "Cash",
      "balance": 400000
    },
    "toWallet": {
      "id": "wallet_id_2",
      "walletType": "Bank",
      "balance": 600000
    },
    "transfer": {
      "id": "transfer_id",
      "fromWalletId": "wallet_id_1",
      "toWalletId": "wallet_id_2",
      "amount": 100000,
      "note": "Chuyển từ tiền mặt sang ngân hàng",
      "status": "completed",
      "createdAt": "2024-04-01T10:30:00Z"
    }
  }
}
```

### Validation Rules

| Rule                | Condition                      | Error Message                             |
| ------------------- | ------------------------------ | ----------------------------------------- |
| **Same Wallet**     | `from !== to`                  | Không được chuyển từ ví này sang chính nó |
| **Amount > 0**      | `amount > 0`                   | Số tiền phải lớn hơn 0                    |
| **Sufficient Fund** | `fromWallet.balance >= amount` | Số dư không đủ                            |

### Key Features

✅ **Atomic Save**: `Promise.all()` đảm bảo cả 2 ví được cập nhật cùng lúc  
✅ **Audit Trail**: Tạo `WalletTransfer` record lưu lịch sử chuyển tiền  
✅ **JWT Auth**: Xác minh người dùng trước khi xử lý  
✅ **Error Handling**: Kiểm tra tất cả điều kiện validation trước

### Flow Diagram Summary

```
1️⃣ User nhập thông tin chuyển tiền (from, to, amount)
   ↓
2️⃣ Validate client-side: from ≠ to, amount > 0
   ↓
3️⃣ Submit API request + JWT token
   ↓
4️⃣ Server verify JWT + fetch cả 2 ví
   ↓
5️⃣ Server validate business logic (đủ tiền, ...)
   ↓
6️⃣ Update balances + save wallets
   ↓
7️⃣ Create WalletTransfer record (audit trail)
   ↓
8️⃣ Return success + updated balances
   ↓
9️⃣ UI refresh + show success message
```
