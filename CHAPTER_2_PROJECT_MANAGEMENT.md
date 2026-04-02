# CHƯƠNG 2: QUẢN LÝ DỰ ÁN

## 2.1 Ước Lượng Dự Án

### 2.1.1 Ước Lượng Chi Phí

Dự án SmartSpender được chia thành 4 Sprint chính theo mô hình **Agile Scrum**, mỗi sprint kéo dài 2 tuần (14 ngày làm việc). Tổng thời gian thực hiện từ 15/01/2026 đến 31/03/2026 (tổng 11 tuần).

| Giai đoạn                          | Công việc                                     | Mô tả                                                                        | Chi phí (Giờ) |
| ---------------------------------- | --------------------------------------------- | ---------------------------------------------------------------------------- | ------------- |
| **Quản lý dự án**                  | Khảo sát yêu cầu dự án                        | Thu thập các yêu cầu tổng quan của dự án                                     | 8             |
|                                    | Khởi tạo dự án                                | Thống báo triển khai dự án                                                   | 4             |
|                                    | Lập kế hoạch phân vi dự án                    | Lập kế hoạch phạm vi dự án                                                   | 8             |
|                                    | Viết báo cáo cao tổng kết                     | Tổng kết lại toàn bộ công việc thành báo cáo cuối cùng                       | 12            |
|                                    | Rút kinh nghiệm                               | Rút kinh nghiệm cho dự án sau                                                | 4             |
| **Phân tích và thiết kế hệ thống** | Đặc tả chi tiết các yêu cầu                   | Từ yêu cầu khảo sát, mô tả chi tiết các yêu cầu cần thiết của phần mềm       | 12            |
|                                    | Thiết kế kiến trúc                            | Xây dựng kiến trúc phần mềm, thành phố bộ hộng, mô hình luồng dữ liệu        | 20            |
|                                    | Thiết kế giao diện                            | Xác định giao diện giữa các thành phần, tích hợp các thành phần vào hệ thống | 16            |
|                                    | Thiết kế cơ sở dữ liệu                        | Thiết kế schema MongoDB cho User, Transaction, Wallet                        | 12            |
| **Lập trình**                      | Kiểm thử giao diện có đặt yêu cầu không       | Kiểm thử giao diện có đáp ứng yêu cầu không                                  | 4             |
|                                    | Viết tài liệu hướng dẫn                       | Tạo bản hướng dẫn sử dụng phần mềm                                           | 8             |
|                                    | Lên kế hoạch phạm vi dự án                    | Sửa các lỗi phát sinh trong quá trình kiểm thử                               | 8             |
|                                    | Sửa các lỗi tái tính trong quá trình kiểm thử | Sửa các lỗi phát sinh trong quá trình kiểm thử liên tục                      | 16            |
|                                    | Viết tài liệu hướng dẫn dân sử dụng phần mềm  | Lên kế hoạch hoạc bảo trì phần mềm                                           | 8             |
|                                    | Lên kế hoạch hoạc bảo trì phần mềm            | Lên kế hoạch hoạc bảo trì phần mềm                                           | 4             |
| **Kết thúc dự án**                 | Tổng kết dự án                                | Tổng kết dự án                                                               | 8             |

### 2.1.2 Ước lượng thời gian

Ước lượng thời gian cho từng Sprint dựa trên khối lượng công việc, độ phức tạp, và năng lực của từng thành viên:

| Giai đoạn                          | Công việc              | Mô tả                                                                             | Thời gian | Phân công                  |
| ---------------------------------- | ---------------------- | --------------------------------------------------------------------------------- | --------- | -------------------------- |
| **Sprint 1** (15/01-29/01, 2 tuần) | Khảo sát yêu cầu dự án | Thu thập các yêu cầu tổng quan của dự án                                          | 1 ngày    | Mai Huy Minh               |
|                                    | Khởi tạo dự án         | Thống báo triển khai dự án                                                        | 1 ngày    | Mai Huy Minh               |
|                                    | Thiết kế Data Diagram  | Các biểu đồ Use Case, Activity Diagram                                            | 2 ngày    | Mai Huy Minh               |
|                                    | Thiết kế UI/UX         | Bản thiết kế các màn hình trên Figma                                              | 2 ngày    | Mai Huy Minh               |
|                                    | Thiết kế Dữ liệu       | Lược độ Database MongoDB (Collections: Users, Transactions)                       | 2 ngày    | Nguyễn Văn Duy             |
|                                    | Base Code              | Cấu trúc thư mục Monorepo được khởi tạo trên GitHub                               | 2 ngày    | Mai Huy Minh, Vũ Ngọc Bảo  |
| **Sprint 2** (30/01-13/02, 2 tuần) | API Login/Register     | Server Node.js sẵn sàng xác thực JWT Token (Chạy Postman)                         | 3 ngày    | Vũ Ngọc Bảo                |
|                                    | Kiến trúc Mobile       | Cấu hình xong State Management (Provider/Riverpod), gọi API thành công từ App     | 2 ngày    | Mai Huy Minh               |
|                                    | Sàn phần mềm           | App chạy được màn hình Splash, Login, Register và lưu được phiên đăng nhập        | 2 ngày    | Trịnh Thái Sơn             |
|                                    | Filter & Lọc CRUD      | API Filter Transaction chi tiết & CRUD cơ bản                                     | 3 ngày    | Nguyễn Văn Duy             |
|                                    | Unit Test Backend      | Viết Unit Test cho Auth Service, Validation                                       | 2 ngày    | Vũ Ngọc Bảo                |
| **Sprint 3** (14/02-28/02, 2 tuần) | API E2E hoàn chỉnh     | App thêm được giao dịch mới và hiển thị ngay lên màn hình Home (Chạy qua Postman) | 4 ngày    | Lê Đức Anh, Nguyễn Văn Duy |
|                                    | Cơ chế bảo vệ (Safety) | Chặn lỗi crash app khi thao tác sai hoặc mất mạng                                 | 2 ngày    | Trịnh Thái Sơn             |
|                                    | API Docs cơ bản        | Các endpoint giao dịch được tài liệu hóa                                          | 2 ngày    | Vũ Ngọc Bảo                |
|                                    | API Statistics         | API lấy thống kê (Thu, Chi, Số dư) theo tháng                                     | 3 ngày    | Nguyễn Văn Duy             |
|                                    | Màn hình Thống Kê      | Hiển thị thống kê giao dịch, biểu đồ danh mục                                     | 2 ngày    | Lê Đức Anh                 |
|                                    | Màn hình Ví            | Quản lý ví, chuyển tiền giữa ví                                                   | 2 ngày    | Lê Đức Anh                 |
| **Sprint 4** (01/03-31/03, 4 tuần) | Hoàn thiện UI          | Làm đầy các màn hình còn trống, kiểm thử hệ thống                                 | 5 ngày    | Trịnh Thái Sơn             |
|                                    | Tích hợp tính năng     | Kiểm thử tổng quan bộ hệ thống, sửa bugs                                          | 4 ngày    | Mai Huy Minh, Lê Đức Anh   |
|                                    | Viết báo cáo tài liệu  | Viết báo cáo Word, tài liệu Swagger hoàn thiện                                    | 3 ngày    | Mai Huy Minh, Vũ Ngọc Bảo  |

---

## 2.2 Lập Lịch và Theo Dõi

### 2.2.1 Bảng Lập Lịch Chi Tiết Theo Sprint

#### **Sprint 1: Khởi Tạo, Phân Tích & Thiết Kế (15/01/2026 - 29/01/2026, 2 tuần)**

**Mục tiêu chính:** Thu thập & phân tích yêu cầu, định hình người dùng, thiết kế giao diện Figma, thiết kế database schema, khởi tạo Base Code trên GitHub.

**Lịch trình Agile Scrum:**

- **Ngày 15/01**: Sprint Planning (4h) - Định nghĩa sprint goal, story points
- **16-28/01**: Development (10 ngày làm việc)
- **29/01**: Sprint Review + Retrospective (2h) - Demo output, rút kinh nghiệm

| Câu trúc phân việc              | Hoạt động                                             | Ngày bắt đầu | Ngày kết thúc | Hoàn thành | Ghi chú  |
| ------------------------------- | ----------------------------------------------------- | ------------ | ------------- | ---------- | -------- |
| **Quản lý dự án**               | **Sprint Planning** - Chốt scope & sprint goal        | 15/01        | 15/01         | ✅         | 4h       |
| Người phụ trách: Mai Huy Minh   | Khảo sát yêu cầu từ mentor/stakeholder                | 16/01        | 17/01         | ✅         | 1 ngày   |
|                                 | Viết PRD (Product Requirements Document)              | 17/01        | 18/01         | ✅         | 1 ngày   |
| **Phân tích và thiết kế UML**   | **Viết User Story & Use Case**                        | 18/01        | 20/01         | ✅         | 1.5 ngày |
| Người phụ trách: Mai Huy Minh   | Vẽ Activity Diagram & Sequence Diagram                | 20/01        | 21/01         | ✅         | 1 ngày   |
| **Thiết kế Dữ liệu (DB)**       | **Thiết kế ERD & MongoDB Collection**                 | 18/01        | 22/01         | ✅         | 2 ngày   |
| Người phụ trách: Nguyễn Văn Duy | Schema: User, Transaction, Wallet, Transfer           | -            | -             | ✅         | -        |
| **Thiết kế UI/UX**              | **Thiết kế 8-10 màn hình trên Figma**                 | 19/01        | 24/01         | ✅         | 2.5 ngày |
| Người phụ trách: Mai Huy Minh   | Color system, Typography, Component Library           | 24/01        | 25/01         | ✅         | 1 ngày   |
| **Base Code Backend**           | **Khởi tạo Node.js + Express + MongoDB structure**    | 22/01        | 25/01         | ✅         | 1.5 ngày |
| Người phụ trách: Vũ Ngọc Bảo    | Setup folder: controllers, middleware, models, routes | -            | -             | ✅         | -        |
| **Base Code Mobile**            | **Khởi tạo Flutter project + folder structure**       | 22/01        | 25/01         | ✅         | 1.5 ngày |
| Người phụ trách: Mai Huy Minh   | Setup pubspec.yaml, core config, constant files       | -            | -             | ✅         | -        |
| **Lập Kế Hoạch Toàn Dự Án**     | **Lập kế hoạch chi tiết 4 Sprint**                    | 25/01        | 27/01         | ✅         | 1.5 ngày |
| Người phụ trách: Mai Huy Minh   | Tạo Gantt Chart, milestone, resource allocation       | -            | -             | ✅         | -        |
| **Chuẩn Bị Môi Trường**         | **Setup môi trường dev team**                         | 27/01        | 28/01         | ✅         | 1 ngày   |
|                                 | IDE, Git, MongoDB local/Atlas, Node v18, Flutter SDK  | -            | -             | ✅         | -        |
| **Git Repository Setup**        | **Push Base Code lên GitHub**                         | 28/01        | 29/01         | ✅         | 0.5 ngày |
|                                 | Setup branch naming, PR template, CI/CD basics        | -            | -             | ✅         | -        |
| **Sprint Review & Retro**       | **Demo output, giải đáp câu hỏi**                     | 29/01        | 29/01         | ✅         | 1h       |
|                                 | Retrospective: What went well, what to improve        | 29/01        | 29/01         | ✅         | 1h       |

**Output đạt được (Deliverables):**

1. ✅ **Tài liệu Đặc tả**: Use Case, Activity Diagram, Sequence Diagram
2. ✅ **Thiết kế UI/UX Figma**: 8-10 màn hình (Home, Transaction, Wallet, Statistics, etc.)
3. ✅ **Database Schema**: ERD, MongoDB Collection definitions
4. ✅ **Base Code Repository**: Backend (Node/Express) + Mobile (Flutter) structure trên GitHub
5. ✅ **Environment Setup**: All team members sẵn sàng dev

---

#### **Sprint 2: Nền Tảng Kiến Trúc & Xác Thực (Auth) (30/01/2026 - 13/02/2026, 2 tuần)**

**Mục tiêu chính:** Dựng xây dựng Mobile state management, Backend authentication API (JWT), kết nối backend-mobile thành công, tạo màn hình Auth UI trên mobile.

**Lịch trình Agile Scrum:**

- **Ngày 30/01**: Sprint Planning - Chốt scope, assign story
- **Giai đoạn 1 "Tập trung cao độ" (30/01-05/02)**: Backend API + Core Infrastructure
- **Giai đoạn 2 "Nhẹ nhàng" (06/02-12/02)**: Testing, Documentation, Refinement
- **Ngày 13/02**: Sprint Review + Retrospective

| Câu trúc phân việc                                   | Hoạt động                                                       | Ngày bắt đầu | Ngày kết thúc | Hoàn thành | Ghi chú  |
| ---------------------------------------------------- | --------------------------------------------------------------- | ------------ | ------------- | ---------- | -------- |
| **Backend - Giai đoạn 1: Tập Trung (30/01-05/02)**   |
| Người: Vũ Ngọc Bảo                                   | Setup Error Handler & Middleware base                           | 30/01        | 01/02         | ✅         | 1.5 ngày |
|                                                      | API User Registration (POST /auth/register)                     | 01/02        | 03/02         | ✅         | 2 ngày   |
|                                                      | API User Login (POST /auth/login) - JWT Token                   | 03/02        | 05/02         | ✅         | 2 ngày   |
|                                                      | Postman testing - Auth flows                                    | 05/02        | 05/02         | ✅         | 0.5 ngày |
| Người: Nguyễn Văn Duy                                | Thiết kế lại API Filter Transaction (GET /transactions?filters) | 30/01        | 02/02         | ✅         | 1.5 ngày |
|                                                      | Query optimization, index planning                              | 02/02        | 05/02         | ✅         | 1.5 ngày |
| **Backend - Giai đoạn 2: Test & Docs (06/02-12/02)** |
| Người: Vũ Ngọc Bảo                                   | Unit Test - Auth Service (register/login)                       | 06/02        | 08/02         | ✅         | 1.5 ngày |
|                                                      | Swagger API Documentation - Auth endpoints                      | 08/02        | 10/02         | ✅         | 1.5 ngày |
|                                                      | Bug fix & refinement từ team feedback                           | 10/02        | 12/02         | ✅         | 1 ngày   |
| **Mobile - Giai đoạn 1: Tập Trung (30/01-05/02)**    |
| Người: Mai Huy Minh                                  | Setup Provider state management base                            | 30/01        | 31/01         | ✅         | 0.5 ngày |
|                                                      | Create API service (Dio, HTTP client)                           | 31/01        | 02/02         | ✅         | 1 ngày   |
|                                                      | Auth Provider (login/register state)                            | 02/02        | 04/02         | ✅         | 1.5 ngày |
|                                                      | Code Review structure, guide team                               | 04/02        | 05/02         | ✅         | 1 ngày   |
| Người: Trịnh Thái Sơn                                | Splash Screen (Loading animation)                               | 30/01        | 01/02         | ✅         | 1 ngày   |
|                                                      | Login Screen UI & Form validation                               | 01/02        | 03/02         | ✅         | 1.5 ngày |
|                                                      | Register Screen UI & Form validation                            | 03/02        | 05/02         | ✅         | 1.5 ngày |
| Người: Lê Đức Anh                                    | Form validation library setup (Formz/Validator)                 | 02/02        | 03/02         | ✅         | 0.5 ngày |
|                                                      | Token storage (shared_preferences)                              | 03/02        | 04/02         | ✅         | 0.5 ngày |
|                                                      | Session persistence (auto-login)                                | 04/02        | 05/02         | ✅         | 1 ngày   |
| **Mobile - Giai đoạn 2: Integration (06/02-12/02)**  |
| Người: Trịnh Thái Sơn                                | Integration - Login API call                                    | 06/02        | 07/02         | ✅         | 1 ngày   |
|                                                      | Integration - Register API call                                 | 07/02        | 08/02         | ✅         | 0.5 ngày |
|                                                      | Error handling UI (toast, dialog)                               | 08/02        | 09/02         | ✅         | 0.5 ngày |
| Người: Lê Đức Anh                                    | Home Screen scaffold (BottomNavigation)                         | 06/02        | 08/02         | ✅         | 1.5 ngày |
|                                                      | Navigation flow (Login → Home)                                  | 08/02        | 10/02         | ✅         | 1 ngày   |
| Người: Mai Huy Minh                                  | Review & merge all PR                                           | 10/02        | 12/02         | ✅         | 1 ngày   |
| **Sprint Review & Retro**                            |
| Toàn Team                                            | Sprint 2 Demo - Auth flow end-to-end                            | 13/02        | 13/02         | ✅         | 1h       |
| Người: Mai Huy Minh                                  | Retrospective meeting                                           | 13/02        | 13/02         | ✅         | 1h       |

**Output đạt được (Deliverables):**

1. ✅ **Backend Auth API**: Register, Login endpoints với JWT token
2. ✅ **Mobile State Management**: Provider setup, Auth state, API service
3. ✅ **UI Screens**: Splash, Login, Register screens hoàn thiện
4. ✅ **API Documentation**: Swagger docs cho Auth API
5. ✅ **E2E Flow**: App có thể register → login → lưu token → auto-login
   | | Setup Base Code hoàn thiện, Folder structure | 10/02 | 12/02 | ✅ | |
   | | Code Review 100% PR của team | 13/02 | 16/02 | ✅ | |
   | Người: Trịnh Thái Sơn | Integration Màn hình Home (API thật) | 10/02 | 13/02 | ✅ | |
   | | Pull-to-refresh & Skeleton Loading | 13/02 | 15/02 | ✅ | |
   | Người: Lê Đức Anh | Form Thêm/Sửa Giao dịch | 10/02 | 12/02 | ✅ | |
   | | Validation chi tiết (Số tiền, Danh mục, Ngày) | 12/02 | 14/02 | ✅ | |
   | **Sprint 2 - Giai đoạn 2: Nhẹ Nhàng (16/02-23/02)** |
   | Toàn Team | Unit Test Mobile (Widget Test) | 16/02 | 19/02 | ✅ | |
   | | Viết Tài liệu (Docs) | 19/02 | 21/02 | ✅ | |
   | | Chỉnh sửa UI nhỏ từ feedback | 21/02 | 22/02 | ✅ | |
   | Người: Mai Huy Minh | Demo Sprint 2 & Retrospective | 22/02 | 23/02 | ✅ | |

**Kết quả đạt được (Output):**

1. ✅ Backend chạy thực tế: Server Node.js sẵn sàng xác thực JWT Token (Chạy qua Postman).
2. ✅ Kiến trúc Mobile: Cấu hình xong State Management (Provider/Riverpod), gọi API thành công từ App.
3. ✅ Sàn phần mềm: App chạy được màn hình Splash, Login, Register và lưu được phiên đăng nhập.

---

#### **Sprint 3: Chức Năng Cốt Lõi (Core CRUD) (24/02/2026 - 09/03/2026)**

**Mục tiêu:** Người dùng phải Thêm, Sửa, Xóa và Xem được danh sách giao dịch (E2E).

| Câu trúc phân việc                                         | Hoạt động                             | Ngày bắt đầu | Ngày kết thúc | Hoàn thành | Chưa hoàn thành |
| ---------------------------------------------------------- | ------------------------------------- | ------------ | ------------- | ---------- | --------------- |
| **Backend - Giai đoạn 1: Tập Trung (24/02-28/02)**         |
| Người: Nguyễn Văn Duy                                      | API Filter Transaction nâng cao       | 24/02        | 26/02         | ✅         |                 |
|                                                            | API Statistics (Aggregation)          | 26/02        | 28/02         | ✅         |                 |
| Người: Vũ Ngọc Bảo                                         | CRUD API (Create/Read/Update/Delete)  | 24/02        | 27/02         | ✅         |                 |
|                                                            | Unit Test CRUD Service                | 27/02        | 28/02         | ✅         |                 |
| **Mobile - Giai đoạn 1: Tập Trung (24/02-02/03)**          |
| Người: Lê Đức Anh                                          | Integration API thêm giao dịch        | 24/02        | 27/02         | ✅         |                 |
|                                                            | Integration API sửa/xóa giao dịch     | 27/02        | 01/03         | ✅         |                 |
|                                                            | Xử lý Error states                    | 01/03        | 02/03         | ✅         |                 |
| Người: Trịnh Thái Sơn                                      | Refactor Home Screen (hiển thị CRUD)  | 24/02        | 27/02         | ✅         |                 |
|                                                            | Cơ chế bảo vệ (Safety) - Chặn crash   | 01/03        | 03/03         | ✅         |                 |
| **Backend - Giai đoạn 2: Mở Rộng Tính Năng (03/03-06/03)** |
| Người: Nguyễn Văn Duy                                      | Wallet Transfer API                   | 03/03        | 05/03         | ✅         |                 |
| Người: Vũ Ngọc Bảo                                         | Notification Service (Optional)       | 03/03        | 06/03         | ✅         |                 |
| **Mobile - Giai đoạn 2: Mở Rộng Tính Năng (03/03-07/03)**  |
| Người: Lê Đức Anh                                          | Màn hình Ví (Wallet Screen MVP)       | 03/03        | 06/03         | ✅         |                 |
|                                                            | Chuyển tiền giữa ví                   | 06/03        | 07/03         | ✅         |                 |
| Người: Trịnh Thái Sơn                                      | Màn hình Thống Kê (Statistics Screen) | 03/03        | 06/03         | ✅         |                 |
|                                                            | Biểu đồ danh mục & Filter theo tháng  | 06/03        | 07/03         | ✅         |                 |
| **Sprint 3 - Kiểm Thử & Chỉnh Sửa (07/03-09/03)**          |
| Toàn Team                                                  | Widget Test Mobile toàn bộ            | 07/03        | 08/03         | ✅         |                 |
| Người: Mai Huy Minh                                        | QA Testing E2E Flow                   | 08/03        | 09/03         | ✅         |                 |
|                                                            | Demo Sprint 3 & Retrospective         | 09/03        | 09/03         | ✅         |                 |

**Kết quả đạt được (Output):**

1. ✅ Luồng E2E hoàn chỉnh: App thêm được giao dịch mới và hiển thị ngay lên màn hình Home.
2. ✅ Cơ chế bảo vệ (Safety): Chặn lỗi crash app khi thao tác sai hoặc mất mạng.
3. ✅ API Docs cơ bản: Các endpoint giao dịch được chỉnh bản.

---

#### **Sprint 4: Hoàn Thiện UI, Tích Hợp & Đóng Gói (10/03/2026 - 28/03/2026)**

**Mục tiêu:** Làm đầy các màn hình còn trống, kiểm thử hệ thống toàn diện, hoàn thành báo cáo.

| Câu trúc phân việc                                         | Hoạt động                                | Ngày bắt đầu | Ngày kết thúc | Hoàn thành | Chưa hoàn thành |
| ---------------------------------------------------------- | ---------------------------------------- | ------------ | ------------- | ---------- | --------------- |
| **Backend - Tối Ưu & Hoàn Thành (10/03-16/03)**            |
| Người: Nguyễn Văn Duy                                      | Tối ưu hóa API Performance               | 10/03        | 12/03         | ✅         |                 |
| Người: Vũ Ngọc Bảo                                         | Hoàn thiện Swagger API Docs              | 10/03        | 13/03         | ✅         |                 |
|                                                            | Integration Test toàn bộ                 | 13/03        | 16/03         | ✅         |                 |
| **Mobile - Giai đoạn 1: Hoàn Thiện UI (10/03-18/03)**      |
| Người: Trịnh Thái Sơn                                      | Tối ưu Home Screen UI                    | 10/03        | 12/03         | ✅         |                 |
|                                                            | Màn hình Profile & Logout                | 12/03        | 14/03         | ✅         |                 |
| Người: Lê Đức Anh                                          | Tối ưu Wallet Screen & Statistics Screen | 10/03        | 13/03         | ✅         |                 |
|                                                            | Chỉnh sửa UI theme & typography          | 14/03        | 16/03         | ✅         |                 |
| Người: Mai Huy Minh                                        | Code Review & Merge PR                   | 10/03        | 18/03         | ✅         |                 |
|                                                            | Build APK & Testing Devices              | 14/03        | 18/03         | ✅         |                 |
| **Mobile - Giai đoạn 2: Kiểm Thử Toàn Diện (18/03-22/03)** |
| Người: Mai Huy Minh                                        | E2E Testing Toàn Bộ Flows                | 18/03        | 20/03         | ✅         |                 |
|                                                            | Performance Testing (Scrolling, Loading) | 20/03        | 21/03         | ✅         |                 |
| Toàn Team                                                  | Sửa Bugs phát sinh từ Testing            | 20/03        | 22/03         | ✅         |                 |
| **Hoàn Thành Dự Án (22/03-28/03)**                         |
| Người: Mai Huy Minh                                        | Ghi lại kết quả testing + Screenshots    | 22/03        | 23/03         | ✅         |                 |
|                                                            | Viết README Deployment                   | 23/03        | 24/03         | ✅         |                 |
| Người: Vũ Ngọc Bảo                                         | Chuẩn bị Backend cho Render Deploy       | 22/03        | 25/03         | ✅         |                 |
| Người: Trịnh Thái Sơn + Lê Đức Anh                         | Chỉnh sửa UI cuối cùng                   | 24/03        | 26/03         | ✅         |                 |
| Toàn Team                                                  | Viết Báo Cáo Tài Liệu Word               | 24/03        | 28/03         | ✅         |                 |
| Người: Mai Huy Minh                                        | Demo Toàn Bộ Dự Án (Final Presentation)  | 28/03        | 28/03         | ✅         |                 |

**Kết quả đạt được (Output):**

1. ✅ Tài liệu API (Swagger Docs): Giao diện Swagger liệt kê đầy của các API (để chứng minh Backend làm việc chuyên nghiệp).
2. ✅ Ứng dụng đầy đủ: Tất cả màn hình hoàn thiện, luồng test toàn bộ, documentation hoàn chỉnh.
3. ✅ Bản tinh gọi: Ứng dụng có thể được test trên thiết bị thật hoặc emulator Android/iOS.

---

### 2.2.2 Bảng Tiến Độ Realtime

Bảng theo dõi tiến độ thực tế so với kế hoạch:

| Sprint                     | Kế hoạch | Thực tế | Tiến độ       | Ghi chú                                             |
| -------------------------- | -------- | ------- | ------------- | --------------------------------------------------- |
| **Sprint 1** (02/02-09/02) | 100%     | 100%    | ✅ Hoàn thành | Khởi tạo đầy đủ, base code sẵn sàng                 |
| **Sprint 2** (10/02-23/02) | 100%     | 100%    | ✅ Hoàn thành | Auth & State Management đạt yêu cầu                 |
| **Sprint 3** (24/02-09/03) | 100%     | 100%    | ✅ Hoàn thành | Core CRUD + Features mở rộng đầy đủ                 |
| **Sprint 4** (10/03-28/03) | 100%     | 100%    | ✅ Hoàn thành | UI hoàn thiện, testing toàn diện, deploy thành công |

---

## 2.3 Phân Công Nhân Sự Chi Tiết

### 2.3.1 Danh Sách Thành Viên & Vai Trò

| STT | Họ & Tên           | Mã SV     | Vai Trò                             | Công Việc Chính                                                                                                                                              | Quyền Hạn                                       | Đánh Giá   |
| --- | ------------------ | --------- | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------- | ---------- |
| 1   | **Mai Huy Minh**   | -         | **Leader / QA Lead**                | • Điều phối toàn team<br/>• Quản lý tiến độ Sprint<br/>• Code Review & Merge<br/>• QA Testing E2E<br/>• Viết báo cáo tài liệu                                | • Approve PR<br/>• Merge code<br/>• Assign task | ⭐⭐⭐⭐⭐ |
| 2   | **Nguyễn Văn Duy** | 233630635 | **Backend Developer (Core)**        | • Thiết kế Database schema<br/>• API Filter & Aggregation<br/>• Statistics Logic<br/>• Performance Optimization<br/>• Unit Testing                           | • Propose architecture<br/>• Request CR         | ⭐⭐⭐⭐   |
| 3   | **Vũ Ngọc Bảo**    | -         | **Backend Developer (CRUD & Docs)** | • API CRUD (Create/Update/Delete)<br/>• Authentication & Middleware<br/>• Validation & Error Handling<br/>• Swagger API Documentation<br/>• Deployment Setup | • Implement CRUD<br/>• Write tests              | ⭐⭐⭐     |
| 4   | **Trịnh Thái Sơn** | -         | **Mobile Developer**                | • Home Screen Integration<br/>• Transaction List UI<br/>• Pull-to-refresh & Loading<br/>• Safety & Error Handling<br/>• Widget Testing                       | • Implement UI<br/>• Test widgets               | ⭐⭐⭐     |
| 5   | **Lê Đức Anh**     | -         | **Mobile Developer**                | • Transaction Form (Add/Edit)<br/>• Wallet Screen<br/>• Statistics Screen & Charts<br/>• State Management Integration<br/>• Wallet Transfer Feature          | • Implement UI<br/>• Integrate features         | ⭐⭐⭐     |

### 2.3.2 Chi Tiết Công Việc Từng Thành Viên Theo Sprint

---

#### **1. Mai Huy Minh (Leader)**

| Sprint       | Công Việc                       | Mô Tả Chi Tiết                          | Thời Gian Est. | Trạng Thái |
| ------------ | ------------------------------- | --------------------------------------- | -------------- | ---------- |
| **Sprint 1** | Khảo sát & Phân tích yêu cầu    | Gặp team, define scope, viết User Story | 2 ngày         | ✅         |
|              | Thiết kế Figma UI               | Thiết kế 8-10 màn hình giao diện        | 2 ngày         | ✅         |
|              | Setup Base Code                 | Khởi tạo folder structure, .gitignore   | 1 ngày         | ✅         |
|              | Lập kế hoạch 4 Sprint           | Tạo timeline chi tiết, define milestone | 1 ngày         | ✅         |
| **Sprint 2** | State Management Setup          | Thiết lập Provider, base API service    | 1 ngày         | ✅         |
|              | Code Review 100% PR             | Review tất cả PR từ team, feedback      | 2 ngày         | ✅         |
|              | Hỗ trợ & Unblock team           | Giải quyết conflict, guide junior       | 1 ngày         | ✅         |
|              | Sprint 2 Demo & Planning        | Chuẩn bị demo, lập kế hoạch Sprint 3    | 1 ngày         | ✅         |
| **Sprint 3** | QA Testing E2E                  | Test toàn bộ CRUD flow trên thiết bị    | 2 ngày         | ✅         |
|              | Bug Fix & CI/CD Setup           | Sửa bug phát sinh, setup GitHub Actions | 1 ngày         | ✅         |
|              | Sprint 3 Demo & Retrospective   | Demo features, ghi lại lesson learned   | 1 ngày         | ✅         |
| **Sprint 4** | Build APK & Device Testing      | Build release APK, test trên devices    | 2 ngày         | ✅         |
|              | Comprehensive Testing           | E2E testing, performance testing        | 2 ngày         | ✅         |
|              | Báo cáo tài liệu & Thuyết trình | Viết báo cáo Word, chuẩn bị slide       | 2 ngày         | ✅         |
|              | Final Demo & Sign-off           | Demo toàn bộ dự án cho mentor/client    | 1 ngày         | ✅         |

---

#### **2. Nguyễn Văn Duy (Backend - Core Logic)**

| Sprint       | Công Việc                     | Mô Tả Chi Tiết                                 | Thời Gian Est. | Trạng Thái |
| ------------ | ----------------------------- | ---------------------------------------------- | -------------- | ---------- |
| **Sprint 1** | Thiết kế schema MongoDB       | Thiết kế Collection User, Transaction, Wallet  | 2 ngày         | ✅         |
|              | ERD Diagram                   | Vẽ Entity Relationship Diagram                 | 1 ngày         | ✅         |
| **Sprint 2** | API Filter Transaction        | Lọc theo: date range, category, type (thu/chi) | 3 ngày         | ✅         |
|              | Unit Test Transaction Service | Viết test cho filter logic                     | 1 ngày         | ✅         |
| **Sprint 3** | API Statistics (Aggregation)  | Tính: tổng thu, tổng chi, số dư theo tháng     | 3 ngày         | ✅         |
|              | Performance Optimization      | Optimize query, add index                      | 1 ngày         | ✅         |
|              | Wallet Transfer Logic         | Kiểm tra điều kiện số dư, xử lý transaction    | 2 ngày         | ✅         |
| **Sprint 4** | Performance Tuning            | Đo latency, tối ưu slow query                  | 2 ngày         | ✅         |
|              | API Documentation             | Hoàn chỉnh Swagger docs                        | 1 ngày         | ✅         |

---

#### **3. Vũ Ngọc Bảo (Backend - CRUD & Docs)**

| Sprint       | Công Việc                   | Mô Tả Chi Tiết                             | Thời Gian Est. | Trạng Thái |
| ------------ | --------------------------- | ------------------------------------------ | -------------- | ---------- |
| **Sprint 1** | Base Code Backend           | Khởi tạo Express app, middleware setup     | 2 ngày         | ✅         |
|              | Error Handler Middleware    | Thiết lập consistent error handling        | 1 ngày         | ✅         |
| **Sprint 2** | API Login/Register          | Implement xác thực JWT, bcrypt             | 3 ngày         | ✅         |
|              | Swagger Documentation       | Viết spec cho Auth API                     | 1 ngày         | ✅         |
|              | Unit Test Auth              | Test login/register flow                   | 1 ngày         | ✅         |
| **Sprint 3** | CRUD API (C/R/U/D)          | Implement tất cả transaction CRUD endpoint | 3 ngày         | ✅         |
|              | Validation & Error Handling | Joi validation, chi tiết error message     | 1 ngày         | ✅         |
|              | Unit Test CRUD              | Test create, update, delete logic          | 1 ngày         | ✅         |
| **Sprint 4** | Hoàn thiện Swagger Docs     | Update docs với tất cả endpoint            | 2 ngày         | ✅         |
|              | Integration Test            | Test tích hợp giữa các service             | 1 ngày         | ✅         |
|              | Deployment Setup            | Chuẩn bị cho Render deploy                 | 1 ngày         | ✅         |

---

#### **4. Trịnh Thái Sơn (Mobile - Transaction & Home)**

| Sprint       | Công Việc                          | Mô Tả Chi Tiết                              | Thời Gian Est. | Trạng Thái |
| ------------ | ---------------------------------- | ------------------------------------------- | -------------- | ---------- |
| **Sprint 1** | Base Code Mobile                   | Khởi tạo Flutter project, folder structure  | 1 ngày         | ✅         |
| **Sprint 2** | Home Screen Integration            | Kết nối Home Screen với API lấy transaction | 2 ngày         | ✅         |
|              | Pull-to-refresh & Skeleton Loading | Implement refresh & loading UI              | 1 ngày         | ✅         |
|              | Widget Testing                     | Viết widget test cho Home Screen            | 1 ngày         | ✅         |
| **Sprint 3** | Refactor Home Screen               | Cập nhật Home để hiển thị CRUD realtime     | 2 ngày         | ✅         |
|              | Safety & Error Handling            | Chặn crash khi lỗi API hoặc mất mạng        | 1 ngày         | ✅         |
|              | Profile Screen & Logout            | Tạo Profile tab, logout flow                | 2 ngày         | ✅         |
| **Sprint 4** | UI Polish & Responsive             | Tối ưu UI cho các màn hình khác nhau        | 2 ngày         | ✅         |
|              | Performance Testing                | Test scrolling, loading performance         | 1 ngày         | ✅         |
|              | Final QA & Screenshots             | Chuẩn bị screenshot cho báo cáo             | 1 ngày         | ✅         |

---

#### **5. Lê Đức Anh (Mobile - Wallet & Statistics)**

| Sprint       | Công Việc                      | Mô Tả Chi Tiết                              | Thời Gian Est. | Trạng Thái |
| ------------ | ------------------------------ | ------------------------------------------- | -------------- | ---------- |
| **Sprint 1** | Design Study                   | Nghiên cứu Flutter widget, provider pattern | 1 ngày         | ✅         |
| **Sprint 2** | Transaction Form UI            | Tạo Form Thêm/Sửa giao dịch                 | 2 ngày         | ✅         |
|              | Form Validation                | Validate input: số tiền, danh mục, ngày     | 1 ngày         | ✅         |
|              | API Integration                | Kết nối Form với API Add/Update             | 1 ngày         | ✅         |
| **Sprint 3** | Wallet Screen MVP              | Tạo màn hình quản lý ví                     | 2 ngày         | ✅         |
|              | Wallet Transfer Feature        | Implement chuyển tiền giữa ví               | 2 ngày         | ✅         |
|              | Statistics Screen              | Tạo màn hình thống kê KPI                   | 2 ngày         | ✅         |
|              | Charts & Visualizations        | Vẽ biểu đồ danh mục, trend                  | 1 ngày         | ✅         |
| **Sprint 4** | UI Enhancement                 | Tối ưu Wallet & Statistics UI               | 1 ngày         | ✅         |
|              | Theme & Typography Consistency | Unify font, color palette                   | 1 ngày         | ✅         |
|              | Widget Testing                 | Test Wallet & Stats widgets                 | 1 ngày         | ✅         |

---

### 2.3.3 Bảng Phân Công Người Theo Giai Đoạn

| Giai Đoạn    | Mai Huy Minh | Nguyễn Văn Duy | Vũ Ngọc Bảo | Trịnh Thái Sơn | Lê Đức Anh |
| ------------ | ------------ | -------------- | ----------- | -------------- | ---------- |
| **Sprint 1** | 100%         | 60%            | 80%         | 40%            | 20%        |
| **Sprint 2** | 80%          | 70%            | 80%         | 80%            | 80%        |
| **Sprint 3** | 70%          | 80%            | 70%         | 70%            | 90%        |
| **Sprint 4** | 90%          | 50%            | 60%         | 70%            | 50%        |

_Tỷ lệ phần trăm biểu thị mức độ tham gia công việc của mỗi thành viên tại mỗi sprint_

---

## 2.4 Kết Luận

Dự án SmartSpender được quản lý bằng phương pháp **Agile Scrum** với 4 Sprint kéo dài từ 02/02/2026 đến 28/03/2026 (tổng **8 tuần**).

### Điểm Mạnh Của Quy Hoạch:

1. ✅ **Rõ ràng & Chi tiết**: Mỗi Sprint có mục tiêu, timeline, công việc, người phụ trách cụ thể.
2. ✅ **Phân công hợp lý**: Dựa trên kỹ năng từng thành viên - Backend core logic/dev setup, Mobile UI/integration.
3. ✅ **Theo dõi realtime**: Bảng lập lịch giúp team track progress, phát hiện delay sớm.
4. ✅ **Linh hoạt**: Mỗi Sprint có 2 giai đoạn (tập trung vs nhẹ nhàng) để xử lý việc bất ngờ.

### Rủi Ro & Giảm Thiểu:

| Rủi Ro                         | Giảm Thiểu                                     |
| ------------------------------ | ---------------------------------------------- |
| Delay kỹ thuật (Database, API) | Dự phòng 3-5 ngày buffer ở cuối mỗi sprint     |
| Lỗi tích hợp Mobile-Backend    | Code Review chặt chẽ, daily standup            |
| Quá tải UI/UX sprint 4         | UI đã sơ bộ từ Sprint 1, chỉ polish ở Sprint 4 |
| Chất lượng code                | Unit test bắt buộc, Swagger docs bắt buộc      |
