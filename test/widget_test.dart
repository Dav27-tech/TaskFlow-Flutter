import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/app/app.dart';

void main() {
  testWidgets('app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}
