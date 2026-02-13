const transactionService = require("../../services/transaction.service");
const request = require("supertest");
const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");
const app = require("../../app");

jest.mock("../../services/transaction.service", () => ({
  getFilteredTransactions: jest.fn(),
}));

describe("Transaction API Integration Tests", () => {
  let token;
  const mockUserId = new mongoose.Types.ObjectId().toString();

  beforeAll(async () => {
    transactionService.getFilteredTransactions.mockResolvedValue({
      data: [],
      meta: {
        total: 0,
        page: 1,
        limit: 5,
      },
      finalStats: {
        income: 0,
        expense: 0,
        balance: 0,
      },
    });
    // Tạo token giả cho user
    const secret = new TextEncoder().encode(process.env.JWT_SECRET);

    token = await new SignJWT({ userId: mockUserId })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("1h")
      .sign(secret);
  });

  // Test Unauthenticated
  it("GET /api/transactions - should return 401 if no token provided", async () => {
    const res = await request(app).get("/api/transactions");
    // .set("Authorization", `Bearer ${token}`) // Gửi token hợp lệ để kiểm tra endpoint
    // .query({ page: 1, limit: 10, month: 2, year: 2026 }); // Thêm query parameters hợp lệ

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });

  // Test Phân trang thực tế
  it("GET /api/transactions - should return correct meta for pagination", async () => {
    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({
        page: 1,
        limit: 5,
        month: 2,
        year: 2026,
      });

    if (res.statusCode !== 200) {
      console.log("Response Body:", JSON.stringify(res.body, null, 2));
    }

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeDefined();
    expect(res.body.data.meta).toHaveProperty("total");
  });
});
