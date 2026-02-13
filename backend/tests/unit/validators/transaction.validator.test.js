const { getTransactionsSchema } = require('../../../validators/transaction.validator');

describe('Transaction Validator - GET /api/transactions', () => {
  // Test Case Thành công
  it('should validate correctly with valid month and year', () => {
    const data = { month: 2, year: 2026, page: 1, limit: 10 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeUndefined();
  });

  // Edge Case: Logic mâu thuẫn
  it('should fail if both range mode (from/to) and monthly mode (month/year) are provided', () => {
    const data = { 
      from: '2026-01-01', to: '2026-01-31', 
      month: 1, year: 2026 
    };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
    // Logic: Dùng .oxor('from', 'month') trong Joi để bắt lỗi này
  });

  // Edge Case: Ngày bắt đầu lớn hơn ngày kết thúc
  it('should fail if "from" date is greater than "to" date', () => {
    const data = { from: '2026-12-31', to: '2026-01-01' };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  // Edge Case: Giá trị không hợp lệ
  it('should fail if month is 13 or year is in the past too far', () => {
    const data = { month: 13, year: 2026 };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });

  it('should fail if type is not "income" or "expense"', () => {
    const data = { type: 'invalid_type' };
    const { error } = getTransactionsSchema.validate(data);
    expect(error).toBeDefined();
  });
});