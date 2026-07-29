import 'package:cloud_firestore/cloud_firestore.dart';

class DemandeAdhesion {
  final String id;
  final String tontineId;
  final String userUid;
  final String userNom;
  final String userTelephone;
  final String userLocalite;
  final DateTime date;
  final String statut; // 'en_attente', 'acceptee', 'refusee'

  DemandeAdhesion({
    required this.id,
    required this.tontineId,
    required this.userUid,
    required this.userNom,
    required this.userTelephone,
    required this.userLocalite,
    required this.date,
    required this.statut,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tontineId': tontineId,
      'userUid': userUid,
      'userNom': userNom,
      'userTelephone': userTelephone,
      'userLocalite': userLocalite,
      'date': Timestamp.fromDate(date),
      'statut': statut,
    };
  }

  factory DemandeAdhesion.fromMap(Map<String, dynamic> map) {
    return DemandeAdhesion(
      id: map['id'] as String,
      tontineId: map['tontineId'] as String,
      userUid: map['userUid'] as String,
      userNom: map['userNom'] as String,
      userTelephone: map['userTelephone'] as String? ?? '',
      userLocalite: map['userLocalite'] as String? ?? '',
      date: (map['date'] as Timestamp).toDate(),
      statut: map['statut'] as String,
    );
  }
}
