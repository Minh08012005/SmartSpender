import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'views/home/home_screen.dart';
import 'core/config/app_config.dart';
import 'core/services/api_service.dart';
import 'core/constants/api_constants.dart';
import 'data/providers/transaction_provider.dart';
//import 'navigation/main_navigation.dart';

void main() async {
  // Ensure Flutter binding initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Print config on startup (useful for debugging)
  AppConfig.printConfig();

  // Initialize API Service
  await ApiService().init();
  debugPrint('✅ API Service initialized');
  debugPrint('🌐 Base URL: ${ApiConstants.baseUrl}');
  debugPrint('📱 Platform: ${Platform.operatingSystem}');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    // Cache Future để tránh gọi lại khi rebuild
    _authCheckFuture = _checkAuthentication();
  }

  /// Kiểm tra xem user đã đăng nhập chưa
  Future<bool> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.accessTokenKey);

    // Debug log
    debugPrint('🔍 Checking authentication...');
    if (token != null && token.isNotEmpty) {
      debugPrint('🔑 Found saved token: ${token.substring(0, 20)}...');
      return true;
    } else {
      debugPrint('🔓 No token found, navigating to Login');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap app với MultiProvider để inject providers
    return MultiProvider(
      providers: [
        // Transaction Provider
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        // TODO: Thêm các providers khác ở đây
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SmartSpender',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),

        // ===== AUTO-LOGIN LOGIC =====
        home: FutureBuilder<bool>(
          future: _authCheckFuture,
          builder: (context, snapshot) {
            // While checking auth state, show a loading screen
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }

            // If token exists -> HomeScreen, otherwise LoginScreen
            if (snapshot.hasData && snapshot.data == true) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
