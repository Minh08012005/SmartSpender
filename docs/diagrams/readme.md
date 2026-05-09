# Diagrams Documentation

Tai lieu trong thu muc nay gom cac so do va mo ta lien quan den luong tuong tac giua Flutter Provider va Backend.

## Tep moi duoc bo sung

- `flutter_state_provider_backend_interaction.md`: Mo ta tong quan kien truc tuong tac giua UI Flutter, Provider, service layer va Backend.
- `activity_statistics.png`: Activity diagram cho man hinh thong ke va luong goi API statistics.
- `sequence_crud_transaction.png`: Sequence diagram cho luong CRUD giao dich giua Flutter, Provider va Backend.

- `mermaid_sequence.md`: Phiên bản sequence diagram (Mermaid) đã cập nhật, thể hiện wallet update và client normalization.
- `mermaid_activity.md`: Phiên bản activity diagram (Mermaid) đã cập nhật, thể hiện case Token expired và filter flow.
- `examples.md`: Ví dụ request/response (POST /api/transactions, GET /api/statistics/summary) để tiện copy vào báo cáo.

## 📊 Thiết Kế Dữ Liệu (Database Schema) - BỔ SUNG MỚI

### 3 Tài Liệu Chính về MongoDB Schema

#### 1. **mongodb_erd_diagram.md** (Sơ Đồ Quan Hệ Thực Thể)

- 📌 **Mục đích**: Vẽ quan hệ giữa các collections trong MongoDB
- 📋 **Nội dung**:
  - ERD (Entity Relationship Diagram) - Sơ đồ quan hệ thực thể
  - Các quan hệ 1:N giữa Users ↔ Wallets, Transactions, WalletTransfers, Notifications
  - Mô tả chi tiết từng trường và ý nghĩa
  - Danh sách các indexes và lý do
  - Embedding vs Referencing pattern
  - Data Flow Diagram
  - Các use cases và cách dữ liệu được sử dụng

#### 2. **mongodb_schema_details.md** (Chi Tiết Cấu Trúc Collections)

- 📌 **Mục đích**: Mô tả chi tiết schema, field, constraints cho mỗi collection
- 📋 **Nội dung**:
  - **5 Collections chính**:
    1. **Users** - Thông tin người dùng (email, password, fullName)
    2. **Wallets** - Ví tiền (cash, bank, ewallet) - 3 ví mặc định/user
    3. **Transactions** - Giao dịch (income/expense) với category
    4. **WalletTransfers** - Chuyển tiền nội bộ giữa các ví
    5. **Notifications** - Thông báo cho người dùng
  - Mô tả chi tiết từng field, type, validation
  - Example documents (JSON) cho mỗi collection
  - Business rules & constraints
  - Query patterns thường dùng
  - Migration & seeding data
  - Data size estimation
  - Security considerations
  - Ghi chú về các cải tiến tương lai

#### 3. **mongodb_class_architecture.md** (Diagram Kiến Trúc & Class)

- 📌 **Mục đích**: Vẽ kiến trúc toàn bộ hệ thống và mối quan hệ classes
- 📋 **Nội dung** (Mermaid diagrams):
  - **Class Diagram** - Mối quan hệ giữa 5 entities
  - **ERD (Mermaid)** - Biểu đồ quan hệ thực thể tương tác
  - **Data Flow Architecture** - Luồng từ Frontend → API → Service → Models → MongoDB
  - **Transaction Flow** - Chi tiết sequence khi tạo giao dịch
  - **Wallet Transfer Flow** - Chi tiết sequence khi chuyển tiền
  - **Statistic Aggregation** - Pipeline thống kê
  - **Security Model** - Các lớp validation & security
  - **Index Strategy** - Chiến lược indexing
  - **Growth Roadmap** - Phát triển schema trong tương lai
  - **Collection Statistics** - Phân bổ dữ liệu
  - **Performance Considerations** - Query performance

### Cách Sử Dụng

1. **Để hiểu cấu trúc dữ liệu**:
   - Đọc `mongodb_erd_diagram.md` để xem quan hệ toàn cục
   - Mở `mongodb_class_architecture.md` để xem biểu đồ Mermaid

2. **Để implement schema**:
   - Tham khảo `mongodb_schema_details.md` cho chi tiết các fields
   - Copy example documents để hiểu format dữ liệu
   - Dùng query patterns cho việc implement

3. **Để trình bày/báo cáo**:
   - Sử dụng diagrams từ `mongodb_class_architecture.md`
   - Tham khảo nội dung ERD từ `mongodb_erd_diagram.md`

---

## Tep dung chung hien co

- `shared/3_tier.md`
- `shared/auth_flow.md`
- `shared/ARCHITECTURE_SLIDE.md`
- `shared/COMPREHENSIVE_ARCHITECTURE_VI.md`
