/**
 * File này chứa các bài test tích hợp cho endpoint quản lý giao dịch
 * Mục tiêu:
 *   - Đảm bảo endpoint trả về đúng dữ liệu với các tham số lọc và phân trang
 *   - Kiểm tra bảo mật: chỉ user có token hợp lệ mới truy cập được
 *   - Xử lý lỗi: thiếu tham số, tham số không hợp lệ, v.v.
 *
 * Lưu ý:
 *   - Mock service để tránh truy cập DB thật
 *   - Kiểm tra kỹ cấu trúc response để đảm bảo không có field thừa (ví dụ: 'meta')
 *   - Test cả trường hợp token hết hạn và lỗi từ service
 */

const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");


jest.mock("../../services/transaction.service", () => ({
  getFilteredTransactions: jest.fn(),
}));

const transactionService = require("../../services/transaction.service");
const request = require("supertest");
const app = require("../../app");

// api giao dịch có pagination, nên cần test kỹ phần này để đảm bảo trả về đúng dữ liệu và không có field thừa như 'meta'
describe("Transaction API Integration Tests", () => {
  let token;
  let secret;
  const mockUserId = new mongoose.Types.ObjectId().toString();

  // Tạo token hợp lệ trước khi chạy các test
  beforeAll(async () => {
    // Mock đúng cấu trúc trả về từ service
    transactionService.getFilteredTransactions.mockResolvedValue({
      transactions: [],
      totalCount: 0,
      page: 1,
      limit: 5,
    });

    secret = new TextEncoder().encode(process.env.JWT_SECRET);
    token = await new SignJWT({ userId: mockUserId })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("1h")
      .sign(secret);
  });

  // Xóa mock sau mỗi test để tránh ảnh hưởng lẫn nhau
  afterEach(() => {
    jest.clearAllMocks();
  });

  // Test bảo mật: không có token sẽ bị từ chối truy cập
  it("GET /api/transactions - should return 401 if no token provided", async () => {
    const res = await request(app).get("/api/transactions");
    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
  });

  // Test trường hợp thành công với tham số hợp lệ và kiểm tra cấu trúc response
  it("GET /api/transactions - should return correct pagination fields", async () => {
    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ page: 1, limit: 5, month: 2, year: 2026 });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toBeDefined();

    // Kiểm tra các field thực tế từ service
    expect(res.body.data).toHaveProperty("transactions");
    expect(res.body.data).toHaveProperty("totalCount", 0);
    expect(res.body.data).toHaveProperty("page", 1);
    expect(res.body.data).toHaveProperty("limit", 5);

    // Đảm bảo không có field 'meta'
    expect(res.body.data.meta).toBeUndefined();
  });

  // Test xem service có được gọi với đúng tham số không
  it("GET /api/transactions - should call service with correct parameters", async () => {
    await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ page: 2, limit: 10, month: 3, year: 2025 });

    expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
      mockUserId,
      { page: 2, limit: 10, month: 3, year: 2025 },
    );
  });

  // Test trường hợp token hết hạn
  it("should return 401 if token expired", async () => {
    // Tạo token đã hết hạn
    const expiredToken = await new SignJWT({ userId: mockUserId })
      .setProtectedHeader({ alg: "HS256" })
      .setIssuedAt()
      .setExpirationTime("0s") // hết hạn ngay
      .sign(secret);

    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${expiredToken}`)
      .query({ month: 2, year: 2026 });

    expect(res.status).toBe(401);
    expect(res.body.message).toMatch(/expired/i);
  });

  // Test trường hợp service throw error và kiểm tra log lỗi
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
});

/**
 * Integration Test
 * GET /api/transactions
 * Mock service layer
 */
describe("GET /api/transactions", () => {
  let token;
  let secret;
  const mockUserId = new mongoose.Types.ObjectId().toString();

  beforeAll(async () => {
    transactionService.getFilteredTransactions.mockResolvedValue({
      transactions: [],
      totalCount: 0,
      page: 1,
      limit: 5,
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

  it("should return 401 if no token", async () => {
    const res = await request(app).get("/api/transactions");
    expect(res.statusCode).toBe(401);
  });

  it("should return paginated result", async () => {
    const res = await request(app)
      .get("/api/transactions")
      .set("Authorization", `Bearer ${token}`)
      .query({ page: 1, limit: 5, month: 2, year: 2026 });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toHaveProperty("transactions");
    expect(res.body.data.meta).toBeUndefined();
  });
});