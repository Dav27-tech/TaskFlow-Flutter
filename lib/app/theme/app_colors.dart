import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFFF7F9FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF1F5F9);
  static const surfaceBorder = Color(0xFFE3E8F0);
  static const textPrimary = Color(0xFF172033);
  static const textSecondary = Color(0xFF68748A);
  static const textFaint = Color(0xFFA0AABC);

  static const violet = Color(0xFF6C5CE7);
  static const cyan = Color(0xFF009FC2);
  static const mint = Color(0xFF16B981);
  static const amber = Color(0xFFF59E0B);
  static const coral = Color(0xFFEF476F);

  static const gradientPrimary = LinearGradient(
    colors: [violet, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
