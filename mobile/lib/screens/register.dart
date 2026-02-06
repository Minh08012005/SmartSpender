import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../navigation/main_navigation.dart';
import '../features/auth/widgets/auth_header.dart';
import '../features/auth/widgets/auth_form_wrapper.dart';
import '../features/auth/widgets/register_form.dart';
import '../shared/utils/smooth_navigation.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _navigateToHome(BuildContext context) {
    SmoothNavigation.pushReplacement(context, const MainNavigation());
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pop(context);
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
              const AuthHeader(title: 'Create Account', showBackButton: true),

              // Form Content
              Expanded(
                child: AuthFormWrapper(
                  child: RegisterForm(
                    onRegisterSuccess: () => _navigateToHome(context),
                    onNavigateToLogin: () => _navigateToLogin(context),
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
