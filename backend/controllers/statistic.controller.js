/**
 * @description Controller for handling statistic-related requests.
 */

const statisticService = require("../services/statistic.service");
const { successResponse } = require("../utils/response.util");

// 1. Hàm CŨ của nhóm (Giữ nguyên không đụng tới)
exports.getSummary = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { month, year } = req.query;

    // Validate month and year
    const data = await statisticService.getMonthlyStatistics(userId, month, year);

    return res.status(200).json(
      successResponse(200, "Get monthly statistics successfully", data)
    );
  } catch (error) {
    next(error);
  }
};

// ==========================================
// 2. Hàm MỚI: Thống kê theo ngày (Task của bạn)
// ==========================================
exports.getDailyStats = async (req, res, next) => {
  try {
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    // Validate theo đúng chuẩn checklist
    if (!month || !year || month < 1 || month > 12) {
      return res.status(400).json({
        success: false,
        message: "month/year không hợp lệ",
      });
    }

    // Lấy ID chuẩn theo văn phong của nhóm
    const userId = req.user._id;

    // Gọi xuống Service
    const data = await statisticService.getDailyStatsByMonth(userId, month, year);

    // Trả về đúng shape contract mà nhóm trưởng (Minh bên Mobile) yêu cầu
    return res.status(200).json({
      success: true,
      data: data
    });
  } catch (error) {
    next(error);
  }
};