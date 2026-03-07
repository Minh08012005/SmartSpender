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
  final FocusNode _focusNode = FocusNode();
  bool _hasStartedTyping = false;
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _hasStartedTyping && !_showValidation) {
      setState(() {
        _showValidation = true;
      });
    }
  }

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
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: _showValidation ? widget.validator : null,
      autovalidateMode: _showValidation
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(
                  color: fieldState.hasError
                      ? AppColors.textLink
                      : AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                enabled: widget.enabled,
                obscureText: widget.obscureText,
                onChanged: (value) {
                  if (!_hasStartedTyping) {
                    setState(() {
                      _hasStartedTyping = true;
                    });
                  }

                  fieldState.didChange(value);
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTextStyle.hint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: widget.suffixIcon,
                ),
              ),
            ),
            if (fieldState.hasError) ...[
              const SizedBox(height: 6),
              Text(
                fieldState.errorText!,
                style: AppTextStyle.subtitle.copyWith(color: AppColors.textLink),
              ),
            ],
          ],
        );
      },
    );
  }
}
