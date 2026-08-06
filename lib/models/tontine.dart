import 'package:cloud_firestore/cloud_firestore.dart';

class Tontine {
  final String id;
  final String nom;
  final String description;
  final int montantCotisation;
  final String frequence;
  final String localite;
  final String adminUid;
  final String adminNom;
  final int maxMembres;
  final List<String> membresUids;
  final DateTime dateDebut;
  final DateTime createdAt;
  final bool isActive;
  final String telephoneVersement;

  Tontine({
    required this.id,
    required this.nom,
    required this.description,
    required this.montantCotisation,
    required this.frequence,
    required this.localite,
    required this.adminUid,
    required this.adminNom,
    required this.maxMembres,
    required this.membresUids,
    required this.dateDebut,
    required this.createdAt,
    this.isActive = true,
    this.telephoneVersement = '',
  });

  int get nombreMembres => membresUids.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'montantCotisation': montantCotisation,
      'frequence': frequence,
      'localite': localite,
      'adminUid': adminUid,
      'adminNom': adminNom,
      'maxMembres': maxMembres,
      'membresUids': membresUids,
      'dateDebut': Timestamp.fromDate(dateDebut),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'telephoneVersement': telephoneVersement,
    };
  }

  factory Tontine.fromMap(Map<String, dynamic> map) {
    return Tontine(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String? ?? '',
      montantCotisation: map['montantCotisation'] as int,
      frequence: map['frequence'] as String,
      localite: map['localite'] as String? ?? '',
      adminUid: map['adminUid'] as String,
      adminNom: map['adminNom'] as String? ?? '',
      maxMembres: map['maxMembres'] as int,
      membresUids: List<String>.from(map['membresUids'] ?? []),
      dateDebut: (map['dateDebut'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] as bool? ?? true,
      telephoneVersement: map['telephoneVersement'] as String? ?? '',
    );
  }
}
