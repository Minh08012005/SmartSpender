const {
  getTransactionsSchema,
  createTransactionSchema,
  updateTransactionSchema,
  objectIdParamSchema,
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

  // Logic mâu thuẫn
  it("should fail if both range mode (from/to) and monthly mode (month/year) are provided", () => {
    const data = {
      from: "2026-01-01",
      to: "2026-01-31",
      month: 1,
      year: 2026,
    };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    //Dùng .oxor('from', 'month') trong Joi để bắt lỗi này
  });

  // Ngày bắt đầu lớn hơn ngày kết thúc
  it('should fail if "from" date is greater than "to" date', () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Giá trị không hợp lệ
  it("should fail if month is 13 or year is in the past too far", () => {
    const data = { month: 13, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Loại giao dịch không hợp lệ
  it('should fail if type is not "income" or "expense"', () => {
    const data = { type: "invalid_type" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Danh mục chứa giá trị không hợp lệ
  it("should fail if category contains invalid value", () => {
    const data = { category: "food,invalid", month: 2, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/category.*not allowed/i);
  });

  // Thiếu tham số bắt buộc
  it("should fail if from > to", () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(
      /to date must be after from date/i,
    );
  });

  // Năm nhỏ hơn 2000
  it("should fail if year < 2000", () => {
    const data = { month: 2, year: 1999 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Cho phép giá trị sắp xếp hợp lệ
  it("should allow valid sortBy values", () => {
    const validValues = ["date", "amount", "category", "createdAt"];
    validValues.forEach((value) => {
      const { error } = getTransactionsSchema.validate({
        sortBy: value,
        month: 2,
        year: 2026,
      });
      expect(error).toBeUndefined();
    });
  });

  // Từ chối giá trị sắp xếp không hợp lệ
  it("should reject invalid sortBy value", () => {
    const data = { sortBy: "invalid", month: 2, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });
});

/**
 * CREATE Transaction Validator Tests
 */
describe("Transaction Validator - POST /api/transactions (Create)", () => {
  it("should validate correctly with all required fields", () => {
    const data = {
      title: "Lunch",
      amount: 150000,
      category: "food",
      type: "expense",
      date: "2026-03-08",
      note: "With team",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should fail if title is missing", () => {
    const data = {
      amount: 150000,
      category: "food",
      type: "expense",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/title/i);
  });

  it("should fail if amount is negative", () => {
    const data = {
      title: "Test",
      amount: -100,
      category: "food",
      type: "expense",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/amount/i);
  });

  it("should fail if amount is not a number", () => {
    const data = {
      title: "Test",
      amount: "abc",
      category: "food",
      type: "expense",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if type is not income or expense", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "food",
      type: "transfer",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/type/i);
  });

  it("should fail if category is invalid", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "invalid_category",
      type: "expense",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if date is in invalid format", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "food",
      type: "expense",
      date: "32-13-2026",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should allow optional note field", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "food",
      type: "expense",
      note: "Optional note",
    };
    const { error } = createTransactionSchema.validate(data);
    expect(error).toBeUndefined();
  });
});

/**
 * UPDATE Transaction Validator Tests
 */
describe("Transaction Validator - PUT /api/transactions/:id (Update)", () => {
  it("should validate correctly with single field update", () => {
    const data = { note: "Updated note" };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should validate correctly with multiple fields", () => {
    const data = {
      title: "Updated",
      amount: 200000,
      note: "New note",
    };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should fail if amount is negative", () => {
    const data = { amount: -100 };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/amount/i);
  });

  it("should fail if date is invalid format", () => {
    const data = { date: "invalid-date" };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if category is invalid", () => {
    const data = { category: "invalid_cat" };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if type is invalid", () => {
    const data = { type: "debit" };
    const { error } = updateTransactionSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/type/i);
  });

  it("should allow empty payload to be caught by service layer", () => {
    const data = {};
    const { error, value } = updateTransactionSchema.validate(data);
    // Empty object should pass validation in schema, but service layer will reject it
    expect(error).toBeUndefined();
    expect(value).toEqual({});
  });
});

/**
 * ObjectId Param Validator Tests
 */
describe("Transaction Validator - ObjectId Parameter Validation", () => {
  it("should validate correct ObjectId format", () => {
    const data = { id: "65c88df8b2f8a1c21c23abcd" };
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should accept uppercase hex characters in ObjectId", () => {
    const data = { id: "65C88DF8B2F8A1C21C23ABCD" };
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should fail if ObjectId is too short", () => {
    const data = { id: "65c88df8b2f8a1c21c23abc" };
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/ObjectId|24 characters|hex/i);
  });

  it("should fail if ObjectId contains non-hex characters", () => {
    const data = { id: "65c88df8b2f8a1c21c23abcg" };
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if ObjectId has spaces", () => {
    const data = { id: "65c88df8 b2f8a1c21c23abcd" };
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if ObjectId is missing", () => {
    const data = {};
    const { error } = objectIdParamSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/id.*required/i);
  });
});
