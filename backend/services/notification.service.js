/**
 * Notification service - business logic for notifications
 */
const Notification = require('../models/notification.model');

const getNotificationsForUser = async (userId) => {
  return Notification.find({ userId }).sort({ createdAt: -1 }).lean();
};

const createNotification = async ({
  userId,
  title,
  message,
  type = 'general',
}) => {
  return Notification.create({ userId, title, message, type });
};

const markAsRead = async (userId, notificationId) => {
  const notif = await Notification.findOne({ _id: notificationId, userId });
  if (!notif) throw new Error('Notification not found');
  notif.isRead = true;
  await notif.save();
  return notif;
};

const markAllAsRead = async (userId) => {
  await Notification.updateMany(
    { userId, isRead: false },
    { $set: { isRead: true } }
  );
  return true;
};

const deleteNotification = async (userId, notificationId) => {
  const res = await Notification.deleteOne({ _id: notificationId, userId });
  return res.deletedCount > 0;
};

module.exports = {
  getNotificationsForUser,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
};
