# Sequence Diagram - Statistics (Simplified for Slide)

Biểu đồ luồng tính năng Thống kê (bản rút gọn): lấy tổng hợp hàng tháng (thu, chi, số dư theo danh mục).

```mermaid
sequenceDiagram
    title Sequence Diagram - Statistics (Monthly Aggregation)
    participant User as User
    participant UI as UI Flutter
    participant API as API Backend
    participant Auth as Auth Middleware
    participant DB as Database

    User->>UI: Mở màn hình thống kê<br/>(chọn tháng/năm)
    UI->>API: GET /api/statistics/summary<br/>?month=MM&year=YYYY
    API->>Auth: Verify JWT

    alt JWT hợp lệ
        Auth->>DB: Query monthly statistics<br/>(totalIncome, totalExpense, byCategory)
        DB-->>Auth: { data }
        Auth-->>API: ✓ Valid
        API-->>UI: 200 Success { data }
        UI-->>User: Hiển thị biểu đồ & bảng
    else JWT không hợp lệ
        Auth-->>API: ✗ Unauthorized
        API-->>UI: 401 Unauthorized
        UI-->>User: "Vui lòng đăng nhập lại"
    else Lỗi máy chủ
        DB-->>API: Error
        API-->>UI: 500 Error
        UI-->>User: "Lỗi máy chủ, vui lòng thử lại"
    end
```

## Technical Details

| Attribute           | Value                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------- |
| **Endpoint**        | `GET /api/statistics/summary?month=<MM>&year=<YYYY>`                                        |
| **Authorization**   | JWT Bearer token in Authorization header                                                    |
| **Query Params**    | `month` (1-12), `year` (YYYY)                                                               |
| **Response Format** | `{ success: true, data: { totalIncome, totalExpense, balanceByCategory }, message: "..." }` |
| **Success Code**    | 200 Ok                                                                                      |
| **Error Codes**     | 401 (unauthorized), 500 (server error)                                                      |

## Key Points

- Lấy dữ liệu từ **transaction history** trong tháng/năm chỉ định
- Tính tổng **Thu**, **Chi**, **Số dư** theo **Danh mục**
- Xử lý JWT validation tại Auth Middleware
- Hiển thị error messages tiếng Việt cho người dùng
