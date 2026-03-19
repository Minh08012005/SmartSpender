/**
 * Integration Test
 * DELETE /api/transactions/:id
 *
 * Lưu ý về token:
 *   - Dùng jose/SignJWT để nhất quán với auth.middleware.js (cũng dùng jose để verify)
 *   - Payload phải chứa `userId` (auth middleware lookup: payload.userId || payload._id)
 */

const request = require("supertest");
const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");

beforeAll(async () => {
  // DB riêng để tránh race condition với transaction.put.test.js khi Jest chạy parallel
  await mongoose.connect("mongodb://127.0.0.1:27017/smartspender_test_delete");
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require("../../app");
const User = require("../../models/users.model");
const Transaction = require("../../models/transaction_schema");

// Helper: tạo JWT hợp lệ bằng jose (nhất quán với auth middleware)
const makeToken = async (userId) => {
  const secret = new TextEncoder().encode(process.env.JWT_SECRET);
  return new SignJWT({ userId: userId.toString() })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(secret);
};

describe("DELETE /api/transactions/:id", () => {
  let user;
  let token;
  let transaction;

  beforeEach(async () => {
    user = await User.create({
      fullName: "Delete Test User",
      email: "deletetest@example.com",
      password: "123456",
    });

    token = await makeToken(user._id);

    transaction = await Transaction.create({
      userId: user._id,
      title: "To Be Deleted",
      amount: 200,
      category: "food",
      type: "expense",
      date: new Date(),
    });
  });

  afterEach(async () => {
    await Transaction.deleteMany();
    await User.deleteMany();
  });

  // ─── Happy path ───────────────────────────────────────────────────────────

  it("should delete transaction and return 200 with deleted document", async () => {
    const res = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(200);
    expect(res.body.message).toBe("Transaction deleted successfully");

    // Contract: data phải là document đã bị xóa (KHÔNG phải null – BUG-10 fix)
    expect(res.body.data).toBeDefined();
    expect(res.body.data._id).toBe(transaction._id.toString());
    expect(res.body.data.title).toBe("To Be Deleted");
  });

  it("should actually remove the document from DB after delete", async () => {
    await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`);

    // Xác nhận bản ghi không còn trong DB
    const found = await Transaction.findById(transaction._id);
    expect(found).toBeNull();
  });

  // ─── Ownership / Authorization ────────────────────────────────────────────

  it("should return 404 if user does not own the transaction", async () => {
    const otherUser = await User.create({
      fullName: "Other User",
      email: "other2@example.com",
      password: "123456",
    });
    const otherToken = await makeToken(otherUser._id);

    const res = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${otherToken}`);

    // Transaction không tồn tại trong scope của otherUser → 404
    // Không được để lộ "transaction exists but you don't own it" → security
    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(404);
    expect(res.body.message).toBe("Transaction not found");
  });

  it("should return 404 if transaction does not exist", async () => {
    const nonExistentId = new mongoose.Types.ObjectId().toString();

    const res = await request(app)
      .delete(`/api/transactions/${nonExistentId}`)
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(404);
    expect(res.body.message).toBe("Transaction not found");
  });

  // ─── Auth ─────────────────────────────────────────────────────────────────

  it("should return 401 with TOKEN_MISSING if no token provided", async () => {
    const res = await request(app).delete(
      `/api/transactions/${transaction._id}`
    );

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_MISSING");
    expect(res.body.message).toBe("Access token required");
  });

  it("should return 401 with TOKEN_INVALID if token is malformed", async () => {
    const res = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", "Bearer not.a.real.token");

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_INVALID");
    expect(res.body.message).toBe("Invalid token");
  });

  // ─── Validation ───────────────────────────────────────────────────────────

  it("should return 400 if id param is not a valid ObjectId", async () => {
    const res = await request(app)
      .delete(`/api/transactions/not-valid-id`)
      .set("Authorization", `Bearer ${token}`);

    // objectIdParamSchema bắt trước khi vào service
    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 if id param is too short (23 chars)", async () => {
    const res = await request(app)
      .delete(`/api/transactions/65c88df8b2f8a1c21c23abc`) // 23 chars
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  // ─── Idempotency check ───────────────────────────────────────────────────

  it("should return 404 on second delete (idempotency – not 500 or 200)", async () => {
    // Lần 1: xóa thành công
    await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`);

    // Lần 2: bản ghi không còn → phải là 404, không phải crash
    const res = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`);

    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(404);
    expect(res.body.message).toBe("Transaction not found");
  });
});
