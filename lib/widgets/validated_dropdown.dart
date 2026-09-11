import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'field_style.dart';

class DropdownOption<T> {
  final T value;
  final String label;
  final Widget? leading;
  const DropdownOption({required this.value, required this.label, this.leading});
}

/// A select field styled like the mockup's dropdowns (project, member,
/// priority, status), with the same idle/active/valid/error treatment as
/// [ValidatedTextField].
class ValidatedDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownOption<T>> options;
  final bool required;
  final ValueChanged<T?> onChanged;
  final bool showError;

  const ValidatedDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.value,
    this.required = true,
    this.showError = false,
  });

  @override
  State<ValidatedDropdown<T>> createState() => ValidatedDropdownState<T>();
}

class ValidatedDropdownState<T> extends State<ValidatedDropdown<T>> {
  bool _open = false;

  FieldState get _state {
    if (_open) return FieldState.active;
    if (widget.value == null && widget.showError) return FieldState.error;
    if (widget.value != null) return FieldState.valid;
    return FieldState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final selected = widget.options
        .where((o) => o.value == widget.value)
        .cast<DropdownOption<T>?>()
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(widget.label, required: widget.required),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            setState(() => _open = true);
            final result = await showModalBottomSheet<T>(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.label.replaceAll('*', '').trim(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: widget.options
                            .map((o) => ListTile(
                                  leading: o.leading,
                                  title: Text(o.label),
                                  trailing: widget.value == o.value
                                      ? const Icon(Icons.check, color: AppColors.primary)
                                      : null,
                                  onTap: () => Navigator.of(ctx).pop(o.value),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
            setState(() => _open = false);
            if (result != null) widget.onChanged(result);
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
                if (selected?.leading != null) ...[
                  selected!.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    selected?.label ?? widget.hint,
                    style: TextStyle(
                      fontSize: 15,
                      color: selected == null ? AppColors.placeholder : AppColors.textPrimary,
                    ),
                  ),
                ),
                trailingIconFor(state) ??
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        if (state == FieldState.error) ...[
          const SizedBox(height: 4),
          Text(
            '${widget.label.replaceAll('*', '').trim()} is required',
            style: const TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
