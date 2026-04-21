import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'navigation/main_navigation.dart';
import 'core/config/app_config.dart';
import 'core/services/api_service.dart';
import 'core/constants/api_constants.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/notifications_provider.dart';
import 'data/providers/statistic_provider.dart';
import 'core/strings.dart';
import 'data/providers/wallet_provider.dart';
import 'theme/colors.dart';

void main() async {
  // Ensure Flutter binding initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Print config on startup (useful for debugging)
  AppConfig.printConfig();

  // Initialize API Service
  await ApiService().init();
  debugPrint('✅ Đã khởi tạo API Service');
  debugPrint('🌐 URL gốc: ${ApiConstants.baseUrl}');
  debugPrint('📱 Nền tảng: ${kIsWeb ? 'web' : defaultTargetPlatform.name}');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<_LaunchTarget> _launchTargetFuture;

  static const Color _appPrimary = Color(0xff2A7C76);

  ThemeData _buildAppTheme() {
    final base = ThemeData(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _appPrimary,
      brightness: Brightness.light,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _appPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _appPrimary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _appPrimary,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _appPrimary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Cache Future để tránh gọi lại khi rebuild
    _launchTargetFuture = _resolveLaunchTarget();
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  Future<bool> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.accessTokenKey);
    final tokenOrigin = prefs.getString(ApiConstants.tokenOriginKey);
    final currentBaseUrl = ApiConstants.baseUrl;

    // Force migration: legacy token without origin metadata is treated as stale.
    if (token != null && token.isNotEmpty) {
      if (tokenOrigin == null || tokenOrigin.isEmpty) {
        debugPrint('⚠️ Phát hiện token cũ. Đang xóa phiên.');
        await prefs.remove(ApiConstants.accessTokenKey);
        await prefs.remove(ApiConstants.refreshTokenKey);
        await prefs.remove(ApiConstants.tokenOriginKey);
        return false;
      }
    }

    // Avoid reusing token issued by another backend (e.g. local -> ngrok).
    if (token != null && token.isNotEmpty) {
      if (tokenOrigin != null &&
          tokenOrigin.isNotEmpty &&
          tokenOrigin != currentBaseUrl) {
        debugPrint('⚠️ Nguồn token không khớp. Đang xóa token cũ.');
        await prefs.remove(ApiConstants.accessTokenKey);
        await prefs.remove(ApiConstants.refreshTokenKey);
        await prefs.remove(ApiConstants.tokenOriginKey);
        return false;
      }
    }

    // Debug log
    debugPrint('🔍 Đang kiểm tra xác thực...');
    if (token != null && token.isNotEmpty) {
      debugPrint('🔑 Đã tìm thấy token đã lưu: ${token.substring(0, 20)}...');
      return true;
    } else {
      debugPrint('🔓 Không tìm thấy token, chuyển sang màn đăng nhập');
      return false;
    }
  }

  Future<_LaunchTarget> _resolveLaunchTarget() async {
    final isLoggedIn = await _checkAuthentication();
    if (isLoggedIn) {
      return _LaunchTarget.app;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding =
        prefs.getBool(ApiConstants.onboardingSeenKey) ?? false;

    return hasSeenOnboarding ? _LaunchTarget.login : _LaunchTarget.onboarding;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap app với MultiProvider để inject providers
    return MultiProvider(
      providers: [
        // Notifications provider (create first)
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),

        // Transaction Provider - inject NotificationsProvider using ProxyProvider
        ChangeNotifierProxyProvider<NotificationsProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, notifications, txProvider) {
            txProvider ??= TransactionProvider();
            txProvider.setNotificationsProvider(notifications);
            return txProvider;
          },
        ),

        // Statistic Provider
        ChangeNotifierProvider(create: (_) => StatisticProvider()),

        // Wallet Provider
        ChangeNotifierProvider(create: (_) => WalletProvider()),

        // TODO: Thêm các providers khác ở đây
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartSpender',
        navigatorKey: ApiService.navigatorKey,
        theme: _buildAppTheme(),

        // ===== NAMED ROUTES =====
        onGenerateRoute: (settings) {
          // Default route
          return null;
        },

        // ===== AUTO-LOGIN LOGIC =====
        home: FutureBuilder<_LaunchTarget>(
          future: _launchTargetFuture,
          builder: (context, snapshot) {
            // Đang kiểm tra token
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.loading,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Đã có kết quả
            switch (snapshot.data) {
              case _LaunchTarget.app:
                return const MainNavigation();
              case _LaunchTarget.onboarding:
                return const OnboardingScreen();
              case _LaunchTarget.login:
              default:
                return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}

enum _LaunchTarget { app, onboarding, login }
