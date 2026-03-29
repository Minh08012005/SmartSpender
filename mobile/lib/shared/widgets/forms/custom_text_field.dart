import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import '../../../theme/text_style.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool forceValidation;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
    this.obscureText = false,
    this.forceValidation = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _hasStartedTyping = false;
  bool _showValidation = false;

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceValidation && !oldWidget.forceValidation) {
      setState(() {
        _showValidation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      validator: _showValidation ? widget.validator : null,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      autovalidateMode: _showValidation
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      onChanged: (value) {
        if (!_hasStartedTyping) {
          setState(() {
            _hasStartedTyping = true;
          });
        }
      },
      onTapOutside: (_) {
        if (_hasStartedTyping) {
          setState(() {
            _showValidation = true;
          });
        }
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyle.hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.textLink, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.textLink, width: 1.2),
        ),
        errorStyle: AppTextStyle.subtitle.copyWith(color: AppColors.textLink),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}
