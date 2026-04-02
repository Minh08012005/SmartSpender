import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';

import '../../../core/strings.dart';
import '../../../theme/colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/config/app_config.dart';
import 'security_widgets.dart';

class ChangePasswordForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const ChangePasswordForm({required this.onSuccess, super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isChangingPassword = false;
  bool _touchedCurrent = false;
  bool _touchedNew = false;
  bool _touchedConfirm = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      // Call backend change-password endpoint
      final api = ApiService();

      final resp = await api.post(
        '/api/auth/change-password',
        data: {
          'currentPassword': _currentPasswordController.text.trim(),
          'newPassword': _newPasswordController.text.trim(),
        },
      );

      final body = resp.data;

      // Save last change timestamp locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastPasswordChange', DateTime.now().toString());

      // If backend returned a fresh access token, persist it
      final newAccess = body?['data']?['accessToken'];
      if (newAccess != null && newAccess is String && newAccess.isNotEmpty) {
        await prefs.setString(ApiConstants.accessTokenKey, newAccess);
        await prefs.setString(
          ApiConstants.tokenOriginKey,
          AppConfig.apiBaseUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.securityChangePasswordSuccess),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        _formKey.currentState?.reset();

        widget.onSuccess();
      }
    } on DioException catch (err) {
      final msg =
          err.error?.toString() ?? AppStrings.securityChangePasswordFailed;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.securityChangePasswordFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(height: 16),
          PasswordField(
            label: AppStrings.securityCurrentPassword,
            controller: _currentPasswordController,
            isObscured: !_showCurrentPassword,
            onToggleVisibility: () {
              setState(() {
                _showCurrentPassword = !_showCurrentPassword;
              });
            },
            onChanged: (v) {
              if (!_touchedCurrent) {
                setState(() {
                  _touchedCurrent = true;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu hiện tại';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PasswordField(
            label: AppStrings.securityNewPassword,
            controller: _newPasswordController,
            isObscured: !_showNewPassword,
            onToggleVisibility: () {
              setState(() {
                _showNewPassword = !_showNewPassword;
              });
            },
            onChanged: (v) {
              if (!_touchedNew) {
                setState(() {
                  _touchedNew = true;
                });
              }
            },
            validator: (value) {
              if (!_touchedNew) return null;
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu mới';
              }
              if (value.length < 8) {
                return AppStrings.passwordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PasswordField(
            label: AppStrings.securityConfirmNewPassword,
            controller: _confirmPasswordController,
            isObscured: !_showConfirmPassword,
            onToggleVisibility: () {
              setState(() {
                _showConfirmPassword = !_showConfirmPassword;
              });
            },
            onChanged: (v) {
              if (!_touchedConfirm) {
                setState(() {
                  _touchedConfirm = true;
                });
              }
            },
            validator: (value) {
              if (!_touchedConfirm) return null;
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu mới';
              }
              if (value != _newPasswordController.text) {
                return AppStrings.passwordMismatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isChangingPassword ? null : _changePassword,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isChangingPassword
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Cập nhật mật khẩu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
