import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ===== SPACING =====
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // ===== BORDER RADIUS =====
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 15.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 30.0;

  // ===== ANIMATION DURATIONS =====
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ===== BUTTON DIMENSIONS =====
  static const double buttonHeight = 52.0;
  static const double textFieldHeight = 44.0;

  // ===== COMMON PADDINGS =====
  static const EdgeInsets paddingScreenHorizontal = EdgeInsets.symmetric(
    horizontal: paddingLarge,
  );
  static const EdgeInsets paddingScreenAll = EdgeInsets.all(paddingLarge);
  static const EdgeInsets paddingFormFields = EdgeInsets.symmetric(
    horizontal: paddingLarge,
    vertical: paddingExtraLarge,
  );
}
