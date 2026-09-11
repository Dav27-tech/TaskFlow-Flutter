import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/tasks_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TaskManagementApp());
}

class TaskManagementApp extends StatelessWidget {
  const TaskManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'TaskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const TasksListScreen(),
      ),
    );
  }
}