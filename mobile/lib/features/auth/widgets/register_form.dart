import 'package:flutter/material.dart';
import '../../../theme/text_style.dart';
import '../../../shared/widgets/forms/custom_text_field.dart';
import '../../../shared/widgets/forms/custom_password_field.dart';
import '../../../shared/widgets/smooth_primary_button.dart';
import '../../../shared/widgets/animated_error_message.dart';
import '../../../services/auth_service.dart';
import '../../../core/strings.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onNavigateToLogin;

  const RegisterForm({
    super.key,
    required this.onRegisterSuccess,
    required this.onNavigateToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _forceValidation = false;

  final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  final RegExp _passwordPolicyRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).+$',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 32),

          // Form Fields
          _buildFormFields(),
          const SizedBox(height: 48),

          // Error Message (Smooth Animation)
          AnimatedErrorMessage(errorMessage: _errorMessage),

          // Register Button (Smooth Loading)
          SmoothPrimaryButton(
            text: AppStrings.createAccount,
            isLoading: _isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 32),

          // Login Link
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.createAccount, style: AppTextStyle.welcomeTitle),
        const SizedBox(height: 8),
        Text(AppStrings.signUpToGetStarted, style: AppTextStyle.subtitle),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Name Field
        CustomTextField(
          controller: _nameController,
          hintText: AppStrings.enterFullName,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return AppStrings.pleaseEnterFullName;
            }
            if (trimmed.length < 2) {
              return AppStrings.fullNameTooShort;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomTextField(
          controller: _emailController,
          hintText: AppStrings.enterEmail,
          keyboardType: TextInputType.emailAddress,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return AppStrings.pleaseEnterEmail;
            }
            if (!_emailRegex.hasMatch(trimmed)) {
              return AppStrings.invalidEmailFormat;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password Field
        CustomPasswordField(
          controller: _passwordController,
          hintText: AppStrings.enterPassword,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return AppStrings.pleaseEnterPassword;
            }
            if (trimmed.length < 8) {
              return AppStrings.passwordMinLength;
            }
            if (!_passwordPolicyRegex.hasMatch(trimmed)) {
              return AppStrings.passwordPolicy;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        CustomPasswordField(
          controller: _confirmPasswordController,
          hintText: AppStrings.confirmPassword,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return AppStrings.pleaseConfirmPassword;
            }
            if (trimmed != _passwordController.text.trim()) {
              return AppStrings.passwordMismatch;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.alreadyHaveAccount, style: AppTextStyle.subtitle),
        GestureDetector(
          onTap: widget.onNavigateToLogin,
          child: Text(AppStrings.signIn, style: AppTextStyle.link),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
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

    final result = await AuthService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
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

    widget.onRegisterSuccess();
  }
}
