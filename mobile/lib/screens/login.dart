import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_style.dart';
import 'register.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              // Status Bar & Navigation Bar
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
                      'Sign in',
                      style: AppTextStyle.appBarTitle,
                    ),
                  ],
                ),
              ),
              // White Content Area
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
                            // Welcome Title
                            Text(
                              'Welcome Back',
                              style: AppTextStyle.welcomeTitle,
                            ),
                            const SizedBox(height: 8),
                            // Subtitle
                            Text(
                              'Hello there, sign in to continue',
                              style: AppTextStyle.subtitle,
                            ),

                            const SizedBox(height: 40),

                            // Email Input
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Password Input
                            _buildPasswordField(
                              controller: _passwordController,
                              hintText: 'Password',
                              obscureText: _obscurePassword,
                              onToggle: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),

                            const SizedBox(height: 24),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Forgot your password ?',
                                style: AppTextStyle.link,
                              ),
                            ),

                            const SizedBox(height: 48),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryButton,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(
                                      color: AppColors.primaryButton,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _formKey.currentState?.validate();
                                },
                                child: const Text(
                                  'Sign in',
                                 // style: TextStyle(
                                 //   color: AppColors.white,
                                 //   fontSize: 18,
                                 //   fontFamily: 'Inter',
                                 //   fontWeight: FontWeight.w600,
                                  style: AppTextStyle.buttonText,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text(
                               "Don't have an account? ",
                              style: AppTextStyle.subtitle,
                              ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                 ),
                               );
                              },
                                child: Text(
                                   'Sign Up',
                                    style: AppTextStyle.link,
                                 ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
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
          errorStyle: AppTextStyle.subtitle.copyWith(color: AppColors.textLink),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
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
          errorStyle: AppTextStyle.subtitle.copyWith(color: AppColors.textLink),
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
    );
  }
}
