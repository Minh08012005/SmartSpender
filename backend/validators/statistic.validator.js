/**
 * @description This file contains the validation schema for the statistic routes.
 * It uses Joi to define the expected structure and constraints for the request parameters.
 * The main focus is on validating the month and year parameters for the summary endpoint.
 * This ensures that the API receives valid data and can handle it appropriately.
 */
const Joi = require("joi");

const getSummarySchema = Joi.object({
  month: Joi.number().integer().min(1).max(12).required(),
  year: Joi.number().integer().min(2000).required(),
});

module.exports = { getSummarySchema };
