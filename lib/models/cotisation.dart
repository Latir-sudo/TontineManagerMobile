import 'package:cloud_firestore/cloud_firestore.dart';

class Cotisation {
  final String id;
  final String tontineId;
  final String tontineNom;
  final String userUid;
  final String userNom;
  final int montant;
  final DateTime date;
  final String statut; // 'payee', 'en_attente', 'en_retard'

  Cotisation({
    required this.id,
    required this.tontineId,
    required this.tontineNom,
    required this.userUid,
    required this.userNom,
    required this.montant,
    required this.date,
    required this.statut,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tontineId': tontineId,
      'tontineNom': tontineNom,
      'userUid': userUid,
      'userNom': userNom,
      'montant': montant,
      'date': Timestamp.fromDate(date),
      'statut': statut,
    };
  }

  factory Cotisation.fromMap(Map<String, dynamic> map) {
    return Cotisation(
      id: map['id'] as String,
      tontineId: map['tontineId'] as String,
      tontineNom: map['tontineNom'] as String? ?? '',
      userUid: map['userUid'] as String,
      userNom: map['userNom'] as String? ?? '',
      montant: map['montant'] as int,
      date: (map['date'] as Timestamp).toDate(),
      statut: map['statut'] as String,
    );
  }
}
