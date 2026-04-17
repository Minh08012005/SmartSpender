# CHƯƠNG 1: TỔNG QUAN KIẾN TRÚC HỆ THỐNG THÔNG TIN

**Người viết hướng dẫn:** Mai Huy Minh  
**Mục tiêu chương:** Cung cấp nền tảng lý thuyết ISA ngắn gọn, dẫn đến việc lựa chọn kiến trúc cho SmartSpender.  
**Độ dài dự kiến:** 1.5-2 trang

---

## 1.1 Khái niệm Kiến Trúc Hệ Thống Thông Tin (ISA)

### Định nghĩa

Kiến trúc hệ thống thông tin là **tập hợp các quyết định cơ bản về cấu trúc tổ chức hệ thống**, bao gồm:

- **Thành phần (Components)**: Các phần của hệ thống (frontend, backend, database, services).
- **Mối quan hệ (Relationships)**: Cách các thành phần kết nối, giao tiếp với nhau.
- **Nguyên tắc thiết kế (Design Principles)**: Những norms và rules hướng dẫn cách xây dựng hệ thống.
- **Mục tiêu (Goals)**: Các chỉ tiêu chất lượng (tốc độ, bảo mật, dễ bảo trì, khả năng mở rộng).

**Tại sao quan trọng:** Kiến trúc tốt quyết định khả năng bảo trì, mở rộng, bảo mật của hệ thống trong dài hạn. Một quyết định kiến trúc sai lúc đầu có thể tốn kém rất nhiều khi phải sửa lại sau.

---

## 1.2 Ba Nguyên Tắc Kiến Trúc Cơ Bản

### Nguyên tắc 1: Separation of Concerns (Tách biệt Trách nhiệm)

**Định nghĩa:** Mỗi thành phần/module chỉ nên chịu trách nhiệm cho **một** điều.

**Ví dụ SmartSpender:**

- **Controller** chỉ nhận HTTP request và gọi Service (không xử lý logic kinh doanh).
- **Service** chỉ xử lý logic kinh doanh (không biết về HTTP, không query database trực tiếp).
- **Model** chỉ định nghĩa schema dữ liệu (không chứa logic business).

**Lợi ích:**

- Dễ hiểu: Mỗi phần code có nhiệm vụ rõ ràng.
- Dễ test: Có thể test từng component riêng lẻ.
- Dễ maintain: Thay đổi một phần không ảnh hưởng toàn bộ.

**Ví dụ ngược (SAI):**

```
TransactionController xử lý lại tất cả:
- Validate dữ liệu
- Ghi vào database trực tiếp
- Cập nhật wallet balance
- Gửi email notification
→ Code dài, khó bảo trì, khó test
```

---

### Nguyên tắc 2: Loose Coupling (Liên Kết Lỏng)

**Định nghĩa:** Các thành phần nên **độc lập nhất có thể**, giảm phụ thuộc lẫn nhau.

**Ví dụ SmartSpender:**

- **Frontend (Flutter)** không biết cách database được tổ chức → chỉ gọi API.
- **Backend** không biết Frontend dùng Flutter hay React → chỉ return JSON.
- Nếu đổi database MongoDB sang PostgreSQL, Frontend không cần thay đổi → Backend thay đổi, Frontend vẫn chạy.

**Cơ chế thực hiện:**

- Dùng **Interface/Contract** (ví dụ: REST API là contract giữa Client-Server).
- Server không phải biết chi tiết client, client không phải biết chi tiết server.

**Lợi ích:**

- Dễ thay đổi: Đổi công nghệ một phần không ảnh hưởng phần khác.
- Dễ scale: Có thể deploy riêng lẻ từng thành phần.
- Dễ test: Có thể mock (giả lập) một thành phần để test thành phần khác.

**Ví dụ ngược (SAI):**

```
Frontend và Backend dùng chung code → tight coupling
Frontend biết chi tiết internal database schema → phải sửa frontend khi DB thay đổi
```

---

### Nguyên tắc 3: High Cohesion (Gắn Kết Cao)

**Định nghĩa:** Các chức năng **liên quan chặt chẽ** nên được nhóm lại với nhau.

**Ví dụ SmartSpender:**

- **TransactionService** gộp tất cả logic liên quan transaction:
  - `createTransaction()`, `getTransactions()`, `updateTransaction()`, `deleteTransaction()`
  - Tất cả đều liên quan đến "giao dịch".
- **WalletService** gộp tất cả logic ví:
  - `getWallet()`, `transfer()`, `updateBalance()`.

**Lợi ích:**

- Dễ tìm code: Nếu cần sửa logic transaction, biết chắc nó ở TransactionService.
- Dễ tái sử dụng: TransactionService có thể dùng ở multiple places.
- Dễ test: Mock TransactionService một lần, dùng lại cho nhiều test case.

**Ví dụ ngược (SAI):**

```
UtilService chứa tất cả:
- validateTransaction()
- validateWallet()
- sendEmail()
- logError()
- calculateStatistics()
→ Code rối, khó tìm, khó bảo trì
```

---

## 1.3 So Sánh Các Mô Hình Kiến Trúc (Architecture Styles)

Dưới đây là **bốn mô hình kiến trúc phổ biến**, mỗi mô hình có ưu-nhược điểm khác nhau:

### Mô hình 1: **N-Tier (hay 3-Tier) Architecture**

**Cấu trúc:**

```
┌─────────────────────┐
│ Presentation Tier   │  ← UI (Web browser, mobile app)
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ Business Logic Tier │  ← Controllers, Services
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ Data Tier           │  ← Database (SQL/NoSQL)
└─────────────────────┘
```

**Đặc điểm:**

- Chia thành N lớp (thường 3: Presentation, Business Logic, Data).
- Mỗi lớp có trách nhiệm riêng.
- Giao tiếp giữa lớp theo thứ tự: Presentation → Business → Data.

**Ưu điểm:**

- ✅ Dễ hiểu: Cấu trúc rõ ràng, phù hợp học tập.
- ✅ Dễ phát triển: Chia công việc rõ ràng.
- ✅ Dễ test: Test từng lớp riêng lẻ.
- ✅ Dễ bảo trì: Tìm lỗi nhanh.

**Nhược điểm:**

- ❌ Khó scale ngang (horizontal scaling): Toàn bộ system trong 1 instance.
- ❌ Monolithic: Mỗi thay đổi phải deploy lại cả ứng dụng.
- ❌ Performance: Nếu database chậm, toàn bộ system bị ảnh hưởng.

**Phù hợp với:** Dự án nhỏ-vừa, startup, yêu cầu phát triển nhanh.

---

### Mô hình 2: **Client-Server Architecture**

**Cấu trúc:**

```
┌──────────────┐         ┌──────────────┐
│   CLIENT     │ ◄────►  │    SERVER    │
│ (Request)    │ HTTP/   │ (Response)   │
│              │ REST    │              │
└──────────────┘         └──────────────┘
```

**Đặc điểm:**

- Client gửi request → Server xử lý → Server gửi response về client.
- Server **stateless** (không lưu trạng thái client).
- Giao tiếp qua **REST API** (HTTP methods: GET, POST, PUT, DELETE).

**Ưu điểm:**

- ✅ Stateless: Mỗi request độc lập, dễ scale.
- ✅ Đơn giản: Client và Server tách biệt rõ ràng.
- ✅ Flexible: Client có thể là browser, mobile app, desktop app.

**Nhược điểm:**

- ❌ Network overhead: Phải giao tiếp qua mạng (có latency).
- ❌ Complexity in client logic: Client phải handle state management.

**Phù hợp với:** Web apps, mobile apps, backend APIs.

---

### Mô hình 3: **Event-Driven Architecture**

**Cấu trúc:**

```
┌──────────────┐
│  Component A │ ──[Publish Event]──┐
└──────────────┘                     │
                                      ▼
                          ┌──────────────────┐
                          │  Message Broker  │
                          │ (RabbitMQ/Kafka) │
                          └──────────────────┘
                                      ▲
┌──────────────┐                     │
│  Component B │ ◄──[Subscribe Event]┘
└──────────────┘
```

**Đặc điểm:**

- Các component giao tiếp qua **events** (không trực tiếp gọi nhau).
- Khi A có sự kiện, publish → broker → các component B, C, D subscribe.
- Xử lý **asynchronous** (không phải đợi phản hồi ngay).

**Ưu điểm:**

- ✅ Loose coupling: Component không phụ thuộc trực tiếp.
- ✅ Async processing: Không block, xử lý nền (background).
- ✅ Real-time: Notification, updates real-time.

**Nhược điểm:**

- ❌ Phức tạp: Khó debug, khó trace flow.
- ❌ Consistency: Eventual consistency (dữ liệu có thể không đồng bộ ngay lập tức).
- ❌ Overhead: Cần message broker, infrastructure phức tạp.

**Phù hợp với:** Real-time systems, notification systems, event processing, large-scale systems.

---

### Mô hình 4: **Microservices Architecture**

**Cấu trúc:**

```
┌─────────────────────────────────────────┐
│           API Gateway                   │
└────────┬─────────────┬─────────────┬────┘
         │             │             │
      ┌──▼──┐      ┌───▼───┐      ┌─▼──┐
      │Auth │      │Trans  │      │Wallet
      │μS   │      │μS     │      │μS
      └──┬──┘      └───┬───┘      └─┬──┘
         │             │             │
     ┌───▼──┐      ┌───▼──┐      ┌──▼───┐
     │DB 1  │      │DB 2  │      │DB 3  │
     └──────┘      └──────┘      └───────┘
```

**Đặc điểm:**

- Chia thành nhiều **service nhỏ**, mỗi service độc lập.
- Mỗi service có database riêng (không share DB).
- Giao tiếp qua **REST API hoặc message queue**.

**Ưu điểm:**

- ✅ Independent deployment: Deploy service riêng lẻ.
- ✅ Technology diversity: Mỗi service dùng công nghệ khác nhau.
- ✅ Scalability: Scale từng service theo nhu cầu.

**Nhược điểm:**

- ❌ Rất phức tạp: DevOps, infrastructure, debugging khó.
- ❌ Distributed transaction: Dữ liệu phân tán khó đảm bảo consistency.
- ❌ Network latency: Nhiều service call → tổng latency cao.

**Phù hợp với:** Large-scale systems, multiple teams, Netflix/Amazon-level companies.

---

## 1.4 Bảng So Sánh Nhanh

| Tiêu chí             | N-Tier               | Client-Server | Event-Driven       | Microservices            |
| -------------------- | -------------------- | ------------- | ------------------ | ------------------------ |
| **Độ phức tạp**      | 🟢 Thấp              | 🟢 Thấp       | 🟡 Trung           | 🔴 Cao                   |
| **Khả năng scale**   | 🟡 Trung             | 🟡 Trung      | 🟢 Cao             | 🟢 Cao                   |
| **Dễ bảo trì**       | 🟢 Cao               | 🟢 Cao        | 🟡 Trung           | 🔴 Thấp                  |
| **Time to market**   | 🟢 Nhanh             | 🟢 Nhanh      | 🟡 Vừa             | 🔴 Chậm                  |
| **DevOps Expertise** | 🟢 Thấp              | 🟢 Thấp       | 🟡 Trung           | 🔴 Cao                   |
| **Quy mô phù hợp**   | Startup, < 10k users | < 100k users  | Notification-heavy | 100k+ users, teams nhiều |

---

## 1.5 Lựa Chọn Kiến Trúc cho SmartSpender

### Phân tích Yêu Cầu của SmartSpender

**Bối cảnh dự án:**

- Dự án môn học (6 tháng, 5 thành viên).
- Quy mô: Ứng dụng quản lý chi tiêu cá nhân.
- Người dùng dự kiến: Lớp học, có thể extend 1-2k users tối đa.
- Deadline: Cần phát triển nhanh.

**Yêu cầu:**

1. **Phát triển nhanh**: Ưu tiên time to market.
2. **Dễ hiểu**: Team nhỏ, cần cấu trúc rõ ràng.
3. **Dễ bảo trì**: Có thể sửa lỗi, thêm tính năng nhanh.
4. **Flexible**: Có thể thêm tính năng (notification, statistics, wallet transfer).
5. **Quy mô vừa**: Dự kiến 1-2k users trong 1 năm, sau đó có thể mở rộng.

### Quyết Định Lựa Chọn

**SmartSpender áp dụng: N-Tier Architecture kết hợp Client-Server REST**

**Tại sao chọn cách này:**

✅ **N-Tier vì:**

- Dễ hiểu, dễ phát triển → Phù hợp dự án học phần.
- Cấu trúc rõ ràng: Presentation (Flutter) - Business Logic (Express) - Data (MongoDB).
- Dễ phân công: Backend team xử lý Business Logic, Mobile team xử lý UI.
- Dễ test: Test từng lớp riêng lẻ.

✅ **Client-Server REST vì:**

- Stateless → Dễ scale khi user tăng.
- Standard API → Có thể extend thêm client (Web, Desktop) sau.
- Flexible: Client (Flutter mobile/web) độc lập, backend độc lập.

❌ **Không chọn Event-Driven vì:**

- Phức tạp quá so với quy mô dự án.
- Chưa cần async processing (hiện tại).
- Infrastructure cần RabbitMQ/Kafka thêm.

❌ **Không chọn Microservices vì:**

- Quá phức tạp cho 5 thành viên, deadline ngắn.
- DevOps overhead (Kubernetes, Docker, service discovery).
- Overkill cho quy mô này.

---

## 1.6 Kết Luận Chương

**N-Tier Architecture + Client-Server REST** là lựa chọn tối ưu cho SmartSpender vì:

1. **Cân bằng giữa độ phức tạp và khả năng**: Đủ mạnh cho tính năng cần thiết, không phức tạp quá.
2. **Dễ phát triển**: Chia công việc rõ ràng, dễ quản lý.
3. **Dễ bảo trì**: Cấu trúc rõ ràng, dễ fix bug, dễ thêm tính năng.
4. **Khả năng mở rộng**: Khi user tăng, có roadmap upgrade sang Strangler Pattern (tách service), rồi Microservices.
5. **Phù hợp deadline**: Có thể phát triển nhanh trong 6 tháng.

**Các chương tiếp theo sẽ chi tiết:**

- Chương 2: Cấu trúc N-Tier 3-Tier của SmartSpender.
- Chương 3: Cơ chế Client-Server REST, JWT, Middleware.
- Chương 4-5: Design Patterns, Component Architecture.
- Chương 6: Lộ trình upgrade nếu cần.

---

## **HƯỚNG DẪN VIẾT CHƯƠNG 1 (Cho thành viên)**

**Độ dài:** 1.5-2 trang A4 (Times New Roman 12pt, 1.5 spacing).

**Cấu trúc bắt buộc:**

- 1.1 Khái niệm ISA (định nghĩa 3-4 câu)
- 1.2 Ba nguyên tắc (SoC, Loose Coupling, High Cohesion - mỗi cái 1 đoạn)
- 1.3 So sánh 4 mô hình (N-Tier, Client-Server, Event-Driven, Microservices - bảng + tóm tắt)
- 1.4 Bảng so sánh
- 1.5 Lựa chọn cho SmartSpender (vì sao chọn, vì sao không chọn)
- 1.6 Kết luận chương (2-3 dòng)

**Sơ đồ bắt buộc:**

- Diagram 1.1: N-Tier 3 lớp (optional - có thể dùng bảng thay).
- Diagram 1.2: Client-Server flow.

**Tài liệu tham khảo:**

- Giáo trình ISA của ĐHGTVT.
- Bass, L. et al. (2012). Software Architecture in Practice.
- Newman, S. (2015). Building Microservices.

---
