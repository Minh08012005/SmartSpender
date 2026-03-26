# Prompt Mẫu: Xây Dựng Wallet Screen MVP - Flutter SmartSpender

> **Dành cho**: AI đối tác xử lý UI Wallet  
> **Ngôn ngữ**: Tiếng Việt + code English  
> **Thời gian ước lượng**: 1.5 - 2 ngày  
> **Mục tiêu**: Hoàn thiện Wallet Screen MVP với quản lý ví nội bộ + điều chuyển tiền giữa các ví

---

## 📋 PHẦN 1: PHÂN TÍCH YÊU CẦU

### 1.1 Phạm vi MVP

Bạn cần xây dựng **WalletScreen** để:

- ✅ Hiển thị **tổng số dư** tất cả ví trên header
- ✅ Hiển thị **danh sách 3 ví mặc định**: Tiền mặt, Ngân hàng, Ví điện tử
- ✅ Cho phép **điều chuyển tiền nội bộ** giữa các ví (không phải chuyển ngân hàng thật)
- ✅ Validation đầy đủ (đủ số dư, ví khác nhau, số tiền > 0)
- ✅ Snackbar feedback rõ ràng (thành công/lỗi)
- ✅ Responsive UI trên màn hình nhỏ

### 1.2 Dữ liệu Ví (Mock Data)

```dart
// Cấu trúc ví
class Wallet {
  final String id;        // 'cash', 'bank', 'ewallet'
  final String name;      // "Tiền mặt", "Ngân hàng", "Ví điện tử"
  final int balance;      // số tiền (VND)
  final IconData icon;    // biểu tượng
  final Color color;      // màu sắc
}
```

**Dữ liệu khởi tạo:**

```json
[
  {
    "id": "cash",
    "name": "Tiền mặt",
    "balance": 1200000,
    "icon": "Icons.wallet_giftcard",
    "color": "Colors.orange"
  },
  {
    "id": "bank",
    "name": "Ngân hàng",
    "balance": 850000,
    "icon": "Icons.account_balance",
    "color": "Colors.blue"
  },
  {
    "id": "ewallet",
    "name": "Ví điện tử",
    "balance": 320000,
    "icon": "Icons.credit_card",
    "color": "Colors.purple"
  }
]
```

**Tính toán tổng số dư**: `totalBalance = cash + bank + ewallet = 2,370,000 VND`

---

## 🎨 PHẦN 2: DESIGN & LAYOUT

### 2.1 Cấu trúc Layout

```
WalletScreen
├─ AppBar
│  └─ "Ví của tôi" (title)
├─ Body (SingleChildScrollView)
│  ├─ Header Card
│  │  ├─ Label: "Tổng số dư"
│  │  └─ Amount: 2.370.000 VND (formatted, bold, large font)
│  ├─ SizedBox (spacing)
│  ├─ Section: "Danh sách ví"
│  │  └─ 3x WalletCard (cash, bank, ewallet)
│  │     ├─ Icon + Name
│  │     ├─ Balance (formatted)
│  │     └─ GestureDetector → mở modal điều chuyển khi tap
│  ├─ SizedBox (spacing)
│  └─ Button Group (2 nút)
│     ├─ "Điều chuyển" (primary button)
│     └─ "Thêm ví" (secondary - có thể placeholder)
└─ Modal (showModalBottomSheet)
   ├─ Title: "Điều chuyển tiền"
   ├─ Form
   │  ├─ Dropdown "Từ ví" [Cash v]
   │  ├─ Dropdown "Đến ví" [Bank v]
   │  ├─ TextFormField "Số tiền" [________]
   │  ├─ TextFormField "Ghi chú" [________] (optional)
   │  └─ Checkbox "Xác nhận điều chuyển" [ ]
   └─ Button Group
      ├─ "Hủy"
      └─ "Xác nhận" (disabled until checkbox checked)
```

### 2.2 Màu sắc & Kiểu chữ

| Thành phần       | Màu                                           | Ghi chú                                |
| ---------------- | --------------------------------------------- | -------------------------------------- |
| Header Card bg   | `Color(0xffF5F5F5)`                           | Xám nhẹ                                |
| Tổng số dư text  | `Colors.black87`                              | Bold, size 24                          |
| Ví card bg       | `Card` default                                | Elevation 2                            |
| Icon đầu card    | Per wallet                                    | Cash=orange, Bank=blue, Ewallet=purple |
| Button primary   | `Theme.primaryColor` hoặc `Color(0xff2A7C76)` | Green theme                            |
| Button secondary | `Colors.grey[600]`                            |                                        |
| Snackbar success | `Colors.green`                                |                                        |
| Snackbar error   | `Colors.red`                                  |                                        |

### 2.3 Định dạng Tiền Tệ

Sử dụng hàm format: **`formatCurrency(amount)` = "2.370.000 VND"**

```dart
String formatCurrency(int amount) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(amount)} VND';
}
```

---

## 🔧 PHẦN 3: LOGIC & VALIDATION

### 3.1 Luật Điều Chuyển Tiền

```
Điều kiện hợp lệ:
✓ Ví nguồn (fromWallet) ≠ Ví đích (toWallet)
✓ Số tiền > 0
✓ Số tiền <= Số dư ví nguồn
✓ Checkbox "Xác nhận" = checked

Hành động:
1. Trừ số tiền khỏi ví nguồn
2. Cộng số tiền vào ví đích
3. Lưu vào local state (hoặc backend nếu có API)
4. Cập nhật UI tức thời
5. Hiển thị snackbar thành công/lỗi
```

### 3.2 Validation & Error Handling

```dart
// Validate form
if (fromWallet == null || toWallet == null) {
  // Error: chọn ví
}
if (fromWallet == toWallet) {
  // Error: "Ví nguồn và ví đích phải khác nhau"
}
if (amount <= 0) {
  // Error: "Số tiền phải lớn hơn 0"
}
if (amount > fromWallet.balance) {
  // Error: "Số dư không đủ. Số dư hiện tại: ${formatCurrency(fromWallet.balance)}"
}
if (!isConfirmed) {
  // Error: "Vui lòng xác nhận điều chuyển"
}
```

### 3.3 State Management

**Sử dụng Provider** (như app hiện tại):

```dart
class WalletProvider extends ChangeNotifier {
  List<Wallet> wallets = [
    Wallet(id: 'cash', name: 'Tiền mặt', balance: 1200000, ...),
    Wallet(id: 'bank', name: 'Ngân hàng', balance: 850000, ...),
    Wallet(id: 'ewallet', name: 'Ví điện tử', balance: 320000, ...),
  ];

  // Hàm điều chuyển tiền
  Future<bool> transferBetweenWallets({
    required String fromWalletId,
    required String toWalletId,
    required int amount,
    required String note,
  }) async {
    // Logic xử lý + notifyListeners()
  }

  int get totalBalance => wallets.fold(0, (sum, w) => sum + w.balance);
}
```

---

## 📱 PHẦN 4: DESIGN PATTERN & REUSABILITY

### 4.1 Component Structure

**File cần tạo/sửa:**

```
lib/views/wallet/
├─ wallet_screen.dart              (main screen)
├─ widgets/
│  ├─ wallet_card.dart             (individual wallet card)
│  ├─ total_balance_card.dart       (header card)
│  └─ transfer_modal_widget.dart    (bottom sheet modal)
└─ providers/
   └─ wallet_provider.dart           (state management)
```

### 4.2 Widget Independence

Mỗi widget phải:

- ❌ Không hardcode color/text (dùng constants từ `lib/core/strings.dart`)
- ✅ Accept parameters (onTap, wallet data, formatted values, ...)
- ✅ Re-usable across screens
- ✅ Responsive design (không fixed width)

### 4.3 Naming Conventions

```dart
// Use consistent naming:
- walletBalanceText → "Số dư"
- transferButtonLabel → "Điều chuyển"
- fromWalletHint → "Chọn ví nguồn"
- toWalletHint → "Chọn ví đích"
- amountInputHint → "Nhập số tiền"
- noteInputHint → "Ghi chú (tùy chọn)"
- confirmTransferText → "Xác nhận điều chuyển"
- insufficientBalanceError → "Số dư không đủ"
```

---

## ✅ PHẦN 5: CHECKLIST TEST & ACCEPTANCE

### 5.1 Unit Test Cases

- [ ] **Test 1**: Hiển thị tổng số dư chính xác (1,200,000 + 850,000 + 320,000 = 2,370,000)
- [ ] **Test 2**: Hiển thị 3 ví card với dữ liệu đúng
- [ ] **Test 3**: Mở modal điều chuyển khi tap vào ví card
- [ ] **Test 4**: Modal có đầy đủ form fields (fromWallet, toWallet, amount, note, checkbox)
- [ ] **Test 5**: Nút "Xác nhận" disabled nếu checkbox không checked
- [ ] **Test 6**: Nút "Xác nhận" disabled nếu amount trống hoặc ≤ 0

### 5.2 Functional Test Cases

| Test ID | Scenario                | Input                                         | Expected Output                                     | Status |
| ------- | ----------------------- | --------------------------------------------- | --------------------------------------------------- | ------ |
| T1      | Điều chuyển hợp lệ      | From=Cash, To=Bank, Amount=100,000            | Cash=1,100,000; Bank=950,000; Snackbar "Thành công" | [ ]    |
| T2      | Ví nguồn = Ví đích      | From=Cash, To=Cash                            | Error message "Ví khác nhau"                        | [ ]    |
| T3      | Số tiền <= 0            | Amount=0 hoặc -100                            | Error message "Số tiền > 0"                         | [ ]    |
| T4      | Số dư không đủ          | From=Cash (1.2M), Amount=2M                   | Error "Số dư không đủ"                              | [ ]    |
| T5      | Không confirm checkbox  | Di out form ko check                          | Snackbar/Error "Xác nhận điều chuyển"               | [ ]    |
| T6      | Refresh UI sau transfer | After successful transfer                     | Tổng số dư không đổi; 2 ví được cập nhật            | [ ]    |
| T7      | Nhiều lần điều chuyển   | Transfer 100K (Cash→Bank), 50K (Bank→Ewallet) | Balances cộng/trừ chính xác, tổng = 2.37M           | [ ]    |
| T8      | UI trên màn nhỏ         | Kiểm tra trên chiều ngang                     | Không tràn chữ, button responsive                   | [ ]    |

### 5.3 Definition of Done (DoD)

- [ ] `WalletScreen` mở từ tab Ví (không còn Placeholder)
- [ ] Hiển thị tổng số dư + 3 ví card chính xác
- [ ] Modal điều chuyển mở/đóng khi tap/hủy
- [ ] Transfer logic thực thi đúng (trừ/cộng số dư)
- [ ] Validation catch tất cả error cases
- [ ] Snackbar show rõ ràng (thành công/lỗi)
- [ ] UI responsive và không tràn text
- [ ] Code pass `flutter analyze` (0 errors/warnings)
- [ ] Code pass `flutter format .`
- [ ] Toàn bộ string lấy từ `lib/core/strings.dart`
- [ ] PR có screenshot trước/sau + test case completed

---

## 🔗 PHẦN 6: INTEGRATION

### 6.1 File cần Sửa

**1) `lib/core/strings.dart`** - Thêm constants sau:

```dart
// Wallet strings
static const String walletTitle = 'Ví của tôi';
static const String totalBalanceLabel = 'Tổng số dư';
static const String walletListLabel = 'Danh sách ví';
static const String transferButtonLabel = 'Điều chuyển';
static const String addWalletButtonLabel = 'Thêm ví'; // placeholder
static const String transferModalTitle = 'Điều chuyển tiền';
static const String fromWalletLabel = 'Từ ví';
static const String toWalletLabel = 'Đến ví';
static const String amountLabel = 'Số tiền';
static const String noteLabel = 'Ghi chú (tùy chọn)';
static const String confirmCheckboxLabel = 'Xác nhận điều chuyển';
static const String cancelButtonLabel = 'Hủy';
static const String confirmButtonLabel = 'Xác nhận';

// Wallet error messages
static const String walletSourceDestinationSame = 'Ví nguồn và ví đích phải khác nhau';
static const String walletAmountMustBePositive = 'Số tiền phải lớn hơn 0';
static const String walletInsufficientBalance = 'Số dư không đủ';
static const String walletTransferSuccess = 'Điều chuyển thành công';
static const String walletTransferFailed = 'Điều chuyển thất bại';
static const String walletPleaseSelectWallet = 'Vui lòng chọn ví';
static const String walletPleaseConfirm = 'Vui lòng xác nhận điều chuyển';

// Wallet names
static const String walletTypeCash = 'Tiền mặt';
static const String walletTypeBank = 'Ngân hàng';
static const String walletTypeEwallet = 'Ví điện tử';
```

**2) `lib/navigation/main_navigation.dart`** - Thay Placeholder bằng:

```dart
// Thay vì: PlaceholderScreen()
WalletScreen()  // Khi tab Ví được chọn
```

**3) `lib/providers/`** - Tạo `wallet_provider.dart` nếu chưa có

### 6.2 Xem Lại Pattern từ StatisticScreen

Bạn có thể tham khảo cách viết từ `lib/views/statistic/` để đảm bảo consistency:

- Cách organize widget (main screen + widgets subfolder)
- Cách dùng Provider + ChangeNotifier
- Cách format currency + colors
- Cách handle loading/error states
- Cách viết bottom sheet modal

---

## 📸 PHẦN 7: ACCEPTANCE CRITERIA & PROOF

### 7.1 Deliverables

Khi hoàn thành, bạn cần cung cấp:

1. ✅ **Code files** (đầy đủ, không placeholder)
2. ✅ **Screenshots** (3 cái):
   - Màn hình Ví khi mở lần đầu (3 ví, tổng số dư)
   - Modal điều chuyển sau khi tap ví card
   - Snackbar thành công/tràn lỗi validation (ví dụ: "Số dư không đủ")
3. ✅ **Test case completed** (ít nhất 7/7 test case từ bảng T1-T7 tích xanh)
4. ✅ **flutter analyze output**: "No issues found!"
5. ✅ **PR description** có mini-summary + checklist

### 7.2 Frontend QA Checklist (Team Lead verify)

- [ ] Đầu ra hiện đúng tổng số dư
- [ ] Các ví card hiển thị đúng dữ liệu + icon + color
- [ ] Modal mở/đóng mượt (không bị giật)
- [ ] Validation error message hiển thị rõ (không bị che khuất)
- [ ] Snackbar feedback rõ (2-3 giây rồi tự tắt)
- [ ] Transfer thành công → số dư cập nhật tức thời
- [ ] UI không bị tràn/cắt trên màn hình nhỏ (test 320px width)
- [ ] Text đầy đủ tiếng Việt (không trộn English)

---

## 🚀 PHẦN 8: QUICK START

### 8.1 Command trước khi code

```bash
# Vào thư mục mobile
cd mobile

# Pull code mới nhất
git checkout dev && git pull

# Tạo branch feature
git checkout -b feat/wallet-mvp

# Get dependencies
flutter pub get

# Analyze để kiểm tra hiện tại
flutter analyze
```

### 8.2 Development Flow

```
1. Tạo file structure: wallet_screen.dart + widgets/
2. Tạo WalletProvider với mock data
3. Build UI components (card, modal, button)
4. Implement transfer logic (validation + state update)
5. Add snackbar feedback
6. Format + analyze
7. Test manual từ device/emulator
8. Create PR + attach proof
```

### 8.3 During Development - Common Issues

| Issue                                            | Solution                                               |
| ------------------------------------------------ | ------------------------------------------------------ |
| Dropdown error "The value is not in list"        | Xác nhận wallet.id khớp với value trong dropdown       |
| Text overflow                                    | Wrap TextField/Text trong `Expanded` hoặc `Flexible`   |
| Modal dismiss không cập nhật                     | Dùng `Navigator.pop(context, result)` và handle result |
| Snackbar bị che                                  | Dùng `ScaffoldMessenger.of(context).showSnackBar()`    |
| Provider notifyListeners() không trigger rebuild | Xác nhận List dùng `List.from()` (tạo object mới)      |

---

## 📞 PHẦN 9: CONTACT & CLARIFICATION

Nếu gặp vấn đề trong quá trình code:

1. **Lỗi UI** → Xem lại design section (2.1-2.3)
2. **Logic validation** → Xem lại logic section (3.1-3.2)
3. **Provider không update** → Xem lại state management (3.3)
4. **Không biết component nào dùng** → Xem StatisticScreen pattern
5. **String/constants** → Cập nhật `lib/core/strings.dart` trước, sau đó import

**Mục tiêu cuối cùng**: Wallet Screen **production-ready**, **demo-ready**, **test-ready** trước ngày bàn giao.

---

**Version**: 1.0  
**Last Updated**: 26/03/2026  
**Status**: Ready to handoff
