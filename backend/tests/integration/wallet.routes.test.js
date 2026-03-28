/**
 * Integration Test
 * Wallet routes: GET /api/wallets, POST /api/wallets/transfer
 */

const request = require('supertest');
const mongoose = require('mongoose');
const { SignJWT } = require('jose');
const { TextEncoder } = require('util');

const app = require('../../app');
const User = require('../../models/users.model');
const Wallet = require('../../models/wallet.model');
const Transaction = require('../../models/transaction_schema');
const WalletTransfer = require('../../models/wallet_transfer.model');

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

const getWalletByType = (wallets, walletType) =>
  wallets.find((wallet) => wallet.walletType === walletType);

describe('Wallet API Integration Tests', () => {
  let owner;
  let ownerToken;

  beforeAll(async () => {
    await mongoose.connect(
      'mongodb://127.0.0.1:27017/smartspender_test_wallet'
    );
  });

  afterAll(async () => {
    await mongoose.connection.dropDatabase();
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    owner = await User.create({
      fullName: 'Wallet Owner',
      email: `wallet.owner.${Date.now()}@example.com`,
      password: '123456',
    });

    ownerToken = await makeToken(owner._id);
  });

  afterEach(async () => {
    await WalletTransfer.deleteMany({});
    await Transaction.deleteMany({});
    await Wallet.deleteMany({});
    await User.deleteMany({});
  });

  it('GET /api/wallets should initialize 3 default wallets and return totalBalance = 0', async () => {
    const res = await request(app)
      .get('/api/wallets')
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data).toHaveLength(3);
    expect(res.body.totalBalance).toBe(0);

    const walletTypes = res.body.data.map((w) => w.walletType).sort();
    expect(walletTypes).toEqual(['bank', 'cash', 'ewallet']);
  });

  it('GET /api/wallets should reconcile balances from transactions', async () => {
    await Wallet.insertMany([
      {
        userId: owner._id,
        walletType: 'cash',
        name: 'Tiền mặt',
        description: 'cash wallet',
        balance: 0,
      },
      {
        userId: owner._id,
        walletType: 'bank',
        name: 'Ngân hàng',
        description: 'bank wallet',
        balance: 0,
      },
      {
        userId: owner._id,
        walletType: 'ewallet',
        name: 'Ví điện tử',
        description: 'ewallet wallet',
        balance: 0,
      },
    ]);

    await Transaction.insertMany([
      {
        userId: owner._id,
        amount: 500000,
        type: 'income',
        walletType: 'cash',
        category: 'salary',
        title: 'Luong thang',
        note: '',
      },
      {
        userId: owner._id,
        amount: 150000,
        type: 'expense',
        walletType: 'cash',
        category: 'food',
        title: 'An trua',
        note: '',
      },
      {
        userId: owner._id,
        amount: 100000,
        type: 'income',
        walletType: 'bank',
        category: 'other',
        title: 'Thu khac',
        note: '',
      },
    ]);

    const res = await request(app)
      .get('/api/wallets')
      .set('Authorization', `Bearer ${ownerToken}`);

    expect(res.statusCode).toBe(200);

    const cash = getWalletByType(res.body.data, 'cash');
    const bank = getWalletByType(res.body.data, 'bank');
    const ewallet = getWalletByType(res.body.data, 'ewallet');

    expect(cash.balance).toBe(350000);
    expect(bank.balance).toBe(100000);
    expect(ewallet.balance).toBe(0);
    expect(res.body.totalBalance).toBe(450000);
  });

  it('POST /api/wallets/transfer should move money and persist transfer ledger', async () => {
    await request(app)
      .post('/api/transactions')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        title: 'Seed cash',
        amount: 200000,
        category: 'salary',
        type: 'income',
        walletType: 'cash',
      });

    const walletsRes = await request(app)
      .get('/api/wallets')
      .set('Authorization', `Bearer ${ownerToken}`);

    const cash = getWalletByType(walletsRes.body.data, 'cash');
    const bank = getWalletByType(walletsRes.body.data, 'bank');

    const transferRes = await request(app)
      .post('/api/wallets/transfer')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        fromWalletId: cash._id,
        toWalletId: bank._id,
        amount: 50000,
        note: 'Chuyen sang ngan hang',
      });

    expect(transferRes.statusCode).toBe(200);
    expect(transferRes.body.success).toBe(true);
    expect(transferRes.body.data.amount).toBe(50000);
    expect(transferRes.body.data.transferId).toBeDefined();

    const transferCount = await WalletTransfer.countDocuments({
      userId: owner._id,
    });
    expect(transferCount).toBe(1);

    const refreshed = await request(app)
      .get('/api/wallets')
      .set('Authorization', `Bearer ${ownerToken}`);

    const refreshedCash = getWalletByType(refreshed.body.data, 'cash');
    const refreshedBank = getWalletByType(refreshed.body.data, 'bank');

    expect(refreshedCash.balance).toBe(150000);
    expect(refreshedBank.balance).toBe(50000);
    expect(refreshed.body.totalBalance).toBe(200000);
  });

  it('POST /api/wallets/transfer should return 400 validation error for invalid wallet ids', async () => {
    const res = await request(app)
      .post('/api/wallets/transfer')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        fromWalletId: 'not-an-objectid',
        toWalletId: 'still-not-an-objectid',
        amount: 50000,
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toBe('Validation failed');
    expect(Array.isArray(res.body.errors)).toBe(true);
  });

  it('POST /api/wallets/transfer should return 400 when source wallet has insufficient balance', async () => {
    const walletsRes = await request(app)
      .get('/api/wallets')
      .set('Authorization', `Bearer ${ownerToken}`);

    const cash = getWalletByType(walletsRes.body.data, 'cash');
    const bank = getWalletByType(walletsRes.body.data, 'bank');

    const res = await request(app)
      .post('/api/wallets/transfer')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({
        fromWalletId: cash._id,
        toWalletId: bank._id,
        amount: 1000,
      });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.message).toMatch(/Số dư không đủ/i);
  });

  it('GET /api/wallets should return 401 TOKEN_MISSING without auth token', async () => {
    const res = await request(app).get('/api/wallets');

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.errorCode).toBe('TOKEN_MISSING');
  });
});
