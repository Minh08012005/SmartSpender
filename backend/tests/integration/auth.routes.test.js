/**
 * Integration Test
 * Auth endpoints
 * - POST /api/auth/register
 * - POST /api/auth/login
 */

const request = require('supertest');
const mongoose = require('mongoose');

beforeAll(async () => {
  await mongoose.connect('mongodb://127.0.0.1:27017/smartspender_test_auth');
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require('../../app');
const User = require('../../models/users.model');

describe('Auth API Integration Tests', () => {
  afterEach(async () => {
    await User.deleteMany();
  });

  it('POST /api/auth/register - should register successfully', async () => {
    const res = await request(app).post('/api/auth/register').send({
      fullName: 'Register User',
      email: 'register.user@example.com',
      password: 'Test@12345',
    });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(201);
    expect(res.body.message).toBe('User registered successfully');
    expect(res.body.data).toBeDefined();
    expect(res.body.data).toHaveProperty('accessToken');
    expect(res.body.data).toHaveProperty('user');
    expect(res.body.data.user.email).toBe('register.user@example.com');
  });

  it('POST /api/auth/login - should login successfully', async () => {
    await request(app).post('/api/auth/register').send({
      fullName: 'Login User',
      email: 'login.user@example.com',
      password: 'Test@12345',
    });

    const res = await request(app).post('/api/auth/login').send({
      email: 'login.user@example.com',
      password: 'Test@12345',
    });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.statusCode).toBe(200);
    expect(res.body.message).toBe('Login successful');
    expect(res.body.data).toBeDefined();
    expect(res.body.data).toHaveProperty('accessToken');
    expect(res.body.data).toHaveProperty('user');
    expect(res.body.data.user.email).toBe('login.user@example.com');
  });

  it('POST /api/auth/register - should return 400 when missing required fields', async () => {
    const res = await request(app).post('/api/auth/register').send({
      email: 'missing.fields@example.com',
      password: 'Test@12345',
    });

    expect(res.statusCode).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(400);
    expect(res.body.message).toBe('Validation failed');
    expect(Array.isArray(res.body.errors)).toBe(true);
  });

  it('POST /api/auth/login - should return 401 with wrong password', async () => {
    await request(app).post('/api/auth/register').send({
      fullName: 'Wrong Password User',
      email: 'wrong.password@example.com',
      password: 'Test@12345',
    });

    const res = await request(app).post('/api/auth/login').send({
      email: 'wrong.password@example.com',
      password: 'Wrong@12345',
    });

    expect(res.statusCode).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.statusCode).toBe(401);
    expect(res.body.message).toBe('Invalid email or password');
  });
});