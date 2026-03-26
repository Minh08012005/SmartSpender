/**
 * Wallet Service
 * Xử lý business logic cho wallets
 */

const Wallet = require('../models/wallet.model');
const Transaction = require('../models/transaction_schema');

const SUPPORTED_WALLET_TYPES = ['cash', 'bank', 'ewallet'];

const normalizeWalletType = (walletType) => {
  const normalized = (walletType || 'cash').toString().trim().toLowerCase();
  return SUPPORTED_WALLET_TYPES.includes(normalized) ? normalized : 'cash';
};

/**
 * Initialize default wallets cho user mới
 * @param {string} userId - User ID
 */
const initializeWalletsForUser = async (userId) => {
  try {
    // Check wallets already exist
    const existingWallets = await Wallet.countDocuments({ userId });
    if (existingWallets > 0) {
      return; // Already initialized
    }

    const defaultWallets = [
      {
        userId,
        walletType: 'cash',
        name: 'Tiền mặt',
        description: 'Ví tiền mặt hằng ngày',
        balance: 0,
      },
      {
        userId,
        walletType: 'bank',
        name: 'Ngân hàng',
        description: 'Tài khoản ngân hàng',
        balance: 0,
      },
      {
        userId,
        walletType: 'ewallet',
        name: 'Ví điện tử',
        description: 'Ví điện tử (Momo, ZaloPay, v.v)',
        balance: 0,
      },
    ];

    await Wallet.insertMany(defaultWallets);
    console.log(`✅ Wallets initialized for user ${userId}`);
  } catch (error) {
    console.error('❌ Error initializing wallets:', error);
    throw error;
  }
};

/**
 * Đồng bộ số dư ví từ toàn bộ transaction hiện có của user.
 * - Giao dịch cũ không có walletType sẽ mặc định vào ví tiền mặt.
 */
const reconcileWalletBalancesForUser = async (userId) => {
  await initializeWalletsForUser(userId);

  const [wallets, transactions] = await Promise.all([
    Wallet.find({ userId }),
    Transaction.find({ userId }).select('amount type walletType').lean(),
  ]);

  const nextBalances = {
    cash: 0,
    bank: 0,
    ewallet: 0,
  };

  for (const tx of transactions) {
    const walletType = normalizeWalletType(tx.walletType);
    const amount = Number(tx.amount) || 0;
    const delta = tx.type === 'income' ? amount : -amount;
    nextBalances[walletType] += delta;
  }

  for (const wallet of wallets) {
    const walletType = normalizeWalletType(wallet.walletType);
    const rawBalance = Number(nextBalances[walletType] || 0);
    wallet.balance = rawBalance < 0 ? 0 : rawBalance;
    wallet.lastUpdated = new Date();
  }

  await Promise.all(wallets.map((wallet) => wallet.save()));

  return wallets;
};

module.exports = {
  initializeWalletsForUser,
  reconcileWalletBalancesForUser,
};
