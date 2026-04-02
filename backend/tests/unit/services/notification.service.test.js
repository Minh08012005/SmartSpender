/**
 * Unit tests for notification.service
 */
const mongoose = require('mongoose');

jest.mock('../../../models/notification.model', () => ({
  find: jest.fn(),
  create: jest.fn(),
  findOne: jest.fn(),
  updateMany: jest.fn(),
  deleteOne: jest.fn(),
}));

const Notification = require('../../../models/notification.model');
const notificationService = require('../../../services/notification.service');

describe('Notification Service - unit', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('getNotificationsForUser calls find with userId and sorts', async () => {
    const userId = new mongoose.Types.ObjectId().toString();

    const mockQuery = {
      sort: jest.fn().mockReturnThis(),
      lean: jest.fn().mockResolvedValue([]),
    };

    Notification.find.mockReturnValue(mockQuery);

    const res = await notificationService.getNotificationsForUser(userId);

    expect(Notification.find).toHaveBeenCalledWith({ userId });
    expect(mockQuery.sort).toHaveBeenCalledWith({ createdAt: -1 });
    expect(res).toEqual([]);
  });

  it('createNotification calls create and returns result', async () => {
    const payload = { userId: 'u1', title: 'T', message: 'M' };
    const created = { _id: 'nid', ...payload };
    Notification.create.mockResolvedValue(created);

    const res = await notificationService.createNotification(payload);

    expect(Notification.create).toHaveBeenCalledWith(
      expect.objectContaining(payload)
    );
    expect(res).toBe(created);
  });

  it('markAsRead finds notification and saves', async () => {
    const userId = 'u1';
    const nid = 'n1';
    const doc = {
      _id: nid,
      userId,
      isRead: false,
      save: jest.fn().mockResolvedValue(true),
    };
    Notification.findOne.mockResolvedValue(doc);

    const res = await notificationService.markAsRead(userId, nid);

    expect(Notification.findOne).toHaveBeenCalledWith({ _id: nid, userId });
    expect(doc.save).toHaveBeenCalled();
    expect(res).toBe(doc);
  });

  it('markAsRead throws when notification not found', async () => {
    Notification.findOne.mockResolvedValue(null);

    await expect(notificationService.markAsRead('u1', 'no')).rejects.toThrow(
      'Notification not found'
    );
  });

  it('markAllAsRead calls updateMany', async () => {
    Notification.updateMany.mockResolvedValue({ modifiedCount: 2 });

    const res = await notificationService.markAllAsRead('u1');

    expect(Notification.updateMany).toHaveBeenCalledWith(
      { userId: 'u1', isRead: false },
      { $set: { isRead: true } }
    );
    expect(res).toBe(true);
  });

  it('deleteNotification returns true when deletedCount > 0', async () => {
    Notification.deleteOne.mockResolvedValue({ deletedCount: 1 });

    const ok = await notificationService.deleteNotification('u1', 'nid');

    expect(Notification.deleteOne).toHaveBeenCalledWith({
      _id: 'nid',
      userId: 'u1',
    });
    expect(ok).toBe(true);
  });

  it('deleteNotification returns false when nothing deleted', async () => {
    Notification.deleteOne.mockResolvedValue({ deletedCount: 0 });

    const ok = await notificationService.deleteNotification('u1', 'nid');

    expect(ok).toBe(false);
  });
});
