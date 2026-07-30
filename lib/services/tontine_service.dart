import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tontine.dart';
import '../models/cotisation.dart';
import '../models/demande_adhesion.dart';
import '../models/app_user.dart';

class TontineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── TONTINES ───

  Future<Tontine> creerTontine({
    required String nom,
    required String description,
    required int montantCotisation,
    required String frequence,
    required String localite,
    required String adminUid,
    required String adminNom,
    required int maxMembres,
    required DateTime dateDebut,
  }) async {
    final doc = _firestore.collection('tontines').doc();
    final tontine = Tontine(
      id: doc.id,
      nom: nom,
      description: description,
      montantCotisation: montantCotisation,
      frequence: frequence,
      localite: localite,
      adminUid: adminUid,
      adminNom: adminNom,
      maxMembres: maxMembres,
      membresUids: [adminUid],
      dateDebut: dateDebut,
      createdAt: DateTime.now(),
    );

    await doc.set(tontine.toMap());
    return tontine;
  }

  Future<List<Tontine>> getMesTontines(String userUid) async {
    try {
      // Chercher avec l'uid actuel
      var query = await _firestore
          .collection('tontines')
          .where('membresUids', arrayContains: userUid)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.map((doc) => Tontine.fromMap(doc.data())).toList();
      }

      // Si rien trouvé, chercher les anciens uids via le téléphone
      final userDocs = await _firestore
          .collection('users')
          .where('uid', isEqualTo: userUid)
          .get();

      if (userDocs.docs.isEmpty) return [];

      final telephone = userDocs.docs.first.data()['telephone'] as String;
      final allUserDocs = await _firestore
          .collection('users')
          .where('telephone', isEqualTo: telephone)
          .get();

      for (final doc in allUserDocs.docs) {
        final oldUid = doc.data()['uid'] as String;
        if (oldUid == userUid) continue;

        query = await _firestore
            .collection('tontines')
            .where('membresUids', arrayContains: oldUid)
            .get();

        if (query.docs.isNotEmpty) {
          // Migrer vers le uid actuel
          for (final tDoc in query.docs) {
            await tDoc.reference.update({
              'membresUids': FieldValue.arrayRemove([oldUid]),
            });
            await tDoc.reference.update({
              'membresUids': FieldValue.arrayUnion([userUid]),
            });
            if (tDoc.data()['adminUid'] == oldUid) {
              await tDoc.reference.update({'adminUid': userUid});
            }
          }
          // Relire après migration
          final updated = await _firestore
              .collection('tontines')
              .where('membresUids', arrayContains: userUid)
              .get();
          return updated.docs.map((doc) => Tontine.fromMap(doc.data())).toList();
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Tontine>> getTontinesDisponibles(String userUid) async {
    try {
      final query = await _firestore.collection('tontines').get();

      return query.docs
          .map((doc) => Tontine.fromMap(doc.data()))
          .where((t) => t.isActive && !t.membresUids.contains(userUid))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Tontine?> getTontine(String tontineId) async {
    final doc = await _firestore.collection('tontines').doc(tontineId).get();
    if (!doc.exists) return null;
    return Tontine.fromMap(doc.data()!);
  }

  Future<void> ajouterMembre(String tontineId, String userUid) async {
    await _firestore.collection('tontines').doc(tontineId).update({
      'membresUids': FieldValue.arrayUnion([userUid]),
    });
  }

  Future<void> retirerMembre(String tontineId, String userUid) async {
    await _firestore.collection('tontines').doc(tontineId).update({
      'membresUids': FieldValue.arrayRemove([userUid]),
    });
  }

  // ─── COTISATIONS ───

  Future<void> enregistrerCotisation({
    required String tontineId,
    required String tontineNom,
    required String userUid,
    required String userNom,
    required int montant,
  }) async {
    final doc = _firestore.collection('cotisations').doc();
    final cotisation = Cotisation(
      id: doc.id,
      tontineId: tontineId,
      tontineNom: tontineNom,
      userUid: userUid,
      userNom: userNom,
      montant: montant,
      date: DateTime.now(),
      statut: 'payee',
    );

    await doc.set(cotisation.toMap());
  }

  Future<List<Cotisation>> getHistoriqueCotisations(String userUid) async {
    try {
      final query = await _firestore
          .collection('cotisations')
          .where('userUid', isEqualTo: userUid)
          .get();

      final cotisations = query.docs.map((doc) => Cotisation.fromMap(doc.data())).toList();
      cotisations.sort((a, b) => b.date.compareTo(a.date));
      return cotisations;
    } catch (e) {
      return [];
    }
  }

  Future<int> getTotalCotise(String userUid) async {
    final cotisations = await getHistoriqueCotisations(userUid);
    int total = 0;
    for (final c in cotisations) {
      if (c.statut == 'payee') total += c.montant;
    }
    return total;
  }

  // ─── DEMANDES D'ADHÉSION ───

  Future<void> envoyerDemande({
    required String tontineId,
    required String userUid,
    required String userNom,
    required String userTelephone,
    required String userLocalite,
  }) async {
    final doc = _firestore.collection('demandes').doc();
    final demande = DemandeAdhesion(
      id: doc.id,
      tontineId: tontineId,
      userUid: userUid,
      userNom: userNom,
      userTelephone: userTelephone,
      userLocalite: userLocalite,
      date: DateTime.now(),
      statut: 'en_attente',
    );

    await doc.set(demande.toMap());
  }

  Future<List<DemandeAdhesion>> getDemandesPourTontine(
      String tontineId) async {
    try {
      final query = await _firestore
          .collection('demandes')
          .where('tontineId', isEqualTo: tontineId)
          .get();

      return query.docs
          .map((doc) => DemandeAdhesion.fromMap(doc.data()))
          .where((d) => d.statut == 'en_attente')
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> accepterDemande(String demandeId, String tontineId,
      String userUid) async {
    await _firestore
        .collection('demandes')
        .doc(demandeId)
        .update({'statut': 'acceptee'});
    await ajouterMembre(tontineId, userUid);
  }

  Future<void> refuserDemande(String demandeId) async {
    await _firestore
        .collection('demandes')
        .doc(demandeId)
        .update({'statut': 'refusee'});
  }

  // ─── MEMBRES ───

  Future<List<AppUser>> getMembresTontine(List<String> membresUids) async {
    if (membresUids.isEmpty) return [];

    final users = <AppUser>[];
    // Firestore limite whereIn à 30 éléments
    for (var i = 0; i < membresUids.length; i += 30) {
      final batch = membresUids.sublist(
          i, i + 30 > membresUids.length ? membresUids.length : i + 30);
      final query = await _firestore
          .collection('users')
          .where('uid', whereIn: batch)
          .get();
      users.addAll(query.docs.map((doc) => AppUser.fromMap(doc.data())));
    }
    return users;
  }

  Future<List<AppUser>> rechercherUtilisateurs(String query) async {
    final results = await _firestore.collection('users').get();
    final q = query.toLowerCase().replaceAll(' ', '');
    return results.docs
        .map((doc) => AppUser.fromMap(doc.data()))
        .where((u) =>
            u.nom.toLowerCase().contains(q) ||
            u.telephone.replaceAll(' ', '').contains(q))
        .toList();
  }
}
