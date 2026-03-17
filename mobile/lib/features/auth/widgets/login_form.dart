import 'package:flutter/material.dart';
import '../../../theme/text_style.dart';
import '../../../shared/widgets/forms/custom_text_field.dart';
import '../../../shared/widgets/forms/custom_password_field.dart';
import '../../../shared/widgets/smooth_primary_button.dart';
import '../../../shared/widgets/animated_error_message.dart';
import '../../../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;

  const LoginForm({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _forceValidation = false;

  final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(),
          const SizedBox(height: 40),

          // Form Fields
          _buildFormFields(),
          const SizedBox(height: 24),

          // Forgot Password
          _buildForgotPasswordLink(),
          const SizedBox(height: 48),

          // Error Message (Smooth Animation)
          AnimatedErrorMessage(errorMessage: _errorMessage),

          // Login Button (Smooth Loading)
          SmoothPrimaryButton(
            text: 'Sign in',
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: 32),

          // Register Link
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome Back', style: AppTextStyle.welcomeTitle),
        const SizedBox(height: 8),
        Text('Hello there, sign in to continue', style: AppTextStyle.subtitle),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          keyboardType: TextInputType.emailAddress,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Please enter your email';
            }
            if (!_emailRegex.hasMatch(trimmed)) {
              return 'Invalid email format';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomPasswordField(
          controller: _passwordController,
          hintText: 'Password',
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text('Forgot your password ?', style: AppTextStyle.link),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: AppTextStyle.subtitle),
        GestureDetector(
          onTap: widget.onNavigateToRegister,
          child: Text('Sign Up', style: AppTextStyle.link),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    // Force validation for all fields
    setState(() {
      _forceValidation = true;
    });

    // Small delay to ensure validation UI updates
    await Future.delayed(const Duration(milliseconds: 50));

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });

    widget.onLoginSuccess();
  }
}
