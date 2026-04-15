# Sequence Diagram - Statistics (Monthly Aggregation)

Biểu đồ luồng tính năng Thống kê: lấy tổng hợp hàng tháng (thu, chi, số dư theo danh mục).

```mermaid
sequenceDiagram
    title Sequence Diagram - Statistics (Monthly Aggregation)
    participant User as User
    participant UI as UI Flutter
    participant Provider as Provider (State)
    participant Service as StatisticService
    participant API as API Backend
    participant Auth as Auth Middleware
    participant Controller as Statistic Controller
    participant DB as Database

    User->>UI: openStatisticsScreen(month, year)
    UI->>Provider: requestStatistics(month, year)
    Provider->>Service: fetchStatistics(month, year)
    Service->>API: GET /api/statistics/summary?month=MM&year=YYYY<br/>(Authorization: Bearer JWT)
    API->>Auth: Verify JWT

    alt JWT valid
        Auth->>Controller: forward request {month, year}
        Controller->>DB: getMonthlyStatistics(userId, month, year)
        DB-->>Controller: { totalIncome, totalExpense, balance, byCategory[] }
        Controller-->>API: 200 { data: monthly summary }
        API-->>Service: 200 { data }
        Service-->>Provider: updateStatisticsData(data)
        Provider-->>UI: notifyListeners() → render charts/tables
    else JWT invalid
        Auth-->>API: 401 Unauthorized
        API-->>Service: 401 Unauthorized
        Service-->>Provider: setAuthError()
        Provider-->>UI: showAuthError("Vui lòng đăng nhập lại")
    end

    alt API error (server error)
        Controller-->>API: 500 Internal Error
        API-->>Service: 500 error
        Service-->>Provider: setError()
        Provider-->>UI: showError("Lỗi máy chủ, vui lòng thử lại")
    end
```

## Technical Details

| Attribute             | Value                                                                                       |
| --------------------- | ------------------------------------------------------------------------------------------- |
| **Endpoint**          | `GET /api/statistics/summary?month=<MM>&year=<YYYY>`                                        |
| **Authorization**     | JWT Bearer token in Authorization header                                                    |
| **Query Params**      | `month` (1-12), `year` (YYYY)                                                               |
| **Response Format**   | `{ success: true, data: { totalIncome, totalExpense, balanceByCategory }, message: "..." }` |
| **Controller Method** | `getSummary()` calls `StatisticService.getMonthlyStatistics()`                              |
| **Aggregation**       | Runs on `transactions` collection, grouped by `category`                                    |
| **Error Codes**       | 401 (unauthorized), 500 (server error)                                                      |

## Key Points

- Thống kê được tính toán **theo ví** (walletType) hoặc **theo danh mục** (category)
- Dữ liệu được **lấy từ transaction history** trong tháng/năm chỉ định
- Cơ chế **reconcile số dư** từ toàn bộ lịch sử giao dịch (không chỉ tháng hiện tại)
- Xử lý **JWT validation** tại middleware trước khi vào controller
