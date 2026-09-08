import 'package:flutter/material.dart';
import 'app/theme/app_colors.dart';
import 'features/dashboard/presentation/dashboard_page.dart';

void main() => runApp(const TaskFlowApp());

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TaskFlow',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.bg, colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet)),
    home: const DashboardPage(),
  );
}
