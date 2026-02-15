const {
  getTransactionsSchema,
} = require("../../../validators/transaction.validator");

// File này chứa các bài test đơn vị cho validator giao dịch
// Mục tiêu:
//   - Đảm bảo validator kiểm tra đúng định dạng và giá trị của tham số tháng, năm, loại giao dịch, danh mục, v.v.
//   - Kiểm tra các trường hợp lỗi: thiếu tham số, tham số không phải số, tháng ngoài 1-12, logic mâu thuẫn giữa from/to và month/year, v.v.
//   - Sử dụng Joi để validate và kiểm tra kết quả trả về
describe("Transaction Validator - GET /api/transactions", () => {
  // Test Case Thành công
  it("should validate correctly with valid month and year", () => {
    const data = { month: 2, year: 2026, page: 1, limit: 10 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeUndefined();
  });

  // Edge Case: Logic mâu thuẫn
  it("should fail if both range mode (from/to) and monthly mode (month/year) are provided", () => {
    const data = {
      from: "2026-01-01",
      to: "2026-01-31",
      month: 1,
      year: 2026,
    };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    // Logic: Dùng .oxor('from', 'month') trong Joi để bắt lỗi này
  });

  // Edge Case: Ngày bắt đầu lớn hơn ngày kết thúc
  it('should fail if "from" date is greater than "to" date', () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Edge Case: Giá trị không hợp lệ
  it("should fail if month is 13 or year is in the past too far", () => {
    const data = { month: 13, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Edge Case: Loại giao dịch không hợp lệ
  it('should fail if type is not "income" or "expense"', () => {
    const data = { type: "invalid_type" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Edge Case: Danh mục chứa giá trị không hợp lệ
  it("should fail if category contains invalid value", () => {
    const data = { category: "food,invalid", month: 2, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/category.*not allowed/i);
  });

  // Edge Case: Thiếu tham số bắt buộc
  it("should fail if from > to", () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(
      /to date must be after from date/i,
    );
  });

  // Edge Case: Năm nhỏ hơn 2000
  it("should fail if year < 2000", () => {
    const data = { month: 2, year: 1999 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });
});
