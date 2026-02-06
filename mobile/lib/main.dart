import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'core/config/app_config.dart';
//import 'navigation/main_navigation.dart';

void main() {
  // Print config on startup (useful for debugging)
  AppConfig.printConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      //   home: MainNavigation(),
    );
  }
}
