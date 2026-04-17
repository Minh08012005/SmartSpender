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

Phần này tóm tắt bốn mô hình kiến trúc thường gặp để làm cơ sở lựa chọn cho SmartSpender.

### 1.3.1. N-Tier Architecture

N-Tier chia hệ thống thành các lớp chức năng như giao diện, nghiệp vụ và dữ liệu. Mô hình này dễ tổ chức công việc, dễ kiểm thử và phù hợp với dự án quy mô nhỏ đến vừa. Hạn chế chính là khó mở rộng độc lập từng chức năng khi hệ thống tăng trưởng mạnh.

### 1.3.2. Client-Server Architecture

Client-Server tổ chức theo cơ chế client gửi yêu cầu, server xử lý và phản hồi, thường thông qua REST API. Mô hình này rõ ràng về vai trò và phù hợp đa nền tảng. Tuy nhiên, hiệu năng phụ thuộc vào chất lượng mạng và năng lực xử lý tập trung ở phía server.

### 1.3.3. Event-Driven Architecture

Event-Driven cho phép các thành phần giao tiếp qua sự kiện thông qua broker. Điểm mạnh là liên kết lỏng và hỗ trợ xử lý bất đồng bộ. Điểm yếu là tăng độ phức tạp trong giám sát, truy vết lỗi và kiểm soát tính nhất quán dữ liệu.

### 1.3.4. Microservices Architecture

Microservices tách hệ thống thành nhiều dịch vụ độc lập theo miền nghiệp vụ. Mô hình này có khả năng mở rộng cao và hỗ trợ triển khai độc lập theo từng dịch vụ. Đổi lại, yêu cầu năng lực vận hành cao và chi phí quản trị hệ thống lớn hơn.

---

## 1.4 Bảng So Sánh Nhanh

| Tiêu chí                              | N-Tier     | Client-Server | Event-Driven | Microservices     |
| ------------------------------------- | ---------- | ------------- | ------------ | ----------------- |
| Độ phức tạp triển khai                | Thấp       | Thấp          | Trung bình   | Cao               |
| Khả năng mở rộng                      | Trung bình | Trung bình    | Cao          | Cao               |
| Khả năng bảo trì                      | Cao        | Cao           | Trung bình   | Trung bình - Thấp |
| Tốc độ phát triển ban đầu             | Nhanh      | Nhanh         | Vừa          | Chậm              |
| Yêu cầu vận hành                      | Thấp       | Thấp          | Trung bình   | Cao               |
| Mức phù hợp với SmartSpender hiện tại | Cao        | Cao           | Thấp         | Thấp              |

---

## 1.5 Lựa Chọn Kiến Trúc cho SmartSpender

### 1.5.1. Bối cảnh và tiêu chí lựa chọn

SmartSpender là dự án học phần với thời gian triển khai giới hạn, quy mô nhóm nhỏ và yêu cầu phát triển nhanh các nghiệp vụ cốt lõi. Vì vậy, kiến trúc được ưu tiên theo các tiêu chí: dễ triển khai, dễ hiểu, dễ bảo trì và có khả năng mở rộng theo từng giai đoạn.

### 1.5.2. Quyết định kiến trúc

Nhóm lựa chọn hướng N-Tier kết hợp Client-Server REST. N-Tier giúp phân lớp rõ ràng giữa giao diện, nghiệp vụ và dữ liệu; Client-Server giúp chuẩn hóa giao tiếp giữa mobile/web với backend thông qua API stateless. Cách lựa chọn này phù hợp với phạm vi hiện tại của dự án và vẫn giữ dư địa nâng cấp trong tương lai.

Event-Driven và Microservices không được chọn ở giai đoạn này do tăng độ phức tạp triển khai, đòi hỏi hạ tầng vận hành cao hơn và chưa phù hợp với quy mô thực tế của hệ thống.

---

## 1.6 Kết Luận Chương

Chương 1 đã làm rõ nền tảng lý thuyết kiến trúc, ba nguyên tắc cốt lõi và cơ sở lựa chọn mô hình cho SmartSpender. Từ các phân tích trên, hướng N-Tier kết hợp Client-Server REST là phù hợp nhất với yêu cầu hiện tại về tiến độ, khả năng bảo trì và mức độ mở rộng. Các chương tiếp theo sẽ phân tích sâu kiến trúc triển khai thực tế, luồng xử lý nghiệp vụ và định hướng tiến hóa của hệ thống.
