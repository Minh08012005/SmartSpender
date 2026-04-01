# Use Case Diagram - SmartSpender Application

Biểu đồ use case tổng quát các chức năng chính của ứng dụng SmartSpender.

```mermaid
graph TB
    subgraph "SmartSpender System"
        subgraph auth["🔐 Authentication"]
            UC1["Sign Up"]
            UC2["Login"]
            UC3["Logout"]
        end

        subgraph transaction["💳 Transaction Management"]
            UC4["Add Transaction"]
            UC5["View Transactions"]
            UC6["Edit Transaction"]
            UC7["Delete Transaction"]
        end

        subgraph wallet["💰 Wallet Management"]
            UC8["View Wallets"]
            UC9["Transfer Between Wallets"]
            UC10["Update Wallet Info"]
        end

        subgraph statistic["📊 Statistics & Reports"]
            UC11["View Monthly Summary"]
            UC12["View Income by Category"]
            UC13["View Expense by Category"]
            UC14["Export Reports"]
        end
    end

    User["👤 User"]

    User -->|Authenticate| UC1
    User -->|Authenticate| UC2
    User -->|Logout| UC3

    User -->|Manage| UC4
    User -->|Manage| UC5
    User -->|Manage| UC6
    User -->|Manage| UC7

    User -->|Manage| UC8
    User -->|Manage| UC9
    User -->|Manage| UC10

    User -->|View| UC11
    User -->|View| UC12
    User -->|View| UC13
    User -->|View| UC14

    UC4 -.->|creates| UC5
    UC6 -.->|updates| UC5
    UC7 -.->|removes from| UC5
    UC9 -.->|updates| UC8
    UC5 -.->|source for| UC11
    UC5 -.->|source for| UC12
    UC5 -.->|source for| UC13

    style User fill:#4A90E2,stroke:#2E5C8A,stroke-width:3px,color:#fff
    style auth fill:#E8F4F8,stroke:#4A90E2,stroke-width:2px
    style transaction fill:#F0F8E8,stroke:#5FA63D,stroke-width:2px
    style wallet fill:#FFF4E8,stroke:#E8A835,stroke-width:2px
    style statistic fill:#F8E8F8,stroke:#9B59B6,stroke-width:2px

    style UC1 fill:#4A90E2,stroke:#2E5C8A,color:#fff
    style UC2 fill:#4A90E2,stroke:#2E5C8A,color:#fff
    style UC3 fill:#4A90E2,stroke:#2E5C8A,color:#fff

    style UC4 fill:#5FA63D,stroke:#3D7A28,color:#fff
    style UC5 fill:#5FA63D,stroke:#3D7A28,color:#fff
    style UC6 fill:#5FA63D,stroke:#3D7A28,color:#fff
    style UC7 fill:#5FA63D,stroke:#3D7A28,color:#fff

    style UC8 fill:#E8A835,stroke:#B8841B,color:#fff
    style UC9 fill:#E8A835,stroke:#B8841B,color:#fff
    style UC10 fill:#E8A835,stroke:#B8841B,color:#fff

    style UC11 fill:#9B59B6,stroke:#6C3F7E,color:#fff
    style UC12 fill:#9B59B6,stroke:#6C3F7E,color:#fff
    style UC13 fill:#9B59B6,stroke:#6C3F7E,color:#fff
    style UC14 fill:#9B59B6,stroke:#6C3F7E,color:#fff
```

## Mô tả Use Cases

### 🔐 Authentication (Xác thực)

| Use Case    | Mô tả                              | Actor |
| ----------- | ---------------------------------- | ----- |
| **Sign Up** | Người dùng tạo tài khoản mới       | User  |
| **Login**   | Người dùng đăng nhập vào hệ thống  | User  |
| **Logout**  | Người dùng đăng xuất khỏi hệ thống | User  |

### 💳 Transaction Management (Quản lý giao dịch)

| Use Case               | Mô tả                                    | Actor |
| ---------------------- | ---------------------------------------- | ----- |
| **Add Transaction**    | Người dùng tạo giao dịch mới (thu/chi)   | User  |
| **View Transactions**  | Người dùng xem danh sách giao dịch       | User  |
| **Edit Transaction**   | Người dùng chỉnh sửa thông tin giao dịch | User  |
| **Delete Transaction** | Người dùng xóa giao dịch                 | User  |

### 💰 Wallet Management (Quản lý ví)

| Use Case                     | Mô tả                                | Actor |
| ---------------------------- | ------------------------------------ | ----- |
| **View Wallets**             | Người dùng xem danh sách ví và số dư | User  |
| **Transfer Between Wallets** | Người dùng chuyển tiền giữa các ví   | User  |
| **Update Wallet Info**       | Người dùng cập nhật tên/mô tả ví     | User  |

### 📊 Statistics & Reports (Thống kê & Báo cáo)

| Use Case                     | Mô tả                               | Actor |
| ---------------------------- | ----------------------------------- | ----- |
| **View Monthly Summary**     | Xem tổng hợp thu/chi theo tháng     | User  |
| **View Income by Category**  | Xem chi tiết thu nhập theo danh mục | User  |
| **View Expense by Category** | Xem chi tiết chi phí theo danh mục  | User  |
| **Export Reports**           | Xuất báo cáo ra file (PDF/Excel)    | User  |

## Mối quan hệ giữa các Use Cases

- **Create → Read**: Tạo giao dịch mới sẽ xuất hiện trong danh sách giao dịch
- **Edit/Delete → Update View**: Chỉnh sửa/xóa giao dịch cập nhật danh sách
- **Transfer → Wallet Balance**: Chuyển tiền giữa ví sẽ cập nhật số dư
- **Transactions → Statistics**: Dữ liệu giao dịch là nguồn tính toán thống kê

## Màu sắc theo chức năng

- 🔵 **Xanh dương** (Authentication): Bảo mật & xác thực
- 🟢 **Xanh lá** (Transactions): Quản lý dữ liệu giao dịch
- 🟠 **Cam** (Wallets): Quản lý tài sản
- 🟣 **Tím** (Statistics): Phân tích & báo cáo
