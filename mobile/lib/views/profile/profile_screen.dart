import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/strings.dart';
import '../../core/constants/api_constants.dart';
import '../../data/providers/transaction_provider.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../screens/login.dart';
import '../../theme/colors.dart';
import 'personal_info_screen.dart';
import 'edit_profile_screen.dart';
import 'login_security_screen.dart';
import 'notifications_screen.dart';
import 'widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  String? _emailPrefix(String? email) {
    final cleanEmail = _nonEmpty(email);
    if (cleanEmail == null) return null;
    final index = cleanEmail.indexOf('@');
    if (index <= 0) return cleanEmail;
    return cleanEmail.substring(0, index);
  }

  String _resolveDisplayName(SharedPreferences prefs) {
    final fullName = _nonEmpty(prefs.getString(ApiConstants.fullNameKey));
    final username = _nonEmpty(prefs.getString(ApiConstants.usernameKey));
    final emailPrefix = _emailPrefix(
      _nonEmpty(prefs.getString(ApiConstants.userEmailKey)),
    );

    return fullName ?? username ?? emailPrefix ?? AppStrings.profileDisplayName;
  }

  String _resolveSubtitle(SharedPreferences prefs) {
    final email = _nonEmpty(prefs.getString(ApiConstants.userEmailKey));
    return email ?? AppStrings.profileUsername;
  }

  String _resolveAvatarText(String displayName) {
    final normalized = displayName.trim();
    if (normalized.isEmpty) return AppStrings.profileAvatarFallback;
    return normalized.substring(0, 1).toUpperCase();
  }

  // ===== LOGOUT FUNCTION =====
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    // Small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      await AuthService.clearSession();

      if (!mounted) return;

      Provider.of<TransactionProvider>(context, listen: false).reset();

      if (!mounted) return;

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.profileLogoutFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // ===== CONFIRM DIALOG =====
  void _confirmLogout(BuildContext context) {
    if (_isLoggingOut) return;

    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _LogoutConfirmDialog(),
    ).then((confirm) async {
      if (confirm == true && mounted) {
        await _handleLogout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Hồ sơ',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== HEADER =====
              SectionReveal(
                delayMs: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, Color(0xff4BA99B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: FutureBuilder<SharedPreferences>(
                    future: SharedPreferences.getInstance(),
                    builder: (context, snapshot) {
                      final prefs = snapshot.data;
                      final displayName = prefs == null
                          ? AppStrings.profileDisplayName
                          : _resolveDisplayName(prefs);
                      final subtitle = prefs == null
                          ? AppStrings.profileUsername
                          : _resolveSubtitle(prefs);
                      final avatarText = _resolveAvatarText(displayName);

                      return ProfileHeader(
                        displayName: displayName,
                        subtitle: subtitle,
                        avatarText: avatarText,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== MENU =====
              SectionReveal(
                delayMs: 100,
                child: ProfileMenuSection(
                  items: [
                    ProfileItem(
                      icon: Icons.account_circle_outlined,
                      title: AppStrings.profilePersonalInfo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonalInfoScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileItem(
                      icon: Icons.lock_outline,
                      title: AppStrings.profileLoginSecurity,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginSecurityScreen(),
                          ),
                        );
                      },
                    ),
                    ProfileItem(
                      icon: Icons.notifications_none,
                      title: AppStrings.profileNotifications,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    // Privacy menu removed: no backend endpoints implemented yet.
                    ProfileItem(
                      icon: Icons.logout,
                      title: AppStrings.profileLogout,
                      isLogout: true,
                      isLoading: _isLoggingOut,
                      onTap: _isLoggingOut
                          ? null
                          : () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmDialog extends StatelessWidget {
  const _LogoutConfirmDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 32,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              AppStrings.profileLogout,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              AppStrings.profileLogoutConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      AppStrings.cancel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
