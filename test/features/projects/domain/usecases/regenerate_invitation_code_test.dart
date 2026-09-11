import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/regenerate_invitation_code.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late RegenerateInvitationCodeUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = RegenerateInvitationCodeUseCase(mockRepository);
  });

  group('RegenerateInvitationCodeUseCase Tests', () {
    const ownerId = 'owner_user_id';
    const nonOwnerId = 'another_user_id';
    const projectId = 'project_123';
    const newCode = 'TFMA-9X8Y-7Z6W';

    test('Owner can regenerate the invitation code', () async {
      when(() => mockRepository.regenerateInvitationCode(
            projectId: projectId,
            currentUserId: ownerId,
          )).thenAnswer((_) async => newCode);

      final result = await useCase(
        projectId: projectId,
        ownerId: ownerId,
        currentUserId: ownerId,
      );

      expect(result, equals(newCode));
      verify(() => mockRepository.regenerateInvitationCode(
            projectId: projectId,
            currentUserId: ownerId,
          )).called(1);
    });

    test('Non-owner cannot regenerate code (throws PermissionDeniedException)', () async {
      expect(
        () => useCase(
          projectId: projectId,
          ownerId: ownerId,
          currentUserId: nonOwnerId,
        ),
        throwsA(isA<PermissionDeniedException>()),
      );
      verifyNever(() => mockRepository.regenerateInvitationCode(
            projectId: any(named: 'projectId'),
            currentUserId: any(named: 'currentUserId'),
          ));
    });
  });
}
