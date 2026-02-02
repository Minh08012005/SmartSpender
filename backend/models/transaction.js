const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    amount: {
      type: Number,
      required: true,
      min: 0
    },

    type: {
      type: String,
      required: true,
      enum: ["income", "expense"]
    },

    category: {
      type: String,
      required: true,
      trim: true
    },

    date: {
      type: Date,
      default: Date.now
    },

    note: {
      type: String,
      default: ""
    }
  },
  {
    timestamps: true
  }
);

transactionSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model("Transaction", transactionSchema);
