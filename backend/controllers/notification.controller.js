/**
 * Notifications controller
 */
const {
  getNotificationsForUser,
  createNotification,
  markAsRead,
  markAllAsRead,
  deleteNotification,
} = require('../services/notification.service');

const { successResponse, errorResponse } = require('../utils/response.util');

const listNotifications = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));
    const items = await getNotificationsForUser(userId);
    res.json(successResponse(200, 'OK', items));
  } catch (err) {
    console.error('Notifications list error', err);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

const create = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    const { title, message, type } = req.body;
    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));
    const created = await createNotification({ userId, title, message, type });
    res.status(201).json(successResponse(201, 'Created', created));
  } catch (err) {
    console.error('Create notification error', err);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

const read = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    const { id } = req.params;
    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));
    await markAsRead(userId, id);
    res.json(successResponse(200, 'Marked as read'));
  } catch (err) {
    console.error('Mark read error', err);
    res.status(400).json(errorResponse(400, err.message || 'Bad request'));
  }
};

const readAll = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));
    await markAllAsRead(userId);
    res.json(successResponse(200, 'All marked as read'));
  } catch (err) {
    console.error('Mark all read error', err);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

const remove = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    const { id } = req.params;
    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));
    const ok = await deleteNotification(userId, id);
    if (!ok) return res.status(404).json(errorResponse(404, 'Not found'));
    res.json(successResponse(200, 'Deleted'));
  } catch (err) {
    console.error('Delete notification error', err);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

module.exports = {
  listNotifications,
  create,
  read,
  readAll,
  remove,
};
