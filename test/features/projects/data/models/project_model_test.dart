import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/projects/data/models/project_model.dart';
import 'package:taskflow/features/projects/domain/entities/project.dart';

void main() {
  group('ProjectModel Tests', () {
    final now = DateTime.now();

    test('2. ProjectModel.fromFirestore should properly convert Firestore snapshot', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final docRef = await fakeFirestore.collection('projects').add({
        'name': 'Test Project',
        'description': 'Test Description',
        'ownerId': 'user_123',
        'invitationCode': 'TFMA-7X3K-QP2L',
        'status': 'active',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'memberIds': ['user_123', 'user_456'],
        'tasksCount': 10,
        'completedTasksCount': 5,
        'membersCount': 2,
      });

      final snapshot = await docRef.get();
      final model = ProjectModel.fromFirestore(snapshot);

      expect(model.id, equals(docRef.id));
      expect(model.name, equals('Test Project'));
      expect(model.description, equals('Test Description'));
      expect(model.ownerId, equals('user_123'));
      expect(model.invitationCode, equals('TFMA-7X3K-QP2L'));
      expect(model.status, equals('active'));
      expect(model.memberIds, containsAll(['user_123', 'user_456']));
      expect(model.tasksCount, equals(10));
      expect(model.completedTasksCount, equals(5));
      expect(model.progressPercentage, equals(50));
      expect(model.isOwner('user_123'), isTrue);
      expect(model.isOwner('user_456'), isFalse);
    });

    test('3. ProjectModel.toFirestore should return proper Map for Firestore saving', () {
      final project = Project(
        id: 'proj_1',
        name: 'New App',
        description: 'App Description',
        ownerId: 'owner_999',
        invitationCode: 'TFMA-AAAA-BBBB',
        status: 'active',
        createdAt: now,
        updatedAt: now,
        memberIds: ['owner_999'],
      );

      final model = ProjectModel.fromEntity(project);
      final map = model.toFirestore();

      expect(map['name'], equals('New App'));
      expect(map['description'], equals('App Description'));
      expect(map['ownerId'], equals('owner_999'));
      expect(map['invitationCode'], equals('TFMA-AAAA-BBBB'));
      expect(map['status'], equals('active'));
      expect(map['memberIds'], equals(['owner_999']));
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
    });
  });
}
