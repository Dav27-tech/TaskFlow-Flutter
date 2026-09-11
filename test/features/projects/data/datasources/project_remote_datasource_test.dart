import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/constants/app_constants.dart';
import 'package:taskflow/features/projects/data/datasources/project_remote_datasource.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late ProjectRemoteDataSourceImpl dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    final mockUser = MockUser(
      uid: 'user_owner_123',
      displayName: 'Alice Owner',
      email: 'alice@example.com',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    dataSource = ProjectRemoteDataSourceImpl(
      firestore: fakeFirestore,
      auth: mockAuth,
    );
  });

  group('ProjectRemoteDataSource Atomic WriteBatch Tests', () {
    test('createProject should write project and owner member doc atomically in Firestore', () async {
      final project = await dataSource.createProject(
        name: 'Atomic Project',
        description: 'Testing WriteBatch atomic commit',
        currentUserId: 'user_owner_123',
        invitationCode: 'TFMA-ATOM-1234',
      );

      expect(project.id, isNotEmpty);
      expect(project.ownerId, equals('user_owner_123'));
      expect(project.invitationCode, equals('TFMA-ATOM-1234'));

      // Check project doc in Firestore
      final projectDoc = await fakeFirestore
          .collection(AppConstants.projectsCollection)
          .doc(project.id)
          .get();

      expect(projectDoc.exists, isTrue);
      expect(projectDoc.data()?['name'], equals('Atomic Project'));
      expect(projectDoc.data()?['ownerId'], equals('user_owner_123'));
      expect(projectDoc.data()?['memberIds'], contains('user_owner_123'));

      // Check subcollection member doc in Firestore
      final memberDoc = await fakeFirestore
          .collection(AppConstants.projectsCollection)
          .doc(project.id)
          .collection(AppConstants.membersSubcollection)
          .doc('user_owner_123')
          .get();

      expect(memberDoc.exists, isTrue);
      expect(memberDoc.data()?['role'], equals('owner'));
      expect(memberDoc.data()?['userId'], equals('user_owner_123'));
      expect(memberDoc.data()?['displayName'], equals('Alice Owner'));
    });
  });
}
