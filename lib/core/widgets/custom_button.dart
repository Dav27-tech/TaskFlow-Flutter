import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final themeColor = backgroundColor ?? const Color(0xFF2878E8);
    final foregroundColor = isOutlined ? themeColor : Colors.white;
    final fillColor = isOutlined ? Colors.transparent : themeColor;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isOutlined ? themeColor : Colors.white,
                ),
              )
            : (icon != null ? Icon(icon, size: 18) : const SizedBox.shrink()),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: fillColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: themeColor.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isOutlined ? BorderSide(color: themeColor, width: 1.2) : BorderSide.none,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
    );
  }
}
