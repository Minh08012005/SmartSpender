```mermaid
sequenceDiagram
    participant User as Người dùng
    participant UI as UI Flutter
    participant Provider as Provider (State)
    participant Service as Transaction Service
    participant API as API Backend
    participant Auth as Auth Middleware
    participant Controller as Transaction Controller
    participant DB as Database

    User->>UI: Thêm / Sửa / Xóa giao dịch
    UI->>Provider: submitTransaction(payload)
    Note right of UI: Client normalizes input
    Provider->>Service: call API (normalized payload)
    Service->>API: HTTP POST/PUT/DELETE /api/transactions\nHeader: Authorization: Bearer JWT
    API->>Auth: Verify JWT
    alt JWT hợp lệ
      Auth->>Controller: cho phép truy cập
      Controller->>DB: INSERT / UPDATE / DELETE transaction
      Note right of Controller: Sau ghi DB -> cập nhật wallet balance / rollback nếu cần
      Controller->>API: OK (201 for POST, 200 for PUT/DELETE)
    else JWT không hợp lệ
      Auth-->>Service: 401 Unauthorized (TOKEN_INVALID / TOKEN_EXPIRED)
    end
    Service-->>Provider: Response (201 / 200 / 400 / 401 / 404)
    alt 200 / 201
      Provider->>Provider: update local list; notifyListeners()
      Provider->>UI: Hiển thị danh sách mới
    else 400
      Provider->>UI: Hiển thị lỗi validation
    else 401
      Provider->>UI: Yêu cầu đăng nhập lại (nếu TOKEN_EXPIRED chuyển sang login)
    end
```
