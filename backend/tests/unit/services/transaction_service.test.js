/** Unit tests for transaction service */

const AppError = require("../../../utils/app_error");
const mongoose = require("mongoose");

jest.mock("../../../models/transaction_schema", () => ({
  find: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
  create: jest.fn(),
  findOneAndUpdate: jest.fn(),
  findOneAndDelete: jest.fn(),
}));

const Transaction = require("../../../models/transaction_schema");
const transactionService = require("../../../services/transaction_service");

describe("Transaction Service - getFilteredTransactions", () => {
  const userId = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    Transaction.aggregate.mockResolvedValue([
      {
        docs: [],
        totalCount: [{ count: 0 }],
        stats: [],
      },
    ]);
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

    const pipeline = Transaction.aggregate.mock.calls[0][0];
    expect(pipeline[0].$match).toEqual(
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

    const pipeline = Transaction.aggregate.mock.calls[0][0];
    expect(pipeline[0].$match.$or).toHaveLength(2);
    expect(pipeline[0].$match.$or[0].note).toEqual(
      expect.objectContaining({
        $regex: expect.any(String),
        $options: "i",
      }),
    );
    expect(pipeline[0].$match.$or[1].title).toEqual(
      expect.objectContaining({
        $regex: expect.any(String),
        $options: "i",
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

    const pipeline = Transaction.aggregate.mock.calls[0][0];
    expect(pipeline[0].$match).toEqual(
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

  it("should coerce string page and limit values", async () => {
    await transactionService.getFilteredTransactions(userId, {
      page: "2",
      limit: "10",
      month: "2",
      year: "2026",
    });

    const pipeline = Transaction.aggregate.mock.calls[0][0];
    expect(pipeline[1].$facet.docs).toEqual([
      { $sort: { date: -1 } },
      { $skip: 10 },
      { $limit: 10 },
    ]);
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

  it("should persist category in lowercase", async () => {
    await transactionService.createTransaction(userId, {
      title: "Lunch",
      amount: 50000,
      type: "expense",
      category: "FOOD",
      date: "2026-02-24",
    });

    expect(Transaction.create).toHaveBeenCalledWith(
      expect.objectContaining({
        category: "food",
      }),
    );
  });

  it("should throw AppError for invalid amount", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Lunch",
        amount: "invalid",
        type: "expense",
        category: "food",
        date: "2026-02-24",
      }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid category", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Lunch",
        amount: 50000,
        type: "expense",
        category: "invalid",
        date: "2026-02-24",
      }),
    ).rejects.toThrow(AppError);
  });
});

describe("Transaction Service - updateTransaction", () => {
  const userId = new mongoose.Types.ObjectId().toString();
  const transactionId = new mongoose.Types.ObjectId().toString();

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should throw AppError for invalid transactionId", async () => {
    await expect(
      transactionService.updateTransaction(userId, "invalid", { title: "test" }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid userId", async () => {
    await expect(
      transactionService.updateTransaction("invalid", transactionId, { title: "test" }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for empty payload", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, {}),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid title type", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { title: 123 }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for empty title", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { title: "   " }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid amount", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { amount: -10 }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid date type", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { date: 123 }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid date format", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { date: "invalid" }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid category type", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { category: 123 }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid category", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { category: "invalid" }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid type", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { type: "invalid" }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError for invalid note type", async () => {
    await expect(
      transactionService.updateTransaction(userId, transactionId, { note: 123 }),
    ).rejects.toThrow(AppError);
  });

  it("should throw AppError if transaction not found or permission denied", async () => {
    Transaction.findOneAndUpdate.mockResolvedValue(null);

    await expect(
      transactionService.updateTransaction(userId, transactionId, { title: "test" }),
    ).rejects.toThrow(AppError);
  });

  it("should update successfully with valid data", async () => {
    const mockUpdated = { _id: transactionId, title: "Updated Title" };
    Transaction.findOneAndUpdate.mockResolvedValue(mockUpdated);

    const result = await transactionService.updateTransaction(userId, transactionId, {
      title: "Updated Title",
      amount: 100,
      category: "food",
      type: "expense",
      date: "2026-03-01",
      note: "test note",
    });

    expect(Transaction.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: new mongoose.Types.ObjectId(transactionId), userId: new mongoose.Types.ObjectId(userId) },
      { $set: expect.objectContaining({
        title: "Updated Title",
        amount: 100,
        category: "food",
        type: "expense",
        note: "test note",
      }) },
      { new: true }
    );
    expect(result).toBe(mockUpdated);
  });
});
