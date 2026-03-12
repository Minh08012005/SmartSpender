/**
 * File này chứa các bài test đơn vị cho service xử lý giao dịch
 * Mục tiêu:
 *   - Đảm bảo service trả về dữ liệu đúng theo filter và phân trang
 *   - Kiểm tra logic xử lý category dạng CSV và search với regex
 *   - Xử lý các trường hợp lỗi như thiếu date filter
 *   - Mock Transaction.find, countDocuments, aggregate để test logic mà không cần DB thật
 */

const AppError = require("../../../utils/appError");
const mongoose = require("mongoose");

jest.mock("../../../models/transaction_schema", () => ({
  find: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
  findOneAndDelete: jest.fn(),
}));

const Transaction = require("../../../models/transaction_schema");
const transactionService = require("../../../services/transaction.service");

// Bộ test này tập trung vào việc kiểm tra hàm getFilteredTransactions trong service xử lý giao dịch. Chúng ta sẽ mock Transaction.find, countDocuments và aggregate để trả về dữ liệu giả và kiểm tra xem hàm có trả về dữ liệu đúng theo filter và phân trang không, cũng như xử lý logic category dạng CSV và search với regex. Ngoài ra, chúng ta cũng sẽ kiểm tra các trường hợp lỗi như thiếu date filter.
describe("Transaction Service - getFilteredTransactions", () => {
  // Mock query builder để kiểm tra các phương thức như sort, skip, limit, lean mà không cần kết nối đến DB thật.
  const mockQuery = {
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    lean: jest.fn().mockResolvedValue([]),
  };

  const userId = new mongoose.Types.ObjectId().toString();

  // Trước mỗi test, chúng ta sẽ xóa tất cả các mock và thiết lập Transaction.find trả về mockQuery, countDocuments trả về 0 và aggregate trả về một mảng rỗng để đảm bảo rằng các test không bị ảnh hưởng bởi dữ liệu cũ.
  beforeEach(() => {
    Transaction.find.mockReturnValue(mockQuery);
    Transaction.countDocuments.mockResolvedValue(0);
    Transaction.aggregate.mockResolvedValue([]);
  });

  // Sau mỗi test, chúng ta sẽ xóa tất cả các mock để đảm bảo rằng các test tiếp theo không bị ảnh hưởng bởi dữ liệu cũ.
  afterEach(() => {
    jest.clearAllMocks();
  });

  // Test cho hàm getFilteredTransactions, chúng ta sẽ kiểm tra xem hàm có trả về dữ liệu đúng theo filter và phân trang không, cũng như xử lý logic category dạng CSV và search với regex. Ngoài ra, chúng ta cũng sẽ kiểm tra các trường hợp lỗi như thiếu date filter.
  it("should throw AppError if no date filter provided", async () => {
    await expect(
      transactionService.getFilteredTransactions(userId, { page: 1 }),
    ).rejects.toThrow(AppError);
  });

  // Test cho hàm getFilteredTransactions, chúng ta sẽ kiểm tra xem hàm có trả về dữ liệu đúng theo filter và phân trang không khi có dữ liệu giả.
  it("should handle multiple categories in CSV format", async () => {
    await transactionService.getFilteredTransactions(userId, {
      category: "food,travel",
      month: 2,
      year: 2026,
    });
    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        category: { $in: ["food", "travel"] },
      }),
    );
  });

  // Test cho hàm getFilteredTransactions, chúng ta sẽ kiểm tra xem hàm có xử lý search với regex đúng không khi có dữ liệu giả.
  it("should handle search with special characters", async () => {
    const searchTerm = ".*+?^${}()|[]\\";
    await transactionService.getFilteredTransactions(userId, {
      search: searchTerm,
      month: 2,
      year: 2026,
    });
    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        note: expect.objectContaining({
          $regex: expect.any(String),
          $options: "i",
        }),
      }),
    );
  });

  // Test Security
  it("should always include userId in the query to prevent data leaking", async () => {
    await transactionService.getFilteredTransactions(userId, {
      page: 1,
      limit: 10,
      month: 2,
      year: 2026,
    });

    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: new mongoose.Types.ObjectId(userId),
      }),
    );
  });

  // Test Logic Tính toán Aggregation
  it("should correctly format finalStats even if no data exists", async () => {
    const result = await transactionService.getFilteredTransactions(userId, {
      page: 1,
      limit: 10,
      month: 2,
      year: 2026,
    });

    expect(result.transactions).toEqual([]);
    expect(result.totalCount).toBe(0);
    expect(result.stats).toBeDefined();
    expect(result.stats).toEqual({
      totalIncome: 0,
      totalExpense: 0,
      balance: 0,
    });
    expect(result.stats).not.toHaveProperty("_id");
    expect(result.stats).not.toHaveProperty("totalAmount");
    expect(typeof result.stats.totalIncome).toBe("number");
    expect(typeof result.stats.totalExpense).toBe("number");
    expect(typeof result.stats.balance).toBe("number");
  });

  it("should return normalized stats contract when aggregation has data", async () => {
    Transaction.aggregate.mockResolvedValueOnce([
      {
        _id: null,
        totalAmount: 300,
        totalIncome: 500,
        totalExpense: 200,
      },
    ]);

    const result = await transactionService.getFilteredTransactions(userId, {
      month: 2,
      year: 2026,
    });

    expect(result.stats).toBeDefined();
    expect(result.stats).toEqual({
      totalIncome: 500,
      totalExpense: 200,
      balance: 300,
    });
    expect(result.stats).not.toHaveProperty("_id");
    expect(result.stats).not.toHaveProperty("totalAmount");
    expect(typeof result.stats.totalIncome).toBe("number");
    expect(typeof result.stats.totalExpense).toBe("number");
    expect(typeof result.stats.balance).toBe("number");
  });
});
