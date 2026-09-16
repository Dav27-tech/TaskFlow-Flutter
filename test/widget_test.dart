import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/app/app.dart';
import 'package:task_flow/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  testWidgets('app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    expect(find.byType(TaskFlowApp), findsOneWidget);
  });

  testWidgets('notifications page shows French labels and notification content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsPage(),
      ),
    );

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Tout marquer comme lu'), findsOneWidget);
    expect(find.text('Nouvelle tâche assignée'), findsOneWidget);
    expect(find.text('Vous avez été assigné à une nouvelle tâche dans le projet « Marketing ».') , findsOneWidget);
  });
}
