import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_style.dart';
import '../navigation/main_navigation.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );
  final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
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
    return Scaffold(
      body: Container(
        color: AppColors.primary,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with back icon and title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Create Account',
                      style: AppTextStyle.appBarTitle,
                    ),
                  ],
                ),
              ),

              // White content area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Create Account', style: AppTextStyle.welcomeTitle),
                            const SizedBox(height: 8),
                            Text('Sign up to get started', style: AppTextStyle.subtitle),

                            const SizedBox(height: 32),

                            // Name
                            _buildTextField(
                              controller: _nameController,
                              hintText: 'Enter your full name',
                              // label: 'Full Name',
                              validator: (value) {
                                final trimmed = value?.trim() ?? '';
                                if (trimmed.isEmpty) {
                                  return 'Vui lòng nhập họ tên';
                                }
                                if (trimmed.length < 2) {
                                  return 'Họ tên tối thiểu 2 ký tự';
                                }
                                if (trimmed.length > 100) {
                                  return 'Họ tên tối đa 100 ký tự';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              //label: 'Email',
                              keyboardType: TextInputType.emailAddress,
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

                          // Password
                          _buildPasswordField(
                            controller: _passwordController,
                            hintText: 'Create a password',
                            //label: 'Password',
                            obscureText: _obscurePassword,
                            onToggle: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: (value) {
                              final trimmed = (value ?? '').trim();
                              if (trimmed.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (trimmed.length < 8 || !_passwordRegex.hasMatch(trimmed)) {
                                return 'Mật khẩu cần tối thiểu 8 ký tự bao gồm chữ số, chữ in hoa và kí tự đặc biệt';
                              }
                              if (trimmed.length > 128) {
                                return 'Mật khẩu tối đa 128 ký tự';
                              }
                             //if (!_passwordRegex.hasMatch(trimmed)) {
                             //   return 'Mật khẩu cần chữ hoa, chữ thường, số và ký tự đặc biệt';
                             // }
                              return null;
                            },
                          ),

                            const SizedBox(height: 16),

                            // Confirm Password
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm your password',
                            obscureText: _obscureConfirmPassword,
                            onToggle: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return 'Vui lòng nhập lại mật khẩu';
                              }
                                if (trimmed != _passwordController.text.trim()) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 32),

                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: AppTextStyle.subtitle.copyWith(
                                  color: AppColors.textLink,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryButton,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handleRegister,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.white,
                                          ),
                                        ),
                                      )
                                    : Text('Sign Up', style: AppTextStyle.buttonText),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Already have account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ', style: AppTextStyle.subtitle),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text('Sign in', style: AppTextStyle.link),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigation(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label, style: AppTextStyle.hint),
        if (label != null) const SizedBox(height: 8),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyle.hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              errorStyle: AppTextStyle.subtitle.copyWith(
                color: AppColors.textLink,
                fontSize: 12,
                height: 1.3,
              ),
              errorMaxLines: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    String? label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label, style: AppTextStyle.hint),
        if (label != null) const SizedBox(height: 8),
        Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyle.hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              errorStyle: AppTextStyle.subtitle.copyWith(
                color: AppColors.textLink,
                fontSize: 12,
                height: 1.3,
              ),
              errorMaxLines: 3,
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
