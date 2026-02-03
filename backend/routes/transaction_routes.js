/**
 * Transaction Routes
 * Define API endpoints related to transactions.
 */

const express = require("express");
const router = express.Router();

const {
  getTransactions,
} = require("../controllers/transaction_controller");

// ✅ GET /api/transactions
router.get("/", getTransactions);

module.exports = router;
