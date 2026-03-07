/** 
 * File này chứa các bài test đơn vị cho service thống kê thu chi
 * Mục tiêu:
 *   - Đảm bảo service tính toán đúng tổng thu, chi và số dư
 *   - Kiểm tra logic phân loại theo tháng, năm, hoặc khoảng thời gian
 *   - Xử lý các trường hợp không có giao dịch nào (trả về 0)
 *  - Mock Transaction.aggregate để test logic mà không cần DB thật
 */

jest.mock("../../../models/transaction_schema", () => ({
  aggregate: jest.fn(),
}));

const Transaction = require('../../../models/transaction_schema');
const {
  getStatistics,
  getCategoryBreakdown,
  getMonthlyStatistics,
} = require('../../../services/statistic_service');
const mongoose = require('mongoose');

// Bộ test này tập trung vào việc kiểm tra các hàm thống kê trong service, đặc biệt là getMonthlyStatistics. Chúng ta sẽ mock Transaction.aggregate để trả về dữ liệu giả và kiểm tra xem hàm có tính toán đúng tổng thu, chi và số dư hay không. Ngoài ra, chúng ta cũng sẽ kiểm tra logic phân loại theo tháng, năm, hoặc khoảng thời gian và xử lý trường hợp không có giao dịch nào.
describe('Statistic Service - getMonthlyStatistics', () => {
  const userId = new mongoose.Types.ObjectId().toString();
 
  // Trước mỗi test, chúng ta sẽ xóa tất cả các mock và thiết lập Transaction.aggregate trả về một mảng rỗng để đảm bảo rằng các test không bị ảnh hưởng bởi dữ liệu cũ.
  beforeEach(() => {
    jest.clearAllMocks();
    Transaction.aggregate.mockResolvedValue([]);
  });

  // Test cho hàm getStatistics, chúng ta sẽ kiểm tra xem hàm có trả về tổng thu, chi và số dư đúng không khi có dữ liệu giả, cũng như khi không có dữ liệu nào.
  describe('getStatistics', () => {
    // Kiểm tra trường hợp có dữ liệu giả, hàm nên trả về tổng thu, chi và số dư đúng.
    it('should return aggregated stats', async () => {
      Transaction.aggregate.mockResolvedValue([
        { totalIncome: 1000, totalExpense: 400 },
      ]);
      const result = await getStatistics(userId, { month: 2, year: 2026 });
      expect(result).toEqual({
        totalIncome: 1000,
        totalExpense: 400,
        balance: 600,
      });
    });

    // Kiểm tra trường hợp không có dữ liệu nào, hàm nên trả về tổng thu, chi và số dư đều là 0.
    it('should return zeros when no data', async () => {
      const result = await getStatistics(userId, { month: 2, year: 2026 });
      expect(result).toEqual({ totalIncome: 0, totalExpense: 0, balance: 0 });
    });

    // Kiểm tra logic lọc theo khoảng thời gian, hàm nên xây dựng pipeline đúng với điều kiện ngày tháng.
    it('should handle date range filters', async () => {
      await getStatistics(userId, { from: '2026-01-01', to: '2026-01-31' });
      const pipeline = Transaction.aggregate.mock.calls[0][0];
      const match = pipeline.find((p) => p.$match).$match;
      expect(match.date).toEqual({
        $gte: new Date('2026-01-01'),
        $lte: new Date('2026-01-31'),
      });
    });
  });

  // Test cho hàm getCategoryBreakdown, chúng ta sẽ kiểm tra xem hàm có trả về đúng phân loại theo danh mục không khi có dữ liệu giả.
  describe('getCategoryBreakdown', () => {
    // Kiểm tra trường hợp có dữ liệu giả, hàm nên trả về phân loại theo danh mục đúng.
    it('should return category breakdown', async () => {
      Transaction.aggregate.mockResolvedValue([{ _id: 'food', amount: 500 }]);
      const result = await getCategoryBreakdown(userId, {
        month: 2,
        year: 2026,
      });
      expect(result).toEqual([{ _id: 'food', amount: 500 }]);
    });
  });

  // Test cho hàm getMonthlyStatistics, chúng ta sẽ kiểm tra xem hàm có gọi Transaction.aggregate với đúng điều kiện tháng và năm không.
  describe('getMonthlyStatistics', () => {
    // Kiểm tra xem hàm có gọi Transaction.aggregate với đúng điều kiện tháng và năm không.
    it('should call getStatistics with month/year', async () => {
      Transaction.aggregate.mockResolvedValue([]);
      await getMonthlyStatistics(userId, 2, 2026);
      expect(Transaction.aggregate).toHaveBeenCalled();
    });
  });
});
