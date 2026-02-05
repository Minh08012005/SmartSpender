import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static const welcomeTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    height: 1.17,
  );

  static const subtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const hint = TextStyle(
    color: AppColors.textHint,
    fontSize: 14,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const link = TextStyle(
    color: AppColors.textLink,
    fontSize: 12,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const buttonText = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const appBarTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}
