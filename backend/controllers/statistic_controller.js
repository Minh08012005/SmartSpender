/**
 * @description Controller for handling statistic-related requests.
 */

const statisticService = require("../services/statistic_service");
const { successResponse } = require("../utils/response_util");

// Get monthly statistics for the authenticated user
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