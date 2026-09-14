import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'field_style.dart';

/// A text field that validates on every keystroke (per the
/// "Affichage d'erreur en temps réel" rule) and renders the idle / active /
/// valid / error states shown in the "États des champs" mockup.
class ValidatedTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final String? Function(String) validator;
  final ValueChanged<bool>? onValidityChanged;

  const ValidatedTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.required = true,
    this.maxLines = 1,
    this.onValidityChanged,
  });

  @override
  State<ValidatedTextField> createState() => ValidatedTextFieldState();
}

class ValidatedTextFieldState extends State<ValidatedTextField> {
  final FocusNode _focusNode = FocusNode();
  String? _error;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_validate);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      setState(() => _touched = true);
    }
    setState(() {});
  }

  void _validate() {
    final result = widget.validator(widget.controller.text);
    setState(() => _error = result);
    widget.onValidityChanged?.call(result == null);
  }

  /// Forces validation + shows errors, used when the user hits submit.
  bool validateNow() {
    setState(() => _touched = true);
    _validate();
    return _error == null;
  }

  FieldState get _state {
    if (_focusNode.hasFocus) return FieldState.active;
    if (_error != null && _touched) return FieldState.error;
    if (widget.controller.text.isNotEmpty && _error == null) {
      return FieldState.valid;
    }
    return FieldState.idle;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_validate);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        fieldLabel(widget.label, required: widget.required),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.placeholder, fontSize: 15),
            filled: state == FieldState.error,
            fillColor: AppColors.fieldErrorBg,
            suffixIcon: trailingIconFor(state),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColorFor(FieldState.idle)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColorFor(state), width: state == FieldState.idle ? 1 : 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColorFor(FieldState.active), width: 1.4),
            ),
          ),
        ),
        if (state == FieldState.error && _error != null) ...[
          const SizedBox(height: 4),
          Text(
            _error!,
            style: const TextStyle(color: AppColors.fieldErrorBorder, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
