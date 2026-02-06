import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

class SmoothPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Duration animationDuration;

  const SmoothPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      width: width ?? double.infinity,
      height: height,
      curve: Curves.easeInOut,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? AppColors.primaryButton.withValues(alpha: 0.7)
              : AppColors.primaryButton,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isLoading
                  ? AppColors.primaryButton.withValues(alpha: 0.7)
                  : AppColors.primaryButton,
              width: 1,
            ),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: AnimatedSwitcher(
          duration: animationDuration,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Text(text, style: AppTextStyle.buttonText),
        ),
      ),
    );
  }
}
