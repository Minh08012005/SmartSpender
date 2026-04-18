# SmartSpender - Timeline cải tiến lịch tháng và mục tiêu chi tiêu

## 1. Mục tiêu và nguyên tắc làm việc

Đợt này chỉ cải tiến trên nền code hiện có, không đụng vào logic lõi đang ổn định. Mục tiêu là làm rõ hơn màn Thống kê để người dùng xem được lịch tháng, giao dịch theo ngày và mục tiêu chi tiêu tháng.

Phạm vi làm:

- Mở rộng màn Thống kê hiện tại để có lịch tháng trực quan.
- Hiển thị tổng chi, tổng thu, số dư theo ngày trong tháng.
- Thêm mục tiêu chi tiêu tháng để đối chiếu với chi tiêu thực tế.
- Cho phép bấm vào ngày để xem danh sách giao dịch của ngày đó.

Phạm vi không làm:

- Không sửa core logic đăng nhập, ví, CRUD giao dịch hiện có.
- Không làm budget theo từng danh mục.
- Không làm các biểu đồ nâng cao ngoài phạm vi lịch tháng.

## 2. UI và backend hiện đang nằm ở đâu

### UI hiện tại

- Tab Thống kê đang nằm ở [mobile/lib/navigation/main_navigation.dart](mobile/lib/navigation/main_navigation.dart).
- Màn Thống kê hiện tại nằm ở [mobile/lib/views/statistic/statistic_screen.dart](mobile/lib/views/statistic/statistic_screen.dart).
- Bộ chọn tháng đang nằm ở [mobile/lib/views/statistic/widgets/period_picker_widget.dart](mobile/lib/views/statistic/widgets/period_picker_widget.dart).
- Logic format tiền, nhóm danh mục, helper thống kê nằm ở [mobile/lib/views/statistic/statistic_utils.dart](mobile/lib/views/statistic/statistic_utils.dart).

### Backend hiện tại

- Route thống kê nằm ở [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js).
- Controller thống kê nằm ở [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js).
- Service thống kê nằm ở [backend/services/statistic.service.js](backend/services/statistic.service.js).
- Route giao dịch nằm ở [backend/routes/transaction_routes.js](backend/routes/transaction_routes.js).
- Controller giao dịch nằm ở [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js).
- Service giao dịch nằm ở [backend/services/transaction.service.js](backend/services/transaction.service.js).

## 3. Vai trò từng người

### Minh

- Vai trò: UI lead, review và điều phối tích hợp.
- Nhiệm vụ chính:
  - Code UI trước bằng dummy data để khóa luồng người dùng.
  - Chốt format response để backend bám theo contract UI.
  - Làm phần UI lịch tháng trên màn Thống kê.
  - Ghép mục tiêu chi tiêu tháng và trạng thái dương/âm.
  - Review code của Nam, Ngọc Anh, Chúc khi tích hợp API thật.
  - Điều phối task khi có API thay đổi field.

### Nam

- Vai trò: backend API cho thống kê theo ngày.
- Nhiệm vụ chính:
  - Mở rộng logic từ [backend/services/statistic.service.js](backend/services/statistic.service.js).
  - Thêm hàm tổng hợp theo ngày trong tháng.
  - Cập nhật [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js) nếu cần thêm endpoint.
  - Cập nhật [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js) và Swagger comment nếu có endpoint mới.

### Ngọc Anh

- Vai trò: backend API cho mục tiêu chi tiêu tháng.
- Nhiệm vụ chính:
  - Thiết kế cách lưu hoặc trả về budget tháng.
  - Mở rộng [backend/services/statistic.service.js](backend/services/statistic.service.js) hoặc tạo service mới nếu cần.
  - Cập nhật [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js) để trả budget.
  - Nếu budget cần lưu riêng, tạo model/route tối thiểu, không làm phức tạp.

### Chúc

- Vai trò: backend API cho giao dịch theo ngày và kiểm thử.
- Nhiệm vụ chính:
  - Mở rộng [backend/services/transaction.service.js](backend/services/transaction.service.js) để lọc giao dịch theo một ngày.
  - Cập nhật [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js) nếu cần trả thêm endpoint hoặc query mới.
  - Viết Postman collection và test case cho các endpoint mới.
  - Kiểm tra edge case như ngày không có giao dịch, từ/ngày không hợp lệ.

### Xuân

- Vai trò: code nhẹ, test và tổng hợp.
- Nhiệm vụ chính:
  - Làm các phần code nhẹ như validator nhỏ, Swagger comment hoặc test helper nếu cần.
  - Ghi ngắn mô tả endpoint và response mẫu.
  - Tổng hợp checklist, trạng thái task và các điểm còn thiếu.
  - Chịu trách nhiệm Postman/test nhanh cho các API mới.
  - Hỗ trợ đối chiếu UI nào gọi API nào.

## 4. Chia task theo file cụ thể

### Nam cần đụng file nào

- [backend/services/statistic.service.js](backend/services/statistic.service.js)
- [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js)
- [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js)
- Có thể thêm/điều chỉnh validator nếu endpoint mới cần.

### Ngọc Anh cần đụng file nào

- [backend/services/statistic.service.js](backend/services/statistic.service.js) nếu budget lấy chung logic thống kê.
- [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js)
- [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js)
- Nếu tách riêng budget thì tạo file mới trong backend theo hướng đơn giản nhất.

### Chúc cần đụng file nào

- [backend/services/transaction.service.js](backend/services/transaction.service.js)
- [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js)
- [backend/routes/transaction_routes.js](backend/routes/transaction_routes.js) nếu cần endpoint mới.

### Minh cần đụng file nào

- [mobile/lib/views/statistic/statistic_screen.dart](mobile/lib/views/statistic/statistic_screen.dart)
- [mobile/lib/views/statistic/widgets/period_picker_widget.dart](mobile/lib/views/statistic/widgets/period_picker_widget.dart)
- Tạo thêm widget mới trong [mobile/lib/views/statistic/widgets/](mobile/lib/views/statistic/widgets/) cho lịch tháng nếu cần.
- [mobile/lib/data/providers/statistic_provider.dart](mobile/lib/data/providers/statistic_provider.dart)
- [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart)

### Xuân cần đụng file nào

- [TIMELINE_CAI_TIEN_LICH_THANG.md](TIMELINE_CAI_TIEN_LICH_THANG.md)
- Có thể tạo thêm file mô tả API trong root hoặc backend/docs nếu team cần.
- Ưu tiên việc ghi chú, tổng hợp, test và chỉnh phần code nhẹ hơn là code nghiệp vụ lớn.

## 5. Timeline 5 ngày theo mô hình UI-first

### Ngày 1: Minh dựng UI trước bằng dummy và khóa contract

Mục tiêu:

- Có bản UI chạy được ngay trên mobile mà chưa cần API thật.
- Khóa contract JSON để backend bám theo, tránh lệch field.

Việc làm cụ thể:

- Minh: sửa [mobile/lib/views/statistic/statistic_screen.dart](mobile/lib/views/statistic/statistic_screen.dart) để thêm khối lịch tháng, mục tiêu tháng, và luồng bấm ngày.
- Minh: tạo widget lịch tháng trong [mobile/lib/views/statistic/widgets/](mobile/lib/views/statistic/widgets/).
- Minh: mở rộng [mobile/lib/data/providers/statistic_provider.dart](mobile/lib/data/providers/statistic_provider.dart) và [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart) ở chế độ mock.
- Nam, Ngọc Anh, Chúc: dựa vào UI đang chạy để chốt response mẫu theo đúng dữ liệu mà mobile cần.
- Xuân: tạo checklist test case đầu tiên dựa trên UI và contract.

Output cuối ngày:

- UI lịch tháng chạy bằng dummy.
- Bộ JSON contract đã chốt.
- Danh sách endpoint cần code đã cố định.

### Ngày 2: Backend code theo contract đã khóa

Mục tiêu:

- Có API thật cho thống kê theo ngày trong tháng.

Việc làm cụ thể:

- Nam: code API thống kê theo ngày trong tháng.
- Minh: review response so với contract, không đổi tùy tiện field.
- Chúc: test endpoint bằng Postman với case có dữ liệu và rỗng dữ liệu.
- Xuân: hỗ trợ test nhanh và cập nhật checklist pass/fail.

Output cuối ngày:

- API daily stats chạy được theo contract.
- Có kết quả test cơ bản cho endpoint này.

### Ngày 3: Hoàn thiện budget tháng và giao dịch theo ngày

Mục tiêu:

- Có đủ API để thay thế dần dummy data.

Việc làm cụ thể:

- Ngọc Anh: code API budget tháng (lấy/lưu mục tiêu tháng).
- Chúc: code API giao dịch theo ngày.
- Nam: hỗ trợ query/aggregation nếu có phần dùng chung.
- Minh: ghép thử 1 phần API thật vào mobile, phần còn lại vẫn để mock nếu backend chưa xong.
- Xuân: test Postman cho budget và giao dịch theo ngày, ghi bug theo checklist.

Output cuối ngày:

- API budget tháng chạy được.
- API giao dịch theo ngày chạy được.
- Mobile ghép thật ít nhất 1 endpoint.

### Ngày 4: Chuyển mobile từ mock sang API thật

Mục tiêu:

- Hoàn tất tích hợp mobile-backend theo contract đã chốt.

Việc làm cụ thể:

- Minh: chuyển provider từ mock sang API cho các phần đã sẵn sàng.
- Minh: xử lý loading, empty state, error state trên màn Thống kê.
- Nam, Ngọc Anh, Chúc: fix nhanh các mismatch field hoặc logic nếu phát sinh khi ghép thật.
- Xuân: chạy test regression luồng đổi tháng, bấm ngày, lưu mục tiêu tháng.

Output cuối ngày:

- Màn lịch tháng chạy dữ liệu thật.
- Mục tiêu tháng và danh sách giao dịch theo ngày chạy dữ liệu thật.

### Ngày 5: Ổn định bản demo

Mục tiêu:

- Chốt bản demo ổn định, ít rủi ro nhất.

Việc làm cụ thể:

- Minh: review tổng thể UI/UX và fix lỗi tích hợp cuối.
- Nam: rà endpoint thống kê theo ngày và tối ưu lỗi biên.
- Ngọc Anh: rà endpoint budget tháng và validate input.
- Chúc: rà endpoint giao dịch theo ngày và Postman collection cuối.
- Xuân: tổng hợp checklist pass/fail, retest critical flow và ghi issue còn lại.

Output cuối ngày:

- Bản demo chạy ổn định theo luồng đầy đủ.
- API và UI đồng bộ theo một contract duy nhất.
- Team có checklist kiểm thử rõ ràng trước khi demo.

## 6. Cách hiểu task theo mức độ ưu tiên

### Ưu tiên cao

- Nam: thống kê theo ngày.
- Ngọc Anh: budget tháng.
- Chúc: giao dịch theo ngày.

### Ưu tiên trung bình

- Minh: UI lịch tháng, ghép dữ liệu, điều phối contract.
- Xuân: code nhẹ, test, checklist và tổng hợp tiến độ.

## 7. Tiêu chí hoàn thành cho từng task

Một task chỉ tính là xong khi:

- Biết chính xác file nào đã sửa.
- API trả đúng format.
- UI gọi được và render được.
- Không ảnh hưởng core logic cũ.
- Có test hoặc Postman request tương ứng.

## 8. Những thứ nên tránh để không trễ tiến độ

- Không mở rộng sang budget theo từng danh mục.
- Không thêm logic recurring phức tạp.
- Không thay đổi quá nhiều trong logic giao dịch cũ.
- Không tách quá nhiều màn hình nếu chưa thật sự cần.

## 9. Luồng người dùng cho tính năng mới

Luồng người dùng mục tiêu (khi đã hoàn thành):

1. Người dùng mở app và vào tab Thống kê.
2. Màn hình mặc định chọn tháng hiện tại.
3. App hiển thị tổng thu, tổng chi, số dư tháng.
4. App hiển thị lịch tháng với dữ liệu theo từng ngày.
5. App hiển thị mục tiêu chi tiêu tháng và phần còn lại.
6. Người dùng bấm vào một ngày trong lịch.
7. App hiển thị danh sách giao dịch của ngày đó.
8. Người dùng đổi tháng thì dữ liệu tải lại theo tháng mới.

Kết quả người dùng nhận được:

- Nhìn nhanh được ngày nào chi nhiều, ngày nào có thu nhập.
- Biết tháng hiện tại đang dương hay âm.
- Biết còn bao nhiêu so với mục tiêu chi tiêu tháng.

## 10. Luồng mobile kết nối backend

Luồng kỹ thuật từ UI đến backend:

1. UI ở [mobile/lib/views/statistic/statistic_screen.dart](mobile/lib/views/statistic/statistic_screen.dart) gọi provider khi vào màn hoặc đổi tháng.
2. Provider ở [mobile/lib/data/providers/statistic_provider.dart](mobile/lib/data/providers/statistic_provider.dart) gọi API thống kê tháng và thống kê theo ngày.
3. Provider ở [mobile/lib/data/providers/transaction_provider.dart](mobile/lib/data/providers/transaction_provider.dart) gọi API giao dịch theo tháng hoặc theo ngày.
4. ApiService gửi request lên backend kèm token Bearer.
5. Backend nhận ở route, đi qua controller, rồi xử lý ở service:
   - [backend/routes/statistic_routes.js](backend/routes/statistic_routes.js)
   - [backend/controllers/statistic.controller.js](backend/controllers/statistic.controller.js)
   - [backend/services/statistic.service.js](backend/services/statistic.service.js)
   - [backend/routes/transaction_routes.js](backend/routes/transaction_routes.js)
   - [backend/controllers/transaction_controller.js](backend/controllers/transaction_controller.js)
   - [backend/services/transaction.service.js](backend/services/transaction.service.js)
6. Backend trả JSON về provider.
7. Provider cập nhật state và notifyListeners.
8. UI tự rebuild để hiển thị lịch, KPI, budget và danh sách giao dịch theo ngày.

Nguyên tắc làm để không vỡ code cũ:

- UI không gọi API trực tiếp, chỉ gọi qua provider.
- Giữ response mới tương thích với màn cũ.
- Chỉ mở rộng route/controller/service, không phá logic cũ.

## 11. Danh sách API mở rộng đề xuất

Tối thiểu cần thêm các API sau:

- API thống kê theo ngày trong tháng:
  - Input: month, year
  - Output: danh sách từng ngày gồm totalIncome, totalExpense, balance, transactionCount

- API budget mục tiêu tháng:
  - Input: month, year, targetAmount
  - Output: targetAmount, actualExpense, remaining, status

- API giao dịch theo ngày:
  - Input: date (hoặc from/to là cùng một ngày)
  - Output: danh sách giao dịch của ngày được chọn

Gợi ý phân vai gắn với API:

- Nam: API thống kê theo ngày.
- Ngọc Anh: API budget mục tiêu tháng.
- Chúc: API giao dịch theo ngày.
- Xuân: test Postman theo từng API và tổng hợp checklist pass/fail.

## 12. Kết luận

Cách làm an toàn nhất là:

- Backend chỉ thêm dữ liệu phục vụ lịch tháng và budget.
- Minh làm UI trước bằng dummy, sau đó ghép API thật ở màn Thống kê hiện có.
- Xuân tập trung test/Postman/checklist và nhận code nhẹ khi cần.
- Nam, Ngọc Anh, Chúc tập trung phần code API chính.

Nếu bám đúng file và timeline này, team sẽ chia task nhanh hơn, phối hợp rõ hơn, và đủ khả năng hoàn thành trong 4-5 ngày.
