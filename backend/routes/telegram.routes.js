const express = require('express');
const router = express.Router();
const {
  sendTestMessage,
  sendNotification,
} = require('../services/telegram.service');
const logger = require('../utils/logger');

/**
 * POST /api/telegram/test
 * Test endpoint - send a test notification
 * Body: {
 *   amount?: number (default 50000),
 *   note?: string (default "Test transaction"),
 *   type?: "income" | "expense" (default "expense")
 * }
 */
router.post('/test', async (req, res) => {
  try {
    const {
      amount = 50000,
      note = 'Test transaction from Postman',
      type = 'expense',
    } = req.body;

    const result = await sendNotification('SmartSpender Test Group', {
      amount,
      type,
      note,
      createdAt: new Date(),
    });

    if (result.success) {
      res.status(200).json({
        status: 'success',
        message: 'Test notification sent to Telegram ✅',
        data: result,
      });
    } else {
      res.status(400).json({
        status: 'error',
        message: 'Failed to send notification',
        error: result.error,
      });
    }
  } catch (error) {
    logger.error(`Telegram test route error: ${error.message}`);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
      error: error.message,
    });
  }
});

/**
 * POST /api/telegram/notify
 * Send custom notification
 * Body: {
 *   groupName: string (required),
 *   amount: number (required),
 *   type: "income" | "expense" (required),
 *   note?: string
 * }
 */
router.post('/notify', async (req, res) => {
  try {
    const { groupName, amount, type, note } = req.body;

    // Validation
    if (!groupName || !amount || !type) {
      return res.status(400).json({
        status: 'error',
        message: 'Missing required fields: groupName, amount, type',
      });
    }

    if (!['income', 'expense'].includes(type)) {
      return res.status(400).json({
        status: 'error',
        message: "Type must be 'income' or 'expense'",
      });
    }

    const result = await sendNotification(groupName, {
      amount,
      type,
      note: note || 'Không có ghi chú',
      createdAt: new Date(),
    });

    if (result.success) {
      res.status(200).json({
        status: 'success',
        message: 'Notification sent to Telegram ✅',
        data: result,
      });
    } else {
      res.status(400).json({
        status: 'error',
        message: 'Failed to send notification',
        error: result.error,
      });
    }
  } catch (error) {
    logger.error(`Telegram notify route error: ${error.message}`);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
      error: error.message,
    });
  }
});

/**
 * GET /api/telegram/health
 * Check if Telegram service is configured
 */
router.get('/health', (req, res) => {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;

  const configured = !!(token && chatId);

  res.status(200).json({
    status: 'ok',
    message: 'Telegram service health check',
    configured,
    details: {
      hasToken: !!token,
      hasChatId: !!chatId,
      botName: '@artspender_bot (or configured bot)',
    },
  });
});

module.exports = router;
