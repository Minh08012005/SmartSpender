/**
 * Integration Test
 * PUT /api/transactions/:id
 * Use real DB
 */


const request = require("supertest");
const mongoose = require("mongoose");
const { SignJWT } = require("jose");
const { TextEncoder } = require("util");

process.env.JWT_SECRET = "testsecret";

beforeAll(async () => {
  await mongoose.connect("mongodb://127.0.0.1:27017/smartspender_test");
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require("../../app");
const User = require("../../models/users.model");
const Transaction = require("../../models/transaction_schema");
const Wallet = require("../../models/wallet.model");

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

describe("PUT /api/transactions/:id", () => {
  let owner;
  let ownerToken;
  let otherUser;
  let otherToken;
  let transaction;

  beforeEach(async () => {
    owner = await User.create({
      fullName: "Test User",
      email: "test@example.com",
      password: "123456",
    });

    otherUser = await User.create({
      fullName: "Other User",
      email: "other@example.com",
      password: "123456",
    });

    ownerToken = await makeToken(owner._id);
    otherToken = await makeToken(otherUser._id);

    await Wallet.insertMany([
      {
        userId: owner._id,
        walletType: "cash",
        name: "Tiền mặt",
        description: "cash",
        balance: 100,
      },
      {
        userId: owner._id,
        walletType: "bank",
        name: "Ngân hàng",
        description: "bank",
        balance: 0,
      },
      {
        userId: owner._id,
        walletType: "ewallet",
        name: "Ví điện tử",
        description: "ewallet",
        balance: 0,
      },
    ]);

    transaction = await Transaction.create({
      userId: owner._id,
      title: "Old Title",
      amount: 100,
      category: "salary",
      type: "income",
      date: new Date(),
    });
  });

  afterEach(async () => {
    await Transaction.deleteMany();
    await Wallet.deleteMany();
    await User.deleteMany();
  });

  it("should return 401 with TOKEN_MISSING if no token provided", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .send({ title: "Updated" });

    expect(res.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_MISSING");
    expect(res.body.message).toBe("Access token required");
  });

  it("should return 401 with TOKEN_INVALID if token is malformed", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", "Bearer not.a.real.token")
      .send({ title: "Updated" });

    expect(res.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_INVALID");
    expect(res.body.message).toBe("Invalid token");
  });

  it("should return 401 with TOKEN_EXPIRED if token is expired", async () => {
    const expiredToken = await makeToken(
      owner._id,
      Math.floor(Date.now() / 1000) - 10
    );

    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${expiredToken}`)
      .send({ title: "Updated" });

    expect(res.statusCode).toBe(401);
    expect(res.body.errorCode).toBe("TOKEN_EXPIRED");
    expect(res.body.message).toBe("Token expired");
  });


  it("should update successfully, including type and note", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        title: "Updated",
        amount: 0,
        category: "food",
        type: "expense",
        note: "some details",
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(200);
    expect(res.body.message).toBe("Transaction updated successfully");
    expect(res.body.data.title).toBe("Updated");
    expect(res.body.data.amount).toBe(0);
    expect(res.body.data.type).toBe("expense");
    expect(res.body.data.note).toBe("some details");
  });

  it("should allow setting amount to zero", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ amount: 0 });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.amount).toBe(0);
  });

  it("should allow partial update, only changing specified fields", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ title: "Partial Update" });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.title).toBe("Partial Update");
    // Ensure other fields remain unchanged
    expect(res.body.data.amount).toBe(100); // original amount
    expect(res.body.data.category).toBe("salary");
    expect(res.body.data.type).toBe("income");
  });

  it("should return 400 if invalid amount", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ amount: -10 });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 if payload is empty", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({});

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 for invalid date", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ date: "not-a-date" });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 for invalid category", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ category: "unknown" });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 400 for malformed id param", async () => {
    const res = await request(app)
      .put(`/api/transactions/123`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ title: "test" });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Validation failed");
  });

  it("should return 404 if not owner", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${otherToken}`)
      .send({ amount: 200 });

    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(404);
    expect(res.body.message).toBe("Transaction not found");
  });

  it("should return 404 if transaction does not exist", async () => {
    const nonExistentId = new mongoose.Types.ObjectId().toString();

    const res = await request(app)
      .put(`/api/transactions/${nonExistentId}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({ amount: 200 });

    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(404);
    expect(res.body.message).toBe("Transaction not found");
  });

  it("should return 400 when update causes insufficient wallet balance", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${ownerToken}`)
      .send({
        type: "expense",
        amount: 200,
        category: "food",
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe("Insufficient balance in cash wallet");
  });
});