import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/remove_member.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late RemoveMemberUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = RemoveMemberUseCase(mockRepository);
  });

  group('RemoveMemberUseCase Tests', () {
    const ownerId = 'owner_user_id';
    const memberId = 'member_user_id';
    const projectId = 'project_123';

    test('8. Owner can remove a project member', () async {
      when(() => mockRepository.removeMember(
            projectId: projectId,
            memberId: memberId,
            currentUserId: ownerId,
          )).thenAnswer((_) async {});

      await useCase(
        projectId: projectId,
        memberId: memberId,
        ownerId: ownerId,
        currentUserId: ownerId,
      );

      verify(() => mockRepository.removeMember(
            projectId: projectId,
            memberId: memberId,
            currentUserId: ownerId,
          )).called(1);
    });

    test('Non-owner cannot remove a member (throws PermissionDeniedException)', () async {
      expect(
        () => useCase(
          projectId: projectId,
          memberId: memberId,
          ownerId: ownerId,
          currentUserId: 'another_user',
        ),
        throwsA(isA<PermissionDeniedException>()),
      );
      verifyNever(() => mockRepository.removeMember(
            projectId: any(named: 'projectId'),
            memberId: any(named: 'memberId'),
            currentUserId: any(named: 'currentUserId'),
          ));
    });

    test('Owner cannot remove himself (throws ValidationException)', () async {
      expect(
        () => useCase(
          projectId: projectId,
          memberId: ownerId,
          ownerId: ownerId,
          currentUserId: ownerId,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
