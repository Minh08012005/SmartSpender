import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
        home: LoginScreen(),
        //   home: MainNavigation(),
      ),
    );
  }
}
