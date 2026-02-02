const express = require("express");
const router = express.Router();

const {
  getTransactions
} = require("../controllers/transaction.controller");

// ✅ GET /api/transactions
router.get("/", getTransactions);

module.exports = router;

exports.getTransactions = async (req, res) => {
  const transactions = await Transaction.find();
  res.json(transactions);
};
