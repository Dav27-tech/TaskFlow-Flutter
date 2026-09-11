import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/entities/project_member.dart';
import 'package:taskflow/features/projects/presentation/pages/project_details_page.dart';
import 'package:taskflow/features/projects/presentation/providers/project_provider.dart';

void main() {
  group('ProjectDetailsPage Widget Tests', () {
    const currentUserId = 'owner_uid_123';
    final now = DateTime.now();

    final testProject = Project(
      id: 'proj_detail_1',
      name: 'TaskFlow Flutter Clean Architecture',
      description: 'Production grade mobile app implementation',
      ownerId: currentUserId,
      invitationCode: 'TFMA-7X3K-QP2L',
      status: 'active',
      createdAt: now,
      updatedAt: now,
      tasksCount: 10,
      completedTasksCount: 7,
      membersCount: 3,
    );

    final testMembers = [
      ProjectMember(
        userId: currentUserId,
        role: 'owner',
        joinedAt: now,
        displayName: 'John Owner',
        email: 'john@taskflow.dev',
      ),
      ProjectMember(
        userId: 'member_uid_456',
        role: 'member',
        joinedAt: now,
        displayName: 'Sarah Member',
        email: 'sarah@taskflow.dev',
      ),
    ];

    testWidgets('2. Should display project summary, metrics and tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue(currentUserId),
            projectDetailsProvider('proj_detail_1').overrideWith((ref) => Future.value(testProject)),
            projectMembersStreamProvider('proj_detail_1').overrideWith((ref) => Stream.value(testMembers)),
          ],
          child: const MaterialApp(
            home: ProjectDetailsPage(projectId: 'proj_detail_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Project title and description
      expect(find.text('TaskFlow Flutter Clean Architecture'), findsWidgets);
      expect(find.text('Production grade mobile app implementation'), findsOneWidget);

      // Metrics
      expect(find.text('Tâches totales'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Terminées'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);

      // Tabs
      expect(find.text('Tâches'), findsOneWidget);
      expect(find.text('Membres'), findsWidgets);
    });
  });
}
