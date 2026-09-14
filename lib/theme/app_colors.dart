import 'package:flutter/material.dart';

/// Central color palette, matched to the provided mockups.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF7F8FA);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color placeholder = Color(0xFF9CA3AF);

  // Priority colors
  static const Color priorityHighBg = Color(0xFFFDE2E2);
  static const Color priorityHighFg = Color(0xFFDC2626);
  static const Color priorityMediumBg = Color(0xFFFFEACC);
  static const Color priorityMediumFg = Color(0xFFF59E0B);
  static const Color priorityLowBg = Color(0xFFDCFCE7);
  static const Color priorityLowFg = Color(0xFF16A34A);

  // Status colors
  static const Color statusTodoBg = Color(0xFFDCEAFE);
  static const Color statusTodoFg = Color(0xFF2563EB);
  static const Color statusInProgressBg = Color(0xFFFFEACC);
  static const Color statusInProgressFg = Color(0xFFF59E0B);
  static const Color statusCompletedBg = Color(0xFFDCFCE7);
  static const Color statusCompletedFg = Color(0xFF16A34A);

  // Field states
  static const Color fieldIdleBorder = Color(0xFFE5E7EB);
  static const Color fieldActiveBorder = primary;
  static const Color fieldValidBorder = Color(0xFF16A34A);
  static const Color fieldErrorBorder = Color(0xFFDC2626);
  static const Color fieldErrorBg = Color(0xFFFEF2F2);
}
