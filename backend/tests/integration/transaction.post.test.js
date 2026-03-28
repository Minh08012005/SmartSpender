/**
 * Integration Test
 * POST /api/transactions
 */

const request = require("supertest");
const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");

beforeAll(async () => {
  // DB riêng để tránh đụng nhau khi chạy song song với file integration khác
  await mongoose.connect("mongodb://127.0.0.1:27017/smartspender_test_create");
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require("../../app");
const User = require("../../models/users.model");
const Transaction = require("../../models/transaction_schema");

const makeToken = async (userId, expiresAt) => {
  const secret = new TextEncoder().encode(process.env.JWT_SECRET);
  const tokenBuilder = new SignJWT({ userId: userId.toString() })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt();

  if (expiresAt !== undefined) {
    tokenBuilder.setExpirationTime(expiresAt);
  } else {
    tokenBuilder.setExpirationTime("1h");
  }

  return tokenBuilder.sign(secret);
};

describe("POST /api/transactions", () => {
  let owner;
  let ownerToken;

  beforeEach(async () => {
    owner = await User.create({
      fullName: "Create Owner",
      email: "create.owner@example.com",
      password: "123456",
    });

    ownerToken = await makeToken(owner._id);
  });

  afterEach(async () => {
    await Transaction.deleteMany();
    await User.deleteMany();
  });

  it("should create transaction successfully and return standardized success response", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Salary",
        amount: 45000,
        category: "SALARY",
        type: "INCOME",
        note: "monthly salary",
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(201);
    expect(res.body.message).toBe("Transaction created successfully");
    expect(res.body.data).toBeDefined();
    expect(res.body.data.title).toBe("Salary");
    expect(res.body.data.amount).toBe(45000);
    expect(res.body.data.category).toBe("salary");
    expect(res.body.data.type).toBe("income");
    expect(res.body.data.userId.toString()).toBe(owner._id.toString());
  });

  it("should return 400 when expense exceeds wallet balance", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Big purchase",
        amount: 200000,
        category: "shopping",
        type: "expense",
        walletType: "cash",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Insufficient balance in cash wallet");
  });

  it("should allow amount = 0", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Opening balance",
        amount: 0,
        category: "other",
        type: "income",
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.data.amount).toBe(0);
  });

  it("should return 400 Validation failed when title is missing", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        amount: 100,
        category: "food",
        type: "expense",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
    expect(Array.isArray(res.body.errors)).toBe(true);
  });

  it("should return 400 Validation failed for invalid amount", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Invalid amount",
        amount: -1,
        category: "food",
        type: "expense",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 Validation failed for invalid category", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Invalid category",
        amount: 10,
        category: "invalid-category",
        type: "expense",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 Validation failed for invalid date format", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Invalid date",
        amount: 10,
        category: "food",
        type: "expense",
        date: "03/19/2026",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 401 TOKEN_MISSING if no token provided", async () => {
    const res = await request(app).post("/api/transactions").send({
      title: "Unauthorized",
      amount: 10,
      category: "food",
      type: "expense",
    });

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_MISSING");
    expect(res.body.message).toBe("Access token required");
  });

  it("should return 401 TOKEN_INVALID if token is malformed", async () => {
    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", "Bearer not.a.real.token")
      .send({
        title: "Unauthorized",
        amount: 10,
        category: "food",
        type: "expense",
      });

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_INVALID");
    expect(res.body.message).toBe("Invalid token");
  });

  it("should return 401 TOKEN_EXPIRED when token is expired", async () => {
    const expiredToken = await makeToken(
      owner._id,
      Math.floor(Date.now() / 1000) - 10
    );

    const res = await request(app)
      .post("/api/transactions")
      .set("Authorization", `Bearer ${expiredToken}`)
      .send({
        title: "Expired token",
        amount: 10,
        category: "food",
        type: "expense",
      });

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_EXPIRED");
    expect(res.body.message).toBe("Token expired");
  });
});