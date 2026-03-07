**Reviewer:** @Minh08012005
**Branch:** `feat/edit-transaction-clean`
**Status:** NEEDS CHANGES (blocking)

## Tóm tắt ngắn

- UI màn Edit đã gọi `updateTransaction(...)` — hướng đúng.
- Tuy nhiên `TransactionProvider` hiện chưa có `updateTransaction` => runtime error nếu merge.
- Theo Swagger, `title` là trường BẮT BUỘC; mobile hiện chưa đảm bảo gửi `title` trong Add/Update.

**Kết luận:** PR chưa thể merge. Cần sửa theo checklist bên dưới trước khi approve.

---

## Blocking (P0) — PHẢI FIX trước khi merge

1. **Implement `updateTransaction` trong provider**
   - File: `mobile/lib/data/providers/transaction_provider.dart`
   - Yêu cầu:
     - Gọi PUT `/api/transactions/{id}` (dùng `ApiService.put(ApiConstants.transactionById(id), data: ...)`).
     - Nếu success: thay thế item trong `_transactions` theo id và `notifyListeners()`.
     - Nếu fail: set `_error` và trả về `false` — KHÔNG xóa item gốc.

   - Gợi ý code (tham khảo):

```dart
Future<bool> updateTransaction(TransactionModel transaction) async {
  _setLoading(true);
  _clearError();
  try {
    final response = await _api_service.put(
      ApiConstants.transactionById(transaction.id),
      data: transaction.toJson(),
    );
    if (response.statusCode == 200) {
      final idx = _transactions.indexWhere((t) => t.id == transaction.id);
      if (idx != -1) {
        _transactions[idx] = transaction;
      } else {
        _transactions.insert(0, transaction);
      }
      notifyListeners();
      return true;
    }
    throw Exception('Failed to update transaction');
  } on DioException catch (e) {
    _setError(e.error?.toString() ?? 'Không thể cập nhật giao dịch');
    return false;
  } catch (e) {
    _setError('Có lỗi xảy ra: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
```

2. **Thêm `title` vào model và xử lý JSON**
   - File: `mobile/lib/data/models/transaction_model.dart`
   - Yêu cầu:
     - Thêm `final String title;` và `required this.title` trong constructor.
     - `fromJson` parse `title` (ví dụ `title: json['title'] ?? ''`).
     - `toJson()` gửi `'title': title`.
     - `copyWith` hỗ trợ `title`.

   - Lý do: backend Swagger yêu cầu `title` là trường bắt buộc; nếu thiếu, backend trả 400.

3. **UI: Bổ sung field `Title` trên Add + Edit**
   - Files:
     - `mobile/lib/screens/add_transaction_screen.dart`
     - `mobile/lib/features/auth/widgets/edit_transaction_form.dart` (hoặc file form tương ứng)
     - `mobile/lib/screens/edit_transaction_screen.dart`
   - Yêu cầu UI:
     - Thêm `TextFormField` cho `Title`.
     - Label: **`Title`** (giữ tiếng Anh theo yêu cầu product).
     - Hint: `e.g. Lunch with friends`.
     - Validation: required, maxLength = 100 (theo Swagger).
     - Khi submit Add/Update, truyền `title: _titleController.text.trim()` vào `TransactionModel`.

4. **Dummy data**
   - Cập nhật `mobile/lib/data/dummy_transactions.dart` để include `title` hoặc keep commented.

---

## Secondary (khuyến nghị)

- Thống nhất message validation (fix typo: `Amout` → `Amount`, chuẩn hoá câu thông báo).
- Chạy `flutter analyze` và fix warnings.
- Manual test flow: login → edit → save → verify backend trả 200 và item được cập nhật (id không đổi).

---

## Checklist đề xuất để close PR

- [ ] `updateTransaction()` implemented in `mobile/lib/data/providers/transaction_provider.dart`.
- [ ] `title` field added to `mobile/lib/data/models/transaction_model.dart` (fromJson/toJson/copyWith).
- [ ] Title input added to Add & Edit forms; Add/Update send `title`.
- [ ] Dummy data updated / commented consistently.
- [ ] `flutter analyze` OK, manual smoke test passed.
- [ ] Push changes to `feat/edit-transaction-clean` and update PR (reopen PR#45 or push new commit).

---

## Gợi ý commit message

```
feat(edit-transaction): add title field, implement updateTransaction and UI for edit/add
```

