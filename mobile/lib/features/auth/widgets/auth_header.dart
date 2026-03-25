import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_style.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeader({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBackPressed ?? () => Navigator.maybePop(context),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Text(title, style: AppTextStyle.appBarTitle),
        ],
      ),
    );
  }
}
