# Sequence Diagram - Wallet Management

Biểu đồ luồng quản lý ví: lấy danh sách ví, xem chi tiết, cập nhật thông tin, và chuyển tiền giữa các ví.

```mermaid
sequenceDiagram
    title Sequence Diagram - Wallet Management (List / Details / Update / Transfer)
    participant User as User
    participant UI as UI Flutter
    participant Provider as Provider (State)
    participant Service as WalletService
    participant API as API Backend
    participant Auth as Auth Middleware
    participant Controller as Wallet Controller
    participant DB as Database

    %% ===== FLOW 1: GET ALL WALLETS =====
    User->>UI: openWalletListScreen()
    UI->>Provider: fetchAllWallets()
    Provider->>Service: getWallets()
    Service->>API: GET /api/wallets<br/>(Authorization: Bearer JWT)
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward request
        Controller->>DB: User.findById(userId).populate('wallets')
        DB-->>Controller: wallets[] with current balances
        Controller->>DB: reconcileBalances(wallets)<br/>→ sum transactions & transfers
        DB-->>Controller: updated balances
        Controller-->>API: 200 { data: wallets[] }
        API-->>Service: 200 { data }
        Service-->>Provider: setWallets(data)
        Provider-->>UI: notifyListeners() → display wallets + total balance
    else JWT invalid
        Auth-->>API: 401 Unauthorized
        API-->>Service: 401 Unauthorized
        Service-->>Provider: setAuthError()
        Provider-->>UI: showAuthError("Vui lòng đăng nhập lại")
    end

    %% ===== FLOW 2: GET WALLET DETAILS =====
    User->>UI: tapWallet(walletId)
    UI->>Provider: fetchWalletDetails(walletId)
    Provider->>Service: getWalletById(walletId)
    Service->>API: GET /api/wallets/:id<br/>(Authorization: Bearer JWT)
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward request {walletId}
        Controller->>DB: Wallet.findById(walletId)
        DB-->>Controller: wallet details + balance
        Controller-->>API: 200 { data: wallet }
        API-->>Service: 200 { data }
        Service-->>Provider: setWalletDetails(data)
        Provider-->>UI: notifyListeners() → display wallet details
    else JWT invalid / Not found
        Auth-->>API: 401/404 error
        API-->>Service: error
        Service-->>Provider: setError()
        Provider-->>UI: showError("Ví không tồn tại hoặc hết phiên đăng nhập")
    end

    %% ===== FLOW 3: UPDATE WALLET INFO =====
    User->>UI: editWallet(walletId, {name, description})
    UI->>Provider: submitWalletUpdate(walletId, payload)
    Provider->>Service: updateWallet(walletId, {name, description})
    Service->>API: PATCH /api/wallets/:id<br/>(Authorization: Bearer JWT)<br/>{name, description}
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward request {walletId, payload}
        Controller->>DB: Wallet.findByIdAndUpdate(walletId, payload)
        DB-->>Controller: updated wallet
        Controller-->>API: 200 { data: wallet }
        API-->>Service: 200 { data }
        Service-->>Provider: updateWalletInList(data)
        Provider-->>UI: notifyListeners() → show success + refresh
    else invalid input / not found
        Auth-->>API: 400/404 error
        API-->>Service: error
        Service-->>Provider: setError()
        Provider-->>UI: showError("Lỗi cập nhật ví")
    end

    %% ===== FLOW 4: TRANSFER FUNDS =====
    User->>UI: initiateTransfer(fromWalletId, toWalletId, amount, note)
    UI->>Provider: submitTransfer(from, to, amount, note)
    Provider->>Service: transferFunds(from, to, amount, note)
    Service->>API: POST /api/wallets/transfer<br/>(Authorization: Bearer JWT)<br/>{fromWalletId, toWalletId, amount, note}
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward request {from, to, amount, note}

        par Fetch wallets
            Controller->>DB: Wallet.findById(from)
            DB-->>Controller: fromWallet
        and
            Controller->>DB: Wallet.findById(to)
            DB-->>Controller: toWallet
        end

        alt Validation check
            alt from === to
                Controller-->>API: 400 { error: "Không được chuyển từ ví này sang chính nó" }
            else amount <= 0
                Controller-->>API: 400 { error: "Số tiền phải lớn hơn 0" }
            else fromWallet.balance < amount
                Controller-->>API: 400 { error: "Số dư không đủ" }
            else Success
                Controller->>DB: fromWallet.balance -= amount
                Controller->>DB: toWallet.balance += amount

                par Save wallets
                    Controller->>DB: fromWallet.save()
                and
                    Controller->>DB: toWallet.save()
                end

                Controller->>DB: WalletTransfer.create({<br/>fromWalletId, toWalletId,<br/>amount, note, status: 'completed'<br/>})
                DB-->>Controller: transfer record (audit trail)

                Controller-->>API: 200 { data: { fromWallet, toWallet, transfer } }
                API-->>Service: 200 { data }
                Service-->>Provider: updateWallets(data)
                Provider-->>UI: notifyListeners() → show success + refresh balances
            end
        end
    else JWT invalid
        Auth-->>API: 401 Unauthorized
        API-->>Service: 401 Unauthorized
        Service-->>Provider: setAuthError()
        Provider-->>UI: showAuthError("Vui lòng đăng nhập lại")
    end
```

## Technical Details

### Endpoints

| Method | Endpoint                | Purpose                               | Auth  |
| ------ | ----------------------- | ------------------------------------- | ----- |
| GET    | `/api/wallets`          | Lấy danh sách ví + reconcile balances | JWT ✓ |
| GET    | `/api/wallets/:id`      | Lấy chi tiết 1 ví                     | JWT ✓ |
| PATCH  | `/api/wallets/:id`      | Cập nhật tên/mô tả ví                 | JWT ✓ |
| POST   | `/api/wallets/transfer` | Chuyển tiền giữa ví                   | JWT ✓ |

### Wallet Lifecycle

- **Auto-create**: Ví được tạo tự động lần đầu khi user gọi `GET /api/wallets` (nếu chưa tồn tại):
  - Cash (Tiền mặt)
  - Bank (Ngân hàng)
  - E-wallet (Ví điện tử)
- **No delete**: Hệ thống không cho phép xóa ví

### Transfer Logic

| Check              | Validation                     | Error Message                               |
| ------------------ | ------------------------------ | ------------------------------------------- |
| Same wallet        | `from !== to`                  | "Không được chuyển từ ví này sang chính nó" |
| Amount > 0         | `amount > 0`                   | "Số tiền phải lớn hơn 0"                    |
| Sufficient balance | `fromWallet.balance >= amount` | "Số dư không đủ"                            |
| Balance update     | Promise.all (atomic save)      | Không lock (race condition risk)            |
| Audit trail        | `WalletTransfer.create()`      | Lưu lịch sử chuyển tiền                     |

### Reconciliation

- Mỗi lần gọi `GET /api/wallets`, hệ thống **tính toán lại số dư** từ:
  - Tất cả `Transaction` liên quan (income/expense)
  - Tất cả `WalletTransfer` (transfer in/out)
- **Công thức**: `balance = sum(transactions) + sum(transfersIn) - sum(transfersOut)`

### Error Codes

| Code | Scenario                                                         |
| ---- | ---------------------------------------------------------------- |
| 200  | Success                                                          |
| 400  | Validation error (same wallet, amount ≤ 0, insufficient balance) |
| 401  | JWT invalid or expired                                           |
| 404  | Wallet not found                                                 |
| 500  | Server error                                                     |
