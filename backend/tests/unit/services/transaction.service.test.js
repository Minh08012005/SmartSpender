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
  create: jest.fn(),
  findOneAndDelete: jest.fn(),
  findOneAndUpdate: jest.fn(),
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

  it("should normalize uppercase type and category filters", async () => {
    await transactionService.getFilteredTransactions(userId, {
      type: "  INCOME  ",
      category: " Food, TRAVEL ",
      month: 2,
      year: 2026,
    });

    expect(Transaction.find).toHaveBeenCalledWith(
      expect.objectContaining({
        type: "income",
        category: { $in: ["food", "travel"] },
      }),
    );

    // Aggregation phải dùng cùng query đã normalize để stats và list đồng nhất.
    expect(Transaction.aggregate).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          $match: expect.objectContaining({
            type: "income",
            category: { $in: ["food", "travel"] },
          }),
        }),
      ])
    );
  });

  it("should throw AppError for invalid from date format", async () => {
    await expect(
      transactionService.getFilteredTransactions(userId, {
        from: "invalid-date",
        to: "2026-03-01",
      }),
    ).rejects.toThrow("Invalid from date format");
  });

  it("should throw AppError when to date is before from date", async () => {
    await expect(
      transactionService.getFilteredTransactions(userId, {
        from: "2026-03-20",
        to: "2026-03-01",
      }),
    ).rejects.toThrow("to date must be after from date");
  });

  it("should parse valid ISO and YYYY-MM-DD date filters", async () => {
    await transactionService.getFilteredTransactions(userId, {
      from: "2026-03-01",
      to: "2026-03-31T23:59:59Z",
    });

    const queryArg = Transaction.find.mock.calls[0][0];
    expect(queryArg.date.$gte).toBeInstanceOf(Date);
    expect(queryArg.date.$lte).toBeInstanceOf(Date);
  });

  it("should include the full `to` day when using YYYY-MM-DD", async () => {
    await transactionService.getFilteredTransactions(userId, {
      from: "2026-03-01",
      to: "2026-03-31",
    });

    const queryArg = Transaction.find.mock.calls[0][0];
    expect(queryArg.date.$gte.toISOString()).toBe("2026-03-01T00:00:00.000Z");
    expect(queryArg.date.$lte.toISOString()).toBe("2026-03-31T23:59:59.999Z");
  });

  it("should build aggregation pipeline with case-insensitive type sums", async () => {
    await transactionService.getFilteredTransactions(userId, {
      month: 2,
      year: 2026,
    });

    const pipeline = Transaction.aggregate.mock.calls[0][0];
    const groupStage = pipeline.find((stage) => stage.$group);

    expect(groupStage.$group.totalIncome.$sum.$cond[0]).toEqual({
      $eq: [{ $toLower: "$type" }, "income"],
    });
    expect(groupStage.$group.totalExpense.$sum.$cond[0]).toEqual({
      $eq: [{ $toLower: "$type" }, "expense"],
    });
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

    const created = {
      ...payload,
      _id: new mongoose.Types.ObjectId(),
      userId: new mongoose.Types.ObjectId(userId),
      toObject: jest.fn().mockReturnValue({ ...payload, _id: "mock-id" }),
    };

    Transaction.create.mockResolvedValue(created);

    const result = await transactionService.createTransaction(userId, payload);

    expect(Transaction.create).toHaveBeenCalled();
    expect(result).toEqual({ ...payload, _id: "mock-id" });
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

  it("should throw error if category is not a string", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Test",
        amount: 100,
        category: 123,
        type: "expense",
      })
    ).rejects.toThrow("Category must be a string");
  });

  it("should throw error if type is not a string", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Test",
        amount: 100,
        category: "food",
        type: 1,
      })
    ).rejects.toThrow("Type must be a string");
  });

  it("should throw error if date has invalid format", async () => {
    await expect(
      transactionService.createTransaction(userId, {
        title: "Test",
        amount: 100,
        category: "food",
        type: "expense",
        date: "not-a-date",
      })
    ).rejects.toThrow("Invalid date format");
  });

  it("should accept ISO datetime date format", async () => {
    const payload = {
      title: "Salary",
      amount: 5000,
      category: "salary",
      type: "income",
      date: "2026-03-16T10:00:00Z",
    };

    const created = {
      ...payload,
      _id: new mongoose.Types.ObjectId(),
      userId: new mongoose.Types.ObjectId(userId),
      toObject: jest.fn().mockReturnValue({ ...payload, _id: "created-id" }),
    };

    Transaction.create.mockResolvedValue(created);

    await transactionService.createTransaction(userId, payload);
    const createArg = Transaction.create.mock.calls[0][0];

    expect(createArg.date).toBeInstanceOf(Date);
    expect(Number.isNaN(createArg.date.getTime())).toBe(false);
  });

  it("should accept YYYY-MM-DD date format", async () => {
    const payload = {
      title: "Lunch",
      amount: 100,
      category: "food",
      type: "expense",
      date: "2026-03-16",
    };

    const created = {
      ...payload,
      _id: new mongoose.Types.ObjectId(),
      userId: new mongoose.Types.ObjectId(userId),
      toObject: jest.fn().mockReturnValue({ ...payload, _id: "created-id-2" }),
    };

    Transaction.create.mockResolvedValue(created);

    await transactionService.createTransaction(userId, payload);
    const createArg = Transaction.create.mock.calls[0][0];

    expect(createArg.date).toBeInstanceOf(Date);
    expect(Number.isNaN(createArg.date.getTime())).toBe(false);
  });
});

/**
 * UPDATE TRANSACTION TESTS
 */

describe("Transaction Service - updateTransaction", () => {
  const userId = new mongoose.Types.ObjectId().toString();
  const id = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Bảo vệ khỏi BSONTypeError nếu JWT bị craft với userId không hợp lệ
  it("should throw AppError 400 if userId is invalid ObjectId", async () => {
    await expect(
      transactionService.updateTransaction("not-valid-id", id, { title: "x" })
    ).rejects.toThrow("Invalid user id");
  });

  it("should throw AppError 400 if transaction id is invalid ObjectId", async () => {
    await expect(
      transactionService.updateTransaction(userId, "not-valid-id", { title: "x" })
    ).rejects.toThrow("Invalid transaction id");
  });

  it("should throw AppError 400 if body is empty object", async () => {
    await expect(
      transactionService.updateTransaction(userId, id, {})
    ).rejects.toThrow("Request body must not be empty");
  });

  it("should throw AppError 400 if date format is invalid", async () => {
    await expect(
      transactionService.updateTransaction(userId, id, { date: "not-a-date" })
    ).rejects.toThrow("Invalid date format");
  });

  // findOneAndUpdate trả về null khi điều kiện _id + userId không khớp (không tìm thấy hoặc không sở hữu)
  it("should throw AppError 404 if transaction not found or not owned", async () => {
    Transaction.findOneAndUpdate.mockReturnValue({
      lean: jest.fn().mockResolvedValue(null),
    });
    await expect(
      transactionService.updateTransaction(userId, id, { title: "x" })
    ).rejects.toThrow(AppError);
  });

  it("should normalize category and type to lowercase before writing to DB", async () => {
    const updatedDoc = { _id: id, userId, title: "Test", amount: 100, category: "food", type: "expense" };
    Transaction.findOneAndUpdate.mockReturnValue({
      lean: jest.fn().mockResolvedValue(updatedDoc),
    });

    await transactionService.updateTransaction(userId, id, { category: "FOOD", type: "EXPENSE" });

    // Kiểm tra dữ liệu được lưu với giá trị được normalize
    const callArg = Transaction.findOneAndUpdate.mock.calls[0][1];
    expect(callArg.$set.category).toBe("food");
    expect(callArg.$set.type).toBe("expense");
  });

  it("should return updated document on success", async () => {
    const updatedDoc = { _id: id, userId, title: "updated title", amount: 200 };
    Transaction.findOneAndUpdate.mockReturnValue({
      lean: jest.fn().mockResolvedValue(updatedDoc),
    });

    const result = await transactionService.updateTransaction(userId, id, { title: "updated title" });

    expect(result).toEqual(updatedDoc);
    expect(Transaction.findOneAndUpdate).toHaveBeenCalledTimes(1);
  });
});

/**
 * DELETE TRANSACTION TESTS
 */

describe("Transaction Service - deleteTransaction", () => {
  const userId = new mongoose.Types.ObjectId().toString();
  const id = new mongoose.Types.ObjectId().toString();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  // Bảo vệ khỏi BSONTypeError nếu JWT bị craft với userId không hợp lệ
  it("should throw AppError 400 if userId is invalid ObjectId", async () => {
    await expect(
      transactionService.deleteTransaction("not-valid-id", id)
    ).rejects.toThrow("Invalid user id");
  });

  it("should throw AppError 400 if transaction id is invalid ObjectId", async () => {
    await expect(
      transactionService.deleteTransaction(userId, "not-valid-id")
    ).rejects.toThrow("Invalid transaction id");
  });

  // findOneAndDelete trả về null khi không tìm thấy hoặc user không sở hữu document
  it("should throw AppError 404 if transaction not found or not owned", async () => {
    Transaction.findOneAndDelete.mockReturnValue({
      lean: jest.fn().mockResolvedValue(null),
    });
    await expect(
      transactionService.deleteTransaction(userId, id)
    ).rejects.toThrow(AppError);
  });

  it("should return deleted document on success", async () => {
    const deletedDoc = { _id: id, userId, title: "to be deleted", amount: 150 };
    Transaction.findOneAndDelete.mockReturnValue({
      lean: jest.fn().mockResolvedValue(deletedDoc),
    });

    const result = await transactionService.deleteTransaction(userId, id);

    // quan trọng: phải trả về đúng deleted doc để controller có dữ liệu trả về client
    expect(result).toEqual(deletedDoc);
    expect(Transaction.findOneAndDelete).toHaveBeenCalledTimes(1);
  });
});
