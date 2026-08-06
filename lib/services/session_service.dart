import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static AppUser? currentAppUser;

  bool get isLoggedIn => _auth.currentUser != null;

  Future<AppUser?> loadCurrentUser() async {
    if (currentAppUser != null) return currentAppUser;

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // D'abord chercher par le uid Firebase Auth (cas inscription)
      var doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        currentAppUser = AppUser.fromMap(doc.data()!);
        return currentAppUser;
      }

      // Sinon chercher tous les users et trouver celui qui match
      // (cas reconnexion avec un nouveau uid Firebase Auth)
      // On ne peut pas trouver sans info supplémentaire, retourner null
      // L'utilisateur devra se reconnecter via PIN
    } catch (e) {
      debugPrint('SessionService.loadCurrentUser error: $e');
    }

    return null;
  }

  void setCurrentUser(AppUser user) {
    currentAppUser = user;
  }

  Future<void> logout() async {
    currentAppUser = null;
    await _auth.signOut();
  }
}
