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
import 'data/providers/statistic_provider.dart';
import 'core/strings.dart';
import 'data/providers/wallet_provider.dart';

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
        // Transaction Provider
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

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
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),

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
