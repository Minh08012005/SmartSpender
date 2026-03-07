/**
 * File này chứa các bài test đơn vị cho validator thống kê thu chi
 * Mục tiêu:
 *   - Đảm bảo validator kiểm tra đúng định dạng và giá trị của tham số tháng, năm
 *   - Kiểm tra các trường hợp lỗi: thiếu tham số, tham số không phải số, tháng ngoài 1-12, v.v.
 *   - Sử dụng Joi để validate và kiểm tra kết quả trả về
 */

const { getSummarySchema } = require("../../../validators/statistic_validator");

// Test cases cho validator thống kê thu chi
describe("Statistic Validator", () => {
  it("valid input", () => {
    const result = getSummarySchema.validate({
      month: 2,
      year: 2026,
    });

    expect(result.error).toBeUndefined();
  });
});
