import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String boardId) {
    return _db
        .collection('boards')
        .doc(boardId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendMessage({
    required String boardId,
    required String text,
    required String userName,
  }) async {
    await _db
        .collection('boards')
        .doc(boardId)
        .collection('messages')
        .add({
      'text': text,
      'userName': userName,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
