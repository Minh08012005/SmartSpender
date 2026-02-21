import 'package:flutter/material.dart';
import '../../../theme/text_style.dart';
import '../../../shared/widgets/forms/custom_text_field.dart';
import '../../../shared/widgets/forms/custom_password_field.dart';
import '../../../shared/widgets/smooth_primary_button.dart';
import '../../../shared/widgets/animated_error_message.dart';
import '../../../services/auth_service.dart';

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
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
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
            text: 'Create Account',
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
        Text('Create Account', style: AppTextStyle.welcomeTitle),
        const SizedBox(height: 8),
        Text('Sign up to get started', style: AppTextStyle.subtitle),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Name Field
        CustomTextField(
          controller: _nameController,
          hintText: 'Enter your full name',
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            if (trimmed.length < 2) {
              return 'Họ và tên quá ngắn';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!_emailRegex.hasMatch(trimmed)) {
              return 'Email không đúng định dạng';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Password Field
        CustomPasswordField(
          controller: _passwordController,
          hintText: 'Enter password',
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (trimmed.length < 8 || !_passwordRegex.hasMatch(trimmed)) {
               return 'Mật khẩu cần tối thiểu 8 ký tự, bao gồm chữ số, chữ in hoa và ký tự đặc biệt';
            }
            if (trimmed.length > 128) {
              return 'Mật khẩu quá dài';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        CustomPasswordField(
          controller: _confirmPasswordController,
          hintText: 'Confirm password',
          forceValidation: _forceValidation,
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (trimmed != _passwordController.text.trim()) {
              return 'Mật khẩu không khớp';
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
        Text('Already have an account? ', style: AppTextStyle.subtitle),
        GestureDetector(
          onTap: widget.onNavigateToLogin,
          child: Text('Sign In', style: AppTextStyle.link),
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
