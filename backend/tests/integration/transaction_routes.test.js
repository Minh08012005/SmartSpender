/** Integration tests for /api/transactions */

const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");

process.env.JWT_SECRET = process.env.JWT_SECRET || "test-secret-key";

jest.mock("../../services/transaction_service", () => ({
  getFilteredTransactions: jest.fn(),
  createTransaction: jest.fn(),
}));

const transactionService = require("../../services/transaction_service");
const request = require("supertest");
const app = require("../../app");

describe("Transaction API Integration Tests", () => {
  let token;
  let secret;
  const mockUserId = new mongoose.Types.ObjectId().toString();
  const createTransactionPayload = {
    title: "Lunch",
    amount: 50000,
    type: "expense",
    category: "food",
    date: "2026-02-24",
    note: "Lunch with friends",
  };

  beforeAll(async () => {
    transactionService.getFilteredTransactions.mockResolvedValue({
      transactions: [],
      totalCount: 0,
      page: 1,
      limit: 5,
    });

    transactionService.createTransaction.mockResolvedValue({
      _id: new mongoose.Types.ObjectId().toString(),
      userId: mockUserId,
      ...createTransactionPayload,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    secret = new TextEncoder().encode(process.env.JWT_SECRET);
    token = await new SignJWT({ userId: mockUserId })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("1h")
      .sign(secret);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("GET /api/transactions - should return 401 if no token provided", async () => {
    const res = await request(app).get("/api/transactions");
    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it("GET /api/transactions - should return correct pagination fields", async () => {
    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ page: 1, limit: 5, month: 2, year: 2026 });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeDefined();

    expect(res.body.data).toHaveProperty("transactions");
    expect(res.body.data).toHaveProperty("totalCount", 0);
    expect(res.body.data).toHaveProperty("page", 1);
    expect(res.body.data).toHaveProperty("limit", 5);

    expect(res.body.data.meta).toBeUndefined();
  });

  it("GET /api/transactions - should call service with correct parameters", async () => {
    await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ page: 2, limit: 10, month: 3, year: 2025 });

    expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
      mockUserId,
      { page: "2", limit: "10", month: "3", year: "2025" },
    );
  });

  it("GET /api/transactions - should return 400 for conflicting date filters", async () => {
    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({
        from: "2026-02-01",
        to: "2026-02-28",
        month: 2,
        year: 2026,
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(transactionService.getFilteredTransactions).not.toHaveBeenCalled();
  });

  it("should return 401 if token expired", async () => {
    const expiredToken = await new SignJWT({ userId: mockUserId })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("0s")
      .sign(secret);

    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${expiredToken}`)
      .query({ month: 2, year: 2026 });

    expect(res.status).toBe(401);
    expect(res.body.message).toMatch(/expired/i);
  });

  it("should return 500 if service throws error", async () => {
    const spy = jest.spyOn(console, "error").mockImplementation(() => {});
    transactionService.getFilteredTransactions.mockRejectedValue(
      new Error("DB error"),
    );

    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ month: 2, year: 2026 });

    expect(res.status).toBe(500);
    spy.mockRestore();
  });

  it("POST /api/transactions - should create transaction successfully", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .send(createTransactionPayload);

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(201);
    expect(res.body.message).toBe("Transaction created successfully");
    expect(res.body.data).toBeDefined();
    expect(res.body.data).toHaveProperty("title", createTransactionPayload.title);
    expect(transactionService.createTransaction).toHaveBeenCalledWith(
      mockUserId,
      createTransactionPayload,
    );
  });

  it("POST /api/transactions - should return 400 when required field is missing", async () => {
    const { title, ...invalidPayload } = createTransactionPayload;

    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .send(invalidPayload);

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe("Validation failed");
    expect(transactionService.createTransaction).not.toHaveBeenCalled();
  });

  it("POST /api/transactions - should return 401 if no token provided", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .send(createTransactionPayload);

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });

  it("POST /api/transactions - should return 400 when category is invalid", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .send({
        ...createTransactionPayload,
        category: "invalid-category",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(transactionService.createTransaction).not.toHaveBeenCalled();
  });
});
