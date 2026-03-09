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
  });
});

// Unit tests for updateTransaction
describe("Transaction Service - updateTransaction", () => {
  const mockTransaction = {
    _id: new mongoose.Types.ObjectId(),
    userId: new mongoose.Types.ObjectId(),
    title: "Original Title",
    amount: 100,
    category: "food",
    type: "expense",
    date: new Date(),
    note: "Original note",
  };

  beforeEach(() => {
    Transaction.findOneAndUpdate = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should update transaction successfully with valid payload", async () => {
    const payload = {
      title: "Updated Title",
      amount: 200,
      category: "travel",
      type: "income",
      note: "Updated note",
    };
    const updatedMock = { ...mockTransaction, ...payload };
    Transaction.findOneAndUpdate.mockResolvedValue(updatedMock);

    const result = await transactionService.updateTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString(),
      payload
    );

    expect(Transaction.findOneAndUpdate).toHaveBeenCalledWith(
      {
        _id: mockTransaction._id,
        userId: mockTransaction.userId,
      },
      {
        $set: {
          title: "Updated Title",
          amount: 200,
          category: "travel",
          type: "income",
          note: "Updated note",
        },
      },
      { new: true }
    );
    expect(result).toEqual(updatedMock);
  });

  it("should throw error for invalid transaction id", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        "invalid-id",
        { title: "Test" }
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for invalid user id", async () => {
    await expect(
      transactionService.updateTransaction(
        "invalid-user-id",
        mockTransaction._id.toString(),
        { title: "Test" }
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for empty payload", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        {}
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for invalid amount", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        { amount: -10 }
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for invalid date", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        { date: "invalid-date" }
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for invalid category", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        { category: "invalid-category" }
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error for invalid type", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        { type: "invalid-type" }
      )
    ).rejects.toThrow(AppError);
  });

  it("should normalize category to lowercase", async () => {
    const payload = { category: "FOOD" };
    const updatedMock = { ...mockTransaction, category: "food" };
    Transaction.findOneAndUpdate.mockResolvedValue(updatedMock);

    await transactionService.updateTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString(),
      payload
    );

    expect(Transaction.findOneAndUpdate).toHaveBeenCalledWith(
      expect.any(Object),
      { $set: { category: "food" } },
      { new: true }
    );
  });

  it("should trim title and note", async () => {
    const payload = { title: "  Title  ", note: "  Note  " };
    const updatedMock = { ...mockTransaction, title: "Title", note: "Note" };
    Transaction.findOneAndUpdate.mockResolvedValue(updatedMock);

    await transactionService.updateTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString(),
      payload
    );

    expect(Transaction.findOneAndUpdate).toHaveBeenCalledWith(
      expect.any(Object),
      { $set: { title: "Title", note: "Note" } },
      { new: true }
    );
  });

  it("should throw 404 if transaction not found or permission denied", async () => {
    Transaction.findOneAndUpdate.mockResolvedValue(null);

    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        { title: "Test" }
      )
    ).rejects.toThrow(AppError);
  });
});

/**
 * DELETE Transaction Tests
 */
describe("Transaction Service - deleteTransaction", () => {
  const mockTransaction = {
    _id: new mongoose.Types.ObjectId(),
    userId: new mongoose.Types.ObjectId(),
    title: "Test Transaction",
    amount: 100000,
    category: "food",
    type: "expense",
    date: new Date("2026-03-08"),
    note: "Test note",
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should delete transaction successfully if it exists and belongs to user", async () => {
    Transaction.findOneAndDelete = jest.fn().mockResolvedValue(mockTransaction);

    const result = await transactionService.deleteTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString()
    );

    expect(result).toEqual(mockTransaction);
    expect(Transaction.findOneAndDelete).toHaveBeenCalledWith({
      _id: new mongoose.Types.ObjectId(mockTransaction._id.toString()),
      userId: new mongoose.Types.ObjectId(mockTransaction.userId.toString()),
    });
  });

  it("should throw 400 if transactionId is invalid ObjectId", async () => {
    await expect(
      transactionService.deleteTransaction(
        mockTransaction.userId.toString(),
        "invalid-id"
      )
    ).rejects.toThrow(/Invalid transaction id/);
  });

  it("should throw 400 if userId is invalid ObjectId", async () => {
    await expect(
      transactionService.deleteTransaction(
        "invalid-user-id",
        mockTransaction._id.toString()
      )
    ).rejects.toThrow(/Invalid user id/);
  });

  it("should throw 404 if transaction not found or permission denied", async () => {
    Transaction.findOneAndDelete = jest.fn().mockResolvedValue(null);

    await expect(
      transactionService.deleteTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString()
      )
    ).rejects.toThrow(AppError);
  });

  it("should not delete transaction if it belongs to different user", async () => {
    const differentUserId = new mongoose.Types.ObjectId();
    Transaction.findOneAndDelete = jest.fn().mockResolvedValue(null);

    await expect(
      transactionService.deleteTransaction(
        differentUserId.toString(),
        mockTransaction._id.toString()
      )
    ).rejects.toThrow(AppError);

    expect(Transaction.findOneAndDelete).toHaveBeenCalledWith({
      _id: new mongoose.Types.ObjectId(mockTransaction._id.toString()),
      userId: new mongoose.Types.ObjectId(differentUserId.toString()),
    });
  });
});

/**
 * CREATE Transaction Tests
 */
describe("Transaction Service - createTransaction", () => {
  const mockUserId = new mongoose.Types.ObjectId();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Note: Full createTransaction tests require integration with actual database
  // Unit tests should focus on validateable logic in the service
  // Comprehensive tests are covered in integration tests (transaction.routes.test.js, transaction.put.test.js)
  
  it("createTransaction exists and is callable", () => {
    expect(typeof transactionService.createTransaction).toBe("function");
  });
});
