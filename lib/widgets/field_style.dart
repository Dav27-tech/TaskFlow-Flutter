import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Builds the field label row, e.g. "Task Title *"
Widget fieldLabel(String label, {bool required = false}) {
  return RichText(
    text: TextSpan(
      text: label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.fieldErrorBorder),
          ),
      ],
    ),
  );
}

/// The 4 states a field can be in, matching the "États des champs" mockup.
enum FieldState { idle, active, valid, error }

Color borderColorFor(FieldState state) {
  switch (state) {
    case FieldState.idle:
      return AppColors.fieldIdleBorder;
    case FieldState.active:
      return AppColors.fieldActiveBorder;
    case FieldState.valid:
      return AppColors.fieldValidBorder;
    case FieldState.error:
      return AppColors.fieldErrorBorder;
  }
}

Widget? trailingIconFor(FieldState state) {
  switch (state) {
    case FieldState.valid:
      return const Icon(Icons.check_circle, color: AppColors.fieldValidBorder, size: 20);
    case FieldState.error:
      return const Icon(Icons.error, color: AppColors.fieldErrorBorder, size: 20);
    default:
      return null;
  }
}
