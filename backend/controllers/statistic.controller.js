/**
 * @description Controller for handling statistic-related requests.
 */

const statisticService = require("../services/statistic.service");
const { successResponse } = require("../utils/response.util");

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

exports.getBudget = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const month = Number(req.query.month);
    const year = Number(req.query.year);

    const data = await statisticService.getBudgetSummary(userId, month, year);

    return res
      .status(200)
      .json(successResponse(200, "Get monthly budget successfully", data));
  } catch (error) {
    next(error);
  }
};

exports.saveBudget = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const month = Number(req.body.month);
    const year = Number(req.body.year);
    const targetAmount = Number(req.body.targetAmount);

    const data = await statisticService.saveBudgetTarget(
      userId,
      month,
      year,
      targetAmount
    );

    return res
      .status(200)
      .json(successResponse(200, "Save monthly budget successfully", data));
  } catch (error) {
    next(error);
  }
};