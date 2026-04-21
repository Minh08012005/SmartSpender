class AppStrings {
  const AppStrings._();

  // Validation messages
  static const String amountRequired = 'Vui lòng nhập số tiền';
  static const String apply = 'Áp dụng';
  static const String year = 'Năm';
  static const String invalidAmount = 'Số tiền không hợp lệ';
  static const String amountMustBeGreaterThanZero = 'Số tiền phải lớn hơn 0';
  static const String amountMustNotExceedOneBillion =
      'Số tiền không được vượt quá 1 tỷ';
  static const String noteMustNotExceed200Characters =
      'Ghi chú không được vượt quá 200 ký tự';
  static const String titleRequired = 'Vui lòng nhập tiêu đề';
  static const String titleMustNotExceed100Characters =
      'Tiêu đề không được vượt quá 100 ký tự';
  static const String pleaseSelectCategory = 'Vui lòng chọn danh mục';
  static const String categoryInvalidForSelectedTransactionType =
      'Danh mục không phù hợp với loại giao dịch đã chọn';

  // Snackbar and feedback messages
  static const String transactionAddedSuccessfully =
      'Đã thêm giao dịch thành công';
  static const String failedToAddTransaction = 'Thêm giao dịch thất bại';
  static const String failedToLoadTransactions =
      'Tải danh sách giao dịch thất bại';
  static const String failedToLoadBudget = 'Tải budget thất bại';
  static const String failedToSaveBudget = 'Lưu budget thất bại';
  static const String budgetSavedSuccessfully = 'Đã lưu budget thành công';
  static const String failedToDeleteTransaction = 'Xóa giao dịch thất bại';
  static const String failedToUpdateTransaction = 'Cập nhật giao dịch thất bại';
  static const String transactionUpdatedSuccessfully =
      'Đã cập nhật giao dịch thành công';
  static const String transactionDeletedSuccessfully =
      'Đã xóa giao dịch thành công';
  static const String cannotFetchTransactions =
      'Không thể tải danh sách giao dịch';
  static const String cannotAddTransaction = 'Không thể thêm giao dịch';
  static const String cannotDeleteTransaction = 'Không thể xóa giao dịch';
  static const String cannotUpdateTransaction = 'Không thể cập nhật giao dịch';
  static const String deleteTransactionTitle = 'Xóa giao dịch';
  static const String deleteTransactionConfirmMessage =
      'Bạn có chắc chắn muốn xóa giao dịch này không?';
  static const String cancel = 'Hủy';
  static const String delete = 'Xóa';
  static const String errorOccurred = 'Đã xảy ra lỗi';
  static const String unexpectedErrorOccurred = 'Đã xảy ra lỗi không mong muốn';

  // Navigation labels
  static const String navHome = 'Trang chủ';
  static const String navStatistic = 'Thống kê';
  static const String navWallet = 'Ví';
  static const String navProfile = 'Hồ sơ';

  // Home screen
  static const String homeTransactionHistory = 'Lịch sử giao dịch';
  static const String homeSeeAll = 'Xem tất cả';
  static const String allTransactionsTitle = 'Tất cả giao dịch';
  static const String homeEmptyTransactions = 'Không có giao dịch nào';
  static const String loading = 'Đang tải...';
  static const String retry = 'Thử lại';

  // Balance card
  static const String totalBalance = 'Tổng số dư';
  static const String totalIncome = 'Thu nhập';
  static const String totalExpense = 'Chi tiêu';

  // Auth UI
  static const String signIn = 'Đăng nhập';
  static const String signUp = 'Đăng ký';
  static const String welcomeBack = 'Chào mừng trở lại';
  static const String signInToContinue = 'Đăng nhập để tiếp tục';
  static const String createAccount = 'Tạo tài khoản';
  static const String signUpToGetStarted = 'Đăng ký để bắt đầu';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String noAccount = 'Chưa có tài khoản? ';
  static const String alreadyHaveAccount = 'Đã có tài khoản? ';
  static const String enterFullName = 'Nhập họ và tên';
  static const String pleaseEnterFullName = 'Vui lòng nhập họ và tên';
  static const String fullNameTooShort = 'Họ và tên quá ngắn';
  static const String enterEmail = 'Nhập email';
  static const String pleaseEnterEmail = 'Vui lòng nhập email';
  static const String invalidEmailFormat = 'Định dạng email không hợp lệ';
  static const String enterPassword = 'Nhập mật khẩu';
  static const String pleaseEnterPassword = 'Vui lòng nhập mật khẩu';
  static const String passwordMinLength = 'Mật khẩu phải có ít nhất 8 ký tự';
  static const String passwordPolicy =
      'Mật khẩu cần có chữ hoa, chữ thường, số và ký tự đặc biệt';
  static const String confirmPassword = 'Xác nhận mật khẩu';
  static const String pleaseConfirmPassword = 'Vui lòng xác nhận mật khẩu';
  static const String passwordMismatch = 'Mật khẩu xác nhận không khớp';

  // Transaction form labels
  static const String addTransaction = 'Thêm giao dịch';
  static const String editTransaction = 'Sửa giao dịch';
  static const String amountLabel = 'Số tiền';
  static const String amountHint = 'Nhập số tiền';
  static const String transactionType = 'Loại giao dịch';
  static const String transactionWallet = 'Ví';
  static const String income = 'Thu nhập';
  static const String expense = 'Chi tiêu';
  static const String category = 'Danh mục';
  static const String title = 'Tiêu đề';
  static const String titleHint = 'Ví dụ: Ăn trưa với bạn bè';
  static const String date = 'Ngày';
  static const String note = 'Ghi chú';
  static const String saveTransaction = 'Lưu giao dịch';
  static const String updateTransaction = 'Cập nhật giao dịch';
  static const String deleteTransaction = 'Xóa giao dịch';

  // Statistic screen
  static const String statisticTitle = 'Thống kê';
  static const String statisticKpiTotalExpense = 'Tổng chi tiêu';
  static const String statisticKpiTotalIncome = 'Tổng thu nhập';
  static const String statisticKpiBalance = 'Số dư còn lại';
  static const String statisticSpentSubtitle = 'Tiền đã chi';
  static const String statisticReceivedSubtitle = 'Tiền đã nhận';
  static const String statisticRemaining = 'Còn lại';
  static const String statisticNegative = 'Âm';
  static const String statisticCategorySection = 'Chi tiêu theo danh mục';
  static const String statisticTotalExpensePrefix = 'Tổng chi';
  static const String statisticNoExpenseInPeriod =
      'Không có chi tiêu trong kỳ này';
  static const String statisticRecentTransactions = 'Giao dịch gần đây';
  static const String statisticRecentTransactionsHint =
      'Tối đa 5 giao dịch mới nhất';
  static const String statisticRecentTransactionsCompactHint =
      'Mặc định hiển thị 3 giao dịch mới nhất';
  static const String statisticRecentTransactionsExpandedHint =
      'Đang hiển thị tất cả giao dịch tháng này';
  static const String statisticSeeMore = 'Xem thêm';
  static const String statisticCollapse = 'Thu gọn';
  static const String statisticMonthlyCalendar = 'Lịch tháng';
  static const String statisticDayTransactionsTitlePrefix = 'Giao dịch ngày';
  static const String statisticNoTransactionInSelectedDay =
      'Không có giao dịch trong ngày này';

  static const String statisticMonthlyBudgetTitle = 'Mục tiêu chi tiêu tháng';
  static const String statisticSetUpBudget = 'Thiết lập';
  static const String statisticBudgetTargetPrefix = 'Mục tiêu';
  static const String statisticBudgetSpentPrefix = 'Đã chi';
  static const String statisticBudgetRemainingPrefix = 'Còn lại';
  static const String statisticBudgetStatusPrefix = 'Trạng thái';
  static const String statisticBudgetStatusOver = 'Vượt mục tiêu';
  static const String statisticBudgetStatusNear = 'Gần chạm mục tiêu';
  static const String statisticBudgetStatusSafe = 'An toàn';
  static const String statisticSummaryIncome = 'Thu nhập';
  static const String statisticSummaryExpense = 'Chi tiêu';
  static const String statisticSummaryTotal = 'Tổng';
  static const String statisticBudgetEditorTitlePrefix =
      'Thiết lập mục tiêu tháng';
  static const String statisticBudgetEditorAmountLabel = 'Số tiền mục tiêu';
  static const String save = 'Lưu';
  static const String statisticCurrentMonth = 'Tháng này';
  static const String statisticPreviousMonth = 'Tháng trước';
  static const String statisticSelectMonth = 'Chọn tháng';

  // Profile
  static const String profileTitle = 'Hồ sơ';
  static const String profilePersonalInfo = 'Thông tin cá nhân';
  static const String profileLoginSecurity = 'Đăng nhập và bảo mật';
  static const String profileNotifications = 'Thông báo';
  static const String profilePrivacy = 'Quyền riêng tư';
  static const String profileLogout = 'Đăng xuất';
  static const String profileEdit = 'Chỉnh sửa';
  static const String profileGroupManagement = 'Quản Lý Nhóm';
  static const String profileAvatarFallback = 'U';
  static const String profileLogoutConfirmMessage =
      'Bạn có chắc muốn đăng xuất không?';
  static const String profileLogoutFailed =
      'Không thể đăng xuất lúc này, vui lòng thử lại.';
  static const String profileDisplayName = 'Người dùng SmartSpender';
  static const String profileUsername = '@nguoi_dung';
  static const String profileEditInfo = 'Chỉnh sửa thông tin';

  // Onboarding
  static const String onboardingTitle = 'Chi tiêu thông minh\nTiết kiệm hơn';
  static const String onboardingGetStarted = 'Bắt đầu';
  static const String onboardingAlreadyHaveAccount = 'Đã có tài khoản? ';

  // Auth service messages
  static const String invalidEmailOrPassword = 'Email hoặc mật khẩu không đúng';
  static const String accountAlreadyExists = 'Tài khoản đã tồn tại';
  static const String serverErrorPrefix = 'Lỗi máy chủ';
  static const String invalidServerResponse =
      'Phản hồi từ máy chủ không hợp lệ';
  static const String requestCancelled = 'Yêu cầu đã bị hủy';
  static const String loginFailed = 'Đăng nhập thất bại';
  static const String loginSuccess = 'Đăng nhập thành công';
  static const String registerSuccess = 'Đăng ký thành công';
  static const String timeoutTryAgain =
      'Kết nối quá thời gian, vui lòng thử lại';
  static const String cannotConnectServer = 'Không thể kết nối đến máy chủ';
  static const String serverConnectionError = 'Lỗi kết nối máy chủ';
  static const String missingAccessToken =
      'Không tìm thấy access token trong phản hồi';

  // Wallet screen
  static const String walletTitle = 'Ví của tôi';
  static const String walletListLabel = 'Danh sách ví';
  static const String walletSelectWallet = 'Chọn ví';
  static const String walletTransferButtonLabel = 'Điều chuyển';
  static const String walletAddButtonLabel = 'Thêm ví';
  static const String walletFeatureComingSoon = 'Tính năng sẽ được cập nhật';

  static const String walletTransferModalTitle = 'Điều chuyển tiền';
  static const String walletFromLabel = 'Từ ví';
  static const String walletToLabel = 'Đến ví';
  static const String walletAmountLabel = 'Số tiền';
  static const String walletNoteLabel = 'Ghi chú (tùy chọn)';
  static const String walletConfirmCheckboxLabel = 'Xác nhận điều chuyển';
  static const String walletConfirmButtonLabel = 'Xác nhận';

  // Wallet error messages
  static const String walletSourceDestinationSame =
      'Ví nguồn và ví đích phải khác nhau';
  static const String walletAmountMustBePositive = 'Số tiền phải lớn hơn 0';
  static const String walletInsufficientBalance = 'Số dư không đủ';
  static const String walletPleaseSelectWallet = 'Vui lòng chọn ví';
  static const String walletPleaseConfirm = 'Vui lòng xác nhận điều chuyển';

  // Wallet success messages
  static const String walletTransferSuccess = 'Điều chuyển thành công';
  static const String walletTransferFailed = 'Điều chuyển thất bại';

  // Wallet names
  static const String walletNameCash = 'Tiền mặt';
  static const String walletNameBank = 'Ngân hàng';
  static const String walletNameEwallet = 'Ví điện tử';

  // Phase 4: Security Settings
  static const String securityChangePassword = 'Đổi mật khẩu';
  static const String securityCurrentPassword = 'Mật khẩu hiện tại';
  static const String securityNewPassword = 'Mật khẩu mới';
  static const String securityConfirmNewPassword = 'Xác nhận mật khẩu mới';
  static const String securityTwoFactorAuth = 'Xác thực hai yếu tố (2FA)';
  static const String securityTwoFactorAuthDesc = 'Bảo vệ tài khoản bằng 2FA';
  static const String securityTwoFactorEnabled = 'Đã bật';
  static const String securityTwoFactorDisabled = 'Chưa bật';
  static const String securityActiveSessions = 'Phiên đang hoạt động';
  static const String securityCurrentDevice = 'Thiết bị hiện tại';
  static const String securityLogoutOtherSessions = 'Đăng xuất các phiên khác';
  static const String securityLogoutOtherSessionsDesc =
      'Đăng xuất mọi phiên đăng nhập khác';
  static const String securityChangePasswordSuccess = 'Đổi mật khẩu thành công';
  static const String securityChangePasswordFailed = 'Đổi mật khẩu thất bại';
  static const String securityInvalidCurrentPassword =
      'Mật khẩu hiện tại không đúng';
  static const String securityPasswordChangedAt = 'Lần cuối thay đổi: ';
  static const String securityLoginActivity = 'Lịch sử đăng nhập';
  static const String securityLastLogin = 'Lần đăng nhập cuối: ';
  static const String securityLocation = 'Vị trí: ';
  static const String securityDevice = 'Thiết bị: ';

  // Phase 5: Notifications Settings
  static const String notificationsTitle = 'Thông báo';
  static const String notificationsInAppNotifications =
      'Thông báo trong ứng dụng';
  static const String notificationsEmailNotifications = 'Thông báo qua email';
  static const String notificationsTransactions = 'Thông báo giao dịch';
  static const String notificationsTransactionsDesc =
      'Nhận thông báo khi có giao dịch mới';
  static const String notificationsSecurityAlerts = 'Cảnh báo bảo mật';
  static const String notificationsSecurityAlertsDesc =
      'Thông báo khi có hoạt động không bình thường';
  static const String notificationsBudgetAlerts = 'Cảnh báo ngân sách';
  static const String notificationsBudgetAlertsDesc =
      'Thông báo khi gần vượt ngân sách';
  static const String notificationsReminders = 'Nhắc nhở';
  static const String notificationsRemindersDesc = 'Nhắc nhở quản lý chi tiêu';
  static const String notificationsPromotions = 'Khuyến mãi và cập nhật';
  static const String notificationsPromotionsDesc =
      'Nhận thông báo về khuyến mãi mới';
  static const String notificationsNoNotifications = 'Không có thông báo nào';
  static const String notificationsMarkAllAsRead = 'Đánh dấu tất cả đã đọc';
  static const String notificationsNotificationCenter = 'Trung tâm thông báo';
  static const String notificationsPreferences = 'Tùy chỉnh thông báo';
  static const String notificationsSavePreferences = 'Lưu tùy chỉnh';
  static const String notificationsPreferencesSaved = 'Tùy chỉnh đã được lưu';
  static const String notificationsPreferencesFailed = 'Lưu tùy chỉnh thất bại';
}
