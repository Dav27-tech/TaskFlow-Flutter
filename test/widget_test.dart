import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:task_flow/app/app.dart';
import 'package:task_flow/features/notifications/presentation/pages/notifications_page.dart';
import 'package:task_flow/features/profile/presentation/pages/profile_page.dart';
import 'package:task_flow/features/profile/presentation/providers/profile_provider.dart';

void main() {
  testWidgets('app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    expect(find.byType(TaskFlowApp), findsOneWidget);
  });

  testWidgets(
    'notifications page shows French labels and notification content',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: NotificationsPage())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Aucune notification'), findsOneWidget);
      expect(
        find.text('Vous n’avez pas encore de nouvelles notifications.'),
        findsOneWidget,
      );
      expect(find.text('Tout marquer comme lu'), findsNothing);
      expect(find.text('Nouvelle tâche assignée'), findsNothing);
    },
  );

  testWidgets('profile edit can be cancelled safely', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileProvider.overrideWith(
            (ref) async => {
              'displayName': 'Utilisateur Test',
              'email': 'test@example.com',
              'createdAt': null,
            },
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    final editProfileFinder = find.text('Modifier le profil');
    await tester.ensureVisible(editProfileFinder);
    await tester.tap(editProfileFinder);
    await tester.pumpAndSettle();
    expect(find.text('Modifier le profil'), findsNWidgets(2));

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.text('Enregistrer'), findsNothing);
  });
}
