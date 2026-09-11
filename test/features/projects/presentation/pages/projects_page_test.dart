import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/pages/projects_page.dart';
import 'package:taskflow/features/projects/presentation/providers/project_provider.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_card.dart';

void main() {
  group('ProjectsPage Widget Tests', () {
    const currentUserId = 'user_test_123';
    final now = DateTime.now();

    final testProjects = [
      Project(
        id: 'proj_1',
        name: 'Mobile App Redesign',
        description: 'Complete UI overhaul in Flutter',
        ownerId: currentUserId,
        invitationCode: 'TFMA-1111-2222',
        status: 'active',
        createdAt: now,
        updatedAt: now,
        tasksCount: 8,
        completedTasksCount: 4,
        membersCount: 3,
      ),
      Project(
        id: 'proj_2',
        name: 'Backend Microservices',
        description: 'Cloud Firestore and functions',
        ownerId: 'another_user',
        invitationCode: 'TFMA-3333-4444',
        status: 'in_progress',
        createdAt: now,
        updatedAt: now,
        tasksCount: 12,
        completedTasksCount: 6,
        membersCount: 2,
      ),
    ];

    testWidgets('1. Should display list of projects with ProjectCards and floating button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue(currentUserId),
            projectsStreamProvider.overrideWith((ref) => Stream.value(testProjects)),
          ],
          child: const MaterialApp(
            home: ProjectsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check AppBar title
      expect(find.text('Projets'), findsOneWidget);

      // Check Project items rendered
      expect(find.byType(ProjectCard), findsNWidgets(2));
      expect(find.text('Mobile App Redesign'), findsOneWidget);
      expect(find.text('Backend Microservices'), findsOneWidget);

      // Check Role badges
      expect(find.text('PROPRIÉTAIRE'), findsOneWidget);
      expect(find.text('MEMBRE'), findsOneWidget);

      // Check Floating Action Button
      expect(find.text('Nouveau projet'), findsOneWidget);
    });

    testWidgets('Should display empty state when user has no projects', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue(currentUserId),
            projectsStreamProvider.overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: ProjectsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun projet pour le moment'), findsOneWidget);
      expect(find.text('Créer un projet'), findsOneWidget);
    });
  });
}
