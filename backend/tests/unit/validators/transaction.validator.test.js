/**
 * Unit Tests for Transaction Validators
 *
 * Mục tiêu:
 * - Đảm bảo tất cả Joi schema validate đúng dữ liệu
 * - Kiểm tra cả trường hợp hợp lệ và không hợp lệ
 * - Bao phủ:
 *    getTransactionsSchema
 *    createTransactionSchema
 *    updateTransactionSchema
 *    objectIdParamSchema
 */

const {
  getTransactionsSchema,
  createTransactionSchema,
  updateTransactionSchema,
  objectIdParamSchema,
} = require("../../../validators/transaction.validator");

describe("Transaction Validator - GET /transactions", () => {
  /**
   * SUCCESS CASES
   */

  it("should validate correctly with month/year filter", () => {
    const data = {
      month: 2,
      year: 2026,
      page: 1,
      limit: 10,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeUndefined();
  });

  /**
   * FAILURE CASES
   */

  it("should fail when both range mode and monthly mode are used", () => {
    const data = {
      from: "2026-01-01",
      to: "2026-01-31",
      month: 1,
      year: 2026,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when from date is greater than to date", () => {
    const data = {
      from: "2026-12-31",
      to: "2026-01-01",
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when month is out of range", () => {
    const data = {
      month: 13,
      year: 2026,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when year is too small", () => {
    const data = {
      month: 2,
      year: 1999,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when type is invalid", () => {
    const data = {
      type: "invalid",
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when category contains invalid value", () => {
    const data = {
      category: "food,invalid",
      month: 2,
      year: 2026,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should normalize uppercase type and category CSV in query", () => {
    const data = {
      type: "INCOME",
      category: "Food, TRAVEL",
      month: 2,
      year: 2026,
    };

    const { error, value } = getTransactionsSchema.validate(data);

    expect(error).toBeUndefined();
    expect(value.type).toBe("income");
    expect(value.category).toBe("food,travel");
  });

  /**
   * SORT TESTS
   */

  it("should allow sorting by date", () => {
    const { error } = getTransactionsSchema.validate({
      sortBy: "date",
      month: 2,
      year: 2026,
    });

    expect(error).toBeUndefined();
  });

  it("should allow sorting by amount", () => {
    const { error } = getTransactionsSchema.validate({
      sortBy: "amount",
      month: 2,
      year: 2026,
    });

    expect(error).toBeUndefined();
  });

  it("should reject invalid sortBy value", () => {
    const data = {
      sortBy: "invalid",
      month: 2,
      year: 2026,
    };

    const { error } = getTransactionsSchema.validate(data);

    expect(error).toBeDefined();
  });
});

/**
 * CREATE TRANSACTION VALIDATOR
 */

describe("Transaction Validator - CREATE Transaction", () => {
  it("should validate when all required fields are correct", () => {
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

  it("should fail when title is missing", () => {
    const data = {
      amount: 150000,
      category: "food",
      type: "expense",
    };

    const { error } = createTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when amount is negative", () => {
    const data = {
      title: "Test",
      amount: -100,
      category: "food",
      type: "expense",
    };

    const { error } = createTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when amount is not a number", () => {
    const data = {
      title: "Test",
      amount: "abc",
      category: "food",
      type: "expense",
    };

    const { error } = createTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when type is invalid", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "food",
      type: "transfer",
    };

    const { error } = createTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when category is invalid", () => {
    const data = {
      title: "Test",
      amount: 100,
      category: "invalid",
      type: "expense",
    };

    const { error } = createTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when date format is invalid", () => {
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

  it("should normalize uppercase category and type", () => {
    const data = {
      title: "Salary",
      amount: 5000000,
      category: "SALARY",
      type: "INCOME",
    };

    const { error, value } = createTransactionSchema.validate(data);

    expect(error).toBeUndefined();
    expect(value.category).toBe("salary");
    expect(value.type).toBe("income");
  });
});

/**
 * UPDATE TRANSACTION VALIDATOR
 */

describe("Transaction Validator - UPDATE Transaction", () => {
  it("should validate when updating single field", () => {
    const data = {
      note: "Updated note",
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeUndefined();
  });

  it("should validate multiple fields update", () => {
    const data = {
      title: "Updated",
      amount: 200000,
      note: "New note",
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeUndefined();
  });

  it("should fail when amount is negative", () => {
    const data = {
      amount: -100,
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when date format invalid", () => {
    const data = {
      date: "invalid-date",
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when category invalid", () => {
    const data = {
      category: "invalid_cat",
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when type invalid", () => {
    const data = {
      type: "debit",
    };

    const { error } = updateTransactionSchema.validate(data);

    expect(error).toBeDefined();
  });

  // BUG-1 fix: type và category phải được normalize lowercase,
  // giống POST contract – client có thể gửi hoa/thường tùy ý
  it("should normalize uppercase type and category to lowercase", () => {
    const data = { type: "EXPENSE", category: "SALARY" };
    const { error, value } = updateTransactionSchema.validate(data);
    expect(error).toBeUndefined();
    expect(value.type).toBe("expense");
    expect(value.category).toBe("salary");
  });

  // BUG-2 fix: date phải strict ISO, từ chối các format không chuẩn
  it("should reject non-ISO date format like MM/DD/YYYY", () => {
    const { error } = updateTransactionSchema.validate({ date: "03/16/2026" });
    // Joi.date().iso() từ chối format này
    expect(error).toBeDefined();
  });

  it("should accept valid ISO date string YYYY-MM-DD", () => {
    const { error } = updateTransactionSchema.validate({ date: "2026-03-16" });
    expect(error).toBeUndefined();
  });

  it("should accept valid ISO datetime string", () => {
    const { error } = updateTransactionSchema.validate({ date: "2026-03-16T00:00:00Z" });
    expect(error).toBeUndefined();
  });

  it("should reject empty payload at validator level (fail fast)", () => {
    // Sau khi fix BUG-3: validator phải bắt empty body, không để lọt xuống service
    const { error } = updateTransactionSchema.validate({});
    expect(error).toBeDefined();
    expect(error.message).toContain("At least one field");
  });
});

/**
 * OBJECT ID VALIDATOR
 */

describe("Transaction Validator - ObjectId Parameter", () => {
  it("should accept valid ObjectId", () => {
    const data = {
      id: "65c88df8b2f8a1c21c23abcd",
    };

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeUndefined();
  });

  it("should accept uppercase ObjectId", () => {
    const data = {
      id: "65C88DF8B2F8A1C21C23ABCD",
    };

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeUndefined();
  });

  it("should fail when ObjectId is too short", () => {
    const data = {
      id: "65c88df8b2f8a1c21c23abc",
    };

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when ObjectId contains non-hex characters", () => {
    const data = {
      id: "65c88df8b2f8a1c21c23abcg",
    };

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when ObjectId contains spaces", () => {
    const data = {
      id: "65c88df8 b2f8a1c21c23abcd",
    };

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeDefined();
  });

  it("should fail when id is missing", () => {
    const data = {};

    const { error } = objectIdParamSchema.validate(data);

    expect(error).toBeDefined();
  });
});