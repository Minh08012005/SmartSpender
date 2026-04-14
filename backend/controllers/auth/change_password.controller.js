/**
 * Controller xử lý đổi mật khẩu.
 */

const { changePassword } = require('../../services/auth.service');
const { successResponse, errorResponse } = require('../../utils/response.util');

const changePasswordController = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    const { currentPassword, newPassword } = req.body;

    if (!userId)
      return res.status(401).json(errorResponse(401, 'Unauthorized'));

    const result = await changePassword(userId, currentPassword, newPassword);

    res.status(200).json(successResponse(200, 'Password changed', result));
  } catch (err) {
    if (err.message === 'Current password incorrect') {
      return res.status(400).json(errorResponse(400, err.message));
    }
    console.error('Change password error:', err);
    res.status(500).json(errorResponse(500, 'Internal server error'));
  }
};

module.exports = changePasswordController;
