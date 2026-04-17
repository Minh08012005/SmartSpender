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

Ba nguyên tắc dưới đây là cơ sở để đánh giá một kiến trúc có được tổ chức hợp lý hay không. Đối với SmartSpender, các nguyên tắc này được thể hiện trực tiếp trong cách phân tách các lớp và module chức năng.

### 1.2.1. Separation of Concerns (Tách biệt trách nhiệm)

Nguyên tắc này yêu cầu mỗi thành phần chỉ đảm nhiệm một nhóm trách nhiệm rõ ràng. Việc tách biệt đúng giúp hệ thống tránh tình trạng trộn lẫn giữa xử lý giao diện, xử lý nghiệp vụ và xử lý dữ liệu.

Trong SmartSpender, lớp controller chủ yếu tiếp nhận request và trả response; lớp service xử lý quy tắc nghiệp vụ; lớp model quản lý cấu trúc và ràng buộc dữ liệu. Cách tổ chức này giúp luồng xử lý mạch lạc, dễ theo dõi khi phát sinh lỗi.

Ý nghĩa thực tiễn của nguyên tắc này là tăng khả năng bảo trì và kiểm thử. Khi cần thay đổi logic nghiệp vụ, nhóm có thể tập trung sửa tại service mà không ảnh hưởng mạnh tới các lớp còn lại.

### 1.2.2. Loose Coupling (Liên kết lỏng)

Nguyên tắc liên kết lỏng nhấn mạnh việc giảm phụ thuộc trực tiếp giữa các thành phần. Các tầng nên giao tiếp thông qua hợp đồng rõ ràng để có thể thay đổi nội bộ mà không làm đứt gãy toàn hệ thống.

Trong SmartSpender, frontend Flutter giao tiếp với backend thông qua REST API và dữ liệu JSON. Điều này giúp phần giao diện không phụ thuộc vào cách backend tổ chức database, đồng thời backend cũng không phụ thuộc vào công nghệ hiển thị ở phía client.

Nhờ đó, hệ thống có tính linh hoạt cao hơn khi mở rộng nền tảng hoặc thay đổi công nghệ ở từng tầng. Đây cũng là tiền đề quan trọng để nâng cấp kiến trúc ở các giai đoạn sau.

### 1.2.3. High Cohesion (Gắn kết cao)

Nguyên tắc gắn kết cao yêu cầu mỗi module tập trung vào một miền chức năng thống nhất. Các hàm trong cùng module cần liên quan chặt chẽ với nhau để bảo đảm tính mạch lạc của mã nguồn.

Trong SmartSpender, các nghiệp vụ liên quan giao dịch được gom trong TransactionService; các nghiệp vụ ví được gom trong WalletService; các xử lý thống kê được tập trung tại StatisticService. Cách tổ chức này giúp xác định nhanh vị trí cần chỉnh sửa khi có yêu cầu mới.

Gắn kết cao làm giảm độ phân tán của nghiệp vụ, tăng khả năng tái sử dụng module và cải thiện chất lượng kiểm thử. Đây là yếu tố quan trọng để duy trì chất lượng kiến trúc khi hệ thống mở rộng.

### 1.2.4. Tiểu kết

Separation of Concerns, Loose Coupling và High Cohesion là ba nguyên tắc nền tảng giúp SmartSpender giữ được cấu trúc rõ ràng, dễ phát triển và thuận lợi cho mở rộng. Trên cơ sở đó, mục tiếp theo sẽ so sánh các mô hình kiến trúc để làm rõ lựa chọn N-Tier kết hợp Client-Server cho hệ thống.

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
