import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/strings.dart';
import '../../shared/widgets/section_reveal.dart';
import '../../theme/colors.dart';
import 'edit_profile_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? _fullName;
  String? _email;
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fullName = _normalizedValue(prefs.getString(ApiConstants.fullNameKey));
        _email = _normalizedValue(prefs.getString(ApiConstants.userEmailKey));
        _username = _normalizedValue(prefs.getString(ApiConstants.usernameKey));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _normalizedValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    ).then((_) {
      // Reload user data when returning from edit profile
      _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.profilePersonalInfo,
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
                  child: Column(
                    children: [
                      // ===== SECTION 1: FULL NAME =====
                      SectionReveal(
                        delayMs: 0,
                        child: _PersonalInfoCard(
                          label: 'Họ và tên',
                          value: _fullName ?? 'Chưa cập nhật',
                          icon: Icons.person_outline,
                          isEmpty: _fullName == null || _fullName!.isEmpty,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== SECTION 2: EMAIL =====
                      SectionReveal(
                        delayMs: 100,
                        child: _PersonalInfoCard(
                          label: 'Email',
                          value: _email ?? 'Chưa cập nhật',
                          icon: Icons.email_outlined,
                          isEmpty: _email == null || _email!.isEmpty,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== SECTION 3: USERNAME =====
                      SectionReveal(
                        delayMs: 200,
                        child: _PersonalInfoCard(
                          label: 'Tên người dùng',
                          value: _username ?? 'Chưa cập nhật',
                          icon: Icons.account_box_outlined,
                          isEmpty: _username == null || _username!.isEmpty,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ===== EDIT BUTTON =====
                      SectionReveal(
                        delayMs: 300,
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _navigateToEditProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text(AppStrings.profileEditInfo),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== INFO TEXT =====
                      SectionReveal(
                        delayMs: 400,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outlined,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Hãy cập nhật thông tin cá nhân của bạn để có trải nghiệm tốt hơn.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade800,
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
    );
  }
}

/// ===== PERSONAL INFO CARD WIDGET =====
class _PersonalInfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEmpty;

  const _PersonalInfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff999999),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Value
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isEmpty ? Colors.grey.shade500 : Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
