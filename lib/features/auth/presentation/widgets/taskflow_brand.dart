import 'package:flutter/material.dart';

class TaskFlowBrand extends StatelessWidget {
  const TaskFlowBrand({
    super.key,
    this.compact = false,
    this.assetPath = 'assets/logo/taskflow-illustration.svg',
  });

  final bool compact;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 64.0 : 76.0;
    final titleSize = compact ? 34.0 : 38.0;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          padding: EdgeInsets.all(compact ? 5 : 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FF),
            borderRadius: BorderRadius.circular(compact ? 18 : 22),
          ),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
        SizedBox(width: compact ? 12 : 16),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: const Color(0xFF14213D),
            ),
            children: const [
              TextSpan(text: 'Task'),
              TextSpan(
                text: 'Flow',
                style: TextStyle(color: Color(0xFF2878E8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
