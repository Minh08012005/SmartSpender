const transactionService = require("../../../services/transaction.service");
const Transaction = require("../../../models/transaction_schema");
const mongoose = require("mongoose");

jest.mock("../../../models/transaction_schema", () => ({
  find: jest.fn(),
  countDocuments: jest.fn(),
  aggregate: jest.fn(),
}));

describe("Transaction Service - getFilteredTransactions", () => {
  const mockQuery = {
    sort: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    lean: jest.fn().mockResolvedValue([]),
  };

  const userId = new mongoose.Types.ObjectId().toString();

  afterEach(() => {
    jest.clearAllMocks();
  });

  // Test Security
  it("should always include userId in the query to prevent data leaking", async () => {
    Transaction.find.mockReturnValue(mockQuery);

    Transaction.countDocuments.mockResolvedValue(0);
    Transaction.aggregate.mockResolvedValue([]);

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
    Transaction.find.mockReturnValue(mockQuery);

    Transaction.countDocuments.mockResolvedValue(0);
    Transaction.aggregate.mockResolvedValue([]);

    const result = await transactionService.getFilteredTransactions(userId, {
      page: 1,
      limit: 10,
      month: 2,
      year: 2026,
    });

    expect(result.finalStats).toBeDefined();
  });
});
