const mongoose = require('mongoose');
const { VALID_WALLET_TYPES } = require('../validators/constants');

const walletTransferSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    fromWalletType: {
      type: String,
      required: true,
      enum: VALID_WALLET_TYPES,
    },
    toWalletType: {
      type: String,
      required: true,
      enum: VALID_WALLET_TYPES,
    },
    amount: {
      type: Number,
      required: true,
      min: [1, 'Transfer amount must be greater than 0'],
    },
    note: {
      type: String,
      trim: true,
      default: '',
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

walletTransferSchema.index({ userId: 1, date: -1 });

module.exports = mongoose.model('WalletTransfer', walletTransferSchema);
