# 🧪 Hướng Dẫn Test Task #35 - Mobile Add/Edit Transaction

**Cho**: Lê Đức Anh (Developer)  
**Giai đoạn**: Test độc lập trước merge vào dev  
**Thời gian dự kiến**: 30-45 phút  
**Mục tiêu**: Đảm bảo flow Add/Edit Transaction hoạt động đúng trước integrate với real API backend

---

## 📋 Tổng quan Test Scope

### Những gì sẽ test:
1. ✅ Widget tests pass (flutter test)
2. ✅ Manual flow: Add transaction từ Home
3. ✅ Manual flow: Edit transaction từ Home
4. ✅ Data validation (invalid input)
5. ✅ Loading/Error states
6. ✅ Refresh logic after Add/Edit

### Những gì KHÔNG test (backend team):
- ❌ Real API connection (backend chưa ready)
- ❌ Statistics calculation (backend phần Nguyễn Văn Duy)
- ❌ Filter/Search (backend phần Vũ Ngọc Bảo)

---

## 🛠️ Yêu cầu tiên quyết

### Công cụ & môi trường:
```bash
# 1. Đảm bảo đang ở nhánh feat/edit-transaction-clean
git branch  # xác nhận current branch

# 2. Pull code mới nhất
git pull origin feat/edit-transaction-clean

# 3. Get dependencies
flutter pub get

# 4. Clean build cache
flutter clean

# 5. Run app trên emulator hoặc device
flutter run
```

### Kiểm tra setup:
- ✅ Android Emulator chạy hoặc iOS Simulator sẵn sàng
- ✅ File `pubspec.yaml` có tất cả dependencies (provider, http, etc.)
- ✅ Không có compilation error

---

## 🧪 Test 1: Widget Tests (Automated)

**Mục tiêu**: Verify smoke test pass, app build được

### Bước thực hiện:

```bash
# Terminal 1: Run widget tests
cd mobile
flutter test test/widget_test.dart -v

# Expected output:
# ✓ Smoke test - app builds and shows login screen (5.123s)
# 
# All tests passed!
```

### Kết quả mong đợi:
- ✅ Test "Smoke test - app builds and shows login screen" PASS
- ✅ Không có error/warning
- ✅ Execution time < 10s

### Nếu FAIL:
```bash
# Debug: Check lỗi chi tiết
flutter test test/widget_test.dart -v --no-pub

# Phổ biến fails:
# 1. MaterialApp not found → Check main.dart MyApp structure
# 2. LoginScreen not found → Check import path
# 3. SharedPreferences mock fail → Check setUp() method
```

**Log kết quả**: Chụp screenshot terminal output hoặc copy output vào file `TEST_LOG_WIDGET.txt`

---

## 🚀 Test 2: Add Transaction Flow (Manual)

**Mục tiêu**: Verify user có thể thêm giao dịch từ Home và data update

### Bước chuẩn bị:
1. Đảm bảo app đang chạy (`flutter run`)
2. Login/Navigate tới Home Screen
3. Có thể thấy: Header (Balance), "Transactions History", FAB (+)

### 2.1 Test Add với dữ liệu hợp lệ

#### Tình huống: Thêm giao dịch chi tiêu (Expense)

**Các bước**:
```
1. Tap FAB (+) ở góc phải dưới
   ✓ Expected: AddTransactionScreen mở, form trống
   
2. Check form layout:
   ✓ Amount field (keyboard number)
   ✓ Type dropdown (Income/Expense) - mặc định Expense
   ✓ Category dropdown - mặc định "Food"
   ✓ Title field (text input)
   ✓ Date field (hiển thị hôm nay)
   ✓ Note field (multiline text)
   ✓ Save button
   
3. Điền dữ liệu hợp lệ:
   - Amount: 150000
   - Type: Expense (giữ mặc định)
   - Category: Travel (chọn từ dropdown)
   - Title: Taxi đi làm
   - Date: Giữ ngày hôm nay
   - Note: Đi từ nhà đến công ty
   
4. Tap "Save Transaction" button
   ✓ Expected: Button disabled (show loading spinner)
   ✓ Expected: Loading indicator xuất hiện (~2s)
   
5. Người dùng quay về Home Screen
   ✓ Expected: List transaction đã update
   ✓ Expected: Item "Travel - Taxi đi làm - 150000 ₫" có trong list
   ✓ Expected: Total Expenses tăng 150000
```

**Kiểm tra chi tiết**:
- [ ] Form mở không crash
- [ ] Dropdown hiển thị đúng categories (Food, Travel, Shopping, etc.)
- [ ] Date picker hoạt động
- [ ] Loading state hiển thị khi submit
- [ ] List transaction update ngay (optimistic UI)
- [ ] Số tiền format đúng (1,500,000 ₫)
- [ ] Transaction xuất hiện ở đầu list

**Log kết quả**: 
```
✓ Test 2.1: Add Expense - PASS
- Form opened successfully
- All fields displayed correctly
- Dropdown categories: Food, Travel, Shopping, Salary, Entertainment, Utility, Other
- Loading spinner visible during submit
- New transaction appeared in list
- Total Expenses updated: +150000
```

---

#### Tình huống 2: Thêm giao dịch thu nhập (Income)

**Các bước**:
```
1. Tap FAB (+)

2. Chọn Type = Income (từ dropdown)
   ✓ Expected: Categories thay đổi (chỉ có: Salary, Other)
   
3. Điền:
   - Amount: 30000000
   - Type: Income
   - Category: Salary
   - Title: Lương tháng này
   - Date: Giữ ngày hôm nay
   - Note: Bonus tháng 3
   
4. Tap Save
   ✓ Expected: Loading indicator
   
5. Back to Home
   ✓ Expected: Transaction mới trong list
   ✓ Expected: Màu xanh (income)
   ✓ Expected: Text "+30,000,000 ₫"
   ✓ Expected: Total Income tăng
```

**Kiểm tra chi tiết**:
- [ ] Category thay đổi khi Type = Income
- [ ] Amount format với dấu phẩy
- [ ] Income color xanh, Expense color đỏ
- [ ] Total balance recalculate đúng

**Log kết quả**:
```
✓ Test 2.2: Add Income - PASS
- Type change triggers category update
- Category dropdown shows: Salary, Other
- Loading indicator visible
- Transaction displayed with green color
- Total Income updated correctly
- Total Balance recalculated
```

---

### 2.2 Test Add với dữ liệu KHÔNG hợp lệ

**Tình huống**: Validate form error handling

#### Case 1: Amount trống

```
1. Tap FAB
2. Bỏ trống Amount field
3. Điền các field khác:
   - Type: Expense
   - Category: Food
   - Title: Café sáng
   - Date: Hôm nay
4. Tap Save
   ✓ Expected: Error message "Amount is required" OR "Amount must be > 0"
   ✓ Expected: Button NOT disabled (không submit API)
   ✓ Expected: Form vẫn mở (NOT navigate back)
```

**Kiểm tra chi tiết**:
- [ ] Error message xuất hiện
- [ ] Error message dùng AppStrings (check file `core/strings.dart`)
- [ ] Save button không gọi API
- [ ] User có thể sửa và submit lại

**Log kết quả**:
```
✓ Test 2.3: Add with empty Amount - PASS
- Error message displayed: "Số tiền không được để trống hoặc phải > 0"
- Form remained open
- Save button still clickable for retry
```

---

#### Case 2: Title trống

```
1. Tap FAB
2. Điền Amount = 100000
3. KHÔNG điền Title
4. Tap Save
   ✓ Expected: Error "Title is required" hiển thị
   ✓ Expected: Form không close
```

**Log kết quả**:
```
✓ Test 2.4: Add with empty Title - PASS
- Error message: "Tiêu đề không được để trống"
```

---

#### Case 3: Amount = 0 hoặc âm

```
1. Tap FAB
2. Amount = 0 hoặc -500
3. Điền các field hợp lệ khác
4. Tap Save
   ✓ Expected: Error "Amount must be > 0"
```

**Log kết quả**:
```
✓ Test 2.5: Add with zero/negative Amount - PASS
- Error message: "Số tiền phải lớn hơn 0"
```

---

## 📝 Test 3: Edit Transaction Flow (Manual)

**Mục tiêu**: Verify user có thể edit giao dịch từ Home

### Bước chuẩn bị:
1. Đảm bảo có ít nhất 1 transaction trong danh sách (từ Test 2)
2. Home Screen hiển thị transaction item

### 3.1 Test Edit hợp lệ

```
1. Home Screen hiển thị list transaction
   ✓ Có thể thấy: Category, date, amount
   
2. Tap vào transaction item (VD: "Travel - Taxi đi làm")
   ✓ Expected: EditTransactionScreen mở
   ✓ Expected: Form pre-fill với dữ liệu transaction:
     - Amount: 150000 (đã nhập trước đó)
     - Type: Expense
     - Category: Travel
     - Title: Taxi đi làm
     - Date: (ngày đã chọn)
     - Note: Đi từ nhà đến công ty
   
3. Sửa một số field:
   - Title: "Taxi đi làm - sáng"
   - Note: "Đi từ nhà đến công ty UPDATED"
   - Amount: 160000
   
4. Tap Save
   ✓ Expected: Loading indicator
   ✓ Expected: Back to Home
   ✓ Expected: Transaction item update ngay:
     - Title thay đổi
     - Amount thay đổi → 160000
     - Total Expenses update: +10000 từ trước đó
```

**Kiểm tra chi tiết**:
- [ ] Form pre-fill hoàn chỉnh
- [ ] Có thể sửa tất cả field
- [ ] Save gọi API update
- [ ] List update hiển thị changes
- [ ] Total balance recalculate

**Log kết quả**:
```
✓ Test 3.1: Edit Transaction - PASS
- Form opened with pre-filled data:
  * Amount: 150000
  * Title: Taxi đi làm
  * Type: Expense
  * Category: Travel
- Successfully edited fields
- Transaction updated in list
- Total Expenses updated: 160000 (from 150000)
```

---

### 3.2 Test Edit validation error

```
1. Tap transaction item
2. Edit Amount → 0
3. Tap Save
   ✓ Expected: Error message
   ✓ Expected: Form không close
   ✓ Expected: Current data preserved (user có thể fix)
```

**Log kết quả**:
```
✓ Test 3.2: Edit with zero Amount - PASS
- Error caught and displayed
- Form remained open with data
```

---

## ⚠️ Test 4: Error States & Loading

**Mục tiêu**: Verify app handle errors gracefully

### 4.1 Loading State

```
1. Tap FAB → Add Form
2. Điền dữ liệu hợp lệ
3. Tap Save
   ✓ Expected lúc submit:
     - Save button disabled (grayed out)
     - Loading spinner xuất hiện trong button
     - User KHÔNG thể tap lại nhiều lần
     - Form fields vẫn hiển thị (user có thể review)
```

**Kiểm tra chi tiết**:
- [ ] Button loading state visual (spinner + disabled)
- [ ] Can't double-tap submit
- [ ] Loading time ~1-3s (simulated delay)

**Log kết quả**:
```
✓ Test 4.1: Loading State - PASS
- Save button shows loading spinner
- Button disabled during submit
- No double-submit possible
```

---

### 4.2 Refresh after Add

```
1. Add transaction thành công (Test 2.1)
2. Home Screen quay về
   ✓ Expected: List tự động refresh (call API lại)
   ✓ Expected: Loading indicator ở list (pull-to-refresh indicator)
   ✓ Expected: Transaction mới hiển thị
   ✓ Expected: Không bị flicker/jump
```

**Kiểm tra chi tiết**:
- [ ] Auto-refresh gọi API
- [ ] No jarring UI jumps
- [ ] Data consistency

**Log kết quả**:
```
✓ Test 4.2: Auto-Refresh after Add - PASS
- Home list refreshed automatically
- New transaction appears in correct position
- No UI jank or flicker
```

---

### 4.3 Refresh after Edit

```
1. Edit transaction thành công (Test 3.1)
2. Home Screen quay về
   ✓ Expected: List refresh
   ✓ Expected: Updated transaction shows latest data
```

**Log kết quả**:
```
✓ Test 4.3: Auto-Refresh after Edit - PASS
- List refreshed after edit
- Transaction shows updated values
```

---

## 📱 Test 5: Navigation & Flow

**Mục tiêu**: Verify navigation không crash, back button hoạt động

### 5.1 Add → Back (Cancel)

```
1. Tap FAB → Add Form
2. Điền một vài field (không save)
3. Tap Android Back button / iOS back arrow
   ✓ Expected: Form close, back to Home
   ✓ Expected: Không crash
   ✓ Expected: Data không được save (API không gọi)
```

**Log kết quả**:
```
✓ Test 5.1: Cancel Add Flow - PASS
- Back button closes form without saving
- Data not persisted
- No unsaved data warning needed (per spec)
```

---

### 5.2 Edit → Back (Cancel)

```
1. Tap transaction item → Edit Form
2. Sửa một field
3. Tap back
   ✓ Expected: Form close, back to Home
   ✓ Expected: Original data unchanged (API không gọi)
```

**Log kết quả**:
```
✓ Test 5.2: Cancel Edit Flow - PASS
- Back button closes form without saving
- Original transaction data preserved
```

---

### 5.3 Multiple Add → List consistency

```
1. Tap FAB → Add
2. Add transaction A
3. Quay Home (auto-refresh)
4. Tap FAB → Add
5. Add transaction B
6. Quay Home
   ✓ Expected: List có cả A và B
   ✓ Expected: Balance update đúng (tổng A + B)
   ✓ Expected: Không bị duplicate
```

**Log kết quả**:
```
✓ Test 5.3: Multiple Add Consistency - PASS
- Both transactions appear in list
- No duplicates
- Balance calculation correct (A + B)
```

---

## 🎯 Test 6: UI/UX Polish

### 6.1 Visual check

```
□ Form field labels rõ ràng, không typo
□ Dropdown items display đúng category format (capitalize)
□ Button style consistent (Save button color = brand color)
□ Loading spinner visible & smooth
□ Error messages display within form (not system alert)
□ Date picker UX smooth
□ Keyboard dismiss khi navigate away
```

**Log kết quả**:
```
✓ Test 6.1: UI Visual - PASS
- All text labels correct: "Amount", "Transaction Type", "Category", etc.
- Typo fixed: "Transaction Type" (not "Tranction Type")
- Category formatting: "Food", "Travel", "Shopping" (capitalized)
- Button colors match brand (green #2A7C76)
- Loading indicators smooth
```

---

### 6.2 Responsiveness check

```
□ Form fit dalam screen (landscape/portrait)
□ Button accessible (tap area large enough)
□ Text readable on different screen sizes
□ Keyboard tidak hide important fields
```

**Log kết quả**:
```
✓ Test 6.2: Responsiveness - PASS
- Form displays correctly on standard screens
- All fields accessible
- Keyboard doesn't hide critical fields
```

---

## 📊 Summary Test Results

### Checklist sebelum merge:

```
Widget Tests:
[ ] flutter test widget_test.dart PASS

Add Flow:
[ ] Test 2.1: Add Expense - PASS
[ ] Test 2.2: Add Income - PASS
[ ] Test 2.3: Validation (empty amount) - PASS
[ ] Test 2.4: Validation (empty title) - PASS
[ ] Test 2.5: Validation (amount = 0) - PASS

Edit Flow:
[ ] Test 3.1: Edit Transaction - PASS
[ ] Test 3.2: Edit Validation - PASS

Error/Loading:
[ ] Test 4.1: Loading state - PASS
[ ] Test 4.2: Auto-refresh after Add - PASS
[ ] Test 4.3: Auto-refresh after Edit - PASS

Navigation:
[ ] Test 5.1: Cancel Add - PASS
[ ] Test 5.2: Cancel Edit - PASS
[ ] Test 5.3: Multiple Add consistency - PASS

UI/UX:
[ ] Test 6.1: Visual check - PASS
[ ] Test 6.2: Responsiveness - PASS
```

### Result Summary:
- **Total Tests**: 14
- **Passed**: ___ / 14
- **Failed**: ___ / 14
- **Status**: 🟢 READY TO MERGE / 🔴 NEEDS FIX

---

## 📝 Cách báo cáo kết quả

### Option 1: Log file (Suggested)

Tạo file `TESTING_RESULTS.md` trong nhánh feat/edit-transaction-clean:

```markdown
# Testing Results - Task #35

## Device Info
- OS: Android 13 / iOS 16
- Device: Emulator / Pixel 7 / iPhone 14
- Flutter version: 3.x

## Test Results
- Widget tests: ✅ PASS
- Add flow: ✅ PASS (5/5 scenarios)
- Edit flow: ✅ PASS (2/2 scenarios)
- Error handling: ✅ PASS (3/3 scenarios)
- Navigation: ✅ PASS (3/3 scenarios)
- UI/UX: ✅ PASS (2/2 checks)

## Issues Found
(Nếu có)

## Ready for Merge
✅ YES
```

### Option 2: Comment trong GitHub PR

Paste kết quả vào PR description trước merge.

---

## ⏰ Thời gian ước tính

| Test | Thời gian |
|------|-----------|
| Widget test | 3-5 min |
| Add flow (3 cases) | 8-10 min |
| Edit flow (2 cases) | 5-7 min |
| Error states (3 cases) | 5-7 min |
| Navigation (3 cases) | 5-7 min |
| UI/UX (2 checks) | 3-5 min |
| **TOTAL** | **30-45 min** |

---

## 🆘 Troubleshooting

### Nếu widget_test FAIL:

```bash
# 1. Check imports
grep -n "import" mobile/test/widget_test.dart
# Must have: flutter_test, shared_preferences, main.dart, screens/login.dart

# 2. Check main.dart structure
# MyApp must return MaterialApp with LoginScreen

# 3. Rebuild & test lại
flutter clean && flutter pub get && flutter test test/widget_test.dart
```

---

### Nếu Add/Edit form CRASH:

```bash
# 1. Check console error
# Look for: null reference, wrong import, controller dispose

# 2. Verify imports dalam file
mobile/lib/screens/add_transaction_screen.dart
mobile/lib/screens/edit_transaction_screen.dart

# 3. Check provider connection
# Form phải có `context.watch<TransactionProvider>()`
```

---

### Nếu List không update sau Add/Edit:

```bash
# 1. Verify pop(true) gọi trong _submit()
# Search: Navigator.pop(context, true)

# 2. Verify _openAddTransactionScreen/_openEditTransactionScreen
# Check: if (result == true) { _refreshTransactions(); }

# 3. Verify _refreshTransactions() method
# Phải call: provider.fetchTransactions()
```

---

## 📞 Contact for Help

Nếu gặp issue:
1. Check console log xem error gì
2. Screenshot error
3. Post vào Slack group với:
   - Error message
   - Steps to reproduce
   - Device info (OS, Flutter version)

---

**Happy Testing! 🚀**

_This guide ensures quality before API integration phase._

---

**Created**: March 17, 2026  
**For**: Lê Đức Anh  
**Scope**: Task #35 Mobile Add/Edit Transaction (Sprint 2)