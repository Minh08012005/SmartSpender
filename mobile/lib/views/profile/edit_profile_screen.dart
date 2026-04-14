import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/strings.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fullName = prefs.getString(ApiConstants.fullNameKey) ?? '';
      final email = prefs.getString(ApiConstants.userEmailKey) ?? '';
      final username = prefs.getString(ApiConstants.usernameKey) ?? '';

      setState(() {
        _fullNameController.text = fullName;
        _emailController.text = email;
        _usernameController.text = username;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin người dùng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _showValidationErrors = true;
      });
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Save to SharedPreferences
      await Future.wait([
        prefs.setString(
          ApiConstants.fullNameKey,
          _fullNameController.text.trim(),
        ),
        prefs.setString(
          ApiConstants.userEmailKey,
          _emailController.text.trim(),
        ),
        prefs.setString(
          ApiConstants.usernameKey,
          _usernameController.text.trim(),
        ),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a bit for better UX then pop
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi lưu thông tin'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _loadUserData();
    setState(() {
      _showValidationErrors = false;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa thông tin',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _showValidationErrors
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        // ===== FULL NAME FIELD =====
                        SectionReveal(
                          delayMs: 0,
                          child: _EditProfileTextField(
                            label: 'Họ và tên',
                            icon: Icons.person_outline,
                            controller: _fullNameController,
                            hintText: 'Nhập họ và tên đầy đủ',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.pleaseEnterFullName;
                              }
                              if (value.trim().length < 2) {
                                return AppStrings.fullNameTooShort;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ===== EMAIL FIELD =====
                        SectionReveal(
                          delayMs: 100,
                          child: _EditProfileTextField(
                            label: 'Email',
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            hintText: 'Nhập địa chỉ email',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            helperText: '(Không thể thay đổi)',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppStrings.pleaseEnterEmail;
                              }
                              if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              ).hasMatch(value)) {
                                return AppStrings.invalidEmailFormat;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ===== USERNAME FIELD =====
                        SectionReveal(
                          delayMs: 200,
                          child: _EditProfileTextField(
                            label: 'Tên người dùng',
                            icon: Icons.account_box_outlined,
                            controller: _usernameController,
                            hintText: 'Nhập tên người dùng',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên người dùng';
                              }
                              if (value.trim().length < 2) {
                                return 'Tên người dùng quá ngắn (tối thiểu 2 ký tự)';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== ACTION BUTTONS =====
                        SectionReveal(
                          delayMs: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving ? null : _resetForm,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _isSaving
                                          ? Colors.grey.shade400
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _isSaving ? null : _saveUserData,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Lưu',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ===== INFO MESSAGE =====
                        SectionReveal(
                          delayMs: 400,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Email không thể thay đổi để bảo vệ tài khoản của bạn.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.amber.shade800,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// ===== EDIT PROFILE TEXT FIELD WIDGET =====
class _EditProfileTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final TextInputType keyboardType;
  final bool readOnly;
  final String? Function(String?)? validator;

  const _EditProfileTextField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.validator,
  });

  @override
  State<_EditProfileTextField> createState() => _EditProfileTextFieldState();
}

class _EditProfileTextFieldState extends State<_EditProfileTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Text field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            helperStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.readOnly
                    ? Colors.grey.shade200
                    : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.readOnly
                    ? Colors.grey.shade200
                    : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: widget.readOnly ? Colors.grey.shade100 : Colors.white,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: widget.readOnly
                ? Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 18,
                  )
                : null,
          ),
          enabled: !widget.readOnly,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: widget.readOnly ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
