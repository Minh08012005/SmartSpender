/**
 * Notifications routes
 */
const express = require('express');
const router = express.Router();

const authenticate = require('../middleware/auth.middleware');
const {
  listNotifications,
  create,
  read,
  readAll,
  remove,
} = require('../controllers/notification.controller');

// GET / -> list
router.get('/', authenticate, listNotifications);

// POST / -> create (protected)
router.post('/', authenticate, create);

// PATCH /:id/read -> mark single as read
router.patch('/:id/read', authenticate, read);

// PATCH /read-all -> mark all as read
router.patch('/read-all', authenticate, readAll);

// DELETE /:id -> delete
router.delete('/:id', authenticate, remove);

module.exports = router;
