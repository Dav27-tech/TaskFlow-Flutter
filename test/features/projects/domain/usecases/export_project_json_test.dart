import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/services/share_service.dart';
import 'package:taskflow/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/projects/data/repositories/project_repository_impl.dart';
import 'package:taskflow/features/tasks/data/models/task_model.dart';

class MockProjectRemoteDataSource extends Mock implements ProjectRemoteDataSource {}
class MockShareService extends Mock implements ShareService {}

void main() {
  late ProjectRepositoryImpl repository;
  late MockProjectRemoteDataSource mockRemoteDataSource;
  late MockShareService mockShareService;

  setUp(() {
    mockRemoteDataSource = MockProjectRemoteDataSource();
    mockShareService = MockShareService();
    repository = ProjectRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      shareService: mockShareService,
    );
  });

  group('ExportProjectJson Tests', () {
    const projectId = 'proj_export_123';
    final now = DateTime.utc(2026, 9, 8, 20, 0, 0);

    test('10. Should generate formatted 2-space indented JSON with project & tasks', () async {
      final project = ProjectModel(
        id: projectId,
        name: 'TaskFlow Architecture',
        description: 'Clean Arch implementation',
        ownerId: 'owner_user_1',
        invitationCode: 'TFMA-7X3K-QP2L',
        status: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final tasks = [
        TaskModel(
          id: 'task_1',
          projectId: projectId,
          title: 'Implement Clean Arch',
          description: 'Create domain and data layers',
          status: 'completed',
          priority: 'high',
          dueDate: DateTime.utc(2026, 9, 10),
          assignedTo: 'owner_user_1',
          createdAt: now,
          updatedAt: now,
        ),
        TaskModel(
          id: 'task_2',
          projectId: projectId,
          title: 'Write Unit Tests',
          description: 'Achieve 100% coverage',
          status: 'todo',
          priority: 'medium',
          dueDate: DateTime.utc(2026, 9, 12),
          assignedTo: 'member_user_2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => mockRemoteDataSource.getProject(projectId))
          .thenAnswer((_) async => project);
      when(() => mockRemoteDataSource.getTasksForProject(projectId))
          .thenAnswer((_) async => tasks);
      when(() => mockShareService.shareJsonFile(
            jsonContent: any(named: 'jsonContent'),
            fileName: any(named: 'fileName'),
            subject: any(named: 'subject'),
            text: any(named: 'text'),
          )).thenAnswer((_) async {});

      await repository.exportProjectJson(projectId: projectId);

      // Verify shareJsonFile was called
      final captured = verify(() => mockShareService.shareJsonFile(
            jsonContent: captureAny(named: 'jsonContent'),
            fileName: 'project_tasks.json',
            subject: any(named: 'subject'),
            text: any(named: 'text'),
          )).captured;

      final jsonContent = captured.first as String;
      expect(jsonContent, isNotEmpty);

      // Verify JSON format structure
      final decoded = json.decode(jsonContent) as Map<String, dynamic>;
      expect(decoded.containsKey('project'), isTrue);
      expect(decoded.containsKey('exportedAt'), isTrue);
      expect(decoded.containsKey('tasks'), isTrue);

      final projectData = decoded['project'] as Map<String, dynamic>;
      expect(projectData['id'], equals(projectId));
      expect(projectData['name'], equals('TaskFlow Architecture'));
      expect(projectData['description'], equals('Clean Arch implementation'));
      expect(projectData['ownerId'], equals('owner_user_1'));

      final tasksList = decoded['tasks'] as List;
      expect(tasksList.length, equals(2));
      expect(tasksList[0]['title'], equals('Implement Clean Arch'));
      expect(tasksList[0]['status'], equals('completed'));
      expect(tasksList[1]['title'], equals('Write Unit Tests'));

      // Check 2-space indentation format
      expect(jsonContent.contains('  "project": {'), isTrue);
      expect(jsonContent.contains('  "tasks": ['), isTrue);
    });
  });
}
