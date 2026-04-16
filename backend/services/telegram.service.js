const axios = require('axios');
const logger = require('../utils/logger');

/**
 * Send notification to Telegram group
 * @param {string} groupName - Name of the SmartSpender group
 * @param {object} transaction - Transaction object
 * @returns {Promise<object>} Result { success: boolean, error?: string }
 */
const sendNotification = async (groupName, transaction) => {
  try {
    const token = process.env.TELEGRAM_BOT_TOKEN;
    const chatId = process.env.TELEGRAM_CHAT_ID;

    if (!token || !chatId) {
      logger.warn('Telegram credentials not configured');
      return { success: false, error: 'Telegram not configured' };
    }

    // Format message with emoji and markdown
    const transactionType =
      transaction.type === 'income' ? '💵 Thu nhập' : '💸 Chi tiêu';
    const amount = transaction.amount || 0;
    const note = transaction.note || 'Không có ghi chú';
    const createdAt = transaction.createdAt
      ? new Date(transaction.createdAt).toLocaleString('vi-VN')
      : new Date().toLocaleString('vi-VN');

    const message = `📝 *Giao dịch mới - ${groupName}*
━━━━━━━━━━━━━━━━━━━━
${transactionType}: *${amount.toLocaleString('vi-VN')}đ*
📌 Chi tiết: ${note}
⏰ Thời gian: ${createdAt}
━━━━━━━━━━━━━━━━━━━━`;

    // Send message to Telegram
    const response = await axios.post(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        chat_id: chatId,
        text: message,
        parse_mode: 'Markdown',
      },
      {
        timeout: 5000, // 5 second timeout
      }
    );

    logger.info(`Telegram notification sent for group: ${groupName}`);
    return { success: true, messageId: response.data.result.message_id };
  } catch (error) {
    logger.error(`Telegram notification error: ${error.message}`);
    // Don't throw error, just log it
    return { success: false, error: error.message };
  }
};

/**
 * Test function - send a test message
 * @returns {Promise<object>}
 */
const sendTestMessage = async (amount = 50000, note = 'Test transaction') => {
  return sendNotification('SmartSpender Test Group', {
    amount,
    type: 'expense',
    note,
    createdAt: new Date(),
  });
};

module.exports = {
  sendNotification,
  sendTestMessage,
};
