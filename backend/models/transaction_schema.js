const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    amount: {
      type: Number,
      required: [true, "Amount is required"],
      min: [0, "Amount cannot be negative"],
    },

    type: {
      type: String,
      required: true,
      enum: ["income", "expense"],
    },

    category: {
      type: String,
      required: true,
      trim: true,
      enum: ["food", "travel", "shopping", "salary", "entertainment", "utility", "other"],
    },

    date: {
      type: Date,
      default: Date.now,
    },

    note: {
      type: String,
      trim: true,
      default: "",
    },

    title: {
      type: String,
      required: true,
      trim: true,
      default: "",
    },
  },
  {
    timestamps: true,
  },
);

transactionSchema.index({ userId: 1, date: -1 });
transactionSchema.index({ userId: 1, type: 1, category: 1});
transactionSchema.index({ title: "text", note: "text" });

module.exports = mongoose.model("Transaction", transactionSchema);
