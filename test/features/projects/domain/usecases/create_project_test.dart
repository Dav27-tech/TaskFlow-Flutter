import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';
import 'package:taskflow/features/projects/domain/repositories/project_repository.dart';
import 'package:taskflow/features/projects/domain/usecases/create_project.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

void main() {
  late CreateProjectUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = CreateProjectUseCase(mockRepository);
  });

  group('CreateProjectUseCase & Owner Rules Tests', () {
    const userId = 'user_abc123';
    final now = DateTime.now();

    test('4. Should call repository to create project and return created project', () async {
      final expectedProject = Project(
        id: 'proj_new',
        name: 'TaskFlow App',
        description: 'New collaboration tool',
        ownerId: userId,
        invitationCode: 'TFMA-1111-2222',
        createdAt: now,
        updatedAt: now,
        memberIds: [userId],
      );

      when(() => mockRepository.createProject(
            name: any(named: 'name'),
            description: any(named: 'description'),
            currentUserId: any(named: 'currentUserId'),
            initialInvitationCode: any(named: 'initialInvitationCode'),
          )).thenAnswer((_) async => expectedProject);

      final result = await useCase(
        name: 'TaskFlow App',
        description: 'New collaboration tool',
        currentUserId: userId,
      );

      expect(result, equals(expectedProject));
      verify(() => mockRepository.createProject(
            name: 'TaskFlow App',
            description: 'New collaboration tool',
            currentUserId: userId,
            initialInvitationCode: any(named: 'initialInvitationCode'),
          )).called(1);
    });

    test('5. & 6. Verify ownerId equals currentUserId and owner role is preserved', () async {
      final createdProject = Project(
        id: 'proj_owner_check',
        name: 'Project Alpha',
        description: 'Desc',
        ownerId: userId,
        invitationCode: 'TFMA-9999-8888',
        createdAt: now,
        updatedAt: now,
        memberIds: [userId],
      );

      when(() => mockRepository.createProject(
            name: any(named: 'name'),
            description: any(named: 'description'),
            currentUserId: any(named: 'currentUserId'),
            initialInvitationCode: any(named: 'initialInvitationCode'),
          )).thenAnswer((_) async => createdProject);

      final result = await useCase(
        name: 'Project Alpha',
        description: 'Desc',
        currentUserId: userId,
      );

      // Owner verification
      expect(result.ownerId, equals(userId));
      expect(result.isOwner(userId), isTrue);
      expect(result.memberIds, contains(userId));
    });

    test('Should throw ValidationException when project name is empty', () async {
      expect(
        () => useCase(name: '   ', description: 'Desc', currentUserId: userId),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(() => mockRepository.createProject(
            name: any(named: 'name'),
            description: any(named: 'description'),
            currentUserId: any(named: 'currentUserId'),
          ));
    });

    test('Should throw AuthException when user is not authenticated', () async {
      expect(
        () => useCase(name: 'Project', description: 'Desc', currentUserId: ''),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
