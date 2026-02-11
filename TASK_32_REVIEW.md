# 📋 Code Review: Task #32 - Filter API for Transactions

**Reviewer:** Leader (Minh)  
**Assignee:** Backend (Duy)  
**Date:** 10/02/2026  
**Status:** 🔄 Need Clarification

---

## 📌 Executive Summary

Duy đã định nghĩa API contract khá **toàn diện**, nhưng có **3-4 điểm cần rõ ràng hóa** trước khi bắt đầu coding. Những điều này sẽ ảnh hưởng đến:

- Logic xử lý backend
- Test cases
- Documentation
- Tương tác với Mobile team

---

## ✅ Điểm được khen

### 1. API Design tổng thể hợp lý

```
GET /api/transactions?month=2&year=2026&category=food&...
```

- ✅ Dùng GET (đúng, không sửa dữ liệu)
- ✅ Endpoint naming chuẩn: `/api/transactions` (plural, resource name)
- ✅ Query params thay vì body (phổ biến cho filter API)

### 2. Query params bao quát

- ✅ Có date filter (range + monthly mode)
- ✅ Có category filter (hỗ trợ multiple values)
- ✅ Có type filter (income/expense)
- ✅ Có pagination (page, limit)
- ✅ Có sort options (sortBy, order)
- ✅ Có search feature

### 3. Response format chuẩn

```json
{
  "success": true,
  "data": [...],
  "meta": { "page": 1, "total": 120, ... }
}
```

- ✅ Thống nhất với existing response format
- ✅ Có metadata (pagination info)

### 4. Documentation chi tiết

- ✅ Mô tả tham số rõ ràng (Type, Description)
- ✅ Có ví dụ request cụ thể
- ✅ Có error codes (400, 401, 500)

---

## ⚠️ Điểm cần rõ ràng hóa

### ❌ Issue #1: Search parameter không rõ scope

**Hiện tại:**

```
search | String | Keyword
```

**Vấn đề:**

- Tìm kiếm trong field nào? (title? note? category?)
- Có case-sensitive không?
- Tìm partial match hay exact match?

**Đề xuất:**

```
search | String | Tìm kiếm trong title và note (case-insensitive, partial match)
       |        | Ví dụ: search=cơm → match "ăn cơm trưa", "cơm nẻ"
```

**Thực hiện:**

- Model dùng MongoDB `$regex` operator: `{ $regex: search, $options: 'i' }`
- Search trong: `title` + `note` fields

---

### ❌ Issue #2: Conflict resolution khi gửi 2 date modes

**Hiện tại:**

- Mode 1: `from` + `to` (date range)
- Mode 2: `month` + `year` (monthly)
- **Không định nghĩa:** Nếu user gửi cả 2 thì ưu tiên cái nào?

**Scenario:**

```
GET /api/transactions?from=2026-02-01&to=2026-02-10&month=2&year=2026
                      ├─ Range: ngày 1-10 tháng 2
                      └─ Monthly: toàn tháng 2

→ Cái nào thắng?
```

**Đề xuất:**

```
Priority: from + to > month + year

Nếu user gửi cả 2:
1. Check from + to trước
2. Nếu có from + to → dùng range mode, bỏ qua month+year
3. Nếu không có from + to → dùng month+year

Validator logic:
if (from && to) {
  // Dùng range mode
  startDate = from;
  endDate = to;
  // Bỏ qua month, year
} else if (month && year) {
  // Tính ngày đầu tháng, ngày cuối tháng
  startDate = 2026-02-01;
  endDate = 2026-02-28;
} else {
  // Không có date filter → Lỗi
  throw "Must provide (from+to) or (month+year)";
}
```

**Impact:**

- Validator sẽ phức tạp hơn 1 chút
- Mobile team cần biết rule này để gọi đúng

---

### ❌ Issue #3: Default values không ghi

**Hiện tại:**

```
page   | Number | (không ghi default)
limit  | Number | (không ghi default)
order  | String | (không ghi default)
sortBy | String | (không ghi default)
```

**Vấn đề:**

- Mobile không biết default là gì
- Nếu mobile không gửi → server trả gì?
- Có thể dẫn tới inconsistent behavior

**Đề xuất:**

```
page    | Number | Trang (default: 1)
limit   | Number | Records per page (default: 20, max: 100)
sortBy  | String | Sort field (default: date) - hỗ trợ: date, amount, title
order   | String | asc/desc (default: desc - mới nhất trước)
```

**Impact:**

- Clear cho mobile dev
- Prevent abuse (limit max 100)

---

### ⚠️ Issue #4: Category param hỗ trợ multiple values nhưng chưa rõ format

**Hiện tại:**

```
category | String (CSV) | Danh mục (comma separated)
         |              | Ví dụ: food,travel,shopping
```

**Vấn đề:**

- Có validation được không?
- Valid categories là gì? (food, travel, shopping, salary, etc?)
- Nếu gửi invalid category thì sao? (400 error?)

**Đề xuất:**

```
category | String (CSV) | Danh mục (comma separated)
         |              | Valid values: food, travel, shopping, salary, entertainment, utility, other
         |              | Ví dụ: food,travel → match transactions có category là food HOẶC travel
         |              | Invalid category → 400 Bad Request

Valid categories:
- food (ăn uống)
- travel (đi lại)
- shopping (mua sắm)
- salary (lương)
- entertainment (giải trí)
- utility (tiện ích: điện, nước)
- other (khác)
```

---

### ⚠️ Issue #5: Statistics (tổng income/expense) nên include ở meta

**Hiện tại:**

- Duy ghi "API Statistics" nhưng thực tế nên merge vào Filter API
- Response meta có cơ hội thêm statistics

**Đề xuất:**

```json
{
  "success": true,
  "data": [ ... transactions ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "totalPages": 3,

    "statistics": {
      "totalIncome": 5000000,
      "totalExpense": 1500000,
      "balance": 3500000
    }
  }
}
```

**Benefit:**

- Mobile chỉ cần gọi 1 API
- Không cần tạo "API Statistics" riêng
- Performance tốt hơn (1 query MongoDB thay vì 2)

---

## 📊 Validation Rule Summary

Để Duy code validator chính xác, đây là tất cả rules cần validate:

| Param      | Type         | Rules                                      | Error |
| ---------- | ------------ | ------------------------------------------ | ----- |
| `from`     | String       | ISO Date (YYYY-MM-DD), `from <= to`        | 400   |
| `to`       | String       | ISO Date (YYYY-MM-DD), `to >= from`        | 400   |
| `month`    | Number       | 1-12, nếu có thì phải có `year`            | 400   |
| `year`     | Number       | >= 2000, nếu có thì phải có `month`        | 400   |
| `type`     | String       | enum: income, expense (case-sensitive)     | 400   |
| `category` | String       | CSV, mỗi value phải trong VALID_CATEGORIES | 400   |
| `search`   | String       | 1-100 characters                           | 400   |
| `page`     | Number       | >= 1                                       | 400   |
| `limit`    | Number       | 1-100                                      | 400   |
| `sortBy`   | String       | enum: date, amount, title                  | 400   |
| `order`    | String       | enum: asc, desc                            | 400   |
| Auth       | Bearer Token | Valid JWT, not expired                     | 401   |
| userId     | (from token) | Match transaction ownership                | 403   |

---

## 🎯 Action Items

### ✏️ Duy cần làm:

- [ ] **Update GitHub Issue #32** với các clarification trên
- [ ] **Tinh chỉnh API Contract** theo suggestions
- [ ] **Xác nhận lại với Sơn (Mobile lead)** về:
  - Default values
  - Priority rule cho date modes
  - Valid categories list
- [ ] **Bắt đầu implement:**
  1. Tạo `backend/validators/transaction.validator.js` (validate rules)
  2. Tạo `backend/models/transaction.js` - method `findFiltered(filters, userId)`
  3. Tạo `backend/controllers/transaction_controller.js` - method `filterTransactions()`
  4. Update `backend/routes/transaction_routes.js` - thêm GET endpoint
  5. Test với Postman

### 🔗 Mobile team (Sơn, Anh) cần biết:

- [ ] Default values khi gọi API
- [ ] Date mode priority rule
- [ ] Valid categories để dùng dropdown
- [ ] Statistics format để display ở UI

---

---

## 💬 Notes

**Tổng đánh giá:** Duy định nghĩa API khá tốt, nhưng cần rõ ràng hóa 5 điểm để tránh rework sau.

**Timeline**

- Hôm nay (10/02): Clarify + update issue
- 11-13/02: Implement (validator, model, controller)
- 14/02: Testing
- 15/02: Code review + merge vào dev

---

**Review by:** Leader  
**Feedback deadline:** 11/02/2026  
**Implementation deadline:** 15/02/2026
