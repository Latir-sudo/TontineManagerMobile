import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userUid;
  final String title;
  final String description;
  final String tontineNom;
  final String type; // paiement, rappel, nouveau_membre, retard, invitation
  final bool isRead;
  final DateTime date;
  final String tontineId;
  final String statut; // '', 'acceptee', 'refusee'

  AppNotification({
    required this.id,
    required this.userUid,
    required this.title,
    required this.description,
    required this.tontineNom,
    required this.type,
    required this.isRead,
    required this.date,
    this.tontineId = '',
    this.statut = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userUid': userUid,
      'title': title,
      'description': description,
      'tontineNom': tontineNom,
      'type': type,
      'isRead': isRead,
      'date': Timestamp.fromDate(date),
      'tontineId': tontineId,
      'statut': statut,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final dateValue = map['date'];
    if (dateValue is Timestamp) {
      parsedDate = dateValue.toDate();
    } else if (dateValue is String) {
      parsedDate = DateTime.parse(dateValue);
    } else {
      parsedDate = DateTime.now();
    }

    return AppNotification(
      id: map['id'] as String? ?? '',
      userUid: map['userUid'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      tontineNom: map['tontineNom'] as String? ?? '',
      type: map['type'] as String? ?? 'rappel',
      isRead: map['isRead'] as bool? ?? false,
      date: parsedDate,
      tontineId: map['tontineId'] as String? ?? '',
      statut: map['statut'] as String? ?? '',
    );
  }
}
