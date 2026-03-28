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
              // TODO: Navigate to notifications
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

                      return _ProfileHeader(
                        displayName: displayName,
                        subtitle: subtitle,
                        avatarText: avatarText,
                        onEdit: () {
                          // TODO: Navigate to edit profile screen when available.
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
                child: _ProfileMenuSection(
                  items: [
                    _ProfileItem(
                      icon: Icons.account_circle_outlined,
                      title: AppStrings.profilePersonalInfo,
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.lock_outline,
                      title: AppStrings.profileLoginSecurity,
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.notifications_none,
                      title: AppStrings.profileNotifications,
                      onTap: () {},
                    ),
                    _ProfileItem(
                      icon: Icons.privacy_tip_outlined,
                      title: AppStrings.profilePrivacy,
                      onTap: () {},
                    ),
                    _ProfileItem(
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

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String subtitle;
  final String avatarText;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.displayName,
    required this.subtitle,
    required this.avatarText,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          right: -32,
          top: -24,
          child: _HeaderAccentCircle(size: 120, opacity: 0.12),
        ),
        const Positioned(
          left: -20,
          bottom: -34,
          child: _HeaderAccentCircle(size: 92, opacity: 0.1),
        ),
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: Color(0xff2A7C76),
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.86),
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text(AppStrings.profileEdit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderAccentCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _HeaderAccentCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  final List<Widget> items;

  const _ProfileMenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.surfaceBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              items[i],
              if (i != items.length - 1)
                const Divider(height: 10, color: Color(0x14000000)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLogout;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.isLogout = false,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isLogout ? Colors.red : const Color(0xff2A7C76);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: accentColor.withValues(alpha: 0.14),
        highlightColor: accentColor.withValues(alpha: 0.08),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    color: isLogout ? Colors.red.shade700 : Colors.black87,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
