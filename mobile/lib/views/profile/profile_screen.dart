import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/strings.dart';
import '../../core/constants/api_constants.dart';
import '../../data/providers/transaction_provider.dart';
import '../../services/auth_service.dart';
import '../../screens/login.dart';

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

  String _resolveSubtitle(SharedPreferences prefs, String displayName) {
    final email = _nonEmpty(prefs.getString(ApiConstants.userEmailKey));
    return email ?? AppStrings.profileUsername;
  }

  // ===== LOGOUT FUNCTION =====
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService.clearSession();

      if (!mounted) return;

      Provider.of<TransactionProvider>(context, listen: false).reset();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đăng xuất lúc này, vui lòng thử lại.'),
        ),
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
  Future<void> _confirmLogout(BuildContext context) async {
    if (_isLoggingOut) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.profileLogout),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.profileLogout),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                decoration: const BoxDecoration(
                  color: Color(0xff2A7C76),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final prefs = snapshot.data!;
                    final displayName = _resolveDisplayName(prefs);
                    final subtitle = _resolveSubtitle(prefs, displayName);

                    return Column(
                      children: [
                        const CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xff2A7C76),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ===== MENU =====
              _ProfileItem(
                icon: Icons.person,
                title: AppStrings.profilePersonalInfo,
                onTap: () {},
              ),
              _ProfileItem(
                icon: Icons.lock,
                title: AppStrings.profileLoginSecurity,
                onTap: () {},
              ),
              _ProfileItem(
                icon: Icons.notifications,
                title: AppStrings.profileNotifications,
                onTap: () {},
              ),
              _ProfileItem(
                icon: Icons.privacy_tip,
                title: AppStrings.profilePrivacy,
                onTap: () {},
              ),

              // ===== LOGOUT =====
              _ProfileItem(
                icon: Icons.logout,
                title: AppStrings.profileLogout,
                isLogout: true,
                isLoading: _isLoggingOut,
                onTap: _isLoggingOut ? null : () => _confirmLogout(context),
              ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red : const Color(0xff2A7C76),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.red : Colors.black,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
