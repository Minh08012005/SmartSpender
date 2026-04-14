/**
 * Integration tests for Notifications API
 */
const request = require('supertest');
const mongoose = require('mongoose');

beforeAll(async () => {
  await mongoose.connect(
    'mongodb://127.0.0.1:27017/smartspender_test_notifications'
  );
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});

const app = require('../../app');
const User = require('../../models/users.model');
const Notification = require('../../models/notification.model');

describe('Notifications API Integration Tests', () => {
  let token;

  afterEach(async () => {
    await User.deleteMany();
    await Notification.deleteMany();
  });

  async function registerAndLogin() {
    await request(app).post('/api/auth/register').send({
      fullName: 'Notif User',
      email: 'notif.user@example.com',
      password: 'Test@12345',
    });

    const res = await request(app).post('/api/auth/login').send({
      email: 'notif.user@example.com',
      password: 'Test@12345',
    });

    return res.body.data?.accessToken;
  }

  it('GET /api/notifications - empty list initially', async () => {
    token = await registerAndLogin();
    const res = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${token}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBe(0);
  });

  it('POST /api/notifications -> create and GET returns it', async () => {
    token = await registerAndLogin();

    const createRes = await request(app)
      .post('/api/notifications')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Hello', message: 'Test notification', type: 'general' });

    expect(createRes.statusCode).toBe(201);
    expect(createRes.body.success).toBe(true);
    expect(createRes.body.data).toBeDefined();
    const id =
      createRes.body.data._id ||
      createRes.body.data.id ||
      createRes.body.data._doc?._id;

    const listRes = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${token}`);

    expect(listRes.statusCode).toBe(200);
    expect(listRes.body.data.length).toBe(1);
    expect(listRes.body.data[0].title).toBe('Hello');

    // mark as read
    const markRes = await request(app)
      .patch(
        `/api/notifications/${createRes.body.data._id || createRes.body.data.id}/read`
      )
      .set('Authorization', `Bearer ${token}`)
      .send();

    expect(markRes.statusCode).toBe(200);

    // delete
    const delRes = await request(app)
      .delete(
        `/api/notifications/${createRes.body.data._id || createRes.body.data.id}`
      )
      .set('Authorization', `Bearer ${token}`);

    expect(delRes.statusCode).toBe(200);
  });

  it('PATCH /api/notifications/read-all marks all as read', async () => {
    token = await registerAndLogin();

    // create two notifications
    await request(app)
      .post('/api/notifications')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'A', message: 'one' });
    await request(app)
      .post('/api/notifications')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'B', message: 'two' });

    const before = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${token}`);
    expect(before.body.data.length).toBe(2);

    const res = await request(app)
      .patch('/api/notifications/read-all')
      .set('Authorization', `Bearer ${token}`)
      .send();

    expect(res.statusCode).toBe(200);

    const after = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${token}`);

    expect(after.body.data.every((n) => n.isRead === true)).toBe(true);
  });
});
