const express = require('express');
const router = express.Router();

// GET /groups - return paginated list of groups
router.get('/', async (req, res, next) => {
  try {
    const skip = parseInt(req.query.skip, 10) || 0;
    const limit = Math.min(parseInt(req.query.limit, 10) || 10, 100);

    const conn = require('mongoose').connection;
    const groupsColl = conn.collection('groups');
    const groups = await groupsColl.find({}).skip(skip).limit(limit).toArray();

    return res.status(200).json({ success: true, data: groups });
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
