/** Unit tests for transaction service */

const AppError = require("../../../utils/app_error");
const mongoose = require("mongoose");

jest.mock("../../../models/transaction_schema", () => ({
  find: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
  create: jest.fn(),
}));

const Transaction = require("../../../models/transaction_schema");
const transactionService = require("../../../services/transaction_service");

describe("Transaction Service - getFilteredTransactions", () => {
  const mockQuery = {
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    lean: jest.fn().mockResolvedValue([]),
  };

  const userId = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    Transaction.find.mockReturnValue(mockQuery);
    Transaction.countDocuments.mockResolvedValue(0);
    Transaction.aggregate.mockResolvedValue([]);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should throw AppError if no date filter provided", async () => {
    await expect(
      transactionService.getFilteredTransactions(userId, { page: 1 }),
    ).rejects.toThrow(AppError);
  });

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

describe("Transaction Service - createTransaction", () => {
  const userId = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    Transaction.create.mockResolvedValue({
      _id: new mongoose.Types.ObjectId().toString(),
      userId,
      title: "Lunch",
      amount: 50000,
      type: "expense",
      category: "food",
      date: new Date("2026-02-24T00:00:00.000Z"),
      note: "Lunch with friends",
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should create transaction successfully", async () => {
    const payload = {
      title: "Lunch",
      amount: 50000,
      type: "expense",
      category: "food",
      date: "2026-02-24",
      note: "Lunch with friends",
    };

    const result = await transactionService.createTransaction(userId, payload);

    expect(Transaction.create).toHaveBeenCalledWith(
      expect.objectContaining({
        userId: new mongoose.Types.ObjectId(userId),
        title: "Lunch",
        amount: 50000,
        type: "expense",
        category: "food",
        date: new Date("2026-02-24T00:00:00.000Z"),
        note: "Lunch with friends",
      }),
    );
    expect(result).toBeDefined();
  });

  it("should throw AppError when date format is invalid", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Lunch",
        amount: 50000,
        type: "expense",
        category: "food",
        date: "24-02-2026",
      }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError when userId is invalid", async () => {
    await expect(
      transactionService.createTransaction("invalid-id", {
        title: "Lunch",
        amount: 50000,
        type: "expense",
        category: "food",
        date: "2026-02-24",
      }),
    ).rejects.toThrow(AppError);
  });
});
