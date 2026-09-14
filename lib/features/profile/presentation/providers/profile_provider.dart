import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    throw Exception('Aucun utilisateur connecté.');
  }

  final userDocument = await FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .get();

  final data = userDocument.data() ?? {};

  return {
    'id': firebaseUser.uid,
    'displayName':
        data['displayName'] ?? firebaseUser.displayName ?? 'Utilisateur',
    'email': data['email'] ?? firebaseUser.email ?? '',
    'photoUrl': data['photoUrl'] ?? '',
    'createdAt': data['createdAt'],
  };
});
