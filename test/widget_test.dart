import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app/app.dart';
import 'package:taskflow/features/projects/presentation/providers/project_provider.dart';

void main() {
  testWidgets('TaskFlowApp initial smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('test_user'),
          projectsStreamProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const TaskFlowApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Projets'), findsOneWidget);
  });
}
