/**
 * File này chứa các bài test đơn vị cho validator thống kê thu chi
 * Mục tiêu:
 *   - Đảm bảo validator kiểm tra đúng định dạng và giá trị của tham số tháng, năm
 *   - Kiểm tra các trường hợp lỗi: thiếu tham số, tham số không phải số, tháng ngoài 1-12, v.v.
 *   - Sử dụng Joi để validate và kiểm tra kết quả trả về
 */

const {
  getSummarySchema,
  getBudgetSchema,
  saveBudgetSchema,
} = require("../../../validators/statistic.validator");

// Test cases cho validator thống kê thu chi
describe("Statistic Validator", () => {
  it("valid input", () => {
    const result = getSummarySchema.validate({
      month: 2,
      year: 2026,
    });

    expect(result.error).toBeUndefined();
  });

  it("valid get budget input", () => {
    const result = getBudgetSchema.validate({
      month: 4,
      year: 2026,
    });

    expect(result.error).toBeUndefined();
  });

  it("invalid get budget month", () => {
    const result = getBudgetSchema.validate({
      month: 13,
      year: 2026,
    });

    expect(result.error).toBeDefined();
  });

  it("valid save budget input", () => {
    const result = saveBudgetSchema.validate({
      month: 4,
      year: 2026,
      targetAmount: 500000,
    });

    expect(result.error).toBeUndefined();
  });

  it("invalid save budget targetAmount <= 0", () => {
    const result = saveBudgetSchema.validate({
      month: 4,
      year: 2026,
      targetAmount: 0,
    });

    expect(result.error).toBeDefined();
  });
});
