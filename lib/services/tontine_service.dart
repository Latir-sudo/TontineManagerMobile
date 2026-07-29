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
    final query = await _firestore
        .collection('tontines')
        .where('membresUids', arrayContains: userUid)
        .get();

    return query.docs.map((doc) => Tontine.fromMap(doc.data())).toList();
  }

  Future<List<Tontine>> getTontinesDisponibles(String userUid) async {
    final query = await _firestore
        .collection('tontines')
        .where('isActive', isEqualTo: true)
        .get();

    return query.docs
        .map((doc) => Tontine.fromMap(doc.data()))
        .where((t) => !t.membresUids.contains(userUid))
        .toList();
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
    final query = await _firestore
        .collection('cotisations')
        .where('userUid', isEqualTo: userUid)
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => Cotisation.fromMap(doc.data())).toList();
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
    final query = await _firestore
        .collection('demandes')
        .where('tontineId', isEqualTo: tontineId)
        .where('statut', isEqualTo: 'en_attente')
        .get();

    return query.docs
        .map((doc) => DemandeAdhesion.fromMap(doc.data()))
        .toList();
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
