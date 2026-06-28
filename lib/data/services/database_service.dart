import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _usersRef => _db.collection('users');

  // Fetch user document from Firestore by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      rethrow;
    }
  }

  // Save or update user profile document in Firestore
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toFirestore());
    } catch (e) {
      debugPrint("Error saving user profile: $e");
      rethrow;
    }
  }
}
