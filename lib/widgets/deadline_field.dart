import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'field_style.dart';

class DeadlineField extends StatelessWidget {
  final DateTime? value;
  final bool showError;
  final ValueChanged<DateTime> onChanged;

  const DeadlineField({
    super.key,
    required this.value,
    required this.onChanged,
    this.showError = false,
  });

  FieldState get _state {
    if (value == null && showError) return FieldState.error;
    if (value != null) return FieldState.valid;
    return FieldState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel('Deadline', required: true),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(now.year, now.month, now.day),
              lastDate: DateTime(now.year + 3),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: state == FieldState.error ? AppColors.fieldErrorBg : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColorFor(state),
                width: state == FieldState.idle ? 1 : 1.4,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value == null ? 'Select deadline' : DateFormat('MMM d, y').format(value!),
                    style: TextStyle(
                      fontSize: 15,
                      color: value == null ? AppColors.placeholder : AppColors.textPrimary,
                    ),
                  ),
                ),
                trailingIconFor(state) ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        if (state == FieldState.error) ...[
          const SizedBox(height: 4),
          const Text(
            'Deadline is required',
            style: TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
