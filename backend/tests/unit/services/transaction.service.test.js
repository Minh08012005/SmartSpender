/**
 * Unit tests for Transaction Service
 *
 * Mục tiêu:
 * - Test logic của service layer
 * - Mock database operations để không cần MongoDB thật
 * - Đảm bảo security: luôn filter theo userId
 */

const mongoose = require("mongoose");
const AppError = require("../../../utils/appError");

/**
 * Mock Transaction Model
 */
jest.mock("../../../models/transaction_schema", () => ({
  find: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
  create: jest.fn(),
  findOneAndUpdate: jest.fn(),
  findOneAndDelete: jest.fn(),
}));

const Transaction = require("../../../models/transaction_schema");
const transactionService = require("../../../services/transaction.service");

/**
 * Helper: mock query builder
 */
const createMockQuery = (data = []) => ({
  sort: jest.fn().mockReturnThis(),
  skip: jest.fn().mockReturnThis(),
  limit: jest.fn().mockReturnThis(),
  lean: jest.fn().mockResolvedValue(data),
});

describe("Transaction Service - getFilteredTransactions", () => {
  const userId = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    Transaction.find.mockReturnValue(createMockQuery());
    Transaction.countDocuments.mockResolvedValue(0);
    Transaction.aggregate.mockResolvedValue([]);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should throw error if no date filter provided", async () => {
    await expect(
      transactionService.getFilteredTransactions(userId, { page: 1 })
    ).rejects.toThrow(AppError);
  });

  it("should support multiple categories (CSV)", async () => {
    await transactionService.getFilteredTransactions(userId, {
      category: "food,travel",
      month: 2,
      year: 2026,
    });

    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        category: { $in: ["food", "travel"] },
      })
    );
  });

  it("should support search with regex", async () => {
    await transactionService.getFilteredTransactions(userId, {
      search: "lunch",
      month: 2,
      year: 2026,
    });

    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        note: expect.objectContaining({
          $regex: expect.any(String),
          $options: "i",
        }),
      })
    );
  });

  it("should always filter by userId", async () => {
    await transactionService.getFilteredTransactions(userId, {
      month: 2,
      year: 2026,
    });

    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: new mongoose.Types.ObjectId(userId),
      })
    );
  });

  it("should return empty result when no transactions", async () => {
    const result = await transactionService.getFilteredTransactions(userId, {
      month: 2,
      year: 2026,
    });

    expect(result.transactions).toEqual([]);
    expect(result.totalCount).toBe(0);
  });
});

/**
 * CREATE TRANSACTION TESTS
 */

describe("Transaction Service - createTransaction", () => {
  const userId = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should create transaction successfully", async () => {
    const payload = {
      title: "Lunch",
      amount: 100000,
      category: "food",
      type: "expense",
      date: new Date(),
      note: "Team lunch",
    };

    const created = { ...payload, _id: new mongoose.Types.ObjectId() };

    Transaction.create.mockResolvedValue(created);

    const result = await transactionService.createTransaction(userId, payload);

    expect(Transaction.create).toHaveBeenCalled();
    expect(result).toEqual(created);
  });

  it("should throw error if userId invalid", async () => {
    await expect(
      transactionService.createTransaction("invalid", {
        title: "Test",
        amount: 100,
        category: "food",
        type: "expense",
      })
    ).rejects.toThrow(AppError);
  });
});

/**
 * UPDATE TRANSACTION TESTS
 */

describe("Transaction Service - updateTransaction", () => {
  const mockTransaction = {
    _id: new mongoose.Types.ObjectId(),
    userId: new mongoose.Types.ObjectId(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should update transaction successfully", async () => {
    const payload = {
      title: "Updated Title",
      amount: 200,
    };

    const updated = { ...mockTransaction, ...payload };

    Transaction.findOneAndUpdate.mockResolvedValue(updated);

    const result = await transactionService.updateTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString(),
      payload
    );

    expect(Transaction.findOneAndUpdate).toHaveBeenCalled();
    expect(result).toEqual(updated);
  });

  it("should throw error if payload empty", async () => {
    await expect(
      transactionService.updateTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString(),
        {}
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error if transaction not found", async () => {
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
 * DELETE TRANSACTION TESTS
 */

describe("Transaction Service - deleteTransaction", () => {
  const mockTransaction = {
    _id: new mongoose.Types.ObjectId(),
    userId: new mongoose.Types.ObjectId(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("should delete transaction successfully", async () => {
    Transaction.findOneAndDelete.mockResolvedValue(mockTransaction);

    const result = await transactionService.deleteTransaction(
      mockTransaction.userId.toString(),
      mockTransaction._id.toString()
    );

    expect(result).toEqual(mockTransaction);
  });

  it("should throw error if invalid transactionId", async () => {
    await expect(
      transactionService.deleteTransaction(
        mockTransaction.userId.toString(),
        "invalid"
      )
    ).rejects.toThrow(AppError);
  });

  it("should throw error if transaction not found", async () => {
    Transaction.findOneAndDelete.mockResolvedValue(null);

    await expect(
      transactionService.deleteTransaction(
        mockTransaction.userId.toString(),
        mockTransaction._id.toString()
      )
    ).rejects.toThrow(AppError);
  });
});