import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/leave_project.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late LeaveProjectUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = LeaveProjectUseCase(mockRepository);
  });

  group('LeaveProjectUseCase Tests', () {
    const ownerId = 'owner_user_id';
    const memberId = 'member_user_id';
    const projectId = 'project_123';

    test('9. A Member can leave a project successfully', () async {
      when(() => mockRepository.leaveProject(
            projectId: projectId,
            currentUserId: memberId,
          )).thenAnswer((_) async {});

      await useCase(
        projectId: projectId,
        ownerId: ownerId,
        currentUserId: memberId,
      );

      verify(() => mockRepository.leaveProject(
            projectId: projectId,
            currentUserId: memberId,
          )).called(1);
    });

    test('Owner cannot leave the project (throws ValidationException)', () async {
      expect(
        () => useCase(
          projectId: projectId,
          ownerId: ownerId,
          currentUserId: ownerId,
        ),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.leaveProject(
            projectId: any(named: 'projectId'),
            currentUserId: any(named: 'currentUserId'),
          ));
    });
  });
}
