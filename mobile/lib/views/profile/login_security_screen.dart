import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/strings.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
import 'widgets/security_widgets.dart';
import 'widgets/change_password_form.dart';

class LoginSecurityScreen extends StatefulWidget {
  const LoginSecurityScreen({super.key});

  @override
  State<LoginSecurityScreen> createState() => _LoginSecurityScreenState();
}

class _LoginSecurityScreenState extends State<LoginSecurityScreen> {
  bool _show2FAForm = false;
  bool _twoFactorEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _twoFactorEnabled = prefs.getBool('twoFactorEnabled') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggle2FA() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newValue = !_twoFactorEnabled;
      await prefs.setBool('twoFactorEnabled', newValue);

      setState(() {
        _twoFactorEnabled = newValue;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newValue ? '2FA đã được bật' : '2FA đã được tắt'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật 2FA thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logoutOtherSessions() async {
    showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.securityLogoutOtherSessions,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn sẽ được đăng xuất khỏi tất cả các thiết bị khác',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((confirm) async {
      if (confirm == true && mounted) {
        try {
          // Simulate API call
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã đăng xuất các phiên khác'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lỗi khi đăng xuất các phiên khác'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.profileLoginSecurity,
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // ===== CHANGE PASSWORD SECTION =====
                      SectionReveal(
                        delayMs: 0,
                        child: SecurityCard(
                          icon: Icons.lock_outline,
                          title: AppStrings.securityChangePassword,
                          onTap: () {
                            setState(() {
                              _show2FAForm = false;
                            });
                          },
                          isExpanded: !_show2FAForm,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ChangePasswordForm(
                              onSuccess: () {
                                setState(() {
                                  _show2FAForm = false;
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== TWO FACTOR AUTH SECTION =====
                      SectionReveal(
                        delayMs: 100,
                        child: SecurityCard(
                          icon: Icons.shield_outlined,
                          title: AppStrings.securityTwoFactorAuth,
                          subtitle: AppStrings.securityTwoFactorAuthDesc,
                          isExpanded: _show2FAForm,
                          onTap: () {
                            setState(() {
                              _show2FAForm = !_show2FAForm;
                            });
                          },
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _twoFactorEnabled,
                              onChanged: (_) => _toggle2FA(),
                              activeThumbColor: AppColors.primary,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _twoFactorEnabled
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _twoFactorEnabled
                                        ? '✓ ${AppStrings.securityTwoFactorEnabled}'
                                        : '○ ${AppStrings.securityTwoFactorDisabled}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _twoFactorEnabled
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== ACTIVE SESSIONS SECTION =====
                      SectionReveal(
                        delayMs: 200,
                        child: SecurityCard(
                          icon: Icons.devices_outlined,
                          title: AppStrings.securityActiveSessions,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                SessionItem(
                                  device: 'Samsung Galaxy S21',
                                  location: 'Hà Nội, Việt Nam',
                                  lastActive: 'Hiện tại',
                                  isCurrent: true,
                                ),
                                const SizedBox(height: 12),
                                SessionItem(
                                  device: 'Web Browser (Chrome)',
                                  location: 'Hà Nội, Việt Nam',
                                  lastActive: '2 giờ trước',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== LOGOUT OTHER SESSIONS BUTTON =====
                      SectionReveal(
                        delayMs: 300,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _logoutOtherSessions,
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
                              child: const Text(
                                AppStrings.securityLogoutOtherSessions,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
