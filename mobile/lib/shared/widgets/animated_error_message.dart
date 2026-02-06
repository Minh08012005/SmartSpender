import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_style.dart';

class AnimatedErrorMessage extends StatelessWidget {
  final String? errorMessage;
  final Duration duration;

  const AnimatedErrorMessage({
    super.key,
    required this.errorMessage,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      height: errorMessage != null ? null : 0,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: duration,
        opacity: errorMessage != null ? 1.0 : 0.0,
        child: errorMessage != null
            ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(
                  errorMessage!,
                  style: AppTextStyle.subtitle.copyWith(
                    color: AppColors.textLink,
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
