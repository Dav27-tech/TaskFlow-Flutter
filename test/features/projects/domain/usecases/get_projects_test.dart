import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/get_projects.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late GetProjectsUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = GetProjectsUseCase(mockRepository);
  });

  group('GetProjectsUseCase Tests', () {
    test('7. Should stream list of projects for the current user', () async {
      final now = DateTime.now();
      final projects = [
        Project(
          id: 'proj_1',
          name: 'Project One',
          description: 'Desc 1',
          ownerId: 'user_1',
          invitationCode: 'TFMA-1111-2222',
          createdAt: now,
          updatedAt: now,
        ),
        Project(
          id: 'proj_2',
          name: 'Project Two',
          description: 'Desc 2',
          ownerId: 'user_other',
          invitationCode: 'TFMA-3333-4444',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(() => mockRepository.getProjects(userId: 'user_1'))
          .thenAnswer((_) => Stream.value(projects));

      final stream = useCase(userId: 'user_1');

      expect(
        stream,
        emits(projects),
      );
      verify(() => mockRepository.getProjects(userId: 'user_1')).called(1);
    });
  });
}
