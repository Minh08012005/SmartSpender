/**
 * Integration Test
 * PUT /api/transactions/:id
 * Use real DB
 */


const request = require("supertest");
const mongoose = require("mongoose");
const jwt = require("jsonwebtoken");

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

describe("PUT /api/transactions/:id", () => {
  let user;
  let token;
  let transaction;

  beforeEach(async () => {
    user = await User.create({
      fullName: "Test User",
      email: "test@example.com",
      password: "123456",
    });

    token = jwt.sign(
      { _id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    transaction = await Transaction.create({
      userId: user._id,
      title: "Old Title",
      amount: 100,
      category: "salary",
      type: "income",
      date: new Date(),
    });
  });

  afterEach(async () => {
    await Transaction.deleteMany();
    await User.deleteMany();
  });


  it("should update successfully, including type and note", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({
        title: "Updated",
        amount: 500,
        category: "food",
        type: "expense",
        note: "some details",
      });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.title).toBe("Updated");
    expect(res.body.data.type).toBe("expense");
    expect(res.body.data.note).toBe("some details");
  });

  it("should allow setting amount to zero", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ amount: 0 });

    expect(res.statusCode).toBe(200);
    expect(res.body.data.amount).toBe(0);
  });

  it("should allow partial update, only changing specified fields", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
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
      .set("Authorization", `Bearer ${token}`)
      .send({ amount: -10 });

    expect(res.statusCode).toBe(400);
  });

  it("should return 400 if payload is empty", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({});

    expect(res.statusCode).toBe(400);
  });

  it("should return 400 for invalid date", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ date: "not-a-date" });

    expect(res.statusCode).toBe(400);
  });

  it("should return 400 for invalid category", async () => {
    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${token}`)
      .send({ category: "unknown" });

    expect(res.statusCode).toBe(400);
  });

  it("should return 400 for malformed id param", async () => {
    const res = await request(app)
      .put(`/api/transactions/123`)
      .set("Authorization", `Bearer ${token}`)
      .send({ title: "test" });

    expect(res.statusCode).toBe(400);
  });

  it("should return 404 if not owner", async () => {
   const otherUser = await User.create({
      fullName: "Other User",
      email: "other@example.com",
      password: "123456",
    });

    const otherToken = jwt.sign(
      { _id: otherUser._id },
      process.env.JWT_SECRET
    );

    const res = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set("Authorization", `Bearer ${otherToken}`)
      .send({ amount: 200 });

    expect(res.statusCode).toBe(404);
  });
});