import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';

class SessionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static AppUser? currentAppUser;

  bool get isLoggedIn => _auth.currentUser != null && currentAppUser != null;

  Future<AppUser?> loadCurrentUser() async {
    if (currentAppUser != null) return currentAppUser;

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        currentAppUser = AppUser.fromMap(doc.data()!);
        // Lancer la migration en arrière-plan sans bloquer
        _migrateOldUids(currentAppUser!);
        return currentAppUser;
      }
    } catch (e) {
      debugPrint('SessionService.loadCurrentUser error: $e');
    }

    return null;
  }

  Future<void> _migrateOldUids(AppUser currentUser) async {
    try {
      final oldDocs = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: currentUser.telephone)
          .get();

      for (final oldDoc in oldDocs.docs) {
        final oldUid = oldDoc.data()['uid'] as String;
        if (oldUid == currentUser.uid) continue;

        final tontines = await _firestore
            .collection('tontines')
            .where('membresUids', arrayContains: oldUid)
            .get();

        for (final t in tontines.docs) {
          await t.reference.update({
            'membresUids': FieldValue.arrayRemove([oldUid]),
          });
          await t.reference.update({
            'membresUids': FieldValue.arrayUnion([currentUser.uid]),
          });
          if (t.data()['adminUid'] == oldUid) {
            await t.reference.update({'adminUid': currentUser.uid});
          }
        }

        final cotisations = await _firestore
            .collection('cotisations')
            .where('userUid', isEqualTo: oldUid)
            .get();
        for (final c in cotisations.docs) {
          await c.reference.update({'userUid': currentUser.uid});
        }

        final demandes = await _firestore
            .collection('demandes')
            .where('userUid', isEqualTo: oldUid)
            .get();
        for (final d in demandes.docs) {
          await d.reference.update({'userUid': currentUser.uid});
        }

        // Supprimer l'ancien doc utilisateur
        if (oldDoc.id != currentUser.uid) {
          await _firestore.collection('users').doc(oldDoc.id).delete();
        }
      }
    } catch (e) {
      debugPrint('SessionService._migrateOldUids error: $e');
    }
  }

  void setCurrentUser(AppUser user) {
    currentAppUser = user;
  }

  Future<void> logout() async {
    currentAppUser = null;
    await _auth.signOut();
  }
}
