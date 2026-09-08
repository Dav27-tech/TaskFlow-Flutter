import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0D14);
  static const surface = Color(0x14FFFFFF);
  static const surfaceBorder = Color(0x1FFFFFFF);
  static const textPrimary = Color(0xFFF3F5FA);
  static const textSecondary = Color(0xFF8B93A7);
  static const textFaint = Color(0xFF565E70);

  static const violet = Color(0xFF6C5CE7);
  static const cyan = Color(0xFF00D9F5);
  static const mint = Color(0xFF00E6A0);
  static const amber = Color(0xFFFFB020);
  static const coral = Color(0xFFFF5C7A);

  static const gradientPrimary = LinearGradient(
    colors: [violet, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
