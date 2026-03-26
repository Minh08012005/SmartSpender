/**
 * Wallet Controller
 * Xử lý logic các endpoint liên quan đến ví người dùng
 */

const Wallet = require('../models/wallet.model');
const AppError = require('../utils/appError');
const {
  initializeWalletsForUser,
  reconcileWalletBalancesForUser,
} = require('../services/wallet.service');

/**
 * GET /wallets
 * Lấy danh sách tất cả ví của người dùng
 */
exports.getAllWallets = async (req, res, next) => {
  try {
    const userId = req.user._id;

    let wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();

    if (!wallets || wallets.length === 0) {
      await initializeWalletsForUser(userId);
      wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();
    }

    await reconcileWalletBalancesForUser(userId);
    wallets = await Wallet.find({ userId }).sort({ createdAt: 1 }).lean();

    res.status(200).json({
      success: true,
      data: wallets,
      totalBalance: wallets.reduce((sum, w) => sum + w.balance, 0),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * GET /wallets/:id
 * Lấy chi tiết một ví
 */
exports.getWalletById = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const wallet = await Wallet.findOne({ _id: id, userId });

    if (!wallet) {
      return next(new AppError('Ví không được tìm thấy', 404));
    }

    res.status(200).json({
      success: true,
      data: wallet,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * POST /wallets/transfer
 * Điều chuyển tiền giữa 2 ví
 * Body: { fromWalletId, toWalletId, amount, note }
 */
exports.transferBetweenWallets = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { fromWalletId, toWalletId, amount, note } = req.body;

    // ===== VALIDATION =====
    if (!fromWalletId || !toWalletId || !amount) {
      return next(
        new AppError('Vui lòng cung cấp toàn bộ thông tin cần thiết', 400)
      );
    }

    if (amount <= 0) {
      return next(new AppError('Số tiền phải lớn hơn 0', 400));
    }

    if (fromWalletId === toWalletId) {
      return next(new AppError('Ví nguồn và ví đích phải khác nhau', 400));
    }

    // ===== FETCH WALLETS =====
    const [fromWallet, toWallet] = await Promise.all([
      Wallet.findOne({ _id: fromWalletId, userId }),
      Wallet.findOne({ _id: toWalletId, userId }),
    ]);

    if (!fromWallet || !toWallet) {
      return next(new AppError('Ví không được tìm thấy', 404));
    }

    // ===== CHECK BALANCE =====
    if (fromWallet.balance < amount) {
      return next(
        new AppError(
          `Số dư không đủ. Số dư hiện tại: ${fromWallet.balance.toLocaleString('vi-VN')} VND`,
          400
        )
      );
    }

    // ===== EXECUTE TRANSFER =====
    fromWallet.balance -= amount;
    toWallet.balance += amount;
    fromWallet.lastUpdated = new Date();
    toWallet.lastUpdated = new Date();

    await Promise.all([fromWallet.save(), toWallet.save()]);

    res.status(200).json({
      success: true,
      message: 'Điều chuyển tiền thành công',
      data: {
        fromWallet,
        toWallet,
        amount,
        note: note || '',
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * PATCH /wallets/:id
 * Cập nhật thông tin ví (tên, mô tả)
 */
exports.updateWallet = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const { name, description } = req.body;

    // Không cho phép update balance trực tiếp - chỉ qua transfer
    const wallet = await Wallet.findOne({ _id: id, userId });

    if (!wallet) {
      return next(new AppError('Ví không được tìm thấy', 404));
    }

    if (name) wallet.name = name;
    if (description !== undefined) wallet.description = description;

    await wallet.save();

    res.status(200).json({
      success: true,
      message: 'Cập nhật ví thành công',
      data: wallet,
    });
  } catch (error) {
    next(error);
  }
};
