import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static AppUser? currentAppUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<AppUser?> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    currentAppUser = AppUser.fromMap(doc.data()!);
    return currentAppUser;
  }

  void setCurrentUser(AppUser user) {
    currentAppUser = user;
  }

  Future<void> logout() async {
    currentAppUser = null;
    await _auth.signOut();
  }
}
