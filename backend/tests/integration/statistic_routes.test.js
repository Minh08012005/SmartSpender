/**
 * File này chứa các bài test tích hợp cho endpoint thống kê thu chi hàng tháng
 * Mục tiêu:
 *   - Đảm bảo endpoint trả về đúng dữ liệu tổng thu, chi và số dư
 *   - Kiểm tra bảo mật: chỉ user có token hợp lệ mới truy cập được
 *   - Xử lý lỗi: thiếu tham số, tham số không hợp lệ, v.v.
 */

const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");

process.env.JWT_SECRET = process.env.JWT_SECRET || "test-secret-key";

// Mock service để tránh truy cập DB thật
jest.mock("../../services/statistic_service", () => ({
  getMonthlyStatistics: jest.fn(),
}));

const statisticService = require("../../services/statistic_service");
const app = require("../../app");
const request = require("supertest");

// Test với getMonthlyStatistics vì đây là endpoint chính trả về thống kê hàng tháng
describe("GET /api/statistics/summary", () => {
  let token;
  const mockUserId = new mongoose.Types.ObjectId().toString();
  const secret = new TextEncoder().encode(process.env.JWT_SECRET);

  // Tạo token JWT hợp lệ trước khi chạy test
  beforeAll(async () => {
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

  // nên trả về 401 nếu không có token
  it("should return 401 if no token provided", async () => {
    const res = await request(app).get("/api/statistics/summary");
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  // nên trả về 400 nếu thiếu tham số month hoặc year
  it("should return 400 if month or year missing", async () => {
    const res = await request(app)
      .get("/api/statistics/summary")
      .set("Authorization", `Bearer ${token}`)
      .query({ month: 2 }); // thiếu year

    expect(res.status).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  // nên trả về 200 với thống kê khi tham số hợp lệ
  it("should return 200 with statistics when valid", async () => {
    const mockData = {
      totalIncome: 5000,
      totalExpense: 3000,
      balance: 2000,
    };
    statisticService.getMonthlyStatistics.mockResolvedValue(mockData);

    const res = await request(app)
      .get("/api/statistics/summary")
      .set("Authorization", `Bearer ${token}`)
      .query({ month: 2, year: 2026 });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data).toEqual(mockData);
    expect(statisticService.getMonthlyStatistics).toHaveBeenCalledWith(
      mockUserId,
      "2",
      "2026",
    );
  }, 10000);
});
