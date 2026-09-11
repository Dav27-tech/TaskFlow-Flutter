import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
import 'package:taskflow/features/projects/presentation/providers/project_provider.dart';
import 'package:taskflow/features/projects/presentation/widgets/project_menu.dart';

void main() {
  group('Project Permissions & Menu Actions Widget Tests', () {
    final now = DateTime.now();

    final testProject = Project(
      id: 'proj_perm_1',
      name: 'Permission Test Project',
      description: 'Testing Owner vs Member permissions',
      ownerId: 'owner_user_id',
      invitationCode: 'TFMA-1234-5678',
      status: 'active',
      createdAt: now,
      updatedAt: now,
    );

    testWidgets('3. Owner should see Manage Members, Edit, Delete and NOT Leave Project in menu', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('owner_user_id'), // Current user is OWNER
            projectDetailsProvider('proj_perm_1').overrideWith((ref) => Future.value(testProject)),
            projectMembersStreamProvider('proj_perm_1').overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: ProjectDetailsPage(projectId: 'proj_perm_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open the action menu
      final menuButton = find.byType(PopupMenuButton<ProjectMenuAction>);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Owner options must be visible
      expect(find.text('Modifier le projet'), findsOneWidget);
      expect(find.text('Gérer les membres'), findsOneWidget);
      expect(find.text('Exporter les tâches en JSON'), findsOneWidget);
      expect(find.text('Supprimer le projet'), findsOneWidget);

      // Leave Project must NOT be visible for Owner
      expect(find.text('Quitter le projet'), findsNothing);
    });

    testWidgets('4. & 5. Member should see Leave Project, Export JSON and NOT Manage Members / Edit / Delete', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('regular_member_id'), // Current user is MEMBER
            projectDetailsProvider('proj_perm_1').overrideWith((ref) => Future.value(testProject)),
            projectMembersStreamProvider('proj_perm_1').overrideWith((ref) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: ProjectDetailsPage(projectId: 'proj_perm_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open the action menu
      final menuButton = find.byType(PopupMenuButton<ProjectMenuAction>);
      expect(menuButton, findsOneWidget);
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // 4. Absence of Manage Members, Edit, Delete for Member
      expect(find.text('Gérer les membres'), findsNothing);
      expect(find.text('Modifier le projet'), findsNothing);
      expect(find.text('Supprimer le projet'), findsNothing);

      // 5. Affichage of Leave Project and Export JSON for Member
      expect(find.text('Quitter le projet'), findsOneWidget);
      expect(find.text('Exporter les tâches en JSON'), findsOneWidget);
    });
  });
}
