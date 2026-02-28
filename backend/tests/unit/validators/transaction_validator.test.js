const {
  getTransactionsSchema,
  createTransactionSchema,
} = require("../../../validators/transaction_validator");

describe("Transaction Validator - GET /api/transactions", () => {
  it("should validate correctly with valid month and year", () => {
    const data = { month: 2, year: 2026, page: 1, limit: 10 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeUndefined();
  });

  it("should fail if both range mode (from/to) and monthly mode (month/year) are provided", () => {
    const data = {
      from: "2026-01-01",
      to: "2026-01-31",
      month: 1,
      year: 2026,
    };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  it('should fail if "from" date is greater than "to" date', () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if month is 13 or year is in the past too far", () => {
    const data = { month: 13, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  it('should fail if type is not "income" or "expense"', () => {
    const data = { type: "invalid_type" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  it("should fail if category contains invalid value", () => {
    const data = { category: "food,invalid", month: 2, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(/category.*not allowed/i);
  });

  it("should fail if from > to", () => {
    const data = { from: "2026-12-31", to: "2026-01-01" };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    expect(error.details[0].message).toMatch(
      /to date must be after from date/i,
    );
  });

  it("should fail if year < 2000", () => {
    const data = { month: 2, year: 1999 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

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

  it("should reject invalid sortBy value", () => {
    const data = { sortBy: "invalid", month: 2, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });
});

describe("Transaction Validator - POST /api/transactions", () => {
  const validPayload = {
    title: "Lunch",
    amount: 50000,
    type: "expense",
    category: "food",
    date: "2026-02-24",
    note: "Lunch with friends",
  };

  it("should validate correctly with valid payload", () => {
    const { error } = createTransactionSchema.validate(validPayload);
    expect(error).toBeUndefined();
  });

  it("should fail when title is missing", () => {
    const { title, ...payloadWithoutTitle } = validPayload;
    const { error } = createTransactionSchema.validate(payloadWithoutTitle);
    expect(error).toBeDefined();
  });

  it("should fail when date is not in YYYY-MM-DD format", () => {
    const { error } = createTransactionSchema.validate({
      ...validPayload,
      date: "2026-02-24T10:00:00.000Z",
    });
    expect(error).toBeDefined();
  });

  it("should normalize category to lowercase", () => {
    const { error, value } = createTransactionSchema.validate({
      ...validPayload,
      category: "FOOD",
    });

    expect(error).toBeUndefined();
    expect(value.category).toBe("food");
  });
});
