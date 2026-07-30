import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Inscription : crée un compte anonyme + stocke les infos dans Firestore
  Future<AuthResult> inscription({
    required String nom,
    required String telephone,
    required String localite,
    required String pin,
  }) async {
    try {
      // Vérifier si le numéro est déjà utilisé
      final existing = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: telephone)
          .get();

      if (existing.docs.isNotEmpty) {
        return AuthResult.failure('Ce numéro de téléphone est déjà utilisé');
      }

      // Créer un compte anonyme (pas besoin d'email/password pour un PIN)
      final credential = await _auth.signInAnonymously();
      final uid = credential.user!.uid;

      // Stocker les données utilisateur dans Firestore
      final user = AppUser(
        uid: uid,
        nom: nom,
        telephone: telephone,
        localite: localite,
        pin: pin,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Une erreur est survenue. Réessayez.');
    }
  }

  // Connexion : cherche l'utilisateur par téléphone + vérifie le PIN
  Future<AuthResult> connexion({
    required String telephone,
    required String pin,
  }) async {
    try {
      // Chercher l'utilisateur par numéro de téléphone
      final query = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: telephone)
          .get();

      if (query.docs.isEmpty) {
        return AuthResult.failure('Aucun compte trouvé avec ce numéro');
      }

      final userData = query.docs.first.data();
      final storedPin = userData['pin'] as String;

      if (storedPin != pin) {
        return AuthResult.failure('Code PIN incorrect');
      }

      // Connecter l'utilisateur via Firebase Auth anonyme
      await _auth.signInAnonymously();

      final user = AppUser.fromMap(userData);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Une erreur est survenue. Réessayez.');
    }
  }

  // Connexion directe par PIN uniquement
  Future<AuthResult> connexionParPin({required String pin}) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('pin', isEqualTo: pin)
          .get();

      if (query.docs.isEmpty) {
        return AuthResult.failure('Code PIN incorrect');
      }

      final userData = query.docs.first.data();
      final originalUid = userData['uid'] as String;

      // Se connecter anonymement si pas déjà connecté
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      final currentUid = _auth.currentUser!.uid;

      // Si le uid Firebase Auth actuel diffère du uid stocké,
      // on doit mettre à jour le doc user ET les membresUids dans les tontines
      if (currentUid != originalUid) {
        final updatedData = Map<String, dynamic>.from(userData);
        updatedData['uid'] = currentUid;
        await _firestore.collection('users').doc(currentUid).set(updatedData);

        // Mettre à jour les tontines où l'ancien uid était membre
        final tontinesQuery = await _firestore
            .collection('tontines')
            .where('membresUids', arrayContains: originalUid)
            .get();

        for (final tontineDoc in tontinesQuery.docs) {
          await tontineDoc.reference.update({
            'membresUids': FieldValue.arrayRemove([originalUid]),
          });
          await tontineDoc.reference.update({
            'membresUids': FieldValue.arrayUnion([currentUid]),
          });
          // Si l'utilisateur est l'admin, mettre à jour adminUid aussi
          if (tontineDoc.data()['adminUid'] == originalUid) {
            await tontineDoc.reference.update({'adminUid': currentUid});
          }
        }

        // Mettre à jour les cotisations
        final cotisationsQuery = await _firestore
            .collection('cotisations')
            .where('userUid', isEqualTo: originalUid)
            .get();

        for (final cotDoc in cotisationsQuery.docs) {
          await cotDoc.reference.update({'userUid': currentUid});
        }

        // Mettre à jour les demandes
        final demandesQuery = await _firestore
            .collection('demandes')
            .where('userUid', isEqualTo: originalUid)
            .get();

        for (final demDoc in demandesQuery.docs) {
          await demDoc.reference.update({'userUid': currentUid});
        }
      }

      final user = AppUser.fromMap({...userData, 'uid': currentUid});
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.failure('Erreur: ${e.toString()}');
    }
  }

  // Récupérer l'utilisateur actuel depuis Firestore
  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromMap(doc.data()!);
  }

  // Chercher un utilisateur par téléphone (pour la connexion par PIN)
  Future<AppUser?> findUserByPhone(String telephone) async {
    final query = await _firestore
        .collection('users')
        .where('telephone', isEqualTo: telephone)
        .get();

    if (query.docs.isEmpty) return null;
    return AppUser.fromMap(query.docs.first.data());
  }

  // Déconnexion
  Future<void> deconnexion() async {
    await _auth.signOut();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'network-request-failed':
        return 'Pas de connexion internet';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final AppUser? user;
  final String? error;

  AuthResult._({required this.isSuccess, this.user, this.error});

  factory AuthResult.success(AppUser user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String error) =>
      AuthResult._(isSuccess: false, error: error);
}
