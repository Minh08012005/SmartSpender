import 'package:flutter/material.dart';
import '../../../theme/colors.dart';
import 'custom_text_field.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool forceValidation;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.enabled = true,
    this.forceValidation = false,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      validator: widget.validator,
      enabled: widget.enabled,
      obscureText: _obscureText,
      forceValidation: widget.forceValidation,
      suffixIcon: IconButton(
        onPressed: _toggleVisibility,
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }
}
