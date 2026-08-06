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
    required String telephoneVersement,
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
      telephoneVersement: telephoneVersement,
    );

    await doc.set(tontine.toMap());
    return tontine;
  }

  Future<void> updateTelephoneVersement(String tontineId, String telephone) async {
    await _firestore.collection('tontines').doc(tontineId).update({
      'telephoneVersement': telephone,
    });
  }

  Future<List<Tontine>> getMesTontines(String userUid) async {
    try {
      final query = await _firestore
          .collection('tontines')
          .where('membresUids', arrayContains: userUid)
          .get();

      return query.docs.map((doc) => Tontine.fromMap(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Tontine>> getTontinesDisponibles(String userUid) async {
    try {
      final query = await _firestore
          .collection('tontines')
          .where('isActive', isEqualTo: true)
          .get();

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

  Future<bool> estDejaMembreTontine(String tontineId, String userUid) async {
    final doc = await _firestore.collection('tontines').doc(tontineId).get();
    if (!doc.exists) return false;
    final membresUids = List<String>.from(doc.data()?['membresUids'] ?? []);
    return membresUids.contains(userUid);
  }

  Future<void> ajouterMembre(String tontineId, String userUid) async {
    final dejaMembre = await estDejaMembreTontine(tontineId, userUid);
    if (dejaMembre) return;
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

  Future<List<Cotisation>> getCotisationsTontine(String tontineId) async {
    try {
      final query = await _firestore
          .collection('cotisations')
          .where('tontineId', isEqualTo: tontineId)
          .get();

      final cotisations = query.docs.map((doc) => Cotisation.fromMap(doc.data())).toList();
      cotisations.sort((a, b) => b.date.compareTo(a.date));
      return cotisations;
    } catch (e) {
      return [];
    }
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
    try {
      final query = await _firestore
          .collection('cotisations')
          .where('userUid', isEqualTo: userUid)
          .where('statut', isEqualTo: 'payee')
          .get();

      int total = 0;
      for (final doc in query.docs) {
        total += (doc.data()['montant'] as num).toInt();
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  int calculerTotalFromList(List<Cotisation> cotisations) {
    int total = 0;
    for (final c in cotisations) {
      if (c.statut == 'payee') total += c.montant;
    }
    return total;
  }

  // ─── DEMANDES D'ADHÉSION ───

  Future<bool> envoyerDemande({
    required String tontineId,
    required String userUid,
    required String userNom,
    required String userTelephone,
    required String userLocalite,
  }) async {
    final dejaMembre = await estDejaMembreTontine(tontineId, userUid);
    if (dejaMembre) return false;

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

    // Notifier l'admin de la tontine
    final tontine = await getTontine(tontineId);
    if (tontine != null) {
      await _createNotification(
        userUid: tontine.adminUid,
        title: 'Nouvelle demande d\'adhésion',
        description: '$userNom souhaite rejoindre votre tontine',
        tontineNom: tontine.nom,
        type: 'nouveau_membre',
      );
    }
    return true;
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

  Future<bool> accepterDemande(String demandeId, String tontineId,
      String userUid) async {
    final dejaMembre = await estDejaMembreTontine(tontineId, userUid);
    if (dejaMembre) return false;

    await _firestore
        .collection('demandes')
        .doc(demandeId)
        .update({'statut': 'acceptee'});
    await ajouterMembre(tontineId, userUid);

    // Notifier le demandeur
    final tontine = await getTontine(tontineId);
    if (tontine != null) {
      await _createNotification(
        userUid: userUid,
        title: 'Demande acceptée',
        description: 'Vous avez été accepté dans la tontine ${tontine.nom}',
        tontineNom: tontine.nom,
        type: 'nouveau_membre',
      );
    }
    return true;
  }

  Future<void> refuserDemande(String demandeId) async {
    // Récupérer la demande pour notifier l'utilisateur
    final demandeDoc = await _firestore.collection('demandes').doc(demandeId).get();

    await _firestore
        .collection('demandes')
        .doc(demandeId)
        .update({'statut': 'refusee'});

    if (demandeDoc.exists) {
      final data = demandeDoc.data()!;
      final tontine = await getTontine(data['tontineId'] as String);
      if (tontine != null) {
        await _createNotification(
          userUid: data['userUid'] as String,
          title: 'Demande refusée',
          description: 'Votre demande pour ${tontine.nom} a été refusée',
          tontineNom: tontine.nom,
          type: 'retard',
        );
      }
    }
  }

  // ─── NOTIFICATIONS ───

  Future<void> _createNotification({
    required String userUid,
    required String title,
    required String description,
    required String tontineNom,
    required String type,
    String tontineId = '',
    String statut = '',
  }) async {
    final doc = _firestore.collection('notifications').doc();
    await doc.set({
      'id': doc.id,
      'userUid': userUid,
      'title': title,
      'description': description,
      'tontineNom': tontineNom,
      'type': type,
      'isRead': false,
      'date': FieldValue.serverTimestamp(),
      'tontineId': tontineId,
      'statut': statut,
    });
  }

  Future<void> envoyerInvitation({
    required String tontineId,
    required String tontineNom,
    required String userUid,
    required String adminNom,
  }) async {
    await _createNotification(
      userUid: userUid,
      title: 'Invitation à rejoindre',
      description: '$adminNom vous invite à rejoindre la tontine $tontineNom',
      tontineNom: tontineNom,
      type: 'invitation',
      tontineId: tontineId,
    );
  }

  Future<void> accepterInvitation(String notificationId, String tontineId, String userUid) async {
    final dejaMembre = await estDejaMembreTontine(tontineId, userUid);
    if (!dejaMembre) {
      await _firestore.collection('tontines').doc(tontineId).update({
        'membresUids': FieldValue.arrayUnion([userUid]),
      });
    }
    await _firestore.collection('notifications').doc(notificationId).update({
      'statut': 'acceptee',
      'isRead': true,
    });
  }

  Future<void> refuserInvitation(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'statut': 'refusee',
      'isRead': true,
    });
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

  Future<List<AppUser>> rechercherUtilisateurs(String query, {int limit = 50}) async {
    final QuerySnapshot<Map<String, dynamic>> results;
    if (limit > 0) {
      results = await _firestore.collection('users').limit(limit).get();
    } else {
      results = await _firestore.collection('users').get();
    }
    final q = query.toLowerCase().replaceAll(' ', '');
    if (q.isEmpty) {
      return results.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    }
    return results.docs
        .map((doc) => AppUser.fromMap(doc.data()))
        .where((u) =>
            u.nom.toLowerCase().contains(q) ||
            u.telephone.replaceAll(' ', '').contains(q))
        .toList();
  }
}
