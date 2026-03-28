const mongoose = require('mongoose');
const request = require('supertest');
const { SignJWT } = require('jose');
const { TextEncoder } = require('util');

process.env.JWT_SECRET = process.env.JWT_SECRET || 'testsecret';

jest.mock('../../services/transaction.service', () => ({
  getFilteredTransactions: jest.fn(),
}));

jest.mock('../../services/statistic.service', () => ({
  getMonthlyStatistics: jest.fn(),
}));

const transactionService = require('../../services/transaction.service');
const statisticService = require('../../services/statistic.service');
const app = require('../../app');

const secret = new TextEncoder().encode(process.env.JWT_SECRET);

const createToken = async (payload = {}, expiresIn = '1h') => {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime(expiresIn)
    .sign(secret);
};

describe('API contract readiness - GET /api/transactions & GET /api/statistics/summary', () => {
  const mockUserId = new mongoose.Types.ObjectId().toString();
  let validToken;
  let expiredToken;

  beforeAll(async () => {
    validToken = await createToken({ userId: mockUserId }, '1h');
    expiredToken = await createToken({ userId: mockUserId }, '0s');
  });

  beforeEach(() => {
    jest.clearAllMocks();

    transactionService.getFilteredTransactions.mockResolvedValue({
      transactions: [
        {
          _id: new mongoose.Types.ObjectId().toString(),
          userId: mockUserId,
          amount: 100,
          type: 'income',
          category: 'salary',
          date: new Date('2026-03-10T00:00:00.000Z').toISOString(),
          note: 'Monthly salary',
          title: 'Salary',
          createdAt: new Date('2026-03-10T00:00:00.000Z').toISOString(),
          updatedAt: new Date('2026-03-10T00:00:00.000Z').toISOString(),
        },
      ],
      totalCount: 1,
      page: 1,
      limit: 20,
      stats: {
        totalIncome: 100,
        totalExpense: 0,
        balance: 100,
      },
    });

    statisticService.getMonthlyStatistics.mockResolvedValue({
      totalIncome: 100,
      totalExpense: 40,
      balance: 60,
    });
  });

  describe('GET /api/transactions', () => {
    it('supports v1 prefix - GET /api/v1/transactions returns success envelope', async () => {
      const res = await request(app)
        .get('/api/v1/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.statusCode).toBe(200);
      expect(res.body).toHaveProperty('data');
    });

    it('new user with no transactions - returns 200 and empty list', async () => {
      transactionService.getFilteredTransactions.mockResolvedValueOnce({
        transactions: [],
        totalCount: 0,
        page: 1,
        limit: 20,
        stats: { totalIncome: 0, totalExpense: 0, balance: 0 },
      });

      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.statusCode).toBe(200);
      expect(res.body.message).toBe('Transactions fetched successfully');
      // verify top-level envelope fields exist
      expect(res.body).toHaveProperty('success');
      expect(res.body).toHaveProperty('statusCode');
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('data');
      // verify data shape for mobile parsing
      expect(res.body.data).toHaveProperty('transactions');
      expect(res.body.data).toHaveProperty('totalCount');
      expect(res.body.data).toHaveProperty('page');
      expect(res.body.data).toHaveProperty('limit');
      expect(res.body.data).toHaveProperty('stats');
      expect(res.body.data.transactions).toEqual([]);
      // stats must have exactly {totalIncome, totalExpense, balance} — no _id, no totalAmount
      expect(res.body.data.stats).toEqual({ totalIncome: 0, totalExpense: 0, balance: 0 });
      expect(res.body.data.stats).not.toHaveProperty('_id');
      expect(res.body.data.stats).not.toHaveProperty('totalAmount');
    });

    it('valid month/year - returns data envelope', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('success', true);
      expect(res.body).toHaveProperty('statusCode', 200);
      expect(res.body).toHaveProperty('message', 'Transactions fetched successfully');
      expect(res.body).toHaveProperty('data');
      // transactions array shape
      expect(res.body.data).toHaveProperty('transactions');
      expect(Array.isArray(res.body.data.transactions)).toBe(true);
      // verify first transaction has all expected fields
      const tx = res.body.data.transactions[0];
      expect(tx).toHaveProperty('_id');
      expect(tx).toHaveProperty('userId');
      expect(tx).toHaveProperty('amount');
      expect(tx).toHaveProperty('type');
      expect(tx).toHaveProperty('category');
      expect(tx).toHaveProperty('date');
      expect(tx).toHaveProperty('title');
      expect(tx).toHaveProperty('createdAt');
      expect(tx).toHaveProperty('updatedAt');
      // stats shape
      expect(res.body.data).toHaveProperty('stats');
      expect(res.body.data.stats).toHaveProperty('totalIncome');
      expect(res.body.data.stats).toHaveProperty('totalExpense');
      expect(res.body.data.stats).toHaveProperty('balance');
      expect(res.body.data.stats).not.toHaveProperty('_id');
      expect(res.body.data.stats).not.toHaveProperty('totalAmount');
      // pagination fields
      expect(res.body.data).toHaveProperty('totalCount');
      expect(res.body.data).toHaveProperty('page');
      expect(res.body.data).toHaveProperty('limit');
    });

    it('missing year - returns 400 validation failed', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3 });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Validation failed');
      expect(Array.isArray(res.body.errors)).toBe(true);
    });

    it('invalid month - returns 400 validation failed', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 13, year: 2026 });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Validation failed');
    });

    it('both month/year and from/to - returns 400 validation failed', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, from: '2026-03-01', to: '2026-03-31' });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Validation failed');
    });

    it('type filter - forwards query to service', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, type: 'expense' });

      expect(res.status).toBe(200);
      expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
        mockUserId,
        expect.objectContaining({ type: 'expense' })
      );
    });

    it('category filter - forwards query to service', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, category: 'food' });

      expect(res.status).toBe(200);
      expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
        mockUserId,
        expect.objectContaining({ category: 'food' })
      );
    });

    it('search filter - forwards query to service', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, search: 'salary' });

      expect(res.status).toBe(200);
      expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
        mockUserId,
        expect.objectContaining({ search: 'salary' })
      );
    });

    it('pagination - page & limit are accepted', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, page: 2, limit: 5 });

      expect(res.status).toBe(200);
      expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
        mockUserId,
        expect.objectContaining({ page: 2, limit: 5 })
      );
    });

    it('sorting - sortBy & order are accepted', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026, sortBy: 'amount', order: 'asc' });

      expect(res.status).toBe(200);
      expect(transactionService.getFilteredTransactions).toHaveBeenCalledWith(
        mockUserId,
        expect.objectContaining({ sortBy: 'amount', order: 'asc' })
      );
    });

    it('missing token - returns 401', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.message).toBe('Access token required');
    });

    it('invalid token - returns 401 with "Invalid token"', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', 'Bearer not-a-valid-jwt')
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(401);
      expect(res.body.message).toBe('Invalid token');
    });

    it('expired token - returns 401 with "Token expired"', async () => {
      const res = await request(app)
        .get('/api/transactions')
        .set('Authorization', `Bearer ${expiredToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(401);
      expect(res.body.message).toBe('Token expired');
    });
  });

  describe('GET /api/statistics/summary', () => {
    it('supports v1 prefix - GET /api/v1/statistics/summary returns success envelope', async () => {
      const res = await request(app)
        .get('/api/v1/statistics/summary')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.statusCode).toBe(200);
      expect(res.body).toHaveProperty('data');
    });

    it('month with data - returns computed summary', async () => {
      statisticService.getMonthlyStatistics.mockResolvedValueOnce({
        totalIncome: 500,
        totalExpense: 200,
        balance: 300,
      });

      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.statusCode).toBe(200);
      expect(res.body.message).toBe('Get monthly statistics successfully');
      // verify exact data shape — no extra fields
      expect(res.body.data).toEqual({
        totalIncome: 500,
        totalExpense: 200,
        balance: 300,
      });
      expect(res.body.data).toHaveProperty('totalIncome');
      expect(res.body.data).toHaveProperty('totalExpense');
      expect(res.body.data).toHaveProperty('balance');
    });

    it('month without data - returns zero summary', async () => {
      statisticService.getMonthlyStatistics.mockResolvedValueOnce({
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
      });

      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 4, year: 2026 });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.statusCode).toBe(200);
      // all three KPI fields must be present and zero
      expect(res.body.data).toEqual({ totalIncome: 0, totalExpense: 0, balance: 0 });
    });

    it('missing token - returns 401', async () => {
      const res = await request(app)
        .get('/api/statistics/summary')
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.message).toBe('Access token required');
    });

    it('invalid token - returns 401 with "Invalid token"', async () => {
      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', 'Bearer bad-token')
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(401);
      expect(res.body.message).toBe('Invalid token');
    });

    it('expired token - returns 401 with "Token expired"', async () => {
      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', `Bearer ${expiredToken}`)
        .query({ month: 3, year: 2026 });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(401);
      expect(res.body.message).toBe('Token expired');
    });

    it('invalid month - returns 400 validation failed', async () => {
      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 13, year: 2026 });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Validation failed');
    });

    it('missing year - returns 400 validation failed', async () => {
      const res = await request(app)
        .get('/api/statistics/summary')
        .set('Authorization', `Bearer ${validToken}`)
        .query({ month: 3 });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.message).toBe('Validation failed');
    });
  });

  describe('CORS behavior', () => {
    it('returns 403 with stable error code for blocked origins', async () => {
      const res = await request(app)
        .get('/health')
        .set('Origin', 'https://blocked-origin.example.com');

      expect(res.status).toBe(403);
      expect(res.body.success).toBe(false);
      expect(res.body.statusCode).toBe(403);
      expect(res.body.errorCode).toBe('CORS_ORIGIN_NOT_ALLOWED');
      expect(res.body.message).toMatch(/CORS origin blocked/i);
    });
  });
});
