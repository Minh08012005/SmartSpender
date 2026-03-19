/**
 * Integration Test
 * Auth matrix for CRUD transaction endpoints:
 * - no token
 * - invalid token
 * - expired token
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { SignJWT } = require('jose');
const { TextEncoder } = require('util');

beforeAll(async () => {
  await mongoose.connect('mongodb://127.0.0.1:27017/smartspender_test_transaction_auth_matrix');
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require('../../app');
const User = require('../../models/users.model');
const Transaction = require('../../models/transaction_schema');

const makeToken = async (userId, expiresAt) => {
  const secret = new TextEncoder().encode(process.env.JWT_SECRET);
  const tokenBuilder = new SignJWT({ userId: userId.toString() })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt();

  if (expiresAt !== undefined) {
    tokenBuilder.setExpirationTime(expiresAt);
  } else {
    tokenBuilder.setExpirationTime('1h');
  }

  return tokenBuilder.sign(secret);
};

describe('Transaction CRUD auth matrix', () => {
  let user;
  let transaction;
  let expiredToken;

  beforeEach(async () => {
    user = await User.create({
      fullName: 'Auth Matrix User',
      email: 'auth.matrix.user@example.com',
      password: '123456',
    });

    transaction = await Transaction.create({
      userId: user._id,
      title: 'Matrix transaction',
      amount: 100,
      category: 'food',
      type: 'expense',
      date: new Date(),
    });

    expiredToken = await makeToken(
      user._id,
      Math.floor(Date.now() / 1000) - 10
    );
  });

  afterEach(async () => {
    await Transaction.deleteMany();
    await User.deleteMany();
  });

  const validCreatePayload = {
    title: 'Matrix create',
    amount: 50,
    category: 'food',
    type: 'expense',
  };

  it('should return 401 TOKEN_MISSING for entire CRUD when no token is provided', async () => {
    const createRes = await request(app)
      .post('/api/transactions')
      .send(validCreatePayload);

    expect(createRes.statusCode).toBe(401);
    expect(createRes.body.errorCode).toBe('TOKEN_MISSING');

    const readRes = await request(app)
      .get('/api/transactions')
      .query({ month: 3, year: 2026 });

    expect(readRes.statusCode).toBe(401);
    expect(readRes.body.errorCode).toBe('TOKEN_MISSING');

    const updateRes = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .send({ title: 'Updated without token' });

    expect(updateRes.statusCode).toBe(401);
    expect(updateRes.body.errorCode).toBe('TOKEN_MISSING');

    const deleteRes = await request(app)
      .delete(`/api/transactions/${transaction._id}`);

    expect(deleteRes.statusCode).toBe(401);
    expect(deleteRes.body.errorCode).toBe('TOKEN_MISSING');
  });

  it('should return 401 TOKEN_INVALID for entire CRUD when token is malformed', async () => {
    const authHeader = { Authorization: 'Bearer not.a.real.token' };

    const createRes = await request(app)
      .post('/api/transactions')
      .set(authHeader)
      .send(validCreatePayload);

    expect(createRes.statusCode).toBe(401);
    expect(createRes.body.errorCode).toBe('TOKEN_INVALID');

    const readRes = await request(app)
      .get('/api/transactions')
      .set(authHeader)
      .query({ month: 3, year: 2026 });

    expect(readRes.statusCode).toBe(401);
    expect(readRes.body.errorCode).toBe('TOKEN_INVALID');

    const updateRes = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set(authHeader)
      .send({ title: 'Updated with invalid token' });

    expect(updateRes.statusCode).toBe(401);
    expect(updateRes.body.errorCode).toBe('TOKEN_INVALID');

    const deleteRes = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set(authHeader);

    expect(deleteRes.statusCode).toBe(401);
    expect(deleteRes.body.errorCode).toBe('TOKEN_INVALID');
  });

  it('should return 401 TOKEN_EXPIRED for entire CRUD when token is expired', async () => {
    const authHeader = { Authorization: `Bearer ${expiredToken}` };

    const createRes = await request(app)
      .post('/api/transactions')
      .set(authHeader)
      .send(validCreatePayload);

    expect(createRes.statusCode).toBe(401);
    expect(createRes.body.errorCode).toBe('TOKEN_EXPIRED');

    const readRes = await request(app)
      .get('/api/transactions')
      .set(authHeader)
      .query({ month: 3, year: 2026 });

    expect(readRes.statusCode).toBe(401);
    expect(readRes.body.errorCode).toBe('TOKEN_EXPIRED');

    const updateRes = await request(app)
      .put(`/api/transactions/${transaction._id}`)
      .set(authHeader)
      .send({ title: 'Updated with expired token' });

    expect(updateRes.statusCode).toBe(401);
    expect(updateRes.body.errorCode).toBe('TOKEN_EXPIRED');

    const deleteRes = await request(app)
      .delete(`/api/transactions/${transaction._id}`)
      .set(authHeader);

    expect(deleteRes.statusCode).toBe(401);
    expect(deleteRes.body.errorCode).toBe('TOKEN_EXPIRED');
  });
});