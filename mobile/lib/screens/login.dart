import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../navigation/main_navigation.dart';
import '../core/strings.dart';
import '../features/auth/widgets/auth_header.dart';
import '../features/auth/widgets/auth_form_wrapper.dart';
import '../features/auth/widgets/login_form.dart';
import '../shared/utils/smooth_navigation.dart';
import 'register.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _navigateToHome(BuildContext context) {
    SmoothNavigation.pushReplacement(context, const MainNavigation());
  }

  void _navigateToRegister(BuildContext context) {
    SmoothNavigation.push(context, const RegisterScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              const AuthHeader(title: AppStrings.signIn, showBackButton: true),

              // Form Content
              Expanded(
                child: AuthFormWrapper(
                  child: LoginForm(
                    onLoginSuccess: () => _navigateToHome(context),
                    onNavigateToRegister: () => _navigateToRegister(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
