# **CHƯƠNG X: THIẾT KẾ VÀ TƯƠNG TÁC HỆ THỐNG**

## **X.1. Tổng quan cơ chế quản lý trạng thái**

Trong hệ thống SmartSpender, ứng dụng di động được phát triển bằng Flutter sử dụng mô hình **quản lý trạng thái Provider** nhằm tách biệt giữa tầng giao diện (UI) và logic nghiệp vụ (Business Logic). Provider đóng vai trò trung gian điều phối dữ liệu giữa giao diện người dùng và Backend thông qua các API RESTful.

Cụ thể, khi người dùng thực hiện các thao tác như thêm, sửa hoặc xóa giao dịch, các sự kiện từ giao diện sẽ được chuyển đến Provider. Provider sau đó thực hiện gọi các dịch vụ (Service Layer) để giao tiếp với Backend. Kết quả trả về sẽ được xử lý và cập nhật lại trạng thái nội bộ, từ đó kích hoạt cơ chế render lại giao diện thông qua hàm `notifyListeners()`.

## **X.2. Kiến trúc tương tác giữa các thành phần**

Kiến trúc tương tác giữa các thành phần trong hệ thống được mô tả theo mô hình phân lớp như sau:

- **Presentation Layer (UI)**: Bao gồm các Widget Flutter, chịu trách nhiệm hiển thị dữ liệu và nhận input từ người dùng.
- **State Management Layer (Provider)**: Quản lý trạng thái ứng dụng, xử lý logic phía client.
- **Service Layer**: Thực hiện các lời gọi HTTP đến Backend API.
- **Backend Layer**: Xử lý logic nghiệp vụ, xác thực người dùng và truy xuất cơ sở dữ liệu.
- **Database Layer**: Lưu trữ dữ liệu giao dịch.

Mô hình này giúp đảm bảo tính tách biệt trách nhiệm (Separation of Concerns), nâng cao khả năng bảo trì và mở rộng hệ thống.

## **X.3. Kịch bản tương tác: Thêm giao dịch (Create Transaction)**

### **X.3.1. Mô tả nghiệp vụ**

Chức năng thêm giao dịch cho phép người dùng nhập thông tin chi tiêu hoặc thu nhập, sau đó lưu trữ dữ liệu này vào hệ thống.

### **X.3.2. Luồng xử lý chi tiết**

Quy trình xử lý được mô tả qua các bước sau:

**Bước 1: Nhập dữ liệu từ giao diện người dùng**  
 Người dùng nhập các thông tin bao gồm số tiền, danh mục, ghi chú và thời gian giao dịch thông qua biểu mẫu (Form) trên giao diện Flutter.

**Bước 2: Gửi sự kiện đến Provider**  
 Sau khi người dùng xác nhận, giao diện gọi phương thức tương ứng trong Provider (ví dụ: `addTransaction()`), truyền vào dữ liệu đã nhập.

**Bước 3: Xử lý tại Provider**  
 Provider thực hiện các nhiệm vụ sau:

- Cập nhật trạng thái loading (`isLoading = true`)
- Gọi Service Layer để gửi request đến Backend
- Chờ phản hồi từ server

**Bước 4: Gọi API từ Service Layer**  
 Service Layer gửi yêu cầu HTTP POST đến endpoint `/transactions`, kèm theo JWT Token trong header để xác thực người dùng.

**Bước 5: Xử lý tại Backend**  
 Backend thực hiện các bước:

- Xác thực JWT Token
- Kiểm tra tính hợp lệ của dữ liệu đầu vào
- Lưu thông tin giao dịch vào cơ sở dữ liệu
- Trả về kết quả cho client

**Bước 6: Nhận phản hồi từ Backend**

- Trường hợp thành công (HTTP 200): trả về dữ liệu giao dịch vừa tạo
- Trường hợp lỗi (HTTP 400): trả về thông báo lỗi

**Bước 7: Cập nhật trạng thái tại Provider**

- Nếu thành công: thêm giao dịch mới vào danh sách nội bộ
- Nếu thất bại: cập nhật thông tin lỗi
- Cập nhật lại trạng thái loading
- Gọi `notifyListeners()` để thông báo thay đổi

**Bước 8: Cập nhật giao diện người dùng**  
 Các Widget lắng nghe Provider sẽ tự động được render lại, hiển thị danh sách giao dịch mới nhất.

## **X.4. Kịch bản tương tác: Cập nhật giao dịch (Update Transaction)**

Quy trình cập nhật giao dịch tương tự như thao tác tạo mới, với sự khác biệt chính là:

- Phương thức HTTP sử dụng là PUT hoặc PATCH
- Backend thực hiện cập nhật bản ghi dựa trên `transactionId`
- Provider cập nhật lại phần tử tương ứng trong danh sách nội bộ

Việc cập nhật được thực hiện theo nguyên tắc đồng bộ dữ liệu giữa client và server nhằm đảm bảo tính nhất quán.

## **X.5. Kịch bản tương tác: Xóa giao dịch (Delete Transaction)**

### **X.5.1. Mô tả nghiệp vụ**

Người dùng có thể xóa một giao dịch đã tồn tại khỏi hệ thống.

### **X.5.2. Luồng xử lý**

- UI gửi yêu cầu xóa đến Provider
- Provider gọi API DELETE `/transactions/{id}`
- Backend xác thực quyền sở hữu giao dịch
- Xóa bản ghi khỏi cơ sở dữ liệu
- Provider cập nhật lại danh sách bằng cách loại bỏ phần tử tương ứng
- Giao diện được cập nhật lại

## **X.6. Cơ chế xác thực và bảo mật**

Hệ thống sử dụng cơ chế xác thực dựa trên **JSON Web Token (JWT)**. Sau khi đăng nhập thành công, người dùng sẽ nhận được một token và token này được gửi kèm trong header của mỗi request đến Backend.

Backend sử dụng middleware để:

- Giải mã token
- Xác định danh tính người dùng
- Gán thông tin người dùng vào request để phục vụ xử lý nghiệp vụ

Cơ chế này đảm bảo rằng chỉ những người dùng hợp lệ mới có quyền truy cập và thao tác trên dữ liệu của mình.

## **X.7. Xử lý lỗi và đồng bộ dữ liệu**

### **X.7.1. Xử lý lỗi**

Provider chịu trách nhiệm bắt các ngoại lệ phát sinh từ Service Layer. Khi xảy ra lỗi, thông tin lỗi sẽ được lưu trong state và hiển thị lên giao diện thông qua các thành phần như Snackbar hoặc Dialog.

### **X.7.2. Đồng bộ dữ liệu**

Hệ thống sử dụng phương pháp cập nhật cục bộ (local state update), nghĩa là sau mỗi thao tác thành công, dữ liệu được cập nhật trực tiếp trên Provider mà không cần gọi lại toàn bộ API. Cách tiếp cận này giúp cải thiện hiệu năng và giảm độ trễ.

## **X.8. Đánh giá mô hình Provider trong hệ thống**

### **Ưu điểm**

- Đơn giản, dễ triển khai
- Tách biệt rõ ràng giữa UI và logic
- Hỗ trợ cơ chế reactive giúp giao diện tự động cập nhật

### **Hạn chế**

- Khó mở rộng đối với hệ thống lớn
- Có thể gây dư thừa render nếu không tối ưu
- Không phù hợp với các ứng dụng có state phức tạp

## **X.9. Các cập nhật đề xuất cho sơ đồ (Review notes)**

Để các biểu đồ dùng làm báo cáo môn học/kiến trúc hệ thống rõ ràng và chính xác hơn, đề xuất các thay đổi sau (đã được bổ sung trong thư mục `docs/diagrams`):

- Thêm bước **Client normalizes input** (trim `title`, `category.toLowerCase()`, đảm bảo `amount` là number) ngay trước khi `Provider` gọi service. Backend vẫn giữ defensive checks.
- Trong sequence diagram: hiển thị rõ bước **Update Wallet Balance** (hoặc rollback) sau khi transaction được ghi vào DB. Điều này phản ánh logic hiện có trong `backend/services/transaction.service.js` (applyWalletDelta, rollback).
- Chỉnh lại response của POST create transaction thành **201 Created** trên sơ đồ (code hiện trả 201).
- Thêm nhánh xử lý **Token expired** trong activity diagram để mobile có cách xử lý riêng (chuyển về màn hình đăng nhập hoặc refresh token).
- Tiêu chuẩn hoá cách xử lý `to` date: khi client gửi `YYYY-MM-DD` cho `to`, backend nâng `to` lên cuối ngày và dùng `$lte`.

Những thay đổi trên đã được minh hoạ bằng hai file Mermaid (`mermaid_sequence.md`, `mermaid_activity.md`) và file ví dụ request/response (`examples.md`) trong cùng thư mục để dễ chèn vào slide/báo cáo.

## **X.10. Ghi chú nhanh cho Mobile (Đức Anh)**

- Khi gọi `POST /api/transactions` nhớ gửi header `Authorization: Bearer <JWT>`; server trả `201` khi tạo thành công.
- Chuẩn hoá payload: `title.trim()`, `category.toLowerCase()`, `amount` là number, `date` ở dạng ISO hoặc `YYYY-MM-DD` (server nâng `to` lên cuối ngày nếu cần).
- Khi nhận `401` với `errorCode: TOKEN_EXPIRED`, điều hướng người dùng tới màn hình đăng nhập (hoặc flow refresh token nếu có thiết kế).

---

Tiếp theo xem các file Mermaid và ví dụ trong cùng thư mục để lấy nội dung đã cập nhật.
