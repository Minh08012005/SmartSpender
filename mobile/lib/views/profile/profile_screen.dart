import 'package:flutter/material.dart';
import '../../core/strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
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
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xff2A7C76),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    AppStrings.profileDisplayName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    AppStrings.profileUsername,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _ProfileItem(
              icon: Icons.person,
              title: AppStrings.profilePersonalInfo,
            ),
            _ProfileItem(
              icon: Icons.lock,
              title: AppStrings.profileLoginSecurity,
            ),
            _ProfileItem(
              icon: Icons.notifications,
              title: AppStrings.profileNotifications,
            ),
            _ProfileItem(
              icon: Icons.privacy_tip,
              title: AppStrings.profilePrivacy,
            ),
            _ProfileItem(icon: Icons.logout, title: AppStrings.profileLogout),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff2A7C76)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
