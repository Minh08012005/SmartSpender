/**
 * Transaction Routes
 * Define API endpoints related to transactions.
 */

const express = require("express");
const router = express.Router();
const { getTransactions } = require("../controllers/transaction_controller");
const authenticate = require("../middleware/auth.middleware");
const validate = require("../middleware/validate.middleware");
const { getTransactionsSchema } = require("../validators/transaction.validator");

// // ✅ GET /api/transactions
// router.get("/", getTransactions);

router.get(
  "/",
  authenticate,
  validate(getTransactionsSchema, 'query'),
  getTransactions
);

module.exports = router;
