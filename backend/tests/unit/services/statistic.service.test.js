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

jest.mock("../../../models/monthly_budget.model", () => ({
  findOne: jest.fn(),
  findOneAndUpdate: jest.fn(),
}));

const Transaction = require('../../../models/transaction_schema');
const MonthlyBudget = require("../../../models/monthly_budget.model");
const {
  getStatistics,
  getCategoryBreakdown,
  getMonthlyStatistics,
  getBudgetSummary,
  saveBudgetTarget,
  computeBudgetStatus,
} = require('../../../services/statistic.service');
const mongoose = require('mongoose');

// Bộ test này tập trung vào việc kiểm tra các hàm thống kê trong service, đặc biệt là getMonthlyStatistics. Chúng ta sẽ mock Transaction.aggregate để trả về dữ liệu giả và kiểm tra xem hàm có tính toán đúng tổng thu, chi và số dư hay không. Ngoài ra, chúng ta cũng sẽ kiểm tra logic phân loại theo tháng, năm, hoặc khoảng thời gian và xử lý trường hợp không có giao dịch nào.
describe('Statistic Service - getMonthlyStatistics', () => {
  const userId = new mongoose.Types.ObjectId().toString();
 
  // Trước mỗi test, chúng ta sẽ xóa tất cả các mock và thiết lập Transaction.aggregate trả về một mảng rỗng để đảm bảo rằng các test không bị ảnh hưởng bởi dữ liệu cũ.
  beforeEach(() => {
    jest.clearAllMocks();
    Transaction.aggregate.mockResolvedValue([]);
    MonthlyBudget.findOne.mockReturnValue({
      lean: jest.fn().mockResolvedValue(null),
    });
    MonthlyBudget.findOneAndUpdate.mockResolvedValue(null);
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

  describe("computeBudgetStatus", () => {
    it("returns safe when no target budget", () => {
      expect(computeBudgetStatus(0, 100)).toBe("safe");
    });

    it("returns over when actual is greater than target", () => {
      expect(computeBudgetStatus(100, 101)).toBe("over");
    });

    it("returns near at 80 percent threshold", () => {
      expect(computeBudgetStatus(100, 80)).toBe("near");
    });
  });

  describe("getBudgetSummary", () => {
    it("returns budget summary with default targetAmount = 0", async () => {
      Transaction.aggregate.mockResolvedValue([{ totalIncome: 0, totalExpense: 300 }]);

      const result = await getBudgetSummary(userId, 4, 2026);

      expect(result).toEqual({
        month: 4,
        year: 2026,
        targetAmount: 0,
        actualExpense: 300,
        remaining: -300,
        status: "safe",
      });
      expect(MonthlyBudget.findOne).toHaveBeenCalledWith({
        userId,
        month: 4,
        year: 2026,
      });
    });

    it("returns near when ratio is between 0.8 and 1.0", async () => {
      MonthlyBudget.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue({ targetAmount: 1000 }),
      });
      Transaction.aggregate.mockResolvedValue([{ totalIncome: 0, totalExpense: 800 }]);

      const result = await getBudgetSummary(userId, 4, 2026);

      expect(result.status).toBe("near");
      expect(result.remaining).toBe(200);
    });
  });

  describe("saveBudgetTarget", () => {
    it("upserts monthly budget and returns summary", async () => {
      MonthlyBudget.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue({ targetAmount: 900 }),
      });
      Transaction.aggregate.mockResolvedValue([{ totalIncome: 0, totalExpense: 200 }]);

      const result = await saveBudgetTarget(userId, 5, 2026, 900);

      expect(MonthlyBudget.findOneAndUpdate).toHaveBeenCalledWith(
        { userId, month: 5, year: 2026 },
        { $set: { targetAmount: 900 } },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
      expect(result).toEqual({
        month: 5,
        year: 2026,
        targetAmount: 900,
        actualExpense: 200,
        remaining: 700,
        status: "safe",
      });
    });
  });
});
