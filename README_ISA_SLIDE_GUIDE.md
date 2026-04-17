# Hướng Dẫn Làm Slide ISA - SmartSpender

Tài liệu này dùng để thiết kế bộ slide thuyết trình cho môn Kiến trúc Hệ thống Thông tin, dựa trên dự án SmartSpender của nhóm.

Mục tiêu là giúp người trình bày làm slide nhanh, đúng trọng tâm môn học, dễ nói, không lan man, và có đủ sơ đồ minh họa cần thiết.

---

## 1. Mục tiêu của bộ slide

- Trình bày được SmartSpender dưới góc nhìn kiến trúc hệ thống, không đi sâu vào code.
- Giải thích được hệ thống đang áp dụng kiến trúc nào, vì sao phù hợp, và có thể phát triển ra sao.
- Bám vào các khái niệm đã học trong học phần: tổng quan kiến trúc, 3-Tier, Client-Server, REST, Event-Driven, SOA, Microservices.
- Có đủ sơ đồ để người nghe nhìn là hiểu luồng hệ thống.

---

## 2. Cách tổ chức luồng slide

Để slide dễ theo dõi và đúng chất trình bày học thuật, nên đi theo **5-6 mục lớn** thay vì liệt kê rời rạc từng slide. Sau trang bìa và phần giới thiệu thành viên, cần có một slide riêng kiểu **agenda / dàn ý** để báo trước toàn bộ mạch trình bày.

### 2.1. 6 mục lớn nên dùng

1. **Mở đầu và định hướng bài trình bày**
2. **Tổng quan kiến trúc và vị trí của SmartSpender**
3. **Kiến trúc 3 lớp của hệ thống**
4. **Cơ chế giao tiếp và bảo mật**
5. **Cấu trúc thành phần và luồng nghiệp vụ**
6. **Đánh giá kiến trúc và hướng mở rộng**

### 2.2. Mạch đi nên trình bày

- Bắt đầu từ mục tiêu và phạm vi.
- Đi vào kiến thức nền tảng đã học.
- Chốt SmartSpender đang thuộc kiến trúc nào.
- Sau đó giải thích từng lớp và cơ chế giao tiếp.
- Tiếp theo minh họa bằng luồng thực tế.
- Cuối cùng đánh giá chất lượng và định hướng mở rộng.

### 2.3. Lý do nên làm như vậy

- Người nghe dễ nắm bố cục ngay từ đầu.
- Người trình bày không bị nhảy ý.
- Nội dung đi từ tổng quan đến chi tiết, đúng phong cách của môn ISA.

---

## 3. Nguyên tắc trình bày slide

### 2.1. Cách viết nội dung

- Mỗi slide chỉ nên có 1 ý chính.
- Câu trên slide nên ngắn, rõ, có từ khóa.
- Không đưa nguyên đoạn văn dài lên slide.
- Mỗi gạch đầu dòng nên gói trong 1 dòng hoặc tối đa 2 dòng.
- Phần giải thích chi tiết để người thuyết trình nói miệng.

### 2.2. Cách bố cục

- Nếu slide có nhiều chữ: chia 2 cột, trái là ý chính, phải là hình.
- Nếu slide thiên về kiến trúc: để sơ đồ ở giữa, chữ ngắn ở bên dưới.
- Nếu slide là sequence diagram: để sơ đồ chiếm phần lớn diện tích.
- Mỗi slide nên có một câu chốt cuối slide để người nghe nhớ ý chính.

### 2.3. Cách dùng hình ảnh và biểu đồ

- Dùng sơ đồ 3-Tier để nói về kiến trúc tổng thể.
- Dùng sơ đồ REST / Client-Server để nói về giao tiếp giữa client và server.
- Dùng sơ đồ JWT flow để giải thích xác thực.
- Dùng middleware pipeline để giải thích xử lý request.
- Dùng sequence diagram cho các luồng login và tạo giao dịch.
- Dùng roadmap / evolution diagram để nói về hướng mở rộng.

### 2.4. Mức chữ nên giữ trên slide

- Tiêu đề: 1 dòng.
- Ý chính: 3 đến 5 gạch đầu dòng.
- Bảng: tối đa 5 đến 7 dòng ngắn.
- Mỗi hình nên có chú thích rất ngắn.

---

## 4. Khung tổng thể 16 slide theo 6 mục lớn

> Bản này đã được chốt theo **16 slide** bằng cách gộp phần agenda với mục tiêu/phạm vi ở đầu bài.

### Mục 1. Mở đầu và định hướng

1. Trang bìa
2. Mục lục / agenda + mục tiêu và phạm vi trình bày

### Mục 2. Tổng quan kiến trúc và vị trí của SmartSpender

3. Tổng quan 6 kiến trúc trong học phần
4. SmartSpender đang áp dụng kiến trúc nào

### Mục 3. Kiến trúc 3 lớp của hệ thống

5. Mô hình 3 lớp của SmartSpender
6. Lớp Presentation
7. Lớp Application
8. Lớp Data

### Mục 4. Cơ chế giao tiếp và bảo mật

9. Client-Server và REST API
10. JWT Authentication
11. Middleware Pipeline

### Mục 5. Cấu trúc thành phần và luồng nghiệp vụ

12. Component Architecture và Design Patterns
13. Sequence Diagram: User Login
14. Sequence Diagram: Create Transaction

### Mục 6. Đánh giá và mở rộng

15. Đánh giá kiến trúc theo tiêu chí ISA
16. Hướng mở rộng và kết luận

---

## 5. Hướng dẫn làm slide mục lục / agenda

Slide này nên xuất hiện ngay sau trang bìa và phần giới thiệu thành viên. Đây là slide giúp người nghe biết ngay bài sẽ đi theo mạch nào.

### Nội dung nên đặt trên slide

- Mở đầu và định hướng
- Tổng quan kiến trúc và vị trí của SmartSpender
- Kiến trúc 3 lớp của hệ thống
- Cơ chế giao tiếp và bảo mật
- Cấu trúc thành phần và luồng nghiệp vụ
- Đánh giá và hướng mở rộng

**Phần mục tiêu/phạm vi ngắn nên gắn ngay bên dưới agenda:**

- Phân tích kiến trúc SmartSpender theo ISA.
- Đối chiếu hệ thống với kiến thức đã học.
- Làm rõ tổ chức lớp, request, bảo mật và lưu trữ.
- Không đi sâu vào code.

### Bố cục gợi ý

- Bên trái: tiêu đề “Nội dung trình bày”.
- Bên phải: 5-6 khối mục lớn, sắp theo thứ tự trình bày.
- Dùng mũi tên hoặc line nhỏ để thể hiện luồng đi từ trên xuống dưới.

### Cách diễn giải khi thuyết trình

- Nói ngắn: “Sau đây nhóm em sẽ trình bày theo 6 phần chính. Trình tự đi từ giới thiệu, kiến trúc tổng quan, mô hình 3 lớp, cơ chế giao tiếp, luồng nghiệp vụ, rồi kết luận và mở rộng.”

---

## 6. Hướng dẫn chi tiết từng slide

### Slide 1. Trang bìa

**Mục tiêu:** Giới thiệu đề tài và tạo ấn tượng ban đầu.

**Nội dung trên slide:**

- Tên đề tài: Phân tích Kiến trúc Hệ thống Thông tin ứng dụng SmartSpender.
- Môn học: Kiến trúc các Hệ thống Thông tin.
- Tên nhóm, tên giảng viên, tên thành viên.
- Một câu ngắn thể hiện trọng tâm, ví dụ: “Từ kiến trúc nền tảng đến luồng vận hành thực tế của SmartSpender”.

**Bố cục gợi ý:**

- Bên trái: tiêu đề lớn.
- Bên phải: ảnh app, mockup điện thoại, hoặc icon tài chính.
- Dưới cùng: thông tin nhóm.

**Biểu đồ / hình nên chèn:**

- Ảnh giao diện SmartSpender hoặc ảnh minh họa quản lý chi tiêu.
- Logo nhóm hoặc logo dự án nếu có.

**Cách diễn giải khi thuyết trình:**

- Mở đầu ngắn gọn: “Nhóm em sẽ trình bày SmartSpender dưới góc nhìn kiến trúc hệ thống, tập trung vào cách tổ chức, giao tiếp và mở rộng của hệ thống.”

---

### Slide 2. Mục lục / Agenda

**Mục tiêu:** Cho người nghe thấy ngay cấu trúc bài trình bày và các mục lớn sẽ đi qua.

**Nội dung trên slide:**

- Mở đầu và định hướng.
- Tổng quan kiến trúc và vị trí của SmartSpender.
- Kiến trúc 3 lớp của hệ thống.
- Cơ chế giao tiếp và bảo mật.
- Cấu trúc thành phần và luồng nghiệp vụ.
- Đánh giá và hướng mở rộng.

**Bố cục gợi ý:**

- Bên trái: tiêu đề lớn “Nội dung trình bày”.
- Bên phải: 5-6 mục chính, dạng card hoặc timeline.
- Nên thể hiện thứ tự từ trên xuống dưới hoặc trái sang phải.

**Biểu đồ / hình nên chèn:**

- Dùng timeline ngang hoặc cột dọc có icon nhỏ cho từng mục.

**Cách diễn giải khi thuyết trình:**

- Có thể nói: “Để dễ theo dõi, nhóm em xin trình bày theo 6 mục chính. Mạch nội dung đi từ tổng quan đến chi tiết, rồi kết thúc bằng đánh giá và định hướng mở rộng.”

---

### Slide 3. Tổng quan 6 kiến trúc trong học phần

**Mục tiêu:** Chứng minh người trình bày nắm được nền tảng lý thuyết của môn học.

**Nội dung trên slide:**

- Kiến trúc tổng quan hệ thống thông tin: nhìn hệ thống như một tổng thể có thành phần và quan hệ.
- N-Tier / 3-Tier: chia hệ thống thành nhiều lớp rõ ràng.
- Client-Server / REST: client gửi yêu cầu, server xử lý và trả phản hồi.
- Event-Driven: giao tiếp qua sự kiện thay vì gọi trực tiếp.
- SOA: tổ chức thành các dịch vụ có thể tái sử dụng.
- Microservices: tách thành các dịch vụ nhỏ, độc lập.

**Bố cục gợi ý:**

- Dùng 6 card hoặc 6 ô.
- Mỗi ô có tên kiến trúc, 1 câu mô tả ngắn, 1 dòng liên hệ SmartSpender.

**Biểu đồ / hình nên chèn:**

- Sơ đồ 6 ô hoặc sơ đồ so sánh ngang giữa các kiến trúc.

**Cách diễn giải khi thuyết trình:**

- Nói ngắn: “Đây là các kiến trúc đã học trong học phần. Trong SmartSpender, nhóm em chủ yếu áp dụng 3-Tier và Client-Server REST, còn các kiến trúc khác được dùng để so sánh và định hướng mở rộng.”

---

### Slide 4. SmartSpender đang áp dụng kiến trúc nào

**Mục tiêu:** Chốt rõ mô hình kiến trúc chính của hệ thống.

**Nội dung ngắn gọn trên slide:**

- 3-Tier + Client-Server REST
- Frontend: Presentation
- Backend: Application Logic
- Database: MongoDB

**Bố cục gợi ý:**

- Bên trái (25%): 4 gạch đầu dòng chính.
- Bên phải (75%): sơ đồ 3-Tier lớn, rõ ràng, có mũi tên flow.

**Biểu đồ / hình nên chèn:**

- Sơ đồ 3-Tier lớn, có mũi tên từ client → server → database.

**Cách diễn giải khi thuyết trình:**

- "3-Tier phù hợp vì tách trách nhiệm rõ, dễ bảo trì, dễ test, và vừa với quy mô nhóm."

---

### Slide 5. Mô hình 3 lớp của SmartSpender

**Mục tiêu:** Giải thích chi tiết ba lớp kiến trúc.

**Nội dung trên slide:**

- Presentation Layer: giao diện người dùng, nhận input, hiển thị dữ liệu.
- Application Layer: xử lý logic nghiệp vụ, điều phối request, kiểm tra dữ liệu.
- Data Layer: lưu trữ, truy vấn và đảm bảo toàn vẹn dữ liệu.

**Bố cục gợi ý:**

- Trình bày theo chiều dọc 3 tầng.
- Mỗi tầng gồm tên, nhiệm vụ, công nghệ tiêu biểu.

**Biểu đồ / hình nên chèn:**

- Sơ đồ stack 3 tầng.

**Cách diễn giải khi thuyết trình:**

- Nhấn mạnh: “Mỗi lớp có nhiệm vụ riêng, nhờ vậy hệ thống không bị trộn lẫn giữa giao diện, nghiệp vụ và dữ liệu.”

---

### Slide 6. Lớp Presentation

**Mục tiêu:** Mô tả phần client của hệ thống.

**Nội dung trên slide:**

- Hiển thị giao diện cho người dùng.
- Nhận dữ liệu nhập từ người dùng.
- Gọi API đến backend.
- Quản lý trạng thái bằng Provider.
- Công nghệ chính: Flutter, Provider, Dio.

**Bố cục gợi ý:**

- Bên trái: chức năng.
- Bên phải: thành phần chính.
- Dưới cùng: ví dụ màn hình thực tế.

**Biểu đồ / hình nên chèn:**

- Sơ đồ: User → UI → Provider → ApiService → Server.
- Nếu có, thêm ảnh màn hình LoginScreen hoặc HomeScreen.

**Cách diễn giải khi thuyết trình:**

- Có thể nói: “Lớp Presentation chỉ tập trung vào tương tác và hiển thị, không xử lý nghiệp vụ nặng để đảm bảo giao diện nhẹ và dễ bảo trì.”

---

### Slide 7. Lớp Application

**Mục tiêu:** Giải thích nơi xử lý logic chính của backend.

**Nội dung trên slide:**

- Nhận request từ client.
- Xác thực và kiểm tra dữ liệu.
- Xử lý nghiệp vụ của từng chức năng.
- Gọi model để tương tác với cơ sở dữ liệu.
- Công nghệ chính: Express.js, Controller, Service, Middleware.

**Bố cục gợi ý:**

- Trình bày theo luồng request.
- Có thể dùng các khối: Routes → Middleware → Controller → Service → Model.

**Biểu đồ / hình nên chèn:**

- Sơ đồ luồng xử lý request của backend.

**Cách diễn giải khi thuyết trình:**

- Nói rằng đây là tầng “đầu não nghiệp vụ”, nơi hệ thống kiểm tra đúng sai, xử lý logic, rồi mới gọi tới dữ liệu.

---

### Slide 8. Lớp Data

**Mục tiêu:** Trình bày cách hệ thống lưu trữ dữ liệu.

**Nội dung trên slide:**

- Sử dụng MongoDB Atlas làm cơ sở dữ liệu.
- Mongoose hỗ trợ schema và validation.
- Các collection chính: users, transactions, wallets, walletTransfers.
- Dữ liệu được lưu theo document, phù hợp dữ liệu linh hoạt.

**Bố cục gợi ý:**

- Bên trái: vai trò của lớp dữ liệu.
- Bên phải: sơ đồ các collection và quan hệ.

**Biểu đồ / hình nên chèn:**

- Sơ đồ 4 collection với mũi tên quan hệ từ user đến transaction và wallet.

**Cách diễn giải khi thuyết trình:**

- Nhấn mạnh: “Cách lưu trữ này phù hợp với ứng dụng quản lý chi tiêu vì dữ liệu có thể thay đổi linh hoạt theo nhu cầu người dùng.”

---

### Slide 9. Client-Server và REST API

**Mục tiêu:** Làm rõ cách client và server trao đổi với nhau.

**Nội dung trên slide:**

- Client gửi request, server xử lý và trả response.
- REST dùng tài nguyên theo URL.
- Mỗi request độc lập, server không giữ session.
- Dữ liệu truyền qua JSON.
- Các phương thức chính: GET, POST, PUT/PATCH, DELETE.

**Bố cục gợi ý:**

- Chia 2 phần.
- Một bên là nguyên tắc REST.
- Một bên là bảng endpoint tiêu biểu.

**Biểu đồ / hình nên chèn:**

- Sơ đồ request-response.
- Bảng 4 đến 6 API tiêu biểu.

**Cách diễn giải khi thuyết trình:**

- Có thể nói: “REST giúp hệ thống giao tiếp chuẩn hóa, dễ mở rộng và phù hợp cả mobile lẫn web.”

---

### Slide 10. JWT Authentication

**Mục tiêu:** Giải thích cơ chế xác thực và bảo mật truy cập.

**Nội dung trên slide:**

- Người dùng đăng nhập bằng email và mật khẩu.
- Server xác thực và tạo JWT.
- Client lưu token sau khi đăng nhập.
- Request sau đó gửi token trong header Authorization.
- Server kiểm tra token trước khi cho phép truy cập.

**Bố cục gợi ý:**

- Bên trái: quy trình.
- Bên phải: cấu trúc token.

**Biểu đồ / hình nên chèn:**

- JWT flow: Login → Generate Token → Store Token → Verify Token → Allow Access.

**Cách diễn giải khi thuyết trình:**

- Nên nhấn: “JWT giúp hệ thống xác thực an toàn, nhẹ, và không cần lưu session ở server.”

---

### Slide 11. Middleware Pipeline

**Mục tiêu:** Cho thấy request được kiểm tra như thế nào trước khi vào logic chính.

**Nội dung ngắn gọn trên slide:**

- CORS check
- JWT verify
- Input validation
- Rate limiting
- Error handling

**Bố cục gợi ý:**

- Bên trái (25%): 5 gạch chính.
- Bên phải (75%): sơ đồ pipeline ngang: Request → CORS → JWT → Validate → RateLimit → Controller → ErrorHandler.

**Biểu đồ / hình nên chèn:**

- Pipeline ngang: Request → CORS → JWT → Validate → RateLimit → Controller → Error Handler.

**Cách diễn giải khi thuyết trình:**

- "Middleware tuần tự kiểm soát: CORS, JWT, validate, rate limit, rồi xử lý. Dễ bảo trì."

---

### Slide 12. Component Architecture và Design Patterns

**Mục tiêu:** Chứng minh hệ thống được chia module rõ ràng và có pattern phù hợp.

**Nội dung ngắn gọn trên slide:**

- Backend: Auth, Transaction, Wallet, Statistic
- Mobile: AuthModule, TransactionModule, WalletModule, Shared
- Pattern: MVC, Repository, Provider, DI

**Bố cục gợi ý:**

- Bên trái (25%): tiêu đề + 3 gạch.
- Bên phải (75%): sơ đồ component 2 khối Backend/Mobile, hoặc 2 cột song song.

**Biểu đồ / hình nên chèn:**

- Sơ đồ component architecture Backend + Mobile.

**Cách diễn giải khi thuyết trình:**

- "Component chia rõ, pattern chuẩn → dễ phân công, dễ test, giảm phụ thuộc."

---

### Slide 13. Sequence Diagram: User Login

**Mục tiêu:** Minh họa một luồng thực tế từ giao diện đến cơ sở dữ liệu.

**Nội dung trên slide:**

- User nhập email và mật khẩu.
- Client kiểm tra dữ liệu sơ bộ.
- Gửi request đăng nhập đến server.
- Server xác thực user và password.
- Tạo JWT và trả về client.
- Client lưu token và chuyển sang màn hình chính.

**Bố cục gợi ý:**

- Sơ đồ tuần tự chiếm phần lớn slide.
- Phần dưới là 3 ghi chú ngắn về bảo mật.

**Biểu đồ / hình nên chèn:**

- Sequence diagram với 4 đối tượng: User, App, Backend, Database.

**Cách diễn giải khi thuyết trình:**

- Nói ngắn gọn: “Luồng login thể hiện rõ hệ thống stateless, có kiểm tra mật khẩu bằng bcrypt và cấp token JWT sau khi xác thực thành công.”

---

### Slide 14. Sequence Diagram: Create Transaction

**Mục tiêu:** Minh họa luồng nghiệp vụ tiêu biểu nhất của SmartSpender.

**Nội dung trên slide:**

- User nhập thông tin giao dịch.
- Client kiểm tra dữ liệu đầu vào.
- Gửi POST request đến server.
- Middleware xác thực và validate.
- Service xử lý logic và lưu dữ liệu.
- Nếu là chi tiêu, cập nhật số dư ví.
- Trả kết quả về UI.

**Bố cục gợi ý:**

- Sơ đồ tuần tự ở trung tâm.
- Một khung nhỏ bên cạnh ghi điều kiện nghiệp vụ.

**Biểu đồ / hình nên chèn:**

- Sequence diagram create transaction.
- Nếu được, ghi rõ bước update wallet balance.

**Cách diễn giải khi thuyết trình:**

- Có thể nói: “Luồng này cho thấy hệ thống không chỉ lưu giao dịch mà còn xử lý đúng logic chi tiêu, đặc biệt là cập nhật ví để đảm bảo dữ liệu nhất quán.”

---

### Slide 15. Đánh giá kiến trúc theo tiêu chí ISA

**Mục tiêu:** Đánh giá chất lượng kiến trúc một cách có hệ thống.

**Nội dung trên slide:**

- Scalability: trung bình.
- Reliability: khá.
- Maintainability: cao.
- Security: khá cao.
- Performance: trung bình.
- Interoperability: tốt.

**Bố cục gợi ý:**

- Bên trái: bảng 6 tiêu chí.
- Bên phải: nhận xét ngắn cho từng tiêu chí.

**Biểu đồ / hình nên chèn:**

- Bảng đánh giá hoặc heatmap đơn giản.

**Cách diễn giải khi thuyết trình:**

- Nêu rõ điểm mạnh và điểm cần cải thiện.
- Ví dụ: “Kiến trúc hiện tại mạnh ở tính dễ bảo trì và bảo mật cơ bản, nhưng khi người dùng tăng cao thì cần bổ sung cache, load balancing hoặc tách dịch vụ.”

---

### Slide 16. Hướng mở rộng và kết luận

**Mục tiêu:** Chốt lại toàn bộ bài bằng kiến trúc hiện tại và lộ trình phát triển.

**Nội dung trên slide:**

- Hiện tại: 3-Tier monolithic phù hợp quy mô nhóm.
- Giai đoạn tiếp theo: có thể thêm cache, gateway, monitoring.
- Xa hơn: có thể tiến tới Event-Driven hoặc Microservices nếu hệ thống lớn hơn.
- Kết luận: kiến trúc hiện tại phù hợp, dễ triển khai và có lộ trình nâng cấp rõ ràng.

**Bố cục gợi ý:**

- Bên trái: kết luận hiện tại.
- Bên phải: roadmap phát triển.

**Biểu đồ / hình nên chèn:**

- Sơ đồ tiến hóa: hiện tại → tối ưu hạ tầng → tách dịch vụ → event-driven.

**Cách diễn giải khi thuyết trình:**

- Kết lại bằng ý: “SmartSpender hiện tại phù hợp với quy mô học phần, và nếu hệ thống phát triển lớn hơn thì hoàn toàn có thể nâng cấp theo lộ trình kiến trúc đã nêu.”

---

## 5. Gợi ý bố cục chung cho toàn bộ slide

### 5.1. Màu sắc

- Chọn 1 màu chủ đạo xuyên suốt.
- Dùng 1 màu nhấn cho từ khóa hoặc tiêu đề phụ.
- Tránh quá nhiều màu khác nhau trên cùng một slide.

### 5.2. Font và kích thước

- Tiêu đề lớn, dễ đọc.
- Nội dung ngắn, không dùng font quá nhỏ.
- Không để một slide quá dày chữ.

### 5.3. Cách dùng icon và sơ đồ

- Dùng icon đơn giản, đồng bộ.
- Dùng sơ đồ lớn thay vì nhiều hình nhỏ rời rạc.
- Nếu có bảng, chỉ nên để bảng ngắn, rõ.

### 5.4. Tỷ lệ chữ và hình

- Với slide lý thuyết: chữ 40%, hình 60%.
- Với slide sequence: hình 70%, chữ 30%.
- Với slide đánh giá: bảng 50%, nhận xét 50%.

---

## 6. Mẫu lời dẫn thuyết trình ngắn

Người trình bày có thể dựa vào các mẫu này để nói dễ hơn, không bị đọc slide:

- “Slide này cho thấy SmartSpender đang được tổ chức theo kiến trúc 3-Tier, tức là chia rõ giao diện, xử lý nghiệp vụ và dữ liệu.”
- “Ở đây nhóm em dùng REST để client và server trao đổi với nhau qua request/response, nên hệ thống phù hợp cho cả mobile lẫn web.”
- “JWT giúp hệ thống xác thực stateless, tức là server không cần giữ session người dùng.”
- “Middleware là lớp kiểm tra trung gian, giúp tách riêng phần xác thực, validate và giới hạn request trước khi vào logic chính.”
- “Hai sequence diagram này cho thấy hệ thống vận hành thực tế như thế nào từ lúc người dùng thao tác cho đến khi dữ liệu được lưu.”

### 6.1. Mẫu lời dẫn chi tiết theo 16 slide (dễ nói hơn)

> Mẹo dùng nhanh: mỗi slide nói 35-60 giây, theo cấu trúc 3 bước: mở ý -> giải thích ngắn -> chốt ý.

**Slide 1 - Trang bìa**

“Nhóm em xin trình bày đề tài phân tích kiến trúc hệ thống thông tin của ứng dụng SmartSpender. Trọng tâm của bài là cách hệ thống được tổ chức thành các lớp, cách các thành phần giao tiếp, và hướng mở rộng trong tương lai. Trong phần trình bày này, nhóm em tập trung vào góc nhìn kiến trúc, không đi sâu vào chi tiết code.”

**Slide 2 - Agenda**

“Để dễ theo dõi, nhóm em chia bài thành 6 phần chính. Đầu tiên là định hướng và vị trí của SmartSpender trong các kiến trúc đã học. Sau đó nhóm em đi vào mô hình 3 lớp, cơ chế giao tiếp và bảo mật, rồi minh họa bằng luồng nghiệp vụ thực tế trước khi kết luận và đề xuất hướng mở rộng.”

**Slide 3 - Tổng quan 6 kiến trúc**

“Ở học phần ISA, chúng ta có các cách tiếp cận như 3-Tier, Client-Server REST, Event-Driven, SOA và Microservices. Mỗi mô hình có điểm mạnh riêng theo quy mô và mục tiêu hệ thống. Với SmartSpender, nhóm em chọn kiến trúc đơn giản nhưng rõ trách nhiệm để phù hợp giai đoạn phát triển hiện tại.”

**Slide 4 - SmartSpender áp dụng kiến trúc nào**

“Kiến trúc chính mà SmartSpender đang dùng là 3-Tier kết hợp Client-Server REST. Frontend đảm nhiệm tương tác người dùng, backend xử lý nghiệp vụ, và MongoDB đảm nhiệm lưu trữ dữ liệu. Cách tách này giúp hệ thống dễ bảo trì, dễ phân công và có thể mở rộng dần theo nhu cầu.”

**Slide 5 - Mô hình 3 lớp**

“Trong mô hình này, mỗi lớp có nhiệm vụ rõ ràng và không chồng chéo. Presentation tập trung hiển thị và nhận input, Application xử lý nghiệp vụ, còn Data quản lý lưu trữ và truy vấn. Nhờ đó khi cần sửa một phần, nhóm có thể tác động cục bộ mà hạn chế ảnh hưởng toàn hệ thống.”

**Slide 6 - Presentation Layer**

“Ở lớp Presentation, ứng dụng Flutter chịu trách nhiệm giao diện và trải nghiệm người dùng. Dữ liệu từ người dùng được kiểm tra sơ bộ trước khi gửi API qua Dio, còn trạng thái màn hình được quản lý bằng Provider. Điểm quan trọng là lớp này không gánh nghiệp vụ nặng, nên giao diện giữ được tính đơn giản và dễ bảo trì.”

**Slide 7 - Application Layer**

“Đây là tầng xử lý chính của backend Express.js. Request đi qua route, middleware, controller, service rồi mới tới model và database. Việc tách thành nhiều lớp nhỏ như vậy giúp logic rõ ràng, dễ test từng phần, và hỗ trợ mở rộng chức năng mà không làm rối code.”

**Slide 8 - Data Layer**

“Ở lớp dữ liệu, nhóm em dùng MongoDB Atlas và Mongoose. Các collection chính gồm users, wallets, transactions và walletTransfers, phản ánh trực tiếp các thực thể nghiệp vụ của ứng dụng. Mô hình document phù hợp với dữ liệu chi tiêu vì linh hoạt, dễ mở rộng cấu trúc khi có yêu cầu mới.”

**Slide 9 - Client-Server và REST API**

“Cơ chế giao tiếp của hệ thống là request-response theo REST. Mỗi tài nguyên được quản lý qua endpoint và phương thức HTTP tương ứng như GET, POST, PATCH hoặc DELETE. Cách làm này giúp chuẩn hóa API, dễ tích hợp cho mobile và thuận lợi khi mở rộng sang web trong tương lai.”

**Slide 10 - JWT Authentication**

“Về bảo mật truy cập, sau khi người dùng đăng nhập thành công thì server cấp JWT cho client. Các request sau đó sẽ đính kèm token trong header Authorization để backend xác thực. Cơ chế này có ưu điểm là stateless, gọn nhẹ và phù hợp với kiến trúc REST hiện tại.”

**Slide 11 - Middleware Pipeline**

“Trước khi vào logic nghiệp vụ, request được đi qua một pipeline middleware theo thứ tự. Tại đây hệ thống kiểm tra CORS, xác thực JWT, validate dữ liệu đầu vào và giới hạn tần suất gọi API. Nhờ pipeline này, hệ thống vừa an toàn hơn, vừa giữ cho controller và service tập trung đúng vào nghiệp vụ.”

**Slide 12 - Component Architecture và Design Patterns**

“SmartSpender được chia module rõ ở cả backend và mobile, ví dụ Auth, Wallet, Transaction, Statistic. Về pattern, nhóm em kết hợp MVC, Repository, Provider và nguyên tắc DI ở mức phù hợp. Cách tổ chức này hỗ trợ làm việc nhóm tốt hơn vì ranh giới chức năng rõ và giảm phụ thuộc chéo.”

**Slide 13 - Sequence Diagram User Login**

“Luồng login bắt đầu từ thao tác nhập thông tin trên app, sau đó gửi request tới backend để xác thực với dữ liệu trong database. Nếu hợp lệ, backend tạo JWT và trả về client để lưu lại cho các request tiếp theo. Sequence này thể hiện rõ mô hình stateless và luồng xác thực chuẩn của hệ thống.”

**Slide 14 - Sequence Diagram Create Transaction**

“Ở luồng tạo giao dịch, dữ liệu được kiểm tra ở cả phía client và middleware backend trước khi xử lý nghiệp vụ. Service không chỉ lưu transaction mà còn cập nhật số dư ví tương ứng khi phát sinh khoản chi. Đây là luồng tiêu biểu vì phản ánh trực tiếp giá trị cốt lõi của SmartSpender: quản lý thu chi gắn với trạng thái ví.”

**Slide 15 - Đánh giá kiến trúc theo tiêu chí ISA**

“Theo các tiêu chí ISA, hệ thống hiện có thế mạnh ở maintainability và mức bảo mật cơ bản. Tuy nhiên scalability và performance mới ở mức trung bình do chưa áp dụng các kỹ thuật tối ưu hạ tầng chuyên sâu. Điều này là hợp lý với quy mô hiện tại, và cũng là cơ sở để xác định lộ trình nâng cấp tiếp theo.”

**Slide 16 - Hướng mở rộng và kết luận**

“Kết luận lại, kiến trúc 3-Tier monolithic hiện tại là phù hợp với phạm vi học phần và năng lực triển khai của nhóm. Trong giai đoạn sau, hệ thống có thể bổ sung cache, monitoring, API gateway hoặc tách dịch vụ theo từng miền nghiệp vụ. Như vậy SmartSpender vừa chạy ổn định ở hiện tại, vừa có đường nâng cấp rõ ràng khi quy mô người dùng tăng.”

### 6.2. Câu nối giữa các phần (tránh bị khựng)

- Từ slide tổng quan sang slide kiến trúc chính: “Sau khi điểm qua các mô hình đã học, nhóm em xin chốt mô hình đang áp dụng trực tiếp trong SmartSpender.”
- Từ phần 3-Tier sang phần giao tiếp: “Khi đã rõ cấu trúc lớp, câu hỏi tiếp theo là các lớp này giao tiếp với nhau như thế nào trong thực tế.”
- Từ bảo mật sang sequence: “Phần tiếp theo nhóm em minh họa luồng thật để thấy các cơ chế vừa nêu hoạt động cụ thể ra sao.”
- Từ đánh giá sang kết luận: “Từ các điểm mạnh và điểm cần cải thiện, nhóm em đề xuất lộ trình mở rộng như sau.”

---

## 7. Checklist trước khi hoàn thành slide

- [ ] Có đủ 15–16 slide.
- [ ] Mỗi slide chỉ có một ý chính.
- [ ] Có sơ đồ cho các phần quan trọng.
- [ ] Có slide cho 3-Tier, REST, JWT, middleware, sequence.
- [ ] Có slide đánh giá kiến trúc và hướng mở rộng.
- [ ] Nội dung trên slide ngắn, dễ đọc.
- [ ] Phần thuyết trình miệng đã có câu gợi ý cho từng slide.

---

## 8. Kết luận ngắn

Bộ slide nên tập trung vào việc chứng minh SmartSpender được thiết kế hợp lý theo kiến trúc hệ thống thông tin, có phân lớp rõ ràng, giao tiếp chuẩn hóa, bảo mật cơ bản tốt và có lộ trình mở rộng thực tế.

Nếu làm đúng theo hướng dẫn này, bạn sẽ có một bộ slide vừa đúng môn, vừa dễ thuyết trình, vừa không bị rối chữ.
