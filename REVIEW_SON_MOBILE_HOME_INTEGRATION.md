# Review tổng thể phần mobile của Sơn

## Phạm vi review

- Màn hình Home và luồng fetch dữ liệu thật cho task `Home Screen Integration & Data Fetching`.
- Các file trọng tâm đã đọc:
  - `mobile/lib/views/home/home_screen.dart`
  - `mobile/lib/views/home/widgets/transaction_item.dart`
  - `mobile/lib/data/providers/transaction_provider.dart`
  - `mobile/lib/data/models/transaction_model.dart`
  - `mobile/lib/core/services/api_service.dart`
- Đối chiếu thêm với contract backend:
  - `backend/docs/transaction.swagger.yaml`
  - `backend/models/transaction_schema.js`
  - `backend/validators/transaction.validator.js`
  - `backend/services/transaction.service.js`

## Kết luận ngắn

Phần xử lý của Sơn cho Home hiện tại có nền tảng ổn: đã có state flow rõ ràng `loading -> error -> empty -> data`, đã gọi API thật, có `RefreshIndicator`, và các file chính không có lỗi analyzer tại thời điểm review.

Tuy nhiên, nếu đánh giá theo mức độ sẵn sàng để ghép backend-mobile mượt và ít phát sinh lỗi hồi quy, vẫn còn một số điểm cần xử lý trước. Có 2 vấn đề nên ưu tiên cao vì ảnh hưởng trực tiếp đến tính đúng của dữ liệu và độ bền contract khi tích hợp thật.

## Findings chính

### 1. Mức độ: Cao

### `TransactionModel` đang lệch contract backend ở trường `title`

**Vị trí liên quan**

- Mobile: `mobile/lib/data/models/transaction_model.dart:12-48`
- Backend schema: `backend/models/transaction_schema.js:48`
- Backend validator create: `backend/validators/transaction.validator.js:61`
- Backend validator update: `backend/validators/transaction.validator.js:74`

**Hiện trạng**

- `TransactionModel` hiện chỉ giữ các field: `id`, `amount`, `category`, `date`, `note`, `type`.
- `fromJson()` không parse `title`.
- `toJson()` cũng không gửi `title` lên backend.
- Trong khi đó backend đang coi `title` là field bắt buộc khi tạo giao dịch và là field hợp lệ khi cập nhật.

**Rủi ro thực tế**

- Nếu Sơn hoặc thành viên khác dùng `TransactionProvider.addTransaction()` với model hiện tại, request tạo transaction có thể bị backend trả `400` vì thiếu `title`.
- Với `updateTransaction()`, nếu sau này form sửa giao dịch dùng chính `TransactionModel` hiện tại, dữ liệu `title` từ backend sẽ bị mất khỏi vòng đời model mobile.
- Đây là kiểu lỗi rất dễ bị bỏ sót khi Home chỉ mới đọc danh sách, nhưng sẽ lộ ra ngay khi bước CRUD hoặc đồng bộ dữ liệu thật mở rộng.

**Khuyến nghị xử lý**

1. Thêm field `title` vào `TransactionModel`.
2. Parse `title` trong `fromJson()`.
3. Gửi `title` trong `toJson()`.
4. Rà lại `dummy_transactions.dart`, các form tạo/sửa transaction và widget hiển thị để dùng `title` đúng vai trò.
5. Nếu UI Home muốn hiện danh mục là chính, vẫn nên giữ `title` trong model để không làm hỏng contract.

**Giải thích ngắn để Sơn xử lý tiếp**

Phần này không phải lỗi “UI Home không chạy”, mà là lỗi “model mobile chưa phản ánh đầy đủ contract backend”. Nếu không sửa từ bây giờ, lúc tích hợp sâu hơn sẽ phát sinh lỗi chéo giữa Home, Add, Edit và test API.

### 2. Mức độ: Cao

### Tổng thu/chi ở header có thể bị stale sau CRUD hoặc sau lần fetch lỗi

**Vị trí liên quan**

- `mobile/lib/data/providers/transaction_provider.dart:19-20`
- `mobile/lib/data/providers/transaction_provider.dart:43`
- `mobile/lib/data/providers/transaction_provider.dart:51`
- `mobile/lib/data/providers/transaction_provider.dart:121-123`
- `mobile/lib/data/providers/transaction_provider.dart:153`
- `mobile/lib/data/providers/transaction_provider.dart:193`
- `mobile/lib/data/providers/transaction_provider.dart:225`

**Hiện trạng**

- Provider lưu `_remoteTotalIncome` và `_remoteTotalExpense`.
- Getter `totalIncome` và `totalExpense` luôn ưu tiên dùng 2 giá trị remote này nếu chúng khác `null`.
- Hai biến này chỉ được gán khi `fetchTransactions()` thành công.
- Nhưng khi `addTransaction()`, `deleteTransaction()` hoặc `updateTransaction()` chạy, provider chỉ sửa `_transactions`, không cập nhật lại 2 biến stats remote.
- Khi fetch lỗi hoặc payload không có `stats`, 2 giá trị remote cũ cũng không bị reset.

**Rủi ro thực tế**

- Home header có thể hiển thị tổng thu/chi cũ dù list transaction bên dưới đã thay đổi.
- Sau khi thêm, sửa, xóa một giao dịch xong mà chưa refetch, phần header và phần danh sách có thể lệch nhau.
- Sau một lần fetch thành công rồi một lần fetch lỗi, header vẫn có thể giữ số liệu cũ, gây cảm giác app đang hiển thị “nửa cũ nửa mới”.

**Khuyến nghị xử lý**

1. Chọn một nguồn sự thật duy nhất cho phần summary.
2. Nếu Home chỉ cần dữ liệu đang hiển thị trên list hiện tại, nên tính `totalIncome` và `totalExpense` trực tiếp từ `_transactions`.
3. Nếu vẫn muốn tận dụng `stats` từ backend, cần thêm hàm đồng bộ stats sau `add/update/delete` và reset stats khi fetch lỗi hoặc khi `reset()`.
4. Nên có test riêng cho case: `fetch -> add -> header cập nhật đúng`, `fetch -> delete -> header cập nhật đúng`, `fetch success -> fetch fail -> header không giữ số liệu stale`.

**Giải thích ngắn để Sơn xử lý tiếp**

Đây là lỗi kiểu “logic state chưa kín”. Bình thường nhìn qua rất dễ tưởng ổn vì list đã đổi và `notifyListeners()` vẫn chạy, nhưng header lại đang đọc cache stats khác với list.

### 3. Mức độ: Trung bình

### Loading UI của Home chưa khớp checklist task và chưa tối ưu cho refresh

**Vị trí liên quan**

- `mobile/lib/views/home/home_screen.dart:190-242`
- `mobile/lib/main.dart:91`

**Hiện trạng**

- Home đang dùng `CircularProgressIndicator` cho loading state.
- Trong task checklist đã ghi rõ phần design có `Skeleton Loading`.
- Khi pull-to-refresh, `provider.isLoading` chuyển `true`, nên body bị thay toàn bộ bằng loading spinner toàn màn hình thay vì giữ danh sách cũ và chỉ hiện refresh indicator.

**Rủi ro thực tế**

- Trải nghiệm refresh bị “giật”, mất context của danh sách đang xem.
- Lệch với checklist task đã đặt ra ban đầu.
- Khó test UX hơn vì `initial load` và `refreshing` đang dùng chung một cờ state.

**Khuyến nghị xử lý**

1. Tách `initialLoading` và `isRefreshing` thành 2 trạng thái khác nhau.
2. Giữ danh sách cũ khi refresh, chỉ dùng `RefreshIndicator` cho thao tác kéo xuống.
3. Nếu muốn bám đúng checklist task, thêm skeleton widget cho initial load.

**Giải thích ngắn để Sơn xử lý tiếp**

Phần này không phải blocker về API, nhưng là điểm nên hoàn thiện trước khi demo tích hợp thật vì người xem sẽ cảm nhận ngay sự mượt hay không mượt của Home.

### 4. Mức độ: Trung bình

### Kiểm thử mobile cho luồng Home hiện gần như chưa có, và test hiện tại đang là test mẫu lỗi thời

**Vị trí liên quan**

- Mobile test hiện có: `mobile/test/widget_test.dart`
- Kết quả chạy `flutter test`: fail ở `mobile/test/widget_test.dart:19`

**Hiện trạng**

- Trong thư mục test của mobile hiện chỉ có test mẫu `Counter increments smoke test`.
- Test này không phản ánh app hiện tại và đang fail vì app không còn UI counter mặc định.
- Chưa có test riêng cho `TransactionProvider` hoặc `HomeScreen` ở các case `success`, `empty`, `error`, `refresh`.

**Rủi ro thực tế**

- Khi ghép API thật, team khó biết lỗi nằm ở parsing, state management hay UI rendering.
- Mỗi lần refactor provider hoặc Home sẽ dễ làm hỏng luồng cũ mà không phát hiện sớm.
- Một test mặc định đang fail sẽ làm tín hiệu CI/test readiness bị nhiễu.

**Khuyến nghị xử lý**

1. Xóa hoặc thay thế test counter mặc định.
2. Viết unit test cho `TransactionModel.fromJson()` và `TransactionProvider.fetchTransactions()`.
3. Viết widget test cho Home với 4 trạng thái: loading, error, empty, data.
4. Thêm test cho `pull-to-refresh` và test cho trường hợp contract backend trả `stats` rỗng hoặc `transactions` rỗng.

**Giải thích ngắn để Sơn xử lý tiếp**

Ở giai đoạn hiện tại, thiếu test không chỉ là “chưa đủ đẹp”, mà là thiếu chốt chặn an toàn trước lúc tích hợp thật.

### 5. Mức độ: Thấp đến Trung bình

### `TransactionItem` đang hiển thị raw category, chưa tận dụng dữ liệu mô tả giao dịch

**Vị trí liên quan**

- `mobile/lib/views/home/widgets/transaction_item.dart:31`

**Hiện trạng**

- Item trên Home đang render `transaction.category` làm dòng chính.
- Backend contract lại có `title` là field bắt buộc và phù hợp hơn để hiển thị nội dung giao dịch.
- Nếu backend trả category theo enum chuẩn như `food`, `salary`, `utility`, UI có thể hiển thị hơi thô và kém thân thiện.

**Rủi ro thực tế**

- UI danh sách nhìn ít thông tin hơn dữ liệu backend đang cung cấp.
- Về sau khi cần search, filter, hoặc edit transaction, team sẽ phải bổ sung lại `title` ở nhiều nơi.

**Khuyến nghị xử lý**

1. Dùng `title` làm text chính của item.
2. Hiển thị `category` và/hoặc `note` làm text phụ nếu cần.
3. Nếu muốn giữ category làm nhãn chính, nên có mapping sang label thân thiện hơn thay vì hiển thị raw enum.

## Điểm tốt cần ghi nhận

- `HomeScreen` đã tổ chức state flow tương đối rõ, dễ đọc.
- Có `RefreshIndicator` cho empty, error và data state, tức là Sơn đã nghĩ đến thao tác reload chứ không chỉ fetch một lần.
- `ListView.builder` là lựa chọn đúng cho danh sách dài.
- `TransactionProvider` đã tách trách nhiệm state khỏi UI, thuận lợi cho việc viết test sau này.
- Core files hiện tại không có lỗi analyzer ở phạm vi đã kiểm tra.

## Việc nên ưu tiên làm ngay

### Ưu tiên 1

- Bổ sung `title` vào `TransactionModel` và rà toàn bộ đường đi `fromJson/toJson`.
- Sửa logic summary để tránh stale totals.

### Ưu tiên 2

- Thay test mẫu mặc định bằng test thực tế cho Home và TransactionProvider.
- Tách state `initial loading` với `refreshing`.

### Ưu tiên 3

- Hoàn thiện skeleton loading nếu team vẫn bám checklist task ban đầu.
- Cải thiện `TransactionItem` để hiển thị thông tin giao dịch tự nhiên hơn.

## Gợi ý test case cho Sơn

1. `fetchTransactions()` parse đúng contract backend: `success`, `data.transactions`, `data.stats`.
2. Home hiển thị `CircularProgressIndicator` hoặc skeleton đúng ở lần tải đầu.
3. Home hiển thị empty state khi `transactions = []`.
4. Home hiển thị error state và retry button khi provider có lỗi.
5. Pull-to-refresh gọi lại fetch nhưng không làm mất context danh sách đang có.
6. Sau `add/update/delete`, phần header summary vẫn đúng với danh sách.
7. `TransactionModel.toJson()` gửi đủ field backend yêu cầu, đặc biệt là `title`.

## Chốt lại cho Sơn

Nếu mục tiêu là “Home nối API thật và chạy ổn”, thì phần của Sơn hiện đã đi khá đúng hướng. Nhưng nếu mục tiêu là “sẵn sàng tích hợp thật, ít lỗi phát sinh khi ghép backend-mobile”, thì nên xử lý dứt điểm 2 điểm sau trước:

- Chuẩn hóa lại `TransactionModel` theo contract backend, nhất là field `title`.
- Khóa chặt logic summary để header không bị stale so với list.

Sau khi xong 2 điểm này và thay bộ test mặc định bằng test đúng ngữ cảnh app, phần Home của Sơn sẽ vững hơn đáng kể cho giai đoạn tích hợp tiếp theo.
